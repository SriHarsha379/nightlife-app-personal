import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/forgot_otp_password_screen.dart';
import 'package:night_life/view/authentication/forgot_otp_verify_screen.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/authentication/otp_verify_screen.dart';
import 'package:night_life/view/other/profile_details.dart';
import 'package:night_life/view/authentication/signup.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';

class WelcomeScreen4 extends StatefulWidget {
  static String routeName = './LoginScreen';

  const WelcomeScreen4({super.key});

  @override
  State<WelcomeScreen4> createState() => _WelcomeScreen4State();
}

TextEditingController passwordController = TextEditingController();
TextEditingController emailController = TextEditingController();

class _WelcomeScreen4State extends State<WelcomeScreen4>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  int _activeIndex = 2;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Create slide animation from bottom to top
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start from bottom (off-screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        // backgroundColor: AppColor.secondryColor,
        resizeToAvoidBottomInset: false,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Background image (static, no animation)
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height,
                  decoration:  BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImage.signupScreen),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              SlideTransition(
                position: _slideAnimation,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: MediaQuery.of(context).size.width*100/100,
                                              height: MediaQuery.of(context).size.height * 56 / 100,
              
                    decoration: BoxDecoration(
                      gradient: AppColor.backgroundGradientcolor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                     
                  
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 9 / 100,
                        ),
                       
                     
                         Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 70 / 100,
                            child: Text(
                             "All in One Place",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                          Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            child: Text(
                            "Discover the best venues, book your seats with ease, and connect with people who share your vibe—all from one app.",
                              textAlign: TextAlign.center,
                              style:  TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          ),
                        
                      
                  
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 8 / 100),
                  
               
                        AppButton(
                            text: AppLanguage.letsgetStartedtext[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: SignUp(),
                                  duration: const Duration(milliseconds: 400),
                                ),
                              );
                            }),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 80 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                             
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 1 / 100,
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
                              
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 1 / 100,
                              ),
                             
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 100,
                        ),
                       
                        // ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                      ],
                    ),
                  ),
                ),
              ),
               Positioned(
          bottom: 65,
            left: 165,
          child: Row(
            children: [
              _dot(_activeIndex == 1),
              _dot(_activeIndex == 0),
              _dot(_activeIndex == 0),
              _dot(_activeIndex == 2),
            ],
          ),
        ),
            ],
            
          ),
        ),
      ),
    );
  }
  
  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 5,
      height: active ? 10 : 5,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF2CDF) :  Color.fromARGB(255, 251, 249, 253),
        shape: BoxShape.circle,
      ),
    );
  }
}
