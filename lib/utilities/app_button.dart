import 'package:flutter/material.dart';
import 'package:night_life/utilities/app_font.dart';
import '../utilities/app_color.dart';

/// Primary action button used throughout the app.
///
/// Optionally accepts a [leadingIcon] so that contextual action buttons
/// (e.g. YES / NO / ACCEPT / REJECT) can carry a recognisable icon that
/// makes the intent immediately clear at a glance.
class AppButton extends StatelessWidget {
  final String text;
  final Function onPress;
  final Color? backgroundColor;
  final IconData? leadingIcon;
  final double height;
  final double widthPercent;
  final double fontSize;
  final FontWeight fontWeight;
  final bool outlined;
  final bool isLoading;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPress,
    this.backgroundColor,
    this.leadingIcon,
    this.height = 54,
    this.widthPercent = 80,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.outlined = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => onPress(),
      child: Container(
        width: MediaQuery.of(context).size.width * widthPercent / 100,
        height: height,
        decoration: BoxDecoration(
          color: outlined
              ? Colors.transparent
              : (backgroundColor ?? AppColor.buttonColor),
          border: outlined
              ? Border.all(color: AppColor.pinkColor, width: 1.8)
              : null,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leadingIcon != null) ...[
                    Icon(
                      leadingIcon,
                      color: outlined ? AppColor.pinkColor : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: outlined ? AppColor.pinkColor : Colors.white,
                      fontWeight: fontWeight,
                      fontFamily: AppFont.fontFamily,
                      fontSize: fontSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
