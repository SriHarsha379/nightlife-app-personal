import 'package:flutter/material.dart';
import 'package:night_life/animation/purple_screen.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/view/bottom%20navigation/home_Screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class StayConnectedOTPVerify extends StatefulWidget {
  static String routeName = './StayConnectedOTPVerify';
  const StayConnectedOTPVerify({super.key, this.isEmail = false});

  final bool isEmail;

  @override
  State<StayConnectedOTPVerify> createState() => _StayConnectedOTPVerifyState();
}

class _StayConnectedOTPVerifyState extends State<StayConnectedOTPVerify> {
  TextEditingController pinputInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  void previousField(String value, FocusNode focusNode) {
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondryColor,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration:
              const BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 6 / 100,
              ),

              //! App Header
              SizedBox(
                width: MediaQuery.of(context).size.width * 90 / 100,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 5 / 100,
                        height: MediaQuery.of(context).size.width * 5 / 100,
                        child: Image.asset(
                          AppImage.backarrow,
                          color: AppColor.secondryColor,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 2 / 100,
                    ),
                    Text(
                      AppLanguage.otpVerificationText[language],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColor.secondryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFont.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 10 / 100,
              ),

              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 80 / 100,
                        child: Text(
                          AppLanguage.enter4digitText[language],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 48 / 100,
                        child: Row(
                          children: [
                            Text(
                              widget.isEmail
                                  ? AppLanguage.xyzgmailText[language]
                                  : AppLanguage.mobilenoText[language],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
                            ),
                            // GestureDetector(
                            //   onTap: () {
                            //     Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //             builder: (context) => SignUp()));
                            //   },
                            //   child: Row(
                            //     children: [
                            //         Text(
                            //         AppLanguage.editText[language],
                            //         textAlign: TextAlign.center,
                            //         style: const TextStyle(
                            //           color: AppColor.secondryColor,
                            //           fontSize: 11,
                            //           fontFamily: AppFont.fontFamily,
                            //            decoration: TextDecoration.underline,
                            //            decorationColor: AppColor.secondryColor,
                            //             decorationThickness: 0.8,
                            //             height: 2.8,
                            //         ),
                            //       ),
                            //       SizedBox(
                            //         width: MediaQuery.of(context).size.width *
                            //             1 /
                            //             100,
                            //       ),
                            //       Image.asset(
                            //         AppImage.pencilIcon,
                            //         height: size.height * 2 / 100,
                            //         width: size.width * 2 / 100,
                            //         color: AppColor.secondryColor,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 7 / 100,
                      ),
                      Pinput(
                        length: 4,
                        controller: pinputInputController,
                        defaultPinTheme: PinTheme(
                          width: MediaQuery.of(context).size.width * 15.8 / 100,
                          height: MediaQuery.of(context).size.width * 14 / 100,
                          textStyle: const TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColor.primaryColor,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.secondryColor,
                            border: Border.all(
                              color: AppColor.secondryColor,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  // offset: const Offset(0, 4),
                                  blurRadius: 0,
                                  color:
                                      AppColor.primaryColor.withOpacity(0.25))
                            ],
                            borderRadius: BorderRadius.circular(13),
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 1 / 100),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 80 / 100,
                        height: MediaQuery.of(context).size.height * 4.5 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLanguage.didntOtpText[language],
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
                            ),
                            Text(
                              AppLanguage.requestAgaintext[language],
                              style: const TextStyle(
                                  color: AppColor.secondryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 39 / 100,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100,
                      ),
                      AppButton(
                          text: AppLanguage.verifyButtonText[language],
                          onPress: () {
                            AppConstant.selectFooterIndex = 0;
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: const PurpleScreen(
                                  nextScreen: MyAppFooter(
                                    initialIndex: 0,
                                  ),
                                ),
                                duration: const Duration(milliseconds: 600),
                              ),
                            );
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: const Home(),
                                duration: const Duration(milliseconds: 600),
                              ),
                            );
                          }),
                    ],
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
