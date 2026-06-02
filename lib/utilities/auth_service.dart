import 'dart:convert';
import 'dart:math';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ========== Google Login ==========
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 🔥 Get auth tokens and sign into Firebase
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Parse name
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

  // ========== Apple Login ==========
  static Future<Map<String, dynamic>?> signInWithApple() async {
    try {
      // Generate a secure nonce (required by Firebase for Apple Sign-In)
      final String rawNonce = _generateNonce();
      final String nonceSha256 = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonceSha256, // pass hashed nonce to Apple
      );

      // 🔥 Sign into Firebase with Apple credential
      final OAuthCredential oauthCredential =
      OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce, // pass raw nonce to Firebase
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Retrieve saved data (Apple only returns name on first sign-in)
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

  // ========== Logout ==========
  static Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {}

    try {
      await FirebaseAuth.instance.signOut(); // 🔥 Sign out from Firebase too
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ========== Helpers ==========
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("socialData", jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("socialData");
    if (data != null) return jsonDecode(data);
    return null;
  }

  /// Generates a cryptographically secure random nonce for Apple Sign-In
  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the SHA-256 hash of the nonce
  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}