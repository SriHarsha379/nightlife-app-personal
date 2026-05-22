// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controller/home/home_controller.dart';
import '../controller/my_profile/get_my_profile.dart';
import '../controller/my_profile/get_my_swipe_profile_controller.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_snack_bar_toast_message.dart';
import '../utilities/auth_session_service.dart';
import '../utilities/session_manager.dart';
import '../view/authentication/login_screen.dart';
import 'post_api_provider.dart';
import 'socket_provider.dart';
import 'user_controller.dart';

class _SessionExpiredHandled implements Exception {}

// ------------------ COMMON REQUEST HANDLER ------------------
Future<Map<String, dynamic>?> _handleRequest(
  Future<http.Response> Function(Uri url, Map<String, String> headers)
      requestFn,
  String endpoint,
  BuildContext? context, {
  Map<String, String>? headers,
}) async {
  try {
    final Uri url = Uri.parse("${AppConfigProvider.apiUrl}$endpoint");
    print('url $url');

    Map<String, String> requestHeaders =
        await _prepareRequestHeaders(headers ?? {}, context);
    http.Response response = await requestFn(url, requestHeaders);

    if (response.statusCode == 401 || response.statusCode == 403) {
      final didRefresh = await SessionManager.tryRefreshSession();
      if (didRefresh) {
        // Retry exactly once with the refreshed token to avoid infinite
        // refresh/retry loops when backend still rejects credentials.
        requestHeaders = SessionManager.withAuthorizationHeader(requestHeaders);
        response = await requestFn(url, requestHeaders);
      }
    }
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return await _handleStatusCode(response, context);
  } on _SessionExpiredHandled {
    return null;
  } catch (e) {
    print("API error: $e");
    return null;
  }
}

Future<Map<String, String>> _prepareRequestHeaders(
  Map<String, String> headers,
  BuildContext? context,
) async {
  final requestHeaders = Map<String, String>.from(headers);
  try {
    final token = await SessionManager.getFreshFirebaseIdToken(
      forceRefresh: true,
    );
    if (token != null && token.trim().isNotEmpty) {
      return SessionManager.withAuthorizationHeader(
        requestHeaders,
        token: token,
      );
    }
  } on SessionExpiredAuthException {
    if (context != null) {
      await _redirectToLogin(context, "Session expired. Please log in again.");
      throw _SessionExpiredHandled();
    }
  } catch (_) {}
  return requestHeaders;
}

// ------------------ STATUS CODE HANDLER ------------------
Future<Map<String, dynamic>?> _handleStatusCode(
    http.Response response, BuildContext? context) async {
  final statusCode = response.statusCode;
  final body = jsonDecode(response.body);

  // Success
  if (statusCode == 200) {
    if (SessionManager.extractToken(body).isNotEmpty ||
        SessionManager.extractRefreshToken(body).isNotEmpty) {
      await SessionManager.captureSessionFromAuthPayload(body);
    }
    return body;
  }

  String errorMessage = _getErrorMessage(body);

  if (statusCode == 400) {
    if (context != null) {
      TopNotification.error(context, errorMessage);
    }
    return null;
  }

  if (statusCode == 401 || statusCode == 403) {
    if (context != null) {
      await _redirectToLogin(context, errorMessage);
    }
    return null;
  }
  if (statusCode == 423) {
    if (context != null) {
      await _redirectToLogin(context, errorMessage);
    }
    return null;
  }

  if (statusCode == 500) {
    if (context != null) {
      TopNotification.error(context, "Server error. Please try again later.");
    }
    return null;
  }

  if (context != null) {
    TopNotification.error(context, errorMessage);
  }
  return null;
}

// ------------------ GET ERROR MESSAGE ------------------
String _getErrorMessage(dynamic body) {
  if (body == null) return "An error occurred";

  // Check message field
  if (body['message'] != null) {
    if (body['message'] is List) {
      return body['message'][language].toString();
    }
    return body['message'].toString();
  }

  if (body['message'] != null) {
    if (body['message'] is Map && body['message'][language] != null) {
      return body['message'][language].toString();
    }
    return body['message'].toString();
  }

  return "An error occurred";
}

