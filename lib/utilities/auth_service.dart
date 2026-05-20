import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  //========== Google Login ===============
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      String fullName = googleUser.displayName ?? "";
      List<String> parts = fullName.trim().split(" ");

      String firstName = parts.isNotEmpty ? parts.first : "";
      String lastName = parts.length > 1 ? parts.sublist(1).join(" ") : "";

      final data = {
        "first_name": firstName,
        "last_name": lastName,
        "full_name": fullName,
        "email": googleUser.email,
        "social_id": googleUser.id,
        "login_type": "google",
      };

      await _saveUserData(data);
      return data;
    } catch (e) {
      debugPrint("Google Login Error: $e");
      return null;
    }
  }

  //========================= Apple Login=========================

  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic>? oldData;

      final saved = prefs.getString("socialData");
      if (saved != null) {
        oldData = jsonDecode(saved);
      }

      String firstName = credential.givenName ?? oldData?["first_name"] ?? "";

      String lastName = credential.familyName ?? oldData?["last_name"] ?? "";

      String fullName = "$firstName $lastName".trim();

      final data = {
        "first_name": firstName,
        "last_name": lastName,
        "full_name": fullName,
        "email": credential.email ?? oldData?["email"] ?? "",
        "social_id": credential.userIdentifier ?? "",
        "login_type": "apple",
      };

      await _saveUserData(data);
      return data;
    } catch (e) {
      debugPrint("Apple Login Error: $e");
      return null;
    }
  }

  /// Save user data
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("socialData", jsonEncode(userData));
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("socialData");

    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
