import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  // Toggle between dark and light mode
  void toggleTheme(bool isOn) {
    print("object$isOn");
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(isOn ? 'dark' : 'light');
    notifyListeners();
  }

  // Set theme to system default
  void setSystemDefault() {
    _themeMode = ThemeMode.system;
    _saveThemeMode('system');
    notifyListeners();
  }

  // Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
  }

  // Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('themeMode') ?? 'system';
    
    if (mode == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (mode == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  // Legacy method for backward compatibility (kept for old code)
  Future<void> _saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }
}