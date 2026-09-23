import 'package:flutter/material.dart';

import '../utilities/app_color.dart';
import '../utilities/app_font.dart';

/// A small, low-key hint shown under a field or action during signup —
/// e.g. "Pick up to 5, you can change these later." Client's ask: help
/// first-time users move through signup faster by explaining what an
/// action does or why it matters, right where they need it, instead of a
/// separate tutorial/tour that would slow signup down.
///
/// Deliberately plain: a small info glyph + one line of muted text. Never
/// blocks or requires dismissal — it's a footnote, not a popup.
class OnboardingFootnote extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const OnboardingFootnote({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.only(top: 6, bottom: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 13,
            color: AppColor.hinttextcolor(context),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFont.fontFamily,
                fontSize: 11.5,
                height: 1.3,
                color: AppColor.hinttextcolor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}