import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseOtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verificationId;
  static int? _resendToken;

  /// Send OTP to phone number
  /// Returns true if OTP sent successfully
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
          // Auto-verification on Android (SMS auto-read)
          debugPrint('Auto verification completed');
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.message}');
          onError(e.message ?? 'OTP sending failed. Please try again.');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          debugPrint('OTP sent successfully');
          onCodeSent();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
      return true;
    } catch (e) {
      onError('Failed to send OTP: $e');
      return false;
    }
  }

  /// Verify OTP entered by user
  /// Returns true if OTP is correct
  static Future<bool> verifyOtp({
    required String otp,
    required Function(String error) onError,
  }) async {
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
      if (e.code == 'invalid-verification-code') {
        onError('Invalid OTP. Please try again.');
      } else if (e.code == 'session-expired') {
        onError('OTP expired. Please request a new one.');
      } else {
        onError(e.message ?? 'OTP verification failed.');
      }
      return false;
    } catch (e) {
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

  /// Clear verification state
  static void reset() {
    _verificationId = null;
    _resendToken = null;
  }
}
