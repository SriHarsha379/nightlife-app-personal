import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/forgot_otp_password_screen.dart';
import 'package:night_life/view/authentication/forgot_otp_verify_screen.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/authentication/otp_verify_screen.dart';
import 'package:night_life/view/other/profile_details.dart';
import 'package:night_life/view/authentication/signup.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';

class WelcomeScreen4 extends StatefulWidget {
  static String routeName = './LoginScreen';

  const WelcomeScreen4({super.key});

  @override
  State<WelcomeScreen4> createState() => _WelcomeScreen4State();
}

TextEditingController passwordController = TextEditingController();
TextEditingController emailController = TextEditingController();

class _WelcomeScreen4State extends State<WelcomeScreen4>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int _activeIndex = 2;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: w,
          height: h,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImage.signupScreen),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              /// SLIDING BOTTOM CARD
              SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: w,
                    height: h * 0.56,
                    decoration: BoxDecoration(
                      gradient: AppColor.backgroundGradientcolor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: h * 0.09),

                        /// TITLE
                        SizedBox(
                          width: w * 0.70,
                          child: Text(
                            "All in One Place",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: w * 0.085,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.02),

                        /// SUBTITLE
                        SizedBox(
                          width: w * 0.80,
                          child: Text(
                            "Discover the best venues, book your seats with ease, and connect with people who share your vibe—all from one app.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: w * 0.043,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.08),

                        /// BUTTON
                        AppButton(
                          text: AppLanguage.letsgetStartedtext[language],
                          onPress: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: SignUp(),
                                duration: const Duration(milliseconds: 400),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: h * 0.04),
                      ],
                    ),
                  ),
                ),
              ),

              /// DOT INDICATOR
              Positioned(
                bottom: h * 0.07,
                left: w * 0.42,
                child: Row(
                  children: [
                    _dot(_activeIndex == 1),
                    _dot(_activeIndex == 0),
                    _dot(_activeIndex == 0),
                    _dot(_activeIndex == 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 5,
      height: active ? 10 : 5,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFF2CDF)
            : const Color.fromARGB(255, 251, 249, 253),
        shape: BoxShape.circle,
      ),
    );
  }
}
