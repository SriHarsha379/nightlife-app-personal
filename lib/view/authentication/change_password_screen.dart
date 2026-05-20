import 'package:flutter/material.dart';
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

class ChangePasswordScreen extends StatefulWidget {
  static String routeName = './ChangePasswordScreen';
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController currentController = TextEditingController();
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

  //===============change password==============//

  void changePasswordValidation() {
    if (Validation.isFieldEmpty(
      context,
      value: currentController.text,
      fieldName: "Current Password",
    )) return;

    if (!Validation.isPasswordLength(context, currentController.text)) return;

    if (Validation.isFieldEmpty(
      context,
      value: newPasswordTextController.text,
      fieldName: AppLanguage.newPasswordText[language],
    )) return;

    if (!Validation.isPasswordLength(context, newPasswordTextController.text))
      return;

    // if (!Validation.isChangePasswordMatch(
    //   context,
    //   currentController.text,
    //   newPasswordTextController.text,
    // )) return;

    if (Validation.isFieldEmpty(
      context,
      value: confirmPasswordTextEditingController.text,
      fieldName: "Confirm New Password",
    )) return;

    if (!Validation.isPasswordLength(
        context, confirmPasswordTextEditingController.text)) return;

    if (!Validation.isChangePasswordMatch(
      context,
      newPasswordTextController.text,
      confirmPasswordTextEditingController.text,
    )) return;

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    apiProvider.chnagePasswordApiCalling(
        context, currentController.text, newPasswordTextController.text);
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
                      AppLanguage.changePasswordText[language],
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

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        height: MediaQuery.of(context).size.height * 6 / 100,
                        child: CustomPasswordField(
                          controller: currentController,
                          hintText: "Current Password",
                          maxLength: 20,
                          fillColor: AppColor.otpboxColor(context),
                          textColor: Colors.black,
                          borderColor: AppColor.transparentColor,
                          iconColor: AppColor.primaryColor(context),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        height: MediaQuery.of(context).size.height * 6 / 100,
                        child: CustomPasswordField(
                          controller: newPasswordTextController,
                          hintText: "New Password",
                          maxLength: 20,
                          fillColor: AppColor.otpboxColor(context),
                          textColor: Colors.black,
                          borderColor: AppColor.transparentColor,
                          iconColor: AppColor.primaryColor(context),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 85 / 100,
                        height: MediaQuery.of(context).size.height * 6 / 100,
                        child: CustomPasswordField(
                          controller: confirmPasswordTextEditingController,
                          hintText: "Confirm New Password",
                          maxLength: 20,
                          fillColor: AppColor.otpboxColor(context),
                          textColor: Colors.black,
                          borderColor: AppColor.transparentColor,
                          iconColor: AppColor.primaryColor(context),
                        ),
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
                            changePasswordValidation();
                          },
                        );
                },
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 5 / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
