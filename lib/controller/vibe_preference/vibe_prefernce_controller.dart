import 'package:flutter/material.dart';

/// The curated vibe picker (fetch a fixed list like "Chill pill", "High
/// Energy" from the backend and let the member tap to select up to 5) has
/// been removed entirely - there is no curated list anymore, no
/// replacement was introduced. This controller now only tracks the
/// free-text vibes the member types themselves (custom_vibes on the
/// backend), which already existed alongside the curated picker before.
class VibePreferenceController with ChangeNotifier {
  List<String> _customVibes = <String>[];
  List<String> get getCustomVibes => List<String>.from(_customVibes);

  int maxSelection = 5;

  /// Add a free-text vibe the member typed in, up to [maxSelection].
  void addCustomVibe(String vibe) {
    final trimmed = vibe.trim();
    if (trimmed.isEmpty) return;
    if (_customVibes.contains(trimmed)) return;
    if (_customVibes.length >= maxSelection) return;
    _customVibes.add(trimmed);
    notifyListeners();
  }

  void removeCustomVibe(String vibe) {
    _customVibes.remove(vibe);
    notifyListeners();
  }

  int get selectedCount => _customVibes.length;

  /// Comma-separated string for the signup/profile-update API call.
  String getSelectedVibesString() {
    return _customVibes.join(',');
  }

  /// Preselect vibes when coming back from a later screen, or when
  /// loading an existing profile's saved custom_vibes for editing.
  void setCustomVibes(List<String> vibes) {
    _customVibes = List<String>.from(vibes);
    notifyListeners();
  }

  void clearSelections() {
    _customVibes.clear();
    notifyListeners();
  }

  void clearData() {
    _customVibes = <String>[];
    notifyListeners();
  }
}