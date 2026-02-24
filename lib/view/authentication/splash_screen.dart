import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/welcomescreens/welcome_screen1.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../provider/socket_provider.dart';
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
          final socketProvider =
              Provider.of<SocketProvider>(context, listen: false);
          socketProvider.initSocket(AppConstant.token);
          if (data['player_id'] != null) {
            AppConstant.playerID = data['player_id'].toString();
          }

          final Map<String, dynamic> userData =
              (data['user'] is Map<String, dynamic>)
                  ? Map<String, dynamic>.from(data['user'])
                  : data;

          final bool isProfileCompleted = userData['is_profile_completed'] ??
              userData['isProfileCompleted'] ??
              false;

          if (!mounted) return;

          userController.setUserFromMap(userData);

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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
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
