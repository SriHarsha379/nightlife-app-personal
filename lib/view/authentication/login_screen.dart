import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_text_field.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/auth_service.dart';
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

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static final Uri _organizerWebsite = Uri.parse('https://hii.life/');

  // ✅ FIX: controllers are instance-level not global
  // audit #03 — prevents stale data between sessions
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _bottomSheetController;
  late Animation<Offset>   _bottomSheetAnimation;
  late AnimationController _overlayController;
  late Animation<Offset>   _overlaySlideAnimation;

  String _privacyPolicyUrl = '';

  @override
  void initState() {
    super.initState();
    _loadContentData();

    _bottomSheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _bottomSheetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bottomSheetController,
      curve: Curves.easeOutCubic,
    ));

    _overlayController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.doAnimate ? 1100 : 0),
    );
    _overlaySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bottomSheetController.forward();
      _overlayController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bottomSheetController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _loadContentData() {
    fetchAllContent((List data) {
      for (var item in data) {
        if (item['content_type'] == 1) {
          if (mounted) setState(() => _privacyPolicyUrl = item['content_url']);
        }
      }
    });
  }

  Future<void> _login() async {
    final api = Provider.of<PostApiProvider>(context, listen: false);
    if (api.loading) return;
    if (Validation.isFieldEmpty(context,
        value: _emailController.text,
        fieldName: AppLanguage.usernameemailIdPhonenumberText[language])) {
      return;
    }
    if (Validation.isFieldEmpty(context,
        value: _passwordController.text,
        fieldName: AppLanguage.passwordtext[language])) {
      return;
    }
    final success = await api.loginUserApiCall(
        context, _emailController.text, _passwordController.text);
    if (success) {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  void _loginGoogle() async {
    final user = await AuthService.signInWithGoogle();
    if (user != null && mounted) {
      Provider.of<PostApiProvider>(context, listen: false)
          .socialLoginApiCalling(context, user);
    }
  }

  void _loginApple() async {
    final user = await AuthService.signInWithApple();
    if (user != null && mounted) {
      Provider.of<PostApiProvider>(context, listen: false)
          .socialLoginApiCalling(context, user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size    = MediaQuery.of(context).size;
    final isDark  = Provider.of<ThemeProvider>(context).isDarkMode;
    final isLoading = context.watch<PostApiProvider>().loading;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) {},
        child: Stack(
          children: [
            // Background
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

            // Bottom sheet
            SlideTransition(
              position: _bottomSheetAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColor.backgroundGradientcolor(context),
                      borderRadius: const BorderRadius.only(
                        topLeft:  Radius.circular(46),
                        topRight: Radius.circular(46),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      // ✅ FIX: bottom padding so button never hides
                      // behind home indicator — audit #02
                      bottom: bottomPad + 16,
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
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),

                        // ✅ FIX: AppTextField with floating label
                        // audit #03 — label visible after typing
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.075),
                          child: AppTextField(
                            controller: _emailController,
                            label: AppLanguage
                                .usernameAndemailIdPhonenumberText[language],
                            hint: 'Email, phone or username',
                            maxLength: 50,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),

                        // ✅ FIX: Password with label + eye toggle
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.075),
                          child: AppTextField(
                            controller: _passwordController,
                            label: AppLanguage.passwordtext[language],
                            hint: 'Enter your password',
                            maxLength: AppConstant.passwordMaxLength,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                          ),
                        ),

                        // ✅ FIX: Forgot password beside password field
                        // audit #03
                        Padding(
                          padding: EdgeInsets.only(
                            right: size.width * 0.075,
                            top: 8,
                          ),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const ForgotPassword(),
                                ),
                              ),
                              child: Text(
                                AppLanguage.forgotpasswordText[language],
                                style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        // ✅ FIX: "Continue with Google" label — audit #03
                        // Plain icon alone is ambiguous
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.075),
                          child: Column(
                            children: [
                              // Divider with OR
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: AppColor.secondryColor(context)
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'or',
                                      style: TextStyle(
                                        color: AppColor.secondryColor(context)
                                            .withValues(alpha: 0.5),
                                        fontSize: 12,
                                        fontFamily: AppFont.fontFamily,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: AppColor.secondryColor(context)
                                          .withValues(alpha: 0.2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Google button with label
                              GestureDetector(
                                onTap: _loginGoogle,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColor.secondryColor(context)
                                          .withValues(alpha: 0.2),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    color: AppColor.textFieldColor(context),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        isDark
                                            ? AppImage.google
                                            : AppImage.googleLight,
                                        width: 22,
                                        height: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          color: AppColor.secondryColor(context),
                                          fontWeight: FontWeight.w600,
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Apple button (iOS only)
                              if (AppConstant.deviceType == "ios") ...[
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _loginApple,
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColor.secondryColor(context)
                                            .withValues(alpha: 0.2),
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      color: AppColor.textFieldColor(context),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          isDark
                                              ? AppImage.apple
                                              : AppImage.appleLight,
                                          width: 22,
                                          height: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Continue with Apple',
                                          style: TextStyle(
                                            color:
                                                AppColor.secondryColor(context),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 0.03),

                        // Sign In button
                        AppButton(
                          text: AppLanguage.continueText[language],
                          isLoading: isLoading,
                          onPress: _login,
                        ),

                        SizedBox(height: size.height * 0.025),

                        // New to app
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "New to the app? ",
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const SignUp(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              ),
                              child: Text(
                                AppLanguage.signupText[language],
                                style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.015),

                        // ✅ FIX: Descriptive organiser link — audit #03
                        // "Click Here" → "Sign in as Organiser"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLanguage.venueEventText[language],
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => launchUrl(
                                _organizerWebsite,
                                mode: LaunchMode.externalApplication,
                              ),
                              child: const Text(
                                'Sign in as Organiser',
                                style: TextStyle(
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 0.02),

                        // Privacy policy
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContentScreen(
                                contenttype: _privacyPolicyUrl,
                                header:
                                    AppLanguage.privacypoliciesText[language],
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.1),
                            child: Text(
                              '${AppLanguage.bySigningupStatementText[language]} ${AppLanguage.userAgreementStatementText[language]}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.secondryColor(context)
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ),

            // Purple overlay animation
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
    );
  }
}
