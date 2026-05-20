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

  /// Validates that [password] meets the strong-password policy:
  ///   • At least [minLength] characters (default 8)
  ///   • Contains at least one uppercase letter
  ///   • Contains at least one lowercase letter
  ///   • Contains at least one digit
  ///   • Contains at least one special character
  ///
  /// Shows a SnackBar error and returns `false` if the policy is violated.
  static bool isStrongPassword(
    BuildContext context,
    String password, {
    int minLength = 8,
  }) {
    if (!context.mounted) return false;

    final value = password.trim();
    if (value.length < minLength) {
      _showError(
        context,
        "Password must be at least $minLength characters and include an uppercase letter, a lowercase letter, a number, and a special character",
      );
      return false;
    }

    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(value);

    if (!hasUpper || !hasLower || !hasDigit || !hasSpecial) {
      _showError(
        context,
        "Password must include an uppercase letter, a lowercase letter, a number, and a special character",
      );
      return false;
    }
    return true;
  }

  static bool isChangePasswordMatch(
      BuildContext context, String password, String confirmPassword) {
    if (!context.mounted) return false;

    if (password != confirmPassword) {
      _showError(context,
          "New password and confirm new password fields must be equal");
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

  /// Validates an optional social-account field that can hold either a
  /// full URL (http/https/www prefix) or a plain username string.
  ///
  /// Returns `true` immediately if [value] is empty (field is optional).
  /// For URL values, checks that the URI is structurally valid.
  /// For plain usernames, checks length constraints ([usernameMinLength]–[usernameMaxLength])
  /// and that only allowed characters are present.
  ///
  /// Shows a SnackBar error and returns `false` on any violation.
  static bool isOptionalSocialValueValid(
    BuildContext context, {
    required String value,
    required String fieldName,
    int usernameMinLength = 2,
    int usernameMaxLength = 50,
  }) {
    if (!context.mounted) return false;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;

    final bool isUrl = trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('www.');
    if (isUrl) {
      final normalized =
          trimmed.startsWith('www.') ? 'https://$trimmed' : trimmed;
      final uri = Uri.tryParse(normalized);
      final valid = uri != null &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
      if (!valid) {
        _showError(context, "Please enter a valid $fieldName link");
        return false;
      }
      return true;
    }

    final username = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    if (username.length < usernameMinLength ||
        username.length > usernameMaxLength) {
      _showError(
        context,
        "$fieldName username must be $usernameMinLength-$usernameMaxLength characters",
      );
      return false;
    }
    final usernameRegex = RegExp(r'^[A-Za-z0-9._-]+$');
    if (!usernameRegex.hasMatch(username)) {
      _showError(context, "Please enter a valid $fieldName username or URL");
      return false;
    }
    return true;
  }
}
