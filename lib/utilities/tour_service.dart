import 'package:shared_preferences/shared_preferences.dart';

/// Tracks which first-time coach-mark tours a user has already seen,
/// so each tour shows only once. Keys are per-screen (e.g. 'home').
class TourService {
  static String _key(String tour) => 'tour_shown_$tour';

  /// True if this tour has NOT been shown yet.
  static Future<bool> shouldShow(String tour) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key(tour)) ?? false);
  }

  /// Mark a tour as shown so it won't appear again.
  static Future<void> markShown(String tour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(tour), true);
  }

  /// Reset one tour (handy while testing).
  static Future<void> reset(String tour) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(tour));
  }

  /// Reset ALL tours (testing only).
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith('tour_shown_')).toList()) {
      await prefs.remove(k);
    }
  }
}
