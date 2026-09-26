import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '/utilities/app_constant.dart';
import '/utilities/local_notification_service.dart';
import '/provider/common_api_helper.dart';

class FcmTokenService {
  static String? _lastSynced;

  /// Tell the backend this phone's current push token. Called when Home opens
  /// (every launch) and whenever Firebase rotates the token. Before, the token
  /// was only sent at login/signup, so members who stayed logged in silently
  /// stopped receiving notifications after a rotation.
  static Future<void> syncWithServer() async {
    final String token = AppConstant.playerID.toString();
    // "123456" is the placeholder used when Firebase gave no token.
    if (token.length < 20 || AppConstant.token.isEmpty || token == _lastSynced) return;
    try {
      final res = await postJsonData(
        'user/update_player_id',
        {'player_id': token, 'device_type': AppConstant.deviceType},
        null,
        headers: {'authorization': 'Bearer ${AppConstant.token}'},
      );
      if (res != null && res['success'] == true) _lastSynced = token;
    } catch (e) {
      debugPrint('Push token sync failed: $e');
    }
  }

  static Future<void> generateAndStoreToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('FCM permission request failed: $e');
    }

    final String? token = await _getTokenWithRetry(messaging: messaging);

    if (token != null && token.isNotEmpty) {
      AppConstant.playerID = token;
      debugPrint('FCM token on app start: ${AppConstant.playerID}');
    } else {
      debugPrint('FCM token on app start: unavailable, keeping fallback token ${AppConstant.playerID}');
    }

    _setupForegroundMessageHandler();

    messaging.onTokenRefresh.listen(
      (String refreshedToken) {
        AppConstant.playerID = refreshedToken;
        debugPrint('FCM token refreshed: ${AppConstant.playerID}');
        syncWithServer();
      },
      onError: (Object error) {
        debugPrint('FCM token refresh listener error: $error');
      },
    );
  }

  static Future<String?> _getTokenWithRetry({
    required FirebaseMessaging messaging,
    int maxAttempts = 3,
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await messaging.getToken();
      } on PlatformException catch (e) {
        debugPrint('FCM getToken PlatformException (attempt $attempt/$maxAttempts): ${e.code} - ${e.message}');
      } catch (e) {
        debugPrint('FCM getToken failed (attempt $attempt/$maxAttempts): $e');
      }

      if (attempt < maxAttempts) {
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      }
    }

    return null;
  }

  static void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('FCM onMessage: id=${message.messageId}, data=${message.data}');
      await LocalNotificationService.showFromRemoteMessage(message);
    });
  }

  static void setupNotificationTapRedirection(
    void Function(RemoteMessage message) onRedirect,
  ) {
    FirebaseMessaging.onMessageOpenedApp.listen(onRedirect);
  }
}