import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/view/authentication/forgot_otp_verify_screen.dart';

import 'package:pinput/pinput.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../utilities/widgets.dart';

class VerifyPasswordScreen extends StatefulWidget {
  static String routeName = './VerifyPasswordScreen';
  const VerifyPasswordScreen({super.key});

  @override
  State<VerifyPasswordScreen> createState() => _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends State<VerifyPasswordScreen> {
  final GlobalKey<FormState> _forgotOtpFormKey = GlobalKey<FormState>();

  TextEditingController pinputInputController = TextEditingController();
  TextEditingController mobileNumberTextEditingController = TextEditingController();
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondryColor,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration:  BoxDecoration(gradient: AppColor.backgroundGradientcolor),
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
                   
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 70 / 100,
                      child: Text(
                        AppLanguage.forgotPasswordText[language],
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
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),
                      Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 70 / 100,
                      child: Text(
                        AppLanguage.pleaseEnteryourAccountText[language],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.lightGreyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ),
                         SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),
                    Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        85 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        6 /
                                        100,
                                    child: CustomTextFieldInput(
                                      hintText: AppLanguage
                                          .enterPhonenoAndenteremailidText[language],
                                      maxLength: AppConstant.mobileMaxLenth,
                                      keyboardType: TextInputType.name,
                                      controller:
                                          mobileNumberTextEditingController,
                                    ),
                                  ),
                                ),

                                 SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),
                      Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 70 / 100,
                      child: Text(
                        AppLanguage.weHavesharedLinktoresetText[language],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.lightGreyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ),
               
                      Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 70 / 100,
                      child: Text(
                        AppLanguage.passwordOnyourEmailText[language],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.lightGreyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ),
                               
                 SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100,
                    ),
                //     Container(
                //       alignment: Alignment.center,
                //       width: MediaQuery.of(context).size.width * 70 / 100,
                //       child: Text(
                //         AppLanguage.forgotpasswordText[language],
                //         textAlign: TextAlign.center,
                //         style: const TextStyle(
                //           color: AppColor.buttonColor,
                //           fontSize: 14,
                //           fontWeight: FontWeight.w600,
                //           fontFamily: AppFont.fontFamily,
                //         ),
                //       ),
                //     ),
                   
             
                 
                    SizedBox(
                      height: MediaQuery.of(context).size.height *43/ 100,
                    ),
                     SizedBox(
                      width: MediaQuery.of(context).size.width * 80 / 100,
                      height: MediaQuery.of(context).size.height * 4.5 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLanguage.didnotRecievetheLinkText[language],
                            style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                            SizedBox(
                      width: MediaQuery.of(context).size.width * 1 / 100,
                    ),
                          Text(
                            AppLanguage.retryInsecText[language],
                            style: const TextStyle(
                                color: AppColor.buttonColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                          ),
                        
                        ],
                      ),
                    ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *1/ 100,
                    ),
                  AppButton(
                      text: AppLanguage.continueText[language],
                      
                      onPress: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyAppFooter()));
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
