import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../provider/common_sharedpreferences.dart';
import 'app_config_provider.dart';
import 'app_constant.dart';

class SessionManager {
  static const String _userDetailsKey = 'user_details';
  static const String _refreshTokenKey = 'session_refresh_token';
  static const String _tokenExpiryEpochKey = 'session_token_expiry_epoch';

  static Future<bool>? _refreshInFlight;

  static String _firstNonEmpty(Iterable<dynamic> values) {
    for (final value in values) {
      final candidate = (value ?? '').toString().trim();
      if (candidate.isNotEmpty) return candidate;
    }
    return '';
  }

  static String extractToken(dynamic payload) {
    if (payload is! Map) return '';

    final data = payload['data'];
    final user = payload['user'];

    return _firstNonEmpty([
      payload['token'],
      payload['access_token'],
      if (data is Map) data['token'],
      if (data is Map) data['access_token'],
      if (user is Map) user['token'],
      if (user is Map) user['access_token'],
    ]);
  }

  static String extractRefreshToken(dynamic payload) {
    if (payload is! Map) return '';

    final data = payload['data'];
    final user = payload['user'];

    return _firstNonEmpty([
      payload['refresh_token'],
      payload['refreshToken'],
      if (data is Map) data['refresh_token'],
      if (data is Map) data['refreshToken'],
      if (user is Map) user['refresh_token'],
      if (user is Map) user['refreshToken'],
    ]);
  }

  static bool isJwtToken(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return false;
    // Structural JWT check only (header.payload.signature); full signature
    // verification is intentionally delegated to backend validation.
    return trimmed.split('.').length == 3;
  }

  static int? decodeJwtExpiryEpoch(String token) {
    final trimmed = token.trim();
    if (!isJwtToken(trimmed)) return null;
    final parts = trimmed.split('.');
    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);
      if (map is! Map || map['exp'] == null) return null;
      return int.tryParse(map['exp'].toString());
    } catch (_) {
      return null;
    }
  }

  static bool isTokenExpired(
    String token, {
    Duration skew = const Duration(seconds: 30),
    bool treatNonJwtAsExpired = false,
  }) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return true;
    final expEpoch = decodeJwtExpiryEpoch(trimmed);
    if (expEpoch == null) return treatNonJwtAsExpired;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expEpoch * 1000);
    return DateTime.now().isAfter(expiry.subtract(skew));
  }

  static Future<Map<String, dynamic>> readCachedUserDetailsMap() async {
    final raw = await CacheHelper.get(_userDetailsKey);
    if (raw == null || raw.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (e) {
      log('Session refresh failed for endpoint=$endpoint error=$e');
    }
    return <String, dynamic>{};
  }

  static Future<void> captureSessionFromAuthPayload(dynamic payload) async {
    if (payload is! Map) return;
    final map = payload is Map<String, dynamic>
        ? payload
        : payload.map((key, value) => MapEntry(key.toString(), value));

    final token = extractToken(map);
    final refreshToken = extractRefreshToken(map);
    final expEpoch = decodeJwtExpiryEpoch(token);

    if (refreshToken.isNotEmpty) {
      await CacheHelper.save(_refreshTokenKey, refreshToken);
    } else {
      await CacheHelper.remove(_refreshTokenKey);
    }

    if (expEpoch != null) {
      await CacheHelper.save(_tokenExpiryEpochKey, expEpoch.toString());
    } else {
      await CacheHelper.remove(_tokenExpiryEpochKey);
    }

    if (token.isNotEmpty) {
      AppConstant.token = token;
    }
  }

  static Future<bool> tryRefreshSession() async {
    if (_refreshInFlight != null) return _refreshInFlight!;
    _refreshInFlight = _doRefreshSession();
    final result = await _refreshInFlight!;
    _refreshInFlight = null;
    return result;
  }

  static Future<bool> _doRefreshSession() async {
    String refreshToken = (await CacheHelper.get(_refreshTokenKey) ?? '').trim();
    if (refreshToken.isEmpty) {
      final session = await readCachedUserDetailsMap();
      refreshToken = extractRefreshToken(session);
    }
    if (refreshToken.isEmpty) return false;

    final endpoints = <String>[
      'auth/refresh_token',
      'auth/refresh',
      'auth/token/refresh',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await http.post(
          Uri.parse('${AppConfigProvider.apiUrl}$endpoint'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'refresh_token': refreshToken}),
        );
        if (response.statusCode != 200) continue;

        final body = jsonDecode(response.body);
        if (body is! Map) continue;
        final bodyMap =
            body.map((key, value) => MapEntry(key.toString(), value));
        final dynamic data = bodyMap['data'];
        final authPayload = data is Map
            ? data.map((key, value) => MapEntry(key.toString(), value))
            : bodyMap;

        final newToken = extractToken(authPayload);
        if (newToken.isEmpty) continue;

        await _mergeAuthPayloadIntoUserCache(authPayload);
        await captureSessionFromAuthPayload(authPayload);
        return true;
      } catch (_) {}
    }

    return false;
  }

  static Future<void> _mergeAuthPayloadIntoUserCache(
    Map<String, dynamic> authPayload,
  ) async {
    final existing = await readCachedUserDetailsMap();
    if (existing.isEmpty) {
      await CacheHelper.save(_userDetailsKey, jsonEncode(authPayload));
      return;
    }

    final merged = Map<String, dynamic>.from(existing);

    void applyToken(Map<String, dynamic> target) {
      final token = extractToken(authPayload);
      if (token.isNotEmpty) {
        target['token'] = token;
      }
      final refreshToken = extractRefreshToken(authPayload);
      if (refreshToken.isNotEmpty) {
        target['refresh_token'] = refreshToken;
      }
    }

    applyToken(merged);
    if (merged['user'] is Map) {
      final user = Map<String, dynamic>.from(merged['user']);
      applyToken(user);
      merged['user'] = user;
    }
    if (merged['data'] is Map) {
      final data = Map<String, dynamic>.from(merged['data']);
      applyToken(data);
      merged['data'] = data;
    }

    await CacheHelper.save(_userDetailsKey, jsonEncode(merged));
  }

  static Map<String, String> withAuthorizationHeader(
    Map<String, String> headers, {
    String? token,
  }) {
    final next = Map<String, String>.from(headers);
    final authToken = (token ?? AppConstant.token).trim();
    if (authToken.isEmpty) return next;

    String? existingKey;
    for (final key in next.keys) {
      if (key.toLowerCase() == 'authorization') {
        existingKey = key;
        break;
      }
    }
    final key = existingKey ?? 'authorization';
    next[key] = 'Bearer $authToken';
    return next;
  }

  static Future<void> clearAuthSession() async {
    AppConstant.token = '';
    await CacheHelper.remove(_userDetailsKey);
    await CacheHelper.remove(_refreshTokenKey);
    await CacheHelper.remove(_tokenExpiryEpochKey);
  }
}
