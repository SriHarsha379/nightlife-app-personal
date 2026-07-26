import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'app_color.dart';

final GlobalKey<MyAppFooterState> footerKey = GlobalKey<MyAppFooterState>();
final ValueNotifier<bool> footerVisibilityNotifier = ValueNotifier<bool>(true);

int language = 0;

class AppConstant {

  static String token = "";
  static String playerID = "123456";

  static int selectFooterIndex = 0;
  static const int describeLength = 500;
  static String mapkey = '';
  static String deviceType = Platform.operatingSystem;
  static const int appStatus = 0;
  // static var deviceType = Platform.isAndroid ? 'android' : 'ios';

  //! Preset hobby options shown as selectable chips on the signup and
  //! edit-hobbies screens. Kept here (one place) so both screens always
  //! offer the same choices - it's a plain data list, not tied to any
  //! backend schema.
  static const List<Map<String, String>> hobbyOptions = [
    {'emoji': '🎮', 'label': 'Gaming'},
    {'emoji': '💃', 'label': 'Dancing'},
    {'emoji': '🎵', 'label': 'Music'},
    {'emoji': '🎬', 'label': 'Movies'},
    {'emoji': '📸', 'label': 'Photography'},
    {'emoji': '✈️', 'label': 'Travel'},
    {'emoji': '👗', 'label': 'Fashion'},
    {'emoji': '📚', 'label': 'Reading'},
    {'emoji': '✍️', 'label': 'Writing'},
    {'emoji': '🌿', 'label': 'Nature'},
    {'emoji': '🎨', 'label': 'Painting'},
    {'emoji': '⚽', 'label': 'Football'},
    {'emoji': '🏋️', 'label': 'Fitness'},
    {'emoji': '🍳', 'label': 'Cooking'},
    {'emoji': '🧘', 'label': 'Yoga'},
    {'emoji': '🐾', 'label': 'Pets'},
    {'emoji': '🚗', 'label': 'Cars'},
    {'emoji': '🍸', 'label': 'Mixology'},
    {'emoji': '🎧', 'label': 'DJing'},
    {'emoji': '🏖️', 'label': 'Beach'},
  ];
  static const int maxHobbies = 5;

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
        RegExp(r'.*')), // Allow all characters including numbers and special chars
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

  static TextStyle textFilledStyle(BuildContext context) {
    return TextStyle(
      color: AppColor.hinttextcolor(context),
      fontWeight: FontWeight.w400,
      fontFamily: AppFont.fontFamily,
      fontSize: 14,
    );
  }

  static TextStyle textFilledStyle1(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontFamily: AppFont.fontFamily,
      fontWeight: FontWeight.w400,
    );
  }

  // Defination of max length
  static const int emailMaxLength = 50;
  static const int passwordMaxLength = 16;
  static const int fullNameText = 50;
  static const int mobileMaxLenth = 10;
  static const int messageMaxLenth = 250;

  static const TextStyle textFilledHeading = TextStyle(
      color: AppColor.textfilledColor,
      fontSize: 15,
      fontWeight: FontWeight.w400);
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