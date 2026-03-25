import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/post_api_provider.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/widgets.dart';
import '../other/profile_details.dart';
import 'refer_code_screen.dart';

class SignUp extends StatefulWidget {
  static String routeName = './SignUp';

  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  static final Uri _organizerWebsite = Uri.parse('https://hii.life/');

  final TextEditingController mobileNumberTextEditingController =
      TextEditingController();
  late AnimationController _overlayController;
  late Animation<Offset> _overlaySlideAnimation;
  Future<void> _openOrganizerWebsite() async {
    await launchUrl(
      _organizerWebsite,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  void initState() {
    super.initState();

    /// 🔥 Purple opening overlay animation
    _overlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      if (!mounted) return;
      signupBottomSheet(context);
      _overlayController.forward();
    });
  }

  void LoginValidation() {
    if (Validation.isFieldEmpty(context,
        value: mobileNumberTextEditingController.text,
        fieldName: AppLanguage.mobileNumberText[language])) return;

    // Add numeric-only validation
    if (!Validation.isMobileNumericOnly(
        context, mobileNumberTextEditingController.text)) return;

    if (!Validation.isMobilValid(
        context, mobileNumberTextEditingController.text)) return;

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    apiProvider.checkNumberApiCalling(
        context, mobileNumberTextEditingController.text);
  }

  @override
  void dispose() {
    mobileNumberTextEditingController.dispose();

    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {},
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              /// Background Image
              GestureDetector(
                onTap: () {},
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

  // =========================
  // EXISTING BOTTOM SHEET CODE
  // =========================
  void signupBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      shape: const RoundedRectangleBorder(),
      barrierColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: Navigator.of(context),
      ),
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {},
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColor.backgroundGradientcolor(context),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(46),
                    topRight: Radius.circular(46),
                  ),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    SizedBox(height: size.height * 0.01),
                    Text(
                      AppLanguage.signupText[language],
                      style: TextStyle(
                        color: AppColor.secondryColor(context),
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SizedBox(
                      width: size.width * 0.85,
                      height: size.height * 0.06,
                      child: CustomTextAreaField(
                        hintText: AppLanguage.enterphonenumber[language],
                        keyboardtype: TextInputType.phone,
                        maxLength: AppConstant.mobileMaxLenth,
                        controller: mobileNumberTextEditingController,
                        prefixText: "+91",
                        readOnly: false,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    AppButton(
                      text: AppLanguage.continueText[language],
                      onPress: () {
                        LoginValidation();
                      },
                    ),
                    SizedBox(height: size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLanguage.alreadyhaveanacoount[language],
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: const LoginScreen(),
                                duration: const Duration(milliseconds: 100),
                              ),
                            );
                          },
                          child: Text(
                            AppLanguage.loginText[language],
                            style: const TextStyle(
                              color: AppColor.buttonColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 80 / 100,
                      // height: MediaQuery.of(context).size.height * 3.5 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Have an Invite Code ?",
                            style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                                fontSize: 12),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 1 / 100,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: UseReferCodeScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: Text(
                              "Enter Here",
                              style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
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
                            width: MediaQuery.of(context).size.width * 1 / 100,
                          ),
                          GestureDetector(
                            onTap: _openOrganizerWebsite,
                            child: Text(
                              AppLanguage.clickhereText[language],
                              style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
