import 'package:firebase_auth/firebase_auth.dart';
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
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber',
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This fires in two cases:
          // 1. Android auto-reads the SMS and verifies silently.
          // 2. Firebase test phone numbers, which often skip codeSent
          //    entirely and verify instantly.
          // Either way, we MUST actually sign in here, or _verificationId
          // never gets set and manual OTP entry will fail with
          // "session expired" or "invalid code".
          debugPrint('Auto verification completed');
          try {
            await _auth.signInWithCredential(credential);
            onCodeSent(); // let UI know it can proceed (user is now signed in)
          } on FirebaseAuthException catch (e) {
            debugPrint('Auto sign-in failed: ${e.code} - ${e.message}');
            onError(e.message ?? 'Auto verification failed.');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.code} - ${e.message}');
          onError(e.message ?? 'OTP sending failed. Please try again.');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          debugPrint('OTP sent successfully, verificationId set');
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('Auto-retrieval timed out, verificationId set for manual entry');
        },
        forceResendingToken: _resendToken,
      );
      return true;
    } catch (e) {
      debugPrint('sendOtp exception: $e');
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