import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';

import '../controller/home/home_controller.dart';
import '../controller/my_profile/get_my_profile.dart';
import '../controller/my_profile/get_my_swipe_profile_controller.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_snack_bar_toast_message.dart';
import '../utilities/session_manager.dart';
import '../view/authentication/login_screen.dart';
import 'socket_provider.dart';
import 'user_controller.dart';

class _SessionExpiredHandled implements Exception {}

// ------------------ COMMON REQUEST HANDLER ------------------

// Normal requests give up after this (uploads have no limit).
const Duration _requestTimeout = Duration(seconds: 25);

// Show a network problem at most once every few seconds (several
// requests usually fail together).
DateTime? _lastNetworkToast;
void _networkErrorToast(BuildContext? context, String message) {
  if (context == null || !context.mounted) return;
  final now = DateTime.now();
  if (_lastNetworkToast != null && now.difference(_lastNetworkToast!) < const Duration(seconds: 4)) return;
  _lastNetworkToast = now;
  TopNotification.error(context, message);
}

const String _offlineMessage = "You're offline. Check your internet connection and try again.";
const String _slowMessage = 'The connection is slow. Please try again.';

// Server error pages (HTML) must never be shown to members as text.
String _friendlyError(int status, String message) {
  final looksLikePage = RegExp(r'<\s*(!doctype|html|head|body|pre)\b', caseSensitive: false).hasMatch(message) ||
      message.length > 300;
  if (!looksLikePage && message.trim().isNotEmpty) return message;
  if (status == 413) return 'This file is too large to upload.';
  if (status == 502 || status == 503 || status == 504) return 'Hii is updating. Please try again in a minute.';
  if (status == 404) return "This isn't available right now. Please try again later.";
  return 'Something went wrong. Please try again.';
}

Future<Map<String, dynamic>?> _handleRequest(
    Future<http.Response> Function(
        Uri url,
        Map<String, String> headers,
        ) requestFn,
    String endpoint,
    BuildContext? context, {
      Map<String, String>? headers,
      bool skipAuth = false,
    }) async {
  try {
    final Uri url = Uri.parse("${AppConfigProvider.apiUrl}$endpoint");

    print("URL: $url");

    Map<String, String> requestHeaders = skipAuth
        ? Map<String, String>.from(headers ?? {})
        : await _prepareRequestHeaders(
      headers ?? {},
      context,
    );

    print("REQUEST HEADERS: $requestHeaders");

    http.Response response = await requestFn(url, requestHeaders).timeout(_requestTimeout);

    // Retry once if token expired
    if (!skipAuth && (response.statusCode == 401 || response.statusCode == 403)) {
      final didRefresh = await SessionManager.tryRefreshSession();

      if (didRefresh) {
        requestHeaders = SessionManager.withAuthorizationHeader(
          requestHeaders,
        );

        response = await requestFn(url, requestHeaders).timeout(_requestTimeout);
      }
    }

    print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

    return await _handleStatusCode(
      response,
      context,
    );
  } on _SessionExpiredHandled {
    return null;
  } on TimeoutException {
    _networkErrorToast(context, _slowMessage);
    return null;
  } on SocketException {
    _networkErrorToast(context, _offlineMessage);
    return null;
  } on http.ClientException {
    _networkErrorToast(context, _offlineMessage);
    return null;
  } catch (e, s) {
    print("API ERROR: $e");
    log("API ERROR", error: e, stackTrace: s);
    return null;
  }
}

// ------------------ PREPARE HEADERS ------------------

