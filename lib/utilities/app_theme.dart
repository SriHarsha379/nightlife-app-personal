import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_font.dart';

class AppThemeConfig {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppFont.fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xffFF1CC0),
          secondary: Colors.white,
          surface: Color(0xff171217),
          background: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        cardTheme: CardTheme(
          color: const Color(0xff171217),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xff0f0616),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xffFF1CC0),
              width: 1,
            ),
          ),
          hintStyle: const TextStyle(color: Color(0xffb8b7bd)),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          displaySmall: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          headlineLarge: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          headlineMedium: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          headlineSmall: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          titleLarge: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          titleSmall: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          bodySmall: TextStyle(
            color: Color(0xffB09CBA),
            fontFamily: AppFont.fontFamily,
          ),
          labelLarge: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          labelMedium: TextStyle(
            color: Colors.white,
            fontFamily: AppFont.fontFamily,
          ),
          labelSmall: TextStyle(
            color: Color(0xffB09CBA),
            fontFamily: AppFont.fontFamily,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        dividerTheme: const DividerThemeData(
          color: Color(0xff333333),
          thickness: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Color(0xffFF1CC0),
          unselectedItemColor: Color(0xffB09CBA),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppFont.fontFamily,
        colorScheme: const ColorScheme.light(
          primary: Color(0xffFF1CC0),
          secondary: Colors.black,
          surface: Colors.white,
          background: Color(0xFFF5F5F5),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5F5),
          foregroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xffFF1CC0),
              width: 1,
            ),
          ),
          hintStyle: const TextStyle(color: Color(0xff999999)),
          labelStyle: const TextStyle(color: Colors.black),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          displayMedium: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          displaySmall: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          headlineLarge: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          headlineMedium: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          headlineSmall: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          titleLarge: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          titleSmall: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          bodyLarge: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          bodyMedium: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          bodySmall: TextStyle(
            color: Color(0xff666666),
            fontFamily: AppFont.fontFamily,
          ),
          labelLarge: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          labelMedium: TextStyle(
            color: Colors.black,
            fontFamily: AppFont.fontFamily,
          ),
          labelSmall: TextStyle(
            color: Color(0xff666666),
            fontFamily: AppFont.fontFamily,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E0E0),
          thickness: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xffFF1CC0),
          unselectedItemColor: Color(0xff666666),
        ),
      );
}
