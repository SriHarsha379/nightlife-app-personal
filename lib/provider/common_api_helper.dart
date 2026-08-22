import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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

Future<Map<String, dynamic>?> _handleRequest(
    Future<http.Response> Function(
        Uri url,
        Map<String, String> headers,
        ) requestFn,
    String endpoint,
    BuildContext? context, {
      Map<String, String>? headers,
    }) async {
  try {
    final Uri url = Uri.parse("${AppConfigProvider.apiUrl}$endpoint");

    print("URL: $url");

    Map<String, String> requestHeaders = await _prepareRequestHeaders(
      headers ?? {},
      context,
    );

    print("REQUEST HEADERS: $requestHeaders");

    http.Response response = await requestFn(url, requestHeaders);

    // Retry once if token expired
    if (response.statusCode == 401 || response.statusCode == 403) {
      final didRefresh = await SessionManager.tryRefreshSession();

      if (didRefresh) {
        requestHeaders = SessionManager.withAuthorizationHeader(
          requestHeaders,
        );

        response = await requestFn(url, requestHeaders);
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
        () => 'com.davisantony.nightlife',
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

        if (FirebaseAuth.instance.currentUser == null) {
          try {
            await FirebaseAuth.instance.signInAnonymously();
            debugPrint('Firebase anonymous login success');
          } catch (e) {
            debugPrint('Firebase anonymous login failed: $e');
          }
        }
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
      TopNotification.error(context, _getErrorMessage(body));
    }
    return null;
  }

  if (statusCode == 401 || statusCode == 403 || statusCode == 423) {
    final isLogout = response.request?.url.toString().contains('auth/logout') ?? false;
    if (context != null && !isLogout) {
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
      _getErrorMessage(body),
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
    }) async {
  print("POST BODY for $endpoint: ${jsonEncode(jsonData)}"); // TEMP DEBUG
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

        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
          entry.key,
          imageBytes,
          filename: '${entry.key}.jpg',
        );

        request.files.add(imageFile);
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print("MULTIPART URL: $url");
    print("MULTIPART STATUS CODE: ${response.statusCode}");
    print("MULTIPART RESPONSE BODY: ${response.body}");

    return _handleStatusCode(
      response,
      context,
    );
  } on _SessionExpiredHandled {
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