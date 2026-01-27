import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'app_color.dart';
final GlobalKey<MyAppFooterState> footerKey = GlobalKey<MyAppFooterState>();

int language = 0;

class AppConstant {
  static const String token ="";
  static  int selectFooterIndex = 0;
   static const int describeLength = 500;
  static String mapkey = '';
  static String deviceType = Platform.operatingSystem;
  static const int appStatus = 0;
  // static var deviceType = Platform.isAndroid ? 'android' : 'ios';

   //! Input Formatter
  static List<TextInputFormatter> onlyDigitFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')) // only digits allowed
  ];
  static List<TextInputFormatter> alphaNumericFormatter = [
    FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9]')) // alphanumeric allowed
  ];
  static List<TextInputFormatter> alphabetAndSpaceFormatter = [
    FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z ]') // alphabet and space allowed
        )
  ];
  static final List<TextInputFormatter> alphabetFormatter = [
    FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z]')), // Only letters, no spaces
  ];

  static List<TextInputFormatter> allAllowFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'.*')) // alphabet allowed
  ];

  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );
  static final RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static const TextStyle textFilledStyle = TextStyle(
      color: AppColor.textfilledColor,
      fontWeight: FontWeight.w400,
      fontFamily: AppFont.fontFamily,
      fontSize: 14);
       static const TextStyle textFilledStyle1 = TextStyle(
      color: AppColor.secondryColor,
      fontWeight: FontWeight.w400,
      fontFamily: AppFont.fontFamily,
      fontSize: 14);
  // Defination of max length
  static const int emailMaxLength = 50;
  static const int passwordMaxLength = 16;
  static const int fullNameText = 50;
  static const int mobileMaxLenth = 15;
  static const int messageMaxLenth = 250;

  static const TextStyle textFilledHeading =
      TextStyle(color: AppColor.textfilledColor, fontSize: 15, fontWeight: FontWeight.w400);
  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.light,
  );
}

class SuccessClass {
  final String title;
  final String message;

  SuccessClass({required this.title, required this.message});
}

enum BottomMenus { notification, home, profile }

