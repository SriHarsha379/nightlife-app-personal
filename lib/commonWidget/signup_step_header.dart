import 'package:flutter/material.dart';

import '../utilities/app_color.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../utilities/app_language.dart';

/// Header for the optional signup steps (Additional info, Vibe Check,
/// Stay connected): back arrow, centred title and - per the client -
/// "Skip for now" in the TOP-RIGHT corner. Pass onSkip: null to hide Skip.
class SignupStepHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onSkip;

  const SignupStepHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SizedBox(
      width: w * 0.9,
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: SizedBox(
              width: w * 0.08,
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  AppImage.backArrowIcon,
                  width: w * 0.04,
                  color: AppColor.secondryColor(context),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: AppFont.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.secondryColor(context),
                  ),
                ),
              ),
            ),
          ),
          if (onSkip != null)
            SignupSkipButton(onTap: onSkip!)
          else
            SizedBox(width: w * 0.08),
        ],
      ),
    );
  }
}

/// Compact pink "Skip for now" pill for the header's top-right corner.
class SignupSkipButton extends StatelessWidget {
  final VoidCallback onTap;
  const SignupSkipButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.32),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColor.pinkColor, width: 1.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppLanguage.skip[language],
            maxLines: 1,
            style: TextStyle(
              fontFamily: AppFont.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColor.pinkColor,
            ),
          ),
        ),
      ),
    );
  }
}