// ------------------ REDIRECT TO LOGIN ------------------
Future<void> _redirectToLogin(BuildContext context, String message) async {
  TopNotification.error(context, message);
  _tryProviderReset(context);
  await SessionManager.clearAuthSession(
    signOutFromFirebase: true,
    clearAllPreferences: true,
  );
  AppConstant.selectFooterIndex = 0;
  AppContentCache().clear();
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

void _tryProviderReset(BuildContext context) {
  try {
    Provider.of<SocketProvider>(context, listen: false).disconnect();
  } catch (_) {}
  try {
    Provider.of<UserController>(context, listen: false).reset();
  } catch (_) {}
  try {
    Provider.of<HomeController>(context, listen: false).clearAllData();
  } catch (_) {}
  try {
    Provider.of<ProfileController>(context, listen: false).clearProfileData();
  } catch (_) {}
  try {
    Provider.of<GetMySwipeProfileController>(context, listen: false).resetState();
  } catch (_) {}
}

// ------------------ GET DATA (HEADERS ONLY - WITH TOKEN) ------------------
Future<Map<String, dynamic>?> getData(
  String endpoint,
  BuildContext? context, {
  Map<String, String>? headers,
}) async {
  return _handleRequest(
    (url, h) => http.get(url, headers: h),
    endpoint,
    context,
    headers: headers,
  );
}

// ------------------ POST DATA (HEADERS ONLY - WITH TOKEN, NO BODY) ------------------
Future<Map<String, dynamic>?> postData(
  String endpoint,
  BuildContext? context, {
  Map<String, String>? headers,
}) async {
  return _handleRequest(
    (url, h) => http.post(url, headers: h),
    endpoint,
    context,
    headers: headers,
  );
}

// ------------------ POST FORM DATA ------------------
Future<Map<String, dynamic>?> postFormData(
  String endpoint,
  Map<String, String> fields,
  BuildContext? context, {
  Map<String, String>? headers,
}) async {
  try {
    final Uri url = Uri.parse("${AppConfigProvider.apiUrl}$endpoint");
    log('url $url');

    var request = http.MultipartRequest('POST', url);
    final preparedHeaders = await _prepareRequestHeaders(headers ?? {}, context);
    request.headers.addAll(preparedHeaders);
    request.fields.addAll(fields);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return _handleStatusCode(response, context);
  } catch (e) {
    print("API error: $e");
    return null;
  }
}

// ------------------ POST JSON DATA ------------------
Future<Map<String, dynamic>?> postJsonData(
  String endpoint,
  Map<String, dynamic> jsonData,
  BuildContext? context, {
  Map<String, String>? headers,
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
  );
}

// ------------------ POST MULTIPART DATA (FOR FILE UPLOAD) ------------------
Future<Map<String, dynamic>?> postMultipartData(
  String endpoint,
  Map<String, String> fields,
  BuildContext? context, {
  Map<String, String>? headers,
  Map<String, XFile>? files,
}) async {
  try {
    final Uri url = Uri.parse("${AppConfigProvider.apiUrl}$endpoint");
    print('url $url');

    var request = http.MultipartRequest('POST', url);
    final preparedHeaders = await _prepareRequestHeaders(headers ?? {}, context);
    request.headers.addAll(preparedHeaders);

    request.fields.addAll(fields);

    if (files != null) {
      for (var entry in files.entries) {
        if (entry.value != null) {
          List<int> imageBytes = await entry.value.readAsBytes();
          http.MultipartFile imageFile = http.MultipartFile.fromBytes(
            entry.key,
            imageBytes,
            filename: '${entry.key}.jpg',
          );
          request.files.add(imageFile);
        }
      }
    }

    print("request.fields: ${request.fields}");
    print("request.files: ${request.files}");

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return _handleStatusCode(response, context);
  } catch (e) {
    print("API error: $e");
    return null;
  }
}

// ------------------ GET FORM DATA (LEGACY - USE getData INSTEAD) ------------------
Future<Map<String, dynamic>?> getFormData(
  String endpoint,
  BuildContext? context, {
  Map<String, String>? headers,
}) async {
  return _handleRequest(
    (url, h) => http.get(url, headers: headers),
    endpoint,
    context,
    headers: headers,
  );
}

// ------------------ COMMON HELPER ------------------
class CommonHelper {
  static void handleInactiveUserRedirect(BuildContext context, dynamic res) {
    if (res != null && res['active_flag'] == 0) {
      _redirectToLogin(context, res['message'][language]);
    }
  }
}
