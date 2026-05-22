import 'package:shared_preferences/shared_preferences.dart';

/// Manages display frequency and trigger logic for Advertisement and Poll popups.
///
/// Frequency rules:
/// - Advertisement popup: shown at most [_maxAdsPerDay] times per day, with a
///   minimum [_adCooldown] interval between consecutive shows.
/// - Poll popup: shown at most [_maxPollsPerDay] times per day.
///
/// Trigger thresholds (used by the caller):
/// - Ad popup  : every [adSwipeTriggerCount] swipes.
/// - Poll popup: every [pollSwipeTriggerCount] swipes.
class PopupManager {
  // ── Trigger thresholds ───────────────────────────────────────────────────────
  static const int adSwipeTriggerCount = 5;
  static const int pollSwipeTriggerCount = 10;

  // ── Frequency limits ─────────────────────────────────────────────────────────
  static const int _maxAdsPerDay = 3;
  static const int _maxPollsPerDay = 1;
  static const Duration _adCooldown = Duration(minutes: 5);

  // ── SharedPreferences keys ───────────────────────────────────────────────────
  static const String _kAdLastShownMs = 'popup_ad_last_shown_ms';
  static const String _kAdCountToday = 'popup_ad_count_today';
  static const String _kAdCountDate = 'popup_ad_count_date';
  static const String _kPollLastShownMs = 'popup_poll_last_shown_ms';
  static const String _kPollCountToday = 'popup_poll_count_today';
  static const String _kPollCountDate = 'popup_poll_count_date';

  // ── Advertisement ─────────────────────────────────────────────────────────────

  /// Returns `true` if an ad popup may be shown right now.
  static Future<bool> shouldShowAdPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    final countDate = prefs.getString(_kAdCountDate) ?? '';
    final countToday =
        countDate == todayKey ? (prefs.getInt(_kAdCountToday) ?? 0) : 0;
    if (countToday >= _maxAdsPerDay) return false;

    final lastShownMs = prefs.getInt(_kAdLastShownMs) ?? 0;
    if (lastShownMs > 0) {
      final elapsed =
          now.difference(DateTime.fromMillisecondsSinceEpoch(lastShownMs));
      if (elapsed < _adCooldown) return false;
    }

    return true;
  }

  /// Records that an ad popup was shown.
  static Future<void> recordAdShown() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    final countDate = prefs.getString(_kAdCountDate) ?? '';
    final countToday =
        countDate == todayKey ? (prefs.getInt(_kAdCountToday) ?? 0) : 0;

    await prefs.setInt(_kAdLastShownMs, now.millisecondsSinceEpoch);
    await prefs.setString(_kAdCountDate, todayKey);
    await prefs.setInt(_kAdCountToday, countToday + 1);
  }

  // ── Poll ─────────────────────────────────────────────────────────────────────

  /// Returns `true` if a poll popup may be shown right now.
  static Future<bool> shouldShowPollPopup() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    final countDate = prefs.getString(_kPollCountDate) ?? '';
    final countToday =
        countDate == todayKey ? (prefs.getInt(_kPollCountToday) ?? 0) : 0;

    return countToday < _maxPollsPerDay;
  }

  /// Records that a poll popup was shown.
  static Future<void> recordPollShown() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = _dateKey(now);

    final countDate = prefs.getString(_kPollCountDate) ?? '';
    final countToday =
        countDate == todayKey ? (prefs.getInt(_kPollCountToday) ?? 0) : 0;

    await prefs.setInt(_kPollLastShownMs, now.millisecondsSinceEpoch);
    await prefs.setString(_kPollCountDate, todayKey);
    await prefs.setInt(_kPollCountToday, countToday + 1);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}
