// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../core/utils/app_constant.dart'; // Import your app_constant.dart

// class LanguageProvider extends ChangeNotifier {
//   // Load language from SharedPreferences on app start
//   Future<void> loadLanguage() async {
//     final prefs = await SharedPreferences.getInstance();
//     language = prefs.getInt('language') ?? 0; // Update global variable
//     notifyListeners();
//   }

//   // Change language and save to SharedPreferences
//   Future<void> changeLanguage(int languageCode) async {
//     language = languageCode; // Update global variable
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('language', languageCode);
//     notifyListeners(); // This will rebuild all listening widgets
//   }

//   // Getter to trigger rebuild when accessed
//   int get currentLanguage => language;

//   String get currentLanguageName => language == 0 ? 'English' : 'Greek';
// }
