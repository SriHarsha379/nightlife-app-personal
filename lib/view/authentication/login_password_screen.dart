import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/page_transition.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/custom_password.dart';
import 'forgot_otp_password_screen.dart';
import 'login_screen.dart' show emailController;

/// Second step of the (now split) login flow.
///
/// [LoginScreen] collects the identifier (email/username/phone) and offers
/// social login as a way to skip this screen entirely. This screen is only
/// reached for password-based login, and its sole job is collecting the
/// password and submitting it.
class LoginPasswordScreen extends StatefulWidget {
  static String routeName = './LoginPasswordScreen';
  final String identifier;

  const LoginPasswordScreen({super.key, required this.identifier});

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    if (apiProvider.loading) return;

    if (Validation.isFieldEmpty(context,
        value: passwordController.text,
        fieldName: AppLanguage.passwordtext[language])) return;

    final success = await apiProvider.loginUserApiCall(
        context, widget.identifier, passwordController.text);
    if (success) {
      emailController.clear();
      passwordController.clear();
    }
  }

  @override
  void dispose() {
    // Note: we dispose the controller here (this instance is truly gone),
    // but we still don't call passwordController.clear() before this — a
    // failed login (wrong password) pops back to this same instance via
    // Navigator, and clearing text on dispose would wipe what the user
    // typed if this screen is ever rebuilt/re-entered mid-flow.
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLoading = context.watch<PostApiProvider>().loading;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return ProgressHUD(
      isLoading: isLoading,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppColor.themeColor,
            body: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColor.backgroundGradientcolor(context),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.04),

                      /// Back button
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: AppColor.secondryColor(context)),
                        onPressed: () => Navigator.pop(context),
                      ),

                      SizedBox(height: size.height * 0.02),

                      Text(
                        AppLanguage.loginText[language],
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFont.fontFamily,
                          fontSize: 22,
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      /// Shows which account is signing in + lets them
                      /// go back and correct it without retyping the password.
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.identifier,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColor.secondryColor(context)
                                      .withOpacity(0.7),
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: AppColor.buttonColor,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.06),

                      /// Password
                      SizedBox(
                        width: double.infinity,
                        height: size.height * 0.066,
                        child: CustomPasswordField(
                          controller: passwordController,
                          hintText: "Enter Password",
                          maxLength: AppConstant.passwordMaxLength,
                          fillColor: AppColor.otpboxColor(context),
                          textColor: Colors.black,
                          borderColor: AppColor.transparentColor,
                          iconColor: AppColor.primaryColor(context),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      /// Forgot password
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: const ForgotPassword(),
                            ),
                          );
                        },
                        child: Text(
                          AppLanguage.forgotpasswordText[language],
                          style: const TextStyle(
                            color: AppColor.buttonColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      /// Login button
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: AppLanguage.continueText[language],
                          onPress: () async {
                            await _login();
                          },
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}