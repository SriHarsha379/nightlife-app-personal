import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../provider/common_api_helper.dart';
import 'app_constant.dart';
import 'local_notification_service.dart';

/// Nudges a signed-in user with an incomplete profile with a local
/// notification whenever the app is opened or brought back to the
/// foreground.
///
/// Uses the same `common/profile_complete_status` endpoint already backing
/// lib/controller/my_profile/profile_indicator_controller.dart, so the
/// "is it complete" answer here matches what the profile-completion UI
/// elsewhere in the app shows (percentage + specific missing items), not
/// just the coarser "did they finish the signup wizard" flag.
///
/// This is deliberately a *local* notification with its own, separate
/// throttle key - it does not read or write the backend's
/// `last_notified_profile_completion` field, so it can never conflict with
/// the backend's own "profile improved" push (helper.checkAndNotifyProfileCompletion),
/// which only fires on an actual edit, not on app open. This reminder
/// covers the app-open case that the backend one intentionally doesn't.
class ProfileCompletionReminder {
  ProfileCompletionReminder._();

  static const String _lastShownKey = 'profile_reminder_last_shown_v1';

  // Don't re-nag on every single app open/resume - once every ~20 hours
  // is enough to be a nudge rather than a nuisance.
  static const Duration _cooldown = Duration(hours: 20);

  // Fixed id so a re-show replaces the previous one instead of stacking
  // duplicates in the notification tray.
  static const int _notificationId = 9021001;

  /// Safe to call with no BuildContext - works both from Splash (cold
  /// start / login) and from main.dart's app-lifecycle resume handler.
  static Future<void> maybeCheckAndShow() async {
    try {
      final String token = AppConstant.token;
      if (token.isEmpty) return; // not logged in - nothing to remind

      final res = await getData(
        'common/profile_complete_status',
        null,
        headers: {'authorization': 'Bearer $token'},
      );

      if (res == null || res['success'] != true) return;
      final dynamic data = res['data'];
      if (data is! Map) return;

      final dynamic apiPercentage = data['profile_completion_percentage'];
      final int percentage =
      apiPercentage is num ? apiPercentage.toInt().clamp(0, 100) : 100;

      if (percentage >= 100) return; // already complete - nothing to nudge

      final dynamic apiMessages = data['messages'];
      final List<String> missing = apiMessages is List
          ? apiMessages
          .whereType<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList()
          : <String>[];

      await _showThrottled(percentage: percentage, missing: missing);
    } catch (_) {
      // Best-effort reminder only - never let this interfere with app
      // startup or resume.
    }
  }

  static Future<void> _showThrottled({
    required int percentage,
    required List<String> missing,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastShownMillis = prefs.getInt(_lastShownKey);
    final DateTime now = DateTime.now();

    if (lastShownMillis != null) {
      final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownMillis);
      if (now.difference(lastShown) < _cooldown) return;
    }

    final String body = missing.isNotEmpty
        ? "You're at $percentage% - ${missing.first} to boost your profile."
        : "You're at $percentage% - finish it up so people can get to know you.";

    await LocalNotificationService.showSimpleNotification(
      id: _notificationId,
      title: "Finish setting up your profile",
      body: body,
      payload: jsonEncode({'action': 'complete_profile'}),
    );

    await prefs.setInt(_lastShownKey, now.millisecondsSinceEpoch);
  }
}