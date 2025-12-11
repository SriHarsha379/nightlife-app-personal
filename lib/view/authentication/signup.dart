import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/authentication/otp_verify_screen.dart';
import 'package:night_life/view/authentication/refer_code_screen.dart';
import 'package:night_life/view/other/profile_details.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';
import '../other/chats/chat_message_screen.dart';
import 'edit_profile_screen.dart';

class SignUp extends StatefulWidget {
  static String routeName = './SignUp';

  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

TextEditingController mobileNumberTextEditingController =
    TextEditingController();

class _SignUpState extends State<SignUp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      signupBottomSheet(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //     systemNavigationBarColor: AppColor.primaryColor,
    //     systemNavigationBarIconBrightness: Brightness.light,
    //     statusBarColor: AppColor.transparentColor,
    //     statusBarIconBrightness: Brightness.light));
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
         canPop: false,
          onPopInvoked: (didPop) {
  },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    transitionAnimationController:
                    AnimationController(
                      duration: const Duration(milliseconds:1000),
                      vsync: Navigator.of(context),
                    );
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signupBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      shape: const RoundedRectangleBorder(),
      barrierColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: Navigator.of(context),
      ),
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColor.backgroundGradientcolor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(46),
                  topRight: Radius.circular(46),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      AppLanguage.signupText[language],
                      style: const TextStyle(
                          color: AppColor.secondryColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFont.fontFamily,
                          fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 3 / 100,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 85 / 100,
                      height: MediaQuery.of(context).size.height * 6 / 100,
                      child: CustomTextAreaField(
                        hintText: AppLanguage.enterphonenumber[language],
                        keyboardType: TextInputType.number,
                        maxLength: AppConstant.mobileMaxLenth,
                        controller: mobileNumberTextEditingController,
                        prefixText: "+91",
                        readOnly: false,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100),
                  AppButton(
                      text: AppLanguage.continueText[language],
                      onPress: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: ProfileDetailsScreen(),
                            duration: const Duration(milliseconds: 600),
                          ),
                        );
                      }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 4 / 100,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 80 / 100,
                    height: MediaQuery.of(context).size.height * 4.5 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLanguage.alreadyhaveanacoount[language],
                          style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                              fontSize: 12),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1 / 100,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: LoginScreen(),
                                duration:  Duration(milliseconds: 100),
                              ),
                            );
                          },
                          child: Text(
                            AppLanguage.loginText[language],
                            style: const TextStyle(
                                color: AppColor.buttonColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                                fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
    SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),
                   SizedBox(
                    width: MediaQuery.of(context).size.width * 80 / 100,
                    // height: MediaQuery.of(context).size.height * 3.5 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Have an Invite Code ?",
                          style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                              fontSize: 12),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1 / 100,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: UseReferCodeScreen(),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: Text(
                            "Enter Here",
                            style: const TextStyle(
                                color: AppColor.buttonColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                                fontSize: 13),
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
                          AppLanguage.venueEventText[language],
                          style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                              fontSize: 12),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 1 / 100,
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
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
