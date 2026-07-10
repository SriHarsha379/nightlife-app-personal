import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseOtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verificationId;
  static int? _resendToken;

  /// Send OTP to phone number
  /// Returns true if the request was submitted successfully
  /// (this does NOT necessarily mean the user is signed in yet —
  /// check onCodeSent vs auto-verification in your UI if needed).
  static Future<bool> sendOtp({
    required String phoneNumber,
    required BuildContext context,
    required Function(String error) onError,
    required Function() onCodeSent,
  }) async {
    final String formattedNumber =
    phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';

    // ---- DEBUG: platform + input sanity check ----
    debugPrint('=== sendOtp START ===');
    debugPrint('Platform: ${Platform.operatingSystem}');
    debugPrint('Raw phoneNumber param: "$phoneNumber"');
    debugPrint('Formatted phoneNumber sent to Firebase: "$formattedNumber"');

    // ---- DEBUG: iOS-only APNs token check ----
    // On iOS, Firebase Phone Auth needs a working APNs token to silently
    // verify the app (or to fall back to reCAPTCHA if it's missing).
    // Simulators do NOT receive real APNs tokens — this will print null
    // there, which alone explains "OTP not coming on iOS".
    if (Platform.isIOS) {
      try {
        final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        debugPrint('iOS APNs token: ${apnsToken ?? "NULL <-- likely cause, see notes below"}');
      } catch (e) {
        debugPrint('iOS APNs token fetch threw: $e');
      }
    }

    try {
      debugPrint('Calling FirebaseAuth.verifyPhoneNumber...');
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This fires in two cases:
          // 1. Android auto-reads the SMS and verifies silently.
          // 2. Firebase test phone numbers, which often skip codeSent
          //    entirely and verify instantly.
          // Either way, we MUST actually sign in here, or _verificationId
          // never gets set and manual OTP entry will fail with
          // "session expired" or "invalid code".
          debugPrint('[callback] verificationCompleted fired (auto sign-in)');
          try {
            await _auth.signInWithCredential(credential);
            debugPrint('[callback] auto sign-in succeeded');
            onCodeSent(); // let UI know it can proceed (user is now signed in)
          } on FirebaseAuthException catch (e) {
            debugPrint('[callback] Auto sign-in failed: ${e.code} - ${e.message}');
            onError(e.message ?? 'Auto verification failed.');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('[callback] verificationFailed fired');
          debugPrint('  code: ${e.code}');
          debugPrint('  message: ${e.message}');
          debugPrint('  plugin: ${e.plugin}');
          debugPrint('  stackTrace: ${e.stackTrace}');
          onError(e.message ?? 'OTP sending failed. Please try again.');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          debugPrint('[callback] codeSent fired, verificationId set: $verificationId');
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('[callback] codeAutoRetrievalTimeout fired, verificationId set: $verificationId');
        },
        forceResendingToken: _resendToken,
      );
      debugPrint('verifyPhoneNumber call returned without throwing (this just means the '
          'request was submitted — check which callback above actually fired)');
      debugPrint('=== sendOtp END ===');
      return true;
    } catch (e, st) {
      debugPrint('sendOtp exception: $e');
      debugPrint('sendOtp stack trace: $st');
      onError('Failed to send OTP: $e');
      return false;
    }
  }

  /// Verify OTP entered by user
  /// Returns true if OTP is correct and sign-in succeeded
  static Future<bool> verifyOtp({
    required String otp,
    required Function(String error) onError,
  }) async {
    // If verificationCompleted already signed the user in (auto-verification
    // or test number instant verification), there's nothing left to verify.
    if (_auth.currentUser != null) {
      debugPrint('User already signed in via auto-verification');
      return true;
    }

    if (_verificationId == null) {
      onError('Session expired. Please request OTP again.');
      return false;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('verifyOtp error: ${e.code} - ${e.message}');
      if (e.code == 'invalid-verification-code') {
        onError('Invalid OTP. Please try again.');
      } else if (e.code == 'session-expired') {
        onError('OTP expired. Please request a new one.');
      } else {
        onError(e.message ?? 'OTP verification failed.');
      }
      return false;
    } catch (e) {
      debugPrint('verifyOtp unexpected error: $e');
      onError('Verification failed: $e');
      return false;
    }
  }

  /// Resend OTP
  static Future<bool> resendOtp({
    required String phoneNumber,
    required BuildContext context,
    required Function(String error) onError,
    required Function() onCodeSent,
  }) async {
    return sendOtp(
      phoneNumber: phoneNumber,
      context: context,
      onError: onError,
      onCodeSent: onCodeSent,
    );
  }

  /// Clear verification state — call this when leaving the OTP screen
  /// or starting a fresh phone auth attempt, so a stale verificationId
  /// from a previous try can't cause invalid-verification-code errors.
  static void reset() {
    _verificationId = null;
    _resendToken = null;
  }
}