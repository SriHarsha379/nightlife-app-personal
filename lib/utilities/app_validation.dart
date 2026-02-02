import 'package:flutter/material.dart';
import '/utilities/app_language.dart';
import '../utilities/app_constant.dart';
import 'app_snack_bar_toast_message.dart';

class Validation {
  // -------------------------
  // COMMON SAFE SNACKBAR CALL
  // -------------------------
  static void _showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    SnackBarToastMessage.info(context, message);
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    SnackBarToastMessage.error(context, message);
  }

  // -------------------------
  // EMPTY FIELD VALIDATION
  // -------------------------
  static bool isFieldEmpty(
    BuildContext context, {
    required String value,
    required String fieldName,
  }) {
    if (!context.mounted) return false;

    if (value.trim().isEmpty) {
      _showInfo(
        context,
        "${AppLanguage.pleaseEnterText[language]} $fieldName",
      );
      return true;
    }
    return false;
  }

  // DROPDOWN / SELECT FIELD

  static bool isFieldSelect(
    BuildContext context, {
    required String value,
    required String fieldName,
  }) {
    if (!context.mounted) return false;

    if (value.trim().isEmpty) {
      _showInfo(
        context,
        "${AppLanguage.pleaseSelectText[language]} $fieldName",
      );
      return true;
    }
    return false;
  }

  // EMAIL VALIDATION

  static bool isEmailValid(BuildContext context, String email) {
    if (!context.mounted) return false;

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showError(context, AppLanguage.validEmailText[language]);
      return false;
    }
    return true;
  }

  // MOBILE NUMBER - NUMERIC ONLY VALIDATION

  static bool isMobileNumericOnly(BuildContext context, String mobile) {
    if (!context.mounted) return false;

    if (!RegExp(r'^[0-9]+$').hasMatch(mobile.trim())) {
      _showError(context, "Mobile number should contain digits only");
      return false;
    }
    return true;
  }

  // MOBILE NUMBER VALIDATION

  static bool isMobilValid(BuildContext context, String mobile) {
    if (!context.mounted) return false;

    if (mobile.trim().length < 10) {
      _showError(context, AppLanguage.validPhoneNumberMsgText[language]);
      return false;
    }
    return true;
  }

  // PASSWORD MIN LENGTH

  static bool isPasswordLength(BuildContext context, String password,
      {int minLength = 6}) {
    if (!context.mounted) return false;

    if (password.trim().length < minLength) {
      _showError(context, AppLanguage.passwordMinMessage[language]);
      return false;
    }
    return true;
  }

  // PASSWORD MATCH

  static bool isPasswordMatch(
      BuildContext context, String password, String confirmPassword) {
    if (!context.mounted) return false;

    if (password != confirmPassword) {
      _showError(context, AppLanguage.passwordNotMatchText[language]);
      return false;
    }
    return true;
  }

  // OTP LENGTH VALIDATION

  static bool isOtpLength(BuildContext context, String otp,
      {int minLength = 4}) {
    if (!context.mounted) return false;

    if (otp.trim().length < minLength) {
      _showError(context, AppLanguage.otpMinLenthMessage[language]);
      return false;
    }
    return true;
  }

  // FILE PICKER VALIDATION

  static bool isFileSelected(
    BuildContext context, {
    required dynamic file,
    required String message,
  }) {
    if (!context.mounted) return false;

    if (file == null) {
      _showInfo(context, message);
      return false;
    }
    return true;
  }

  // IFSC VALIDATION

  static bool isIfscValid(BuildContext context, String ifsc) {
    if (!context.mounted) return false;

    final trimmed = ifsc.trim().toUpperCase();

    if (trimmed.length != 11) {
      _showError(context, "Please enter a valid 11-digit IFSC code");
      return false;
    }

    final ifscRegex = RegExp(r'^[A-Z]{4}0[0-9]{6}$');
    if (!ifscRegex.hasMatch(trimmed)) {
      _showError(context, "Invalid IFSC format (Expected: ABCD0XXXXXX)");
      return false;
    }

    return true;
  }

  // ACCOUNT NUMBER LENGTH

  static bool isAccountNumberValid(BuildContext context, String accNo) {
    if (!context.mounted) return false;

    final trimmed = accNo.trim();

    if (trimmed.length < 9 || trimmed.length > 18) {
      _showError(context, "Account number must be 9–18 digits");
      return false;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      _showError(context, "Account number should contain digits only");
      return false;
    }

    return true;
  }

  // ACCOUNT NUMBER MATCH

  static bool isAccountMatch(
      BuildContext context, String acc, String confirmAcc) {
    if (!context.mounted) return false;

    if (acc.trim() != confirmAcc.trim()) {
      _showError(context, "Account number does not match");
      return false;
    }
    return true;
  }

  static bool isAlphabetOnly(
    BuildContext context, {
    required String value,
    required String fieldName,
  }) {
    if (!context.mounted) return false;

    final trimmed = value.trim();

    // Allows letters and spaces only
    final regex = RegExp(r'^[a-zA-Z ]+$');

    if (!regex.hasMatch(trimmed)) {
      _showError(context, "$fieldName should contain alphabets only");
      return false;
    }
    return true;
  }
}
