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
import 'edit_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = './LoginScreen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

TextEditingController passwordController = TextEditingController();
TextEditingController emailController = TextEditingController();

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after build
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
    final size = MediaQuery.of(context).size;

  
    return  AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          child: Stack(
            children: [
              // Background image (static, no animation)
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImage.signupScreen),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
      
              // Animated bottom sheet sliding up from bottom
              SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColor.backgroundGradientcolor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(46),
                          topRight: Radius.circular(46),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 3 / 100,
                          ),
                          Image.asset(
                            AppImage.dashIcon,
                            height: size.height * 0.8 / 100,
                            width: size.width * 15 / 100,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              AppLanguage.loginText[language],
                              style: const TextStyle(
                                  color: AppColor.secondryColor,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 6 / 100,
                          ),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 85 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                              child: CustomTextFieldInput(
                                hintText: AppLanguage
                                    .usernameAndemailIdPhonenumberText[language],
                                maxLength: AppConstant.mobileMaxLenth,
                                keyboardType: TextInputType.name,
                                controller: emailController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 3 / 100,
                          ),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 85 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                              child: CustomTextFieldInput(
                                hintText: AppLanguage.enterpassword[language],
                                maxLength: AppConstant.mobileMaxLenth,
                                keyboardType: TextInputType.name,
                                controller: passwordController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 3 / 100,
                          ),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImage.google,
                                  width: MediaQuery.of(context).size.width *
                                      14 /
                                      100,
                                  height: MediaQuery.of(context).size.width *
                                      14 /
                                      100,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 2 / 100,
                                ),
                                if (AppConstant.deviceType == "ios")
                                  Image.asset(
                                    AppImage.apple,
                                    width: MediaQuery.of(context).size.width *
                                        15 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        15 /
                                        100,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: ForgotPassword(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 70 / 100,
                              child: Text(
                                AppLanguage.forgotpasswordText[language],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          AppButton(
                              text: AppLanguage.continueText[language],
                              onPress: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeftWithFade,
                                    child: ForgotOtpverify(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              }),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 4 / 100,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            // height: MediaQuery.of(context).size.height * 3.5 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLanguage.venueEventText[language],
                                  style: const TextStyle(
                                      color: AppColor.secondryColor,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 12),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 1 / 100,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   PageTransition(
                                    //     type: PageTransitionType.rightToLeftWithFade,
                                    //     child: LoginScreen(),
                                    //     duration: const Duration(milliseconds: 500),
                                    //   ),
                                    // );
                                  },
                                  child: Text(
                                    AppLanguage.clickhereText[language],
                                    style: const TextStyle(
                                        color: AppColor.buttonColor,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 1 / 100,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            // height: MediaQuery.of(context).size.height * 3.5 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "New to the app ?",
                                  style: const TextStyle(
                                      color: AppColor.secondryColor,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 12),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 1 / 100,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: SignUp(),
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLanguage.signupText[language],
                                    style: const TextStyle(
                                        color: AppColor.buttonColor,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 3 / 100,
                          ),
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 80 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Horizontally center
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Vertically center
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center inside column
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 1.0),
                                        child: Text(
                                          AppLanguage
                                              .bySigningupStatementText[language],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: AppColor.secondryColor,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.3 /
                                                100,
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10.0),
                                            child: Text(
                                              AppLanguage
                                                      .userAgreementStatementText[
                                                  language],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: AppColor.secondryColor,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                2 /
                                                100,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
