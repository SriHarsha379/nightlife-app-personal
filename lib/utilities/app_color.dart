import 'package:flutter/material.dart';

class AppColor {
  // ============================================================================
  // THEME-AWARE COLORS - These change based on dark/light mode
  // ============================================================================

  static Color primaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : const Color(0xFFF5F5F5);
  }

  static Color otpboxColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Color.fromARGB(255, 216, 214, 214);
  }

  /// Get secondary color (text color) based on theme
  static Color secondryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  /// Get notification container color based on theme
  static Color notificationContainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff171217)
        : Colors.white;
  }

  /// Get notification text color based on theme
  static Color notificationtextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffB09CBA)
        : const Color(0xff666666);
  }

  /// Get text field filled color based on theme
  static Color textfieldfilledColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff0f0616)
        : const Color(0xFFF8F9FA);
  }

  /// Get hint text color based on theme
  static Color hinttextcolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffb8b7bd)
        : const Color(0xff999999);
  }

  static Color whiteBlackcolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }

  /// Get background gradient based on theme
  static LinearGradient backgroundGradientcolor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 71, 38, 87),
          Color(0xFF000000),
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFffffff),
          Color(0xFFffffff),
        ],
      );
    }
  }

  static LinearGradient welcomebackgroundGradientcolor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 71, 38, 87),
          Color(0xFF000000),
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 71, 38, 87),
          Color(0xFF000000),
        ],
      );
    }
  }

  /// Get profile settings row color based on theme
  static Color profilesettignrowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff200920)
        : const Color(0xFFE8E8E8);
  }

  /// Get toggle color based on theme
  static Color toggleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF332938)
        : const Color(0xFFCCCCCC);
  }

  /// Get dropdown color based on theme
  static Color dropdownColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF52395f)
        : const Color(0xFFE0E0E0);
  }

  /// Get container color based on theme
  static Color cotainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffE8E9EA)
        : const Color(0xFF333333);
  }

  /// Get popup color based on theme
  static Color popupColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF2a1434)
        : Colors.white;
  }

  /// Get book event container color based on theme
  static Color bookeventcontainercolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 42, 26, 56)
        : const Color(0xFFF0F0F0);
  }

  /// Get text field container color based on theme
  static Color textfieldcontainercolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff1a1919)
        : const Color(0xFFF5F5F5);
  }

  /// Get refer container color based on theme
  static Color refercontainercolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff171217)
        : Colors.white;
  }

  /// Get send invite container color based on theme
  static Color sendinvitecontainercolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff1c1218)
        : const Color(0xFFF8F8F8);
  }

  /// Get chat support color based on theme
  static Color chatSupportcolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff9CA3AF)
        : const Color(0xff666666);
  }

  /// Get span color based on theme
  static Color spancolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff716A74)
        : const Color(0xff999999);
  }

  /// Get filled color based on theme
  static Color filledcolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff36214A)
        : const Color(0xFFE8E8E8);
  }

  /// Get filled text color based on theme
  static Color filledText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffAD8FCC)
        : const Color(0xff666666);
  }

  /// Get list text color based on theme
  static Color listTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffAD91C9)
        : const Color(0xff555555);
  }

  /// Get text tap color based on theme
  static Color textTapColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffA49DA7)
        : const Color(0xff777777);
  }

  /// Get past time color based on theme
  static Color pasttimecolor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffb8b8b8)
        : const Color(0xff999999);
  }

  /// Get light grey color based on theme
  static Color lightGreyColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xffBDB6B6)
        : const Color(0xff888888);
  }

  /// Get my perfect container color based on theme
  static Color myperfectcontainercolr(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color.fromARGB(255, 71, 39, 100)
        : const Color(0xFFE0E0E0);
  }

  /// Get logout container color based on theme
  static Color logoutContainerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff41274c)
        : const Color(0xFFE8E8E8);
  }

  /// Get capsule color based on theme
  static Color capsuleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff22161e)
        : const Color(0xFFF0F0F0);
  }

  /// Get dark purple color based on theme
  static Color darlpurpalColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff09040D)
        : const Color(0xFFF8F8F8);
  }

  /// Get purple color based on theme
  static Color purpleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff4b3058)
        : const Color(0xFFD0D0D0);
  }

  static Color textFieldColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xff341941)
        : const Color(0xFFffffff);
  }

  /// Get chat container gradient based on theme
  static LinearGradient chatContainerColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const LinearGradient(
        colors: [Color(0xff734E84), Color(0xff341941)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return const LinearGradient(
        colors: [Color(0xFFE8E8E8), Color(0xFFD0D0D0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  /// Get welcome front card gradient based on theme
  static LinearGradient welcomefrontCardcolor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const LinearGradient(
        colors: [
          Color(0xFF5B308D),
          Color(0xFF331F53),
          Color(0xFF1E1030),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      return const LinearGradient(
        colors: [
          Color(0xFF5B308D),
          Color(0xFF331F53),
          Color(0xFF1E1030),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    }
  }

  // ============================================================================
  // STATIC COLORS - These remain the same in both themes
  // ============================================================================

  static const Color transparentColor = Colors.transparent;
  static const Color pinkColor = Color(0xffFF1CC0);
  static const Color redColor = Color(0xffFF3819);
  static const Color greenColor = Color(0xff38C976);
  static const Color greenColor1 = Color(0xff0aa161);
  static const Color buttonColor = Color(0xffFF1CC0);
  static const Color buttonColor1 = Color(0xffed1fb6);
  static const Color shadowcolor = Color(0xffFF1C38);
  static const Color darkPurpleColor = Color(0xffB131FA);
  static const Color emojibackgroundColor = Color(0xff927dfe);
  static const Color appHeadTextColor = Color.fromRGBO(218, 72, 158, 1);
  static const Color appButtonColor = Color.fromRGBO(255, 28, 192, 1);
  static const Color hintPlaceHolderText = Color.fromRGBO(173, 143, 204, 1);
  static const Color eventSmallCardBorder = Color.fromRGBO(177, 49, 250, 1);
  static const Color cardFillColor = Color.fromRGBO(177, 49, 250, 0.5);
  static const Color darkGreyColor = Color.fromRGBO(51, 51, 51, 1);

  // Old static colors (kept for backward compatibility)
  static const Color themeColorlight = Color.fromARGB(255, 255, 235, 223);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color homeOfferColor = Color(0xfffef1e8);
  static const Color textfieldfillColor = Color(0xffE5E7EB);
  static const Color textfieldborderColor = Color.fromARGB(255, 189, 190, 191);
  static const Color greyLightColor = Color(0xffa7a7a7);
  static const Color greygreyLightColor = Color.fromARGB(255, 239, 240, 241);
  static const Color textfilledColor = Color(0xff888686);
  static const Color thirdColor = Colors.red;
  static const Color fourthColor = Colors.lightBlue;
  static const Color fifthColor = Colors.green;
  static const Color sixthColor = Colors.amber;
  static const Color lightwhite = Color.fromARGB(255, 250, 249, 249);
  static Color blurColor =
      const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.3);
  static const Color grayColor = Color(0xff212529);
  static const Color successColor = Color(0xff4CAF50);
  static const Color earningContainercolor = Color(0xffFFF3EB);
  static const Color washpressColor = Color(0xff262626);
  static const Color textcolor = Color(0xff6D6868);
  static const Color bottomsheettextcolor = Color(0xff383838);
  static const Color buttonPrimaryColor = Color(0xffF5751B);
  static const Color buttonSecondaryColor = Color(0xffEFEFEF);
  static const Color buttonTextColor = Color(0xff404040);
  static const Color bankdetailColor = Color(0xfffef8f3);
  static const Color lightgreyColor = Color(0xff495057);
  static const Color addAnotherdetailContainercolor = Color(0xffF4F7FB);
  static const Color notificationHintTextColor = Color(0xff858E96);
  static const Color notificationHaderTextColor = Color(0xff212529);
  static const Color timeFieldHintTextColor = Color(0xff575A57);
  static const Color blueTextColor = Color(0xff2AB0FC);
  static const Color lightfeildtextColor = Color(0xff616161);
  static const Color bottumcolorColor = Color(0xffE9E8E8);
  static const Color textFieldBackgroundColor = Color(0xFFF8F9FA);
  static const Color UpcomeingBookingboxColor = Color(0xFF00000033);
  static const Color backgroundColor = Color(0xFF400164);
  static const Color startingscreenColor = Color(0xFF3d0060);
  static const Color nextButtoncolor = Color(0xFF2c0f39);
  static const Color topColor = Color(0xFF4A1D59);
  static const Color bottomColor = Color(0xFF1A1A1A);
  static const Color purpleScreenColor = Color(0xff4A007A);
  static const Color greyContainer = Color(0xffD4D6D9);
  static const Color statusbar = Color(0xFF472657);
  static const Color borderColor = Color(0xff4A0074);
  static const Color backgrondsplashColor = Color(0xff420d8a);
  static const Color richBlackColor = Color(0xff000009);
  static const Color culturedColor = Color(0xffF5F5F5);
  static const Color darkBackgroundColor = Color(0xFF121212);

  // Static gradients
  static const Gradient backgroundGradient = LinearGradient(
    colors: [topColor, bottomColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color themeColor1 = Color(0xff000000);
  static const LinearGradient backgroundGradient1 = LinearGradient(
    colors: [Color(0xff341941), themeColor1],
    begin: Alignment.topCenter,
    end: Alignment.bottomRight,
  );

  static const Color themeColor = Color(0xff341941);
  static const Color color = Color(0xffD768AE);
  static const Color color1 = Color(0xff2D17C1);

  static const Gradient profileContainercolor = LinearGradient(
    colors: [color, color1],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color chatColor = Color(0xff734E84);
  static const Color chatcolor1 = Color(0xff341941);

  static const LinearGradient backgroundGradientcolor1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3D1F47),
      Color(0xFF1A0F1F),
      Color(0xFF000000),
    ],
    stops: [0.0, 0.3, 1.0],
  );

  static const LinearGradient welcomefrontCardcolor1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x66D768AE),
      Color(0x662D17C1),
    ],
  );

  static LinearGradient welcomefrontCardcolor2 = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x66D769AE),
      Color(0x662D17C1),
    ],
  );
}