Future<Map<String, String>> _prepareRequestHeaders(
    Map<String, String> headers,
    BuildContext? context,
    ) async {
  final requestHeaders = Map<String, String>.from(headers);

  // ── Baseline headers to prevent Imunify360 bot-detection ──
  // putIfAbsent means we never overwrite headers already set by the caller.
  requestHeaders.putIfAbsent(
    'User-Agent',
        () => 'NightLifeApp/1.0 (Flutter; iOS)',
  );
  requestHeaders.putIfAbsent('Accept', () => 'application/json');
  requestHeaders.putIfAbsent(
    'X-Requested-With',
        () => 'com.example.nightLife',
  );
  // ──────────────────────────────────────────────────────────

  try {
    // ── Token priority: backend JWT > Firebase token ──
    // Always prefer the backend JWT stored in AppConstant.token.
    // Only fall back to Firebase token when no backend token exists
    // (e.g. unauthenticated calls like login/signup).
    final backendToken = AppConstant.token.trim();

    if (backendToken.isNotEmpty) {
      // Use backend JWT — do NOT call getFreshFirebaseIdToken()
      // as it returns a Firebase anonymous token that the backend rejects.
      print("TOKEN FROM SESSION: [backend JWT present]");
      final updatedHeaders = SessionManager.withAuthorizationHeader(
        requestHeaders,
        token: backendToken,
      );
      print("FINAL HEADERS: $updatedHeaders");
      return updatedHeaders;
    }

    // No backend token — try Firebase token (for unauthenticated endpoints)
    final firebaseToken = await SessionManager.getFreshFirebaseIdToken(
      forceRefresh: true,
    );

    print("TOKEN FROM SESSION: $firebaseToken");

    if (firebaseToken != null && firebaseToken.trim().isNotEmpty) {
      final updatedHeaders = SessionManager.withAuthorizationHeader(
        requestHeaders,
        token: firebaseToken,
      );

      print("FINAL HEADERS: $updatedHeaders");

      return updatedHeaders;
    } else {
      print("TOKEN IS NULL OR EMPTY");
    }
  } catch (e, s) {
    print("HEADER PREPARATION ERROR: $e");
    log("HEADER PREPARATION ERROR", error: e, stackTrace: s);

    final errorText = e.toString().toLowerCase();

    final looksLikeSessionExpired =
        errorText.contains('session expired') ||
            errorText.contains('token expired') ||
            errorText.contains('user token has expired') ||
            errorText.contains('requires recent login') ||
            errorText.contains('credential') ||
            errorText.contains('unauthenticated');

    if (looksLikeSessionExpired && context != null) {
      print("SESSION EXPIRED");

      await _redirectToLogin(
        context,
        "Session expired. Please log in again.",
      );

      throw _SessionExpiredHandled();
    }
  }

  return requestHeaders;
}

// ------------------ STATUS CODE HANDLER ------------------

Future<Map<String, dynamic>?> _handleStatusCode(
    http.Response response,
    BuildContext? context,
    ) async {
  final statusCode = response.statusCode;

  dynamic body;
  try {
    body = jsonDecode(response.body);
  } catch (_) {
    body = {'message': response.body};
  }

  final String errorMessage = _getErrorMessage(body).trim().toLowerCase();

  final bool blockedByFirewall =
      errorMessage.contains('access denied by imunify360') ||
          errorMessage.contains('bot-protection') ||
          errorMessage.contains('whitelisted');

  if (statusCode == 200 && !blockedByFirewall) {
    if (body is Map<String, dynamic>) {
      if (SessionManager.extractToken(body).isNotEmpty ||
          SessionManager.extractRefreshToken(body).isNotEmpty) {
        await SessionManager.captureSessionFromAuthPayload(body);
        // (No anonymous Firebase sign-in: it's disabled in the Firebase project
        // and the app no longer needs it to stay logged in.)
      }

      return body;
    }

    return null;
  }

  if (blockedByFirewall) {
    if (context != null) {
      TopNotification.error(
        context,
        "Server blocked this request. Please contact admin or try again later.",
      );
    }
    return null;
  }

  if (statusCode == 400) {
    if (context != null) {
      TopNotification.error(context, _friendlyError(statusCode, _getErrorMessage(body)));
    }
    return null;
  }

  // Log out only on a real "session over": 401 (login invalid / account
  // deleted) or 423 (deactivated). A 403 means "not allowed" - show it,
  // don't log the member out.
  if (statusCode == 403) {
    if (context != null && context.mounted) {
      TopNotification.error(context, _getErrorMessage(body));
    }
    return null;
  }
  if (statusCode == 401 || statusCode == 423) {
    if (context != null) {
      await _redirectToLogin(
        context,
        _getErrorMessage(body),
      );
    }
    return null;
  }

  if (statusCode == 500) {
    if (context != null) {
      TopNotification.error(
        context,
        "Server error. Please try again later.",
      );
    }
    return null;
  }

  if (context != null) {
    TopNotification.error(
      context,
      _friendlyError(statusCode, _getErrorMessage(body)),
    );
  }

  return null;
}

// ------------------ ERROR MESSAGE ------------------

String _getErrorMessage(dynamic body) {
  if (body == null) {
    return "An error occurred";
  }

  if (body is Map && body['message'] != null) {
    if (body['message'] is List && body['message'].isNotEmpty) {
      return body['message'][0].toString();
    }

    return body['message'].toString();
  }

  return "An error occurred";
}

// ------------------ REDIRECT TO LOGIN ------------------

Future<void> _redirectToLogin(
    BuildContext context,
    String message,
    ) async {
  TopNotification.error(context, message);

  _tryProviderReset(context);

  await SessionManager.clearAuthSession(
    signOutFromFirebase: true,
    clearAllPreferences: true,
  );

  AppConstant.selectFooterIndex = 0;

  Navigator.pushAndRemoveUntil(
    context,
    PageTransition(
      type: PageTransitionType.rightToLeftWithFade,
      child: const LoginScreen(),
      duration: const Duration(milliseconds: 100),
    ),
        (route) => false,
  );
}

