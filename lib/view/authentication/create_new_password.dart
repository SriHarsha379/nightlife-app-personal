import 'package:flutter/material.dart';
import 'package:night_life/animation/purple_screen.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_language.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/custom_password.dart';

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

  Future<void> _submitNewPassword() async {
    final newPassword = newPasswordTextController.text.trim();
    final confirmPassword = confirmPasswordTextEditingController.text.trim();

    if (Validation.isFieldEmpty(
      context,
      value: newPassword,
      fieldName: AppLanguage.enterpassword[language],
    )) {
      return;
    }

    if (!Validation.isStrongPassword(context, newPassword)) {
      return;
    }

    if (Validation.isFieldEmpty(
      context,
      value: confirmPassword,
      fieldName: AppLanguage.confirmPassword[language],
    )) {
      return;
    }

    if (!Validation.isPasswordMatch(context, newPassword, confirmPassword)) {
      return;
    }

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    final res = await apiProvider.confirmPasswordApiCalling(
      context,
      newPassword: newPassword,
    );

    if (!mounted) return;
    if (res != null && res['success'] == true) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
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
                          color: AppColor.secondryColor(context),
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
                      style: TextStyle(
                        color: AppColor.secondryColor(context),
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
                          style: TextStyle(
                            color: AppColor.lightGreyColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 5 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        height: MediaQuery.of(context).size.height * 6 / 100,
                        child: CustomPasswordField(
                          controller: newPasswordTextController,
                          hintText: AppLanguage.enterpassword[language],
                          maxLength: AppConstant.passwordMaxLength,
                          fillColor: AppColor.otpboxColor(context),
                          textColor: Colors.black,
                          borderColor: AppColor.transparentColor,
                          iconColor: AppColor.primaryColor(context),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        height: MediaQuery.of(context).size.height * 6 / 100,
                        child: CustomPasswordField(
                          controller: confirmPasswordTextEditingController,
                          hintText: AppLanguage.confirmPassword[language],
                          maxLength: AppConstant.passwordMaxLength,
                          fillColor: AppColor.otpboxColor(context),
                          textColor: Colors.black,
                          borderColor: AppColor.transparentColor,
                          iconColor: AppColor.primaryColor(context),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                    ],
                  ),
                ),
              ),
              Consumer<PostApiProvider>(
                builder: (context, apiProvider, child) {
                  return apiProvider.loading
                      ? const CircularProgressIndicator(
                          color: AppColor.pinkColor,
                        )
                      : AppButton(
                          text: AppLanguage.continueText[language],
                          onPress: () {
                            _submitNewPassword();
                          },
                        );
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
