import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_font.dart';

class SnackBarToastMessage {
  SnackBarToastMessage._();
  static showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColor.culturedColor,
        duration: const Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColor.richBlackColor,
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}