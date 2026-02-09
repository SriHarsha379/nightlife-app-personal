import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  // ✅ FIX: System theme को भी handle करें
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // System की current brightness check करें
      final brightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  /// Toggle between dark and light mode
  /// @param isOn - true for dark mode, false for light mode
  void toggleTheme(bool isOn) {
    print("Theme toggled: ${isOn ? 'Dark' : 'Light'}");
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(isOn ? 'dark' : 'light');
    notifyListeners();
  }

  /// Set theme to system default
  void setSystemDefault() {
    print("Theme set to: System Default");
    _themeMode = ThemeMode.system;
    _saveThemeMode('system');
    notifyListeners();
  }

  /// Set theme mode directly
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    String modeString = mode == ThemeMode.dark
        ? 'dark'
        : mode == ThemeMode.light
            ? 'light'
            : 'system';
    _saveThemeMode(modeString);
    notifyListeners();
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', mode);
      print("Theme saved: $mode");
    } catch (e) {
      print("Error saving theme: $e");
    }
  }

  /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mode = prefs.getString('themeMode') ?? 'dark';

      if (mode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (mode == 'light') {
        _themeMode = ThemeMode.light;
      } else if (mode == 'system') {
        _themeMode = ThemeMode.system;
      }

      print("Theme loaded: $mode");
      notifyListeners();
    } catch (e) {
      print("Error loading theme: $e");
      _themeMode = ThemeMode.dark; // Fallback to dark mode
    }
  }
}
