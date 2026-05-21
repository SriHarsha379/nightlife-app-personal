import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/welcomescreens/app_onboarding_screen.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';

import '../../provider/socket_provider.dart';
import '../../provider/user_chat_socket_provider.dart';
import '../../view/authentication/otp_verify_screen.dart';
import '../../view/other/city_Preference/citypreference_screen.dart';
import '../../view/other/city_Preference/music_genres.dart';
import '../../view/other/city_Preference/stay_connected_otp_verification.dart';
import '../../view/other/city_Preference/stay_connected_screen.dart';
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
  bool _isTokenExpired(String token) {
    final trimmed = token.trim();
    if (trimmed.isEmpty) return true;
    final parts = trimmed.split('.');
    if (parts.length != 3) return true;
    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded);
      if (map is! Map || map['exp'] == null) return true;
      final exp = int.tryParse(map['exp'].toString());
      if (exp == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return true;
    }
  }

  int _parseSignupStep(dynamic stepValue) {
    if (stepValue is int) return stepValue;
    if (stepValue is String) return int.tryParse(stepValue) ?? 0;
    return 0;
  }

  void _navigateForAuthenticatedUser(Map<String, dynamic> userData) {
    final bool isVerified =
        userData['is_verified'] ?? userData['isEmailVerified'] ?? false;
    final bool isProfileCompleted = userData['is_profile_completed'] ??
        userData['isProfileCompleted'] ??
        false;
    final bool isAnotherEmailVerify =
        userData['is_another_email_verify'] == true;
    final String anotherEmail = (userData['another_email'] ?? '').toString();
    final int signupStep = _parseSignupStep(userData['signup_step']);

    if (signupStep >= 3 &&
        anotherEmail.trim().isNotEmpty &&
        !isAnotherEmailVerify) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: StayConnectedOTPVerify(
            isEmail: true,
            email: anotherEmail,
          ),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    if (isProfileCompleted) {
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
    if (signupStep >= 3) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: StayConnectedScreen(),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    if (signupStep == 2) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const MusicGenresScreen(),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    if (signupStep == 1 && isVerified) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const CityPreference(),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    if (signupStep == 1 && !isVerified) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: OtpVerify(
            mobile: userData['phone_number']?.toString() ?? '',
          ),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: const LoginScreen(),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3));

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
          String token = (data['token'] ?? '').toString().trim();
          if (token.isEmpty && data['user'] is Map) {
            token = (data['user']['token'] ?? '').toString().trim();
          }

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
          if (_isTokenExpired(token)) {
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
          final authUserId =
              ((data['user'] is Map ? data['user']['_id'] : data['_id']) ?? '')
                  .toString()
                  .trim();
          Provider.of<SocketProvider>(context, listen: false)
              .setToken(AppConstant.token, authUserId: authUserId);
          if (data['player_id'] != null) {
            AppConstant.playerID = data['player_id'].toString();
          }

          final Map<String, dynamic> userData =
              (data['user'] is Map<String, dynamic>)
                  ? Map<String, dynamic>.from(data['user'])
                  : data;

          if (!mounted) return;

          userController.setUserFromMap(userData);
          _navigateForAuthenticatedUser(userData);
          return;
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
        MaterialPageRoute(builder: (context) => const AppOnboardingScreen()),
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
