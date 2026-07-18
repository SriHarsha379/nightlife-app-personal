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

  /// Optional Material icon displayed to the left of [text].
  /// Use this for semantic action buttons (e.g. Icons.check for YES/ACCEPT,
  /// Icons.close for NO/REJECT) to improve visual clarity.
  final IconData? leadingIcon;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPress,
    this.backgroundColor,
    this.leadingIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 80 / 100,
        // Fixed height (not a % of screen height) so the button looks the
        // same size on a small phone (iPhone SE) and a large one (Pro Max) —
        // button size should track finger/text size, not screen height.
        height: 54,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColor.buttonColor,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: AppFont.fontFamily,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
