import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/welcomescreens/app_onboarding_screen.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';

import '../../provider/socket_provider.dart';
import '../../view/authentication/otp_verify_screen.dart';
import '../../view/other/city_Preference/citypreference_screen.dart';
import '../../view/other/city_Preference/music_genres.dart';
import '../../view/other/city_Preference/stay_connected_otp_verification.dart';
import '../../view/other/city_Preference/stay_connected_screen.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_image.dart';
import '../../utilities/auth_session_service.dart';
import '../../utilities/session_manager.dart';
import '../../provider/common_sharedpreferences.dart';
import '../../provider/user_controller.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/my_profile/get_my_profile.dart';
import '../../controller/my_profile/get_my_swipe_profile_controller.dart';

class Splash extends StatefulWidget {
  static String routeName = './Splash';

  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _isTokenExpired(String token) {
    return SessionManager.isTokenExpired(token);
  }

  int _parseSignupStep(dynamic stepValue) {
    if (stepValue is int) return stepValue;
    if (stepValue is String) return int.tryParse(stepValue) ?? 0;
    return 0;
  }

  Future<void> _clearSessionAndNavigateUnauthenticated(
    UserController userController,
    HomeController homeController,
    ProfileController profileController,
    GetMySwipeProfileController swipeProfileController,
  ) async {
    AppConstant.token = '';
    userController.reset();
    homeController.clearAllData();
    profileController.clearProfileData();
    swipeProfileController.resetState();
    await SessionManager.clearAuthSession(signOutFromFirebase: true);
    await _navigateToUnauthenticatedEntry();
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
      debugPrint(
          'Authenticated Firebase user with no cached user_details; routing to app footer.');
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
      // Wait for Firebase to emit its auth state rather than reading
      // currentUser synchronously.  On hot-restart the Dart VM re-initialises
      // but Firebase restores its session from native storage asynchronously,
      // so currentUser can be null for a short window even when the user is
      // actually signed in.
      bool isAuthenticated;
      try {
        isAuthenticated = await SessionManager.authStateChanges()
            .first
            .timeout(const Duration(seconds: 10));
      } on TimeoutException {
        isAuthenticated = SessionManager.hasAuthenticatedUser;
        log('Firebase auth state stream timed out; falling back to synchronous check (isAuthenticated=$isAuthenticated)');
      } catch (e) {
        isAuthenticated = SessionManager.hasAuthenticatedUser;
        log('Firebase auth state stream error: $e; falling back to synchronous check (isAuthenticated=$isAuthenticated)');
      }

      if (!isAuthenticated) {
        // Firebase can briefly emit/appear as signed-out during hot-restart
        // while native session restoration is still settling. Give it one
        // short grace re-check before performing destructive sign-out.
        try {
          final recoveredAuth = await SessionManager.authStateChanges()
              .firstWhere((signedIn) => signedIn)
              .timeout(
                const Duration(seconds: 2),
                onTimeout: () => false,
              );
          if (recoveredAuth) {
            isAuthenticated = true;
            log('Recovered authenticated state after grace re-check.');
          }
        } catch (e) {
          log('Grace auth re-check failed: $e');
        }
      }

      if (!isAuthenticated) {
        await _clearSessionAndNavigateUnauthenticated(
          userController,
          homeController,
          profileController,
          swipeProfileController,
        );
        return;
      }

      try {
        await SessionManager.getFreshFirebaseIdToken(forceRefresh: true);
      } on SessionExpiredAuthException {
        await _clearSessionAndNavigateUnauthenticated(
          userController,
          homeController,
          profileController,
          swipeProfileController,
        );
        return;
      }

      Map<String, dynamic> data = await SessionManager.readCachedUserDetailsMap();
      if (data.isNotEmpty) {
        log("userdetails$data");
        String token = SessionManager.extractToken(data);

        if (token.isEmpty) {
          await _clearSessionAndNavigateUnauthenticated(
            userController,
            homeController,
            profileController,
            swipeProfileController,
          );
          return;
        }
        final isInitiallyExpired = _isTokenExpired(token);
        var isStillExpired = isInitiallyExpired;
        if (isInitiallyExpired) {
          final didRefresh = await SessionManager.tryRefreshSession();
          if (didRefresh) {
            data = await SessionManager.readCachedUserDetailsMap();
            token = SessionManager.extractToken(data);
            isStillExpired = _isTokenExpired(token);
          }
        }
        if (token.isEmpty || isStillExpired) {
          await _clearSessionAndNavigateUnauthenticated(
            userController,
            homeController,
            profileController,
            swipeProfileController,
          );
          return;
        }
        await SessionManager.captureSessionFromAuthPayload(data);
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

      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const MyAppFooter(initialIndex: 0),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    } catch (e) {
      print("Error checking login status: $e");
    }

    if (mounted) {
      userController.reset();
      homeController.clearAllData();
      profileController.clearProfileData();
      swipeProfileController.resetState();
    }

    await _navigateToUnauthenticatedEntry();
  }
 
  Future<void> _navigateToUnauthenticatedEntry() async {
    final hasCompletedOnboarding =
        await CacheHelper.get(AppOnboardingScreen.completionStorageKey) ==
            'true';

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: hasCompletedOnboarding
            ? const LoginScreen()
            : const AppOnboardingScreen(),
        duration: const Duration(milliseconds: 400),
      ),
    );
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
          _navigateToUnauthenticatedEntry();
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
