import 'dart:convert';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FirebaseOtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? _verificationId;
  static int? _resendToken;

  // Saved on the phone so a verification survives the app being closed
  // (Android may close it while Firebase's browser captcha is open).
  static const String _sessionKey = 'otp_session';
  static const String _attemptKey = 'otp_attempt';

  static Future<void> _saveSession(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, jsonEncode({
        'vid': _verificationId,
        'token': _resendToken,
        'phone': phone,
        'at': DateTime.now().millisecondsSinceEpoch,
      }));
    } catch (_) {}
  }

  static Future<void> _saveAttempt(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_attemptKey, jsonEncode({
        'phone': phone,
        'at': DateTime.now().millisecondsSinceEpoch,
      }));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> _readFresh(String key, String phone, Duration maxAge) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      final at = DateTime.fromMillisecondsSinceEpoch((data['at'] ?? 0) as int);
      if (DateTime.now().difference(at) > maxAge) return null;
      if (!_samePhone(data['phone']?.toString(), phone)) return null;
      return Map<String, dynamic>.from(data);
    } catch (_) {
      return null;
    }
  }

  /// A code was sent to this number recently (app reopened after being
  /// closed) - restore that session so the SMS code can still be entered.
  static Future<bool> restoreRecentSession(String phone,
      {Duration maxAge = const Duration(minutes: 10)}) async {
    final data = await _readFresh(_sessionKey, phone, maxAge);
    final vid = data?['vid']?.toString();
    if (vid == null || vid.isEmpty) return false;
    _verificationId = vid;
    _resendToken = data!['token'] is int ? data['token'] as int : null;
    return true;
  }

  /// A send to this number was started recently but never completed
  /// (e.g. the app was closed during the captcha).
  static Future<bool> hadRecentAttempt(String phone,
      {Duration within = const Duration(minutes: 2)}) async {
    return (await _readFresh(_attemptKey, phone, within)) != null;
  }

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
    _saveAttempt(phoneNumber);

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
          _saveSession(phoneNumber);
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
  /// Last 10 digits of two numbers match (verified must be non-empty).
  static bool _samePhone(String? verified, String? requested) {
    String last10(String? s) {
      final d = (s ?? '').replaceAll(RegExp(r'\D'), '');
      return d.length > 10 ? d.substring(d.length - 10) : d;
    }
    final v = last10(verified);
    if (v.isEmpty) return false;
    return requested == null || v == last10(requested);
  }

  /// Firebase's proof that the phone number was verified - the backend
  /// checks it (auth/otp_verify), so a typed code alone can't be faked.
  static Future<String?> getVerifiedIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken(true);
    } catch (e) {
      debugPrint('getVerifiedIdToken failed: $e');
      return null;
    }
  }

  static Future<bool> verifyOtp({
    required String otp,
    required Function(String error) onError,
    String? phoneNumber,
  }) async {
    // Already verified THIS number (Android auto-read / test number)? Then
    // there's nothing left to check. NB: the app also signs in to Firebase
    // anonymously after the first signup step - that is NOT a verified
    // phone, so it must not count (it used to make any code "correct").
    final current = _auth.currentUser;
    if (current != null && _samePhone(current.phoneNumber, phoneNumber)) {
      debugPrint('Phone already verified via auto-verification');
      return true;
    }

    // App reopened after being closed? Pick up the saved session.
    if (_verificationId == null && phoneNumber != null) {
      await restoreRecentSession(phoneNumber);
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
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_sessionKey);
      prefs.remove(_attemptKey);
    }).catchError((_) {});
  }
}