// ------------------ RESET PROVIDERS ------------------

void _tryProviderReset(BuildContext context) {
  try {
    Provider.of<SocketProvider>(
      context,
      listen: false,
    ).disconnect();
  } catch (_) {}

  try {
    Provider.of<UserController>(
      context,
      listen: false,
    ).reset();
  } catch (_) {}

  try {
    Provider.of<HomeController>(
      context,
      listen: false,
    ).clearAllData();
  } catch (_) {}

  try {
    Provider.of<ProfileController>(
      context,
      listen: false,
    ).clearProfileData();
  } catch (_) {}

  try {
    Provider.of<GetMySwipeProfileController>(
      context,
      listen: false,
    ).resetState();
  } catch (_) {}
}

// ------------------ GET DATA ------------------

Future<Map<String, dynamic>?> getData(
    String endpoint,
    BuildContext? context, {
      Map<String, String>? headers,
    }) async {
  return _handleRequest(
        (url, h) => http.get(
      url,
      headers: h,
    ),
    endpoint,
    context,
    headers: headers,
  );
}

// ------------------ POST DATA ------------------

Future<Map<String, dynamic>?> postData(
    String endpoint,
    BuildContext? context, {
      Map<String, String>? headers,
    }) async {
  return _handleRequest(
        (url, h) => http.post(
      url,
      headers: h,
    ),
    endpoint,
    context,
    headers: headers,
  );
}

// ------------------ GET FORM DATA ------------------

Future<Map<String, dynamic>?> getFormData(
    String endpoint,
    BuildContext? context, {
      Map<String, String>? headers,
    }) async {
  return _handleRequest(
        (url, h) => http.get(
      url,
      headers: h,
    ),
    endpoint,
    context,
    headers: headers,
  );
}

// ------------------ POST JSON DATA ------------------

Future<Map<String, dynamic>?> postJsonData(
    String endpoint,
    Map<String, dynamic> jsonData,
    BuildContext? context, {
      Map<String, String>? headers,
      bool skipAuth = false,
    }) async {
  return _handleRequest(
        (url, h) => http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...h,
      },
      body: jsonEncode(jsonData),
    ),
    endpoint,
    context,
    headers: headers,
    skipAuth: skipAuth,
  );
}

// ------------------ POST MULTIPART DATA ------------------

Future<Map<String, dynamic>?> postMultipartData(
    String endpoint,
    Map<String, String> fields,
    BuildContext? context, {
      Map<String, String>? headers,
      Map<String, XFile>? files,
    }) async {
  try {
    final Uri url = Uri.parse("${AppConfigProvider.apiUrl}$endpoint");

    var request = http.MultipartRequest('POST', url);

    final preparedHeaders = await _prepareRequestHeaders(
      headers ?? {},
      context,
    );

    request.headers.addAll(preparedHeaders);
    request.fields.addAll(fields);

    if (files != null) {
      for (var entry in files.entries) {
        List<int> imageBytes = await entry.value.readAsBytes();

        // Detect the real mime type from the picked file's path/bytes instead
        // of assuming JPEG. Falls back to image/jpeg only if detection fails.
        final String? detectedMimeType =
            lookupMimeType(entry.value.path, headerBytes: imageBytes) ??
                entry.value.mimeType;
        final String mimeType = detectedMimeType ?? 'image/jpeg';

        // Prefer the picked file's own name (it already has the right
        // extension). Only fall back to building one from the mime type.
        final String originalName = entry.value.name.isNotEmpty
            ? entry.value.name
            : entry.value.path.split('/').last;
        String filename = originalName;
        if (!originalName.contains('.')) {
          final String subtype =
          mimeType.contains('/') ? mimeType.split('/').last : 'jpeg';
          final String extension = subtype == 'jpg' ? 'jpeg' : subtype;
          filename = '${entry.key}.$extension';
        }

        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
          entry.key,
          imageBytes,
          filename: filename,
          contentType: http_parser.MediaType.parse(mimeType),
        );

        request.files.add(imageFile);
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleStatusCode(
      response,
      context,
    );
  } on _SessionExpiredHandled {
    return null;
  } on SocketException {
    _networkErrorToast(context, _offlineMessage);
    return null;
  } on http.ClientException {
    _networkErrorToast(context, _offlineMessage);
    return null;
  } catch (e, s) {
    print("MULTIPART ERROR: $e");
    log("MULTIPART ERROR", error: e, stackTrace: s);
    return null;
  }
}

// ------------------ COMMON HELPER ------------------

class CommonHelper {
  static void handleInactiveUserRedirect(
      BuildContext context,
      dynamic res,
      ) {
    if (res != null && res['active_flag'] == 0) {
      _redirectToLogin(
        context,
        res['message'][0].toString(),
      );
    }
  }
}