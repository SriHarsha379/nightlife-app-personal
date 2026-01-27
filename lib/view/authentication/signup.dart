import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/other/profile_details.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';

class SignUp extends StatefulWidget {
  static String routeName = './SignUp';

  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

TextEditingController mobileNumberTextEditingController =
    TextEditingController();

class _SignUpState extends State<SignUp> with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<Offset> _overlaySlideAnimation;

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
      signupBottomSheet(context);
      _overlayController.forward();
    });
  }

  @override
  void dispose() {
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
                decoration: const BoxDecoration(
                  gradient: AppColor.backgroundGradientcolor,
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
                      style: const TextStyle(
                        color: AppColor.secondryColor,
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
                        keyboardType: TextInputType.number,
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
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: const ProfileDetailsScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: size.height * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLanguage.alreadyhaveanacoount[language],
                          style: const TextStyle(
                            color: AppColor.secondryColor,
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
                    SizedBox(height: size.height * 0.03),
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
