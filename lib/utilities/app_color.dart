import 'package:flutter/material.dart';

class AppColor {
  static const Color themeColorlight =
      Color.fromARGB(255, 255, 235, 223); // kalash

  static const Color transparentColor = Colors.transparent; // kalash
  static const Color darkTextColor = Color(0xFFFFFFFF);

  static const Color homeOfferColor = Color(0xfffef1e8); // kalash
  static const Color primaryColor = Colors.black;
  static const Color textfieldfillColor = Color(0xffE5E7EB); // kalash
  static const Color textfieldborderColor =
      Color.fromARGB(255, 189, 190, 191); // kalash

  static const Color greyLightColor = Color(0xffa7a7a7);
  static const Color greygreyLightColor =
      Color.fromARGB(255, 239, 240, 241); // kalash
  static const Color textfilledColor = Color(0xff888686);
  static const Color secondryColor = Colors.white;
  static const Color thirdColor = Colors.red; // kalash
  static const Color fourthColor = Colors.lightBlue; // kalash
  static const Color fifthColor = Colors.green; // kalash
  static const Color sixthColor = Colors.amber; // kalash

  static const Color lightwhite =
      const Color.fromARGB(255, 250, 249, 249); // kalash

  static Color blurColor =
      const Color.fromRGBO(255, 255, 255, 1).withOpacity(0.3);
  static const Color grayColor = Color(0xff212529);
  //parinay
  static const Color successColor = Color(0xff4CAF50); //Raj
  static const Color earningContainercolor = Color(0xffFFF3EB); //Raj
  static const Color washpressColor = Color(0xff262626); //
  static const Color textcolor = Color(0xff6D6868); //
  static const Color bottomsheettextcolor = Color(0xff383838);

  //pritam --01-10-2025
  static const Color buttonPrimaryColor = Color(0xffF5751B);
  static const Color buttonSecondaryColor = Color(0xffEFEFEF);
  static const Color buttonTextColor = Color(0xff404040);

  //pritam --02-10-2025
  static const Color redColor = Color(0xffFF3819);
  static const Color greenColor = Color(0xff38C976);
  //parinay ----06/10
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
//Parinay 07/10
  static const Color backgroundColor = Color(0xFF400164);

  static const Color startingscreenColor = Color(0xFF3d0060);
  static const Color nextButtoncolor = Color(0xFF2c0f39);

  static const Color topColor = Color(0xFF4A1D59);
  static const Color bottomColor = Color(0xFF1A1A1A);
  static const Gradient backgroundGradient = LinearGradient(
    colors: [topColor, bottomColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  //  FF1CC0
  static const Color pinkColor = Color(0xffFF1CC0); // kalash

  static const Color themeColor1 = Color(0xff000000);
  static const Gradient backgroundGradient1 = LinearGradient(
      colors: [themeColor, themeColor1],
      begin: Alignment.topCenter,
      end: Alignment.bottomRight);
  static const Color themeColor = Color(0xff341941);
  static const Color filledcolor = Color(0xff36214A);

  static const Color color = Color(0xffD768AE);
  static const Color color1 = Color(0xff2D17C1);
  static const Gradient profileContainercolor = LinearGradient(
      colors: [color, color1],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
  static const Color buttonColor = Color(0xffFF1CC0);
  static const Color buttonColor1 = Color(0xffed1fb6);

  static const Color shadowcolor = Color(0xffFF1C38);
  static const Color greyContainer = Color(0xffD4D6D9);
  static const Color purpleColor = Color(0xff4b3058);

  static const Gradient chatContainerColor = LinearGradient(
      colors: [chatColor, chatcolor1],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
  static const Color chatColor = Color(0xff734E84);
  static const Color chatcolor1 = Color(0xff341941);

  static const Color statusbar = Color(0xff331940);
  static const Color cotainerColor = Color(0xffE8E9EA);
  static const Color notificationContainerColor = Color(0xff171217);
  static const Color notificationtextColor = Color(0xffB09CBA);

  //01-11
  static const Color filledText = Color(0xffAD8FCC);
  static const Color borderColor = Color(0xff4A0074);
  static const Color lightGreyColor = Color(0xffBDB6B6);

  static const Color backgrondsplashColor = Color(0xff420d8a);

  //Pritam 31/10/2025
  static const Color listTextColor = Color(0xffAD91C9);
  static const Color darkPurpleColor = Color(0xffB131FA);

//shreeraj 31/10/2025
  static const Color textTapColor = Color(0xffA49DA7);
//Pritam 1/10/2025

  // static const Color filledcolor = Color(0xff36214A);

  static const Color darlpurpalColor = Color(0xff09040D);

//10/11
  static const Color richBlackColor = Color(0xff000009);
  static const Color culturedColor = Color(0xffF5F5F5);
  static const Color capsuleColor = Color(0xff22161e);
  static const Color logoutContainerColor = Color(0xff41274c);

  static const LinearGradient backgroundGradientcolor = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color.fromARGB(255, 71, 38, 87),
      const Color(0xFF000000),
    ],
  );

// static const LinearGradient backgroundGradientcolor = LinearGradient(
//   begin: Alignment.topCenter,
//   end: Alignment.bottomCenter,
//   colors: [
//     Color(0xFF46215F),
//     Color(0xFF281333),
//     Color(0xFF070109),
//   ],
//   stops: [0.0, 0.55, 1.0],
// );

  static const LinearGradient backgroundGradientcolor1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3D1F47), // Deep purple at top
      Color(0xFF1A0F1F), // Mid purple-black
      Color(0xFF000000), // Pure black at bottom
    ],
    stops: [0.0, 0.3, 1.0], // Control the transition points
  );
  static const Color profilesettignrowColor = Color(0xff200920);
  static const Color darkBackgroundColor = Color(0xFF121212);

  static const Color popupColor = Color(0xFF2a1434);
  static const Color toggleColor = Color(0xFF332938);
  static const Color dropdownColor = Color(0xFF52395f);

  static const Gradient welcomefrontCardcolor = LinearGradient(
    colors: [
      Color(0xFF5B308D), // Upper Muted Purple
      Color(0xFF331F53), // Middle Deep Violet
      Color(0xFF1E1030), // Lower Darkest Purple (near black)
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient welcomefrontCardcolor1 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x66D768AE),
      Color(0x662D17C1),
    ],
    // stops: [0.0, 0.40, 1.0],
  );
  static Gradient welcomefrontCardcolor2 = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x66D769AE),
      Color(0x662D17C1),
    ],
  );
  static const Color greenColor1 = Color(0xff0aa161);
  static const Color textfieldfilledColor = Color(0xff0f0616);
  static const Color hinttextcolor = Color(0xffb8b7bd);

  static const Color bookeventcontainercolor = Color.fromARGB(255, 42, 26, 56);
  static const Color emojibackgroundColor = Color(0xff927dfe);
  static const Color textfieldcontainercolor = Color(0xff1a1919);
  static const Color pasttimecolor = Color(0xffb8b8b8);
  static const Color myperfectcontainercolr = Color.fromARGB(255, 71, 39, 100);

  static const Color refercontainercolor = Color(0xff171217);

    static const Color sendinvitecontainercolor = Color(0xff1c1218);

}
