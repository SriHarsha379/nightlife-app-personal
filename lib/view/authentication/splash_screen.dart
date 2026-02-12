import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/otp_verify_screen.dart';
import 'package:night_life/view/other/city_Preference/citypreference_screen.dart';
import 'package:night_life/view/other/city_Preference/music_genres.dart';
import 'package:night_life/view/welcomescreens/welcome_screen1.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_image.dart';
import '../../provider/common_sharedpreferences.dart';
import '../../provider/user_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/my_profile/get_my_profile.dart';
import '../../controller/my_profile/get_my_swipe_profile_controller.dart';

class Splash extends StatefulWidget {
  static String routeName = './Splash';

  Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final userController = Provider.of<UserController>(context, listen: false);
    final homeController = Provider.of<HomeController>(context, listen: false);
    final profileController =
        Provider.of<ProfileController>(context, listen: false);
    final swipeProfileController =
        Provider.of<GetMySwipeProfileController>(context, listen: false);

    try {
      final userDetails = await CacheHelper.get('user_details');

      if (userDetails != null && userDetails.isNotEmpty) {
        final data = json.decode(userDetails);
        log("userdetails$data");
        if (data is Map<String, dynamic>) {
          final token = (data['token'] ?? '').toString().trim();
          if (token.isEmpty) {
            AppConstant.token = '';
            userController.reset();
            homeController.clearAllData();
            profileController.clearProfileData();
            swipeProfileController.resetState();
            await CacheHelper.remove('user_details');
            _navigateToWelcome();
            return;
          }
          AppConstant.token = token;
          log("app token----->>>>${AppConstant.token}");

          if (data['player_id'] != null) {
            AppConstant.playerID = data['player_id'].toString();
          }

          final bool isVerified =
              data['is_verified'] ?? data['isEmailVerified'] ?? false;
          final bool isProfileCompleted = data['is_profile_completed'] ??
              data['isProfileCompleted'] ??
              false;

          int signupStep = 0;
          final dynamic stepValue = data['signup_step'];
          if (stepValue is int) {
            signupStep = stepValue;
          } else if (stepValue is String) {
            signupStep = int.tryParse(stepValue) ?? 0;
          }

          if (!mounted) return;

          userController.setUserFromMap(data);

          if (isProfileCompleted || signupStep >= 3) {
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeftWithFade,
                child: const MyAppFooter(initialIndex: 0),
                duration: const Duration(milliseconds: 400),
              ),
            );
            return;
          }

          if (signupStep == 1 && isVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CityPreference(),
              ),
            );
            return;
          }

          if (signupStep == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MusicGenresScreen(),
              ),
            );
            return;
          }

          if (signupStep == 1 && !isVerified) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerify(
                  mobile: data['phone_number']?.toString() ?? '',
                ),
              ),
            );
            return;
          }
        }
      }
    } catch (e) {
      print("Error checking login status: $e");
    }

    if (mounted) {
      userController.reset();
      homeController.clearAllData();
      profileController.clearProfileData();
      swipeProfileController.resetState();
    }

    _navigateToWelcome();
  }

  void _navigateToWelcome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen1()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.transparentColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.transparentColor,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
      backgroundColor: AppColor.transparentColor,
      body: GestureDetector(
        onTap: () {
          _navigateToWelcome();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            AppImage.newGif,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
