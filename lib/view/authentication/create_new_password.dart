import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/animation/purple_screen.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_language.dart';
import '../../utilities/app_image.dart';
import '../../utilities/widgets.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  static String routeName = './CreateNewPasswordScreen';
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  TextEditingController pinputInputController = TextEditingController();
  TextEditingController newPasswordTextController = TextEditingController();
  TextEditingController confirmPasswordTextEditingController =
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
                      AppLanguage.createNewPassText[language],
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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.createNewPassHeader[language],
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
                        height: MediaQuery.of(context).size.height * 5 / 100,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 85 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: CustomTextFieldInput(
                            hintText: AppLanguage.enterpassword[language],
                            maxLength: AppConstant.mobileMaxLenth,
                            keyboardType: TextInputType.name,
                            controller: newPasswordTextController,
                            fillColor: AppColor.secondryColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 85 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: CustomTextFieldInput(
                            hintText: AppLanguage.confirmPassword[language],
                            maxLength: AppConstant.mobileMaxLenth,
                            keyboardType: TextInputType.name,
                            controller: confirmPasswordTextEditingController,
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
                      type: PageTransitionType.bottomToTop,
                      child: const PurpleScreen(
                        nextScreen: LoginScreen(
                          doAnimate: true,
                        ),
                      ),
                      duration: const Duration(milliseconds: 400),
                    ),
                  );
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => const ShutterTransition(
                  //       nextScreen: LoginScreen(),
                  //     ),
                  //   ),
                  // );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 3 / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
