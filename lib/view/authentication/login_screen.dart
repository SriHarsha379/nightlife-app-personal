import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/content_service.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_loader.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/auth_service.dart';
import '../../utilities/custom_password.dart';
import '../../utilities/widgets.dart';
import '../content_screen/content_screen.dart';
import 'forgot_otp_password_screen.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = './LoginScreen';
  const LoginScreen({super.key, this.doAnimate = false});

  final bool doAnimate;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

TextEditingController passwordController = TextEditingController();
TextEditingController emailController = TextEditingController();

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static final Uri _organizerWebsite = Uri.parse('https://hii.life/');
  late AnimationController _bottomSheetController;
  late Animation<Offset> _bottomSheetAnimation;

  late AnimationController _overlayController;
  late Animation<Offset> _overlaySlideAnimation;
  String privacypolicytype = '';
  String termsandconditionstype = '';

  Future<void> _openOrganizerWebsite() async {
    await launchUrl(
      _organizerWebsite,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void initState() {
    super.initState();
    loadContentData();

    /// Bottom login container animation
    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _bottomSheetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _bottomSheetController,
        curve: Curves.easeOutCubic,
      ),
    );

    /// Purple overlay opening animation
    _overlayController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.doAnimate ? 1100 : 0),
    );

    _overlaySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1), // slide DOWN
    ).animate(
      CurvedAnimation(
        parent: _overlayController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bottomSheetController.forward();
      _overlayController.forward();
    });
  }

  Future<void> LoginValidation() async {
    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    // Prevent duplicate submissions while an existing login request is in-flight.
    if (apiProvider.loading) return;

    if (Validation.isFieldEmpty(context,
        value: emailController.text,
        fieldName: AppLanguage.usernameemailIdPhonenumberText[language]))
      return;
    if (Validation.isFieldEmpty(context,
        value: passwordController.text,
        fieldName: AppLanguage.passwordtext[language])) return;
    final success = await apiProvider.loginUserApiCall(
        context, emailController.text, passwordController.text);
    if (success) {
      emailController.clear();
      passwordController.clear();
    }
  }

  // ---- Google Login ------
  void loginGoogle(BuildContext context) async {
    final user = await AuthService.signInWithGoogle();
    log("userrrrrrr$user");
    if (user != null) {
      final apiprovider = Provider.of<PostApiProvider>(context, listen: false);
      apiprovider.socialLoginApiCalling(context, user);
    }
  }

  // ---- Apple Login ------
  void loginApple(BuildContext context) async {
    final user = await AuthService.signInWithApple();
    if (user != null) {
      final apiprovider = Provider.of<PostApiProvider>(context, listen: false);
      apiprovider.socialLoginApiCalling(context, user);
    }
  }

  @override
  void dispose() {
    _bottomSheetController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  loadContentData() {
    fetchAllContent((List data) {
      for (var item in data) {
        // Privacy Policy (content_type: 1)
        if (item['content_type'] == 1) {
          setState(() {
            privacypolicytype = item['content_url'];
          });
        }

        // Terms and Conditions (content_type: 2)
        if (item['content_type'] == 2) {
          setState(() {
            termsandconditionstype = item['content_url'];
          });
        }
      }
    });
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
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {},
          child: Stack(
            children: [
              /// Background image
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImage.signupScreen),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              /// Bottom login container
              SlideTransition(
                position: _bottomSheetAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColor.backgroundGradientcolor(context),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(46),
                          topRight: Radius.circular(46),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: size.height * 0.03),
                          Image.asset(
                            AppImage.dashIcon,
                            height: size.height * 0.008,
                            width: size.width * 0.15,
                          ),
                          SizedBox(height: size.height * 0.02),

                          Text(
                            AppLanguage.loginText[language],
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontWeight: FontWeight.w700,
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                            ),
                          ),

                          SizedBox(height: size.height * 0.06),

                          /// Email

                          SizedBox(
                            width: size.width * 0.85,
                            height: size.height * 0.066,
                            child: CustomLoginTextField(
                              controller: emailController,
                              hintText: AppLanguage
                                  .usernameAndemailIdPhonenumberText[language],
                              maxLength: 50,
                              fillColor: AppColor.otpboxColor(context),
                              textColor: Colors.black,
                              borderColor: AppColor.transparentColor,
                              // iconColor: AppColor.primaryColor,
                            ),
                          ),

                          SizedBox(height: size.height * 0.03),

                          /// Password
                          // SizedBox(
                          //   width: size.width * 0.85,
                          //   height: size.height * 0.06,
                          //   child: CustomTextFieldInput(
                          //     hintText: AppLanguage.enterpassword[language],
                          //     maxLength: AppConstant.mobileMaxLenth,
                          //     controller: passwordController,
                          //     fillColor: AppColor.secondryColor(context),
                          //     keyboardType: TextInputType.text,
                          //   ),
                          // ),

                          SizedBox(
                            width: size.width * 0.85,
                            height: size.height * 0.066,
                            child: CustomPasswordField(
                              controller: passwordController,
                              hintText: "Enter Password",
                              maxLength: 20,
                              fillColor: AppColor.otpboxColor(context),
                              textColor: Colors.black,
                              borderColor: AppColor.transparentColor,
                              iconColor: AppColor.primaryColor(context),
                            ),
                          ),

                          SizedBox(height: size.height * 0.03),

                          /// Social login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  loginGoogle(context);
                                },
                                child: Image.asset(
                                  isDark
                                      ? AppImage.google
                                      : AppImage.googleLight,
                                  width: size.width * 0.14,
                                  height: size.width * 0.14,
                                ),
                              ),
                              if (AppConstant.deviceType == "ios") ...[
                                SizedBox(width: size.width * 0.02),
                                GestureDetector(
                                  onTap: () {
                                    loginApple(context);
                                  },
                                  child: Image.asset(
                                    isDark
                                        ? AppImage.apple
                                        : AppImage.appleLight,
                                    width: size.width * 0.15,
                                    height: size.width * 0.15,
                                  ),
                                ),
                              ],
                            ],
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
                          SizedBox(height: size.height * 0.02),

                          /// Continue button
                          AppButton(
                            text: AppLanguage.continueText[language],
                            onPress: () async {
                              await LoginValidation();
                            },
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 4 / 100,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            // height: MediaQuery.of(context).size.height * 3.5 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLanguage.venueEventText[language],
                                  style: TextStyle(
                                      color: AppColor.secondryColor(context),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 12),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      1 /
                                      100,
                                ),
                                GestureDetector(
                                  onTap: _openOrganizerWebsite,
                                  child: Text(
                                    AppLanguage.clickhereText[language],
                                    style: const TextStyle(
                                        color: AppColor.buttonColor,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            // height: MediaQuery.of(context).size.height * 3.5 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "New to the app ?",
                                  style: TextStyle(
                                      color: AppColor.secondryColor(context),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 12),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      1 /
                                      100,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: const SignUp(),
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppLanguage.signupText[language],
                                    style: const TextStyle(
                                        color: AppColor.buttonColor,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 3 / 100,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContentScreen(
                                    contenttype: privacypolicytype,
                                    header: AppLanguage
                                        .privacypoliciesText[language],
                                  ),
                                ),
                              );
                            },
                            child: Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    80 /
                                    100,
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // Horizontally center
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center, // Vertically center
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center, // Center inside column
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 1.0),
                                          child: Text(
                                            AppLanguage
                                                    .bySigningupStatementText[
                                                language],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColor.secondryColor(
                                                  context),
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.3 /
                                              100,
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text(
                                                AppLanguage
                                                        .userAgreementStatementText[
                                                    language],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: AppColor.secondryColor(
                                                      context),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  2 /
                                                  100,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              /// 🔥 Purple opening overlay (MUST BE LAST)
              SlideTransition(
                position: _overlaySlideAnimation,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: AppColor.purpleScreenColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
