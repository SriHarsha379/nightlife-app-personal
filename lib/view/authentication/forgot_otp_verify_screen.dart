import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'package:pinput/pinput.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import 'signup.dart';

class ForgotOtpverify extends StatefulWidget {
  static String routeName = './OtpVerify';
  const ForgotOtpverify({super.key});

  @override
  State<ForgotOtpverify> createState() => _ForgotOtpverifyState();
}

class _ForgotOtpverifyState extends State<ForgotOtpverify> {
  final GlobalKey<FormState> _forgotOtpFormKey = GlobalKey<FormState>();

  TextEditingController pinputInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // forgotOtpUserValidation(String pinputInputController) async {
  //   if (pinputInputController.isEmpty) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.otpMessage[language]);
  //     return false;
  //   } else if (pinputInputController.length < 4) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.otpMinLenthMessage[language]);
  //     return false;
  //   } else {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const AppFooter()),
  //     );

  //     // forgotOtpUserApiCall(firstInput, secondInput, thirdInput, fourthInput);
  //   }
  // }

  // forgotOtpUserApiCall(String firstInput, String secondInput, String thirdInput,
  //     String fourthInput) async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const Home()),
  //   );
  //   // Navigator.pushNamed(
  //   //   context,
  //   //   Home.routeName,
  //   //   arguments: SuccessClass(
  //   //     message: "Hello",
  //   //     title: "Hello World",
  //   //   ),
  //   // );

  //   // print("Call Update Api");
  // }

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
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondryColor,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _forgotOtpFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 6 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      // child: Image.asset(
                      //   AppImage.appLogo,
                      //   width: MediaQuery.of(context).size.width * 60 / 100,
                      //   height: MediaQuery.of(context).size.height * 20 / 100,
                      // ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 70 / 100,
                      child: Text(
                        AppLanguage.otpVerificationText[language],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.secondryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ),
    
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
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
                            AppLanguage.mobilenoText[language],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 1 / 100,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()));
                            },
                            child: Row(
                              children: [
                                  Text(
                                  AppLanguage.editText[language],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColor.secondryColor,
                                    fontSize: 11,
                                    fontFamily: AppFont.fontFamily,
                                     decoration: TextDecoration.underline,
                                     decorationColor: AppColor.secondryColor,
                                      decorationThickness: 0.8,
                                      height: 2.8,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      1 /
                                      100,
                                ),
                                Image.asset(
                                  AppImage.pencilIcon,
                                  height: size.height * 2 / 100,
                                  width: size.width * 2 / 100,
                                  color: AppColor.secondryColor,
                                ),
                              ],
                            ),
                          ),
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
                                color: AppColor.primaryColor.withOpacity(0.25))
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
                            width: MediaQuery.of(context).size.width * 1 / 100,
                          ),
                          Text(
                            AppLanguage.requestAgaintext[language],
                            style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14),
                          ),
                          // TextButton(
                          //   child: Text(
                          //     AppLanguage.resendOtp[language],
                          //     style: const TextStyle(
                          //       decoration: TextDecoration.underline,
                          //       fontSize: 13,
                          //       fontFamily: AppFont.fontFamily,
                          //       fontWeight: FontWeight.w500,
                          //       color: AppColor.thirdColor,
                          //     ),
                          //   ),
                          //   onPressed: () async {
                          //     // Navigator.push(
                          //     //   context,
                          //     //   MaterialPageRoute(
                          //     //       builder: (context) => ()),
                          //     // );
                          //   },
                          // )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 39 / 100,
                    ),
                    //  SizedBox(
                    //   width: MediaQuery.of(context).size.width * 80 / 100,
                    //   height: MediaQuery.of(context).size.height * 4.5 / 100,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text(
                    //         AppLanguage.notUsingyourEmail[language],
                    //         style: const TextStyle(
                    //             color: Colors.grey,
                    //             fontWeight: FontWeight.w500,
                    //             fontSize: 12),
                    //       ),
                    //         SizedBox(
                    //   width: MediaQuery.of(context).size.width * 1 / 100,
                    // ),
                    //       Text(
                    //         AppLanguage.skip[language],
                    //         style: const TextStyle(
                    //             color: AppColor.buttonColor,
                    //             fontWeight: FontWeight.w500,
                    //             fontSize: 14),
                    //       ),
    
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),
                    AppButton(
                        text: AppLanguage.verifyButtonText[language],
                        onPress: () {
                           Navigator.push(context,
    
                    PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: MyAppFooter(initialIndex: 0),
                    duration: const Duration(milliseconds: 500),
                  ),);
                          // forgotPasswordUserValidation(
                          //     mobilenumberTextEditingController.text);
                        }),
    
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
