import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_language.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/widgets.dart';
import 'forgot_otp_verify_screen.dart';

class ForgotPassword extends StatefulWidget {
  static String routeName = './ForgotPassword';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
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

  bool _isEmailInput(String value) {
    return value.contains('@');
  }

  Future<void> forgotPasswordValidation() async {
    final input = mobileNumberTextEditingController.text.trim();
    if (Validation.isFieldEmpty(
      context,
      value: input,
      fieldName: AppLanguage.usernameemailIdPhonenumberText1[language],
    )) {
      return;
    }

    final isEmail = _isEmailInput(input);
    if (isEmail) {
      if (!Validation.isEmailValid(context, input)) return;
    } else {
      if (!Validation.isMobileNumericOnly(context, input)) return;
      if (!Validation.isMobilValid(context, input)) return;
    }

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    final res = await apiProvider.forgotPasswordApiCalling(
      context,
      email: isEmail ? input : null,
      phoneNumber: isEmail ? null : input,
    );

    if (!mounted) return;
    if (res != null && res['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotOtpverify(
            isEmail: isEmail,
            identifier: input,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: GestureDetector(
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
                        AppLanguage.forgotPasswordText[language],
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
                            AppLanguage.forgotPasswordHeader[language],
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
                          height: MediaQuery.of(context).size.height * 10 / 100,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 85 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                          child: CustomLoginTextField(
                            controller: mobileNumberTextEditingController,
                            hintText: AppLanguage
                                .enterPhonenoAndenteremailidText[language],
                            maxLength: 50,
                            fillColor: AppColor.otpboxColor(context),
                            textColor: Colors.black,
                            borderColor: AppColor.transparentColor,
                            // iconColor: AppColor.primaryColor,
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
                              forgotPasswordValidation();
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
      ),
    );
  }
}
