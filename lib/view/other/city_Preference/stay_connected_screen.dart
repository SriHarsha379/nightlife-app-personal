import 'package:flutter/material.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:page_transition/page_transition.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/widgets.dart';
import 'stay_connected_otp_verification.dart';

class StayConnectedScreen extends StatefulWidget {
  static String routeName = './StayConnectedScreen';
  const StayConnectedScreen({super.key});

  @override
  State<StayConnectedScreen> createState() => _StayConnectedScreenState();
}

class _StayConnectedScreenState extends State<StayConnectedScreen> {
  TextEditingController pinputInputController = TextEditingController();
  TextEditingController mobileNumberTextEditingController =
      TextEditingController();
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
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration:
              const BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 4 / 100,
              ),

              //! App Header
              SizedBox(
                width: MediaQuery.of(context).size.width * 90 / 100,
                height: MediaQuery.of(context).size.height * 8 / 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 4 / 100,
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Image.asset(
                                AppImage.backArrowIcon,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 80 / 100,
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.stayConnectedText[language],
                              style: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 1 / 100,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.stayConnectedHeader[language],
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
                        height: MediaQuery.of(context).size.height * 10 / 100,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 85 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: CustomTextFieldInput(
                            hintText: AppLanguage.entterEmailText[language],
                            maxLength: AppConstant.mobileMaxLenth,
                            keyboardType: TextInputType.name,
                            controller: mobileNumberTextEditingController,
                            fillColor: AppColor.secondryColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                    ],
                  ),
                ),
              ),
              AppButton(
                text: AppLanguage.continueText[language],
                onPress: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: const StayConnectedOTPVerify(isEmail: true,),
                      duration: const Duration(milliseconds: 600),
                    ),
                  );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: const StayConnectedOTPVerify(isEmail: true,),
                      duration: const Duration(milliseconds: 600),
                    ),
                  );
                },
                child: Text(
                  textAlign: TextAlign.center,
                  AppLanguage.skip[language],
                  style: const TextStyle(
                    fontFamily: AppFont.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColor.greyLightColor,
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 4 / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
