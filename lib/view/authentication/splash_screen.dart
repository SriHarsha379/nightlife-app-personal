import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
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
import '../../utilities/location_service.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/my_profile/get_my_profile.dart';
import '../../controller/my_profile/get_my_swipe_profile_controller.dart';
import '../../utilities/profile_completion_reminder.dart';

class Splash extends StatefulWidget {
  static String routeName = './Splash';

  const Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // Guard: ensures navigation only happens once, even if async tasks overlap.
  bool _hasNavigated = false;

  bool _isTokenExpired(String token) {
    return SessionManager.isTokenExpired(token);
  }

  int _parseSignupStep(dynamic stepValue) {
    if (stepValue is int) return stepValue;
    if (stepValue is String) return int.tryParse(stepValue) ?? 0;
    return 0;
  }

  // Safe navigate — only navigates once, guards against mounted + double-nav.
// Safe navigate — only navigates once, guards against mounted + double-nav.
  void _safeNavigate(Widget child) {
    if (_hasNavigated) return;
    if (!mounted) return;

    // If some other screen (e.g. the OTP screen's own explicit navigation)
    // has already been pushed on top of Splash, Splash's route is no
    // longer the current one. That means navigation already happened
    // elsewhere — don't fight it with a redundant, stale navigation.
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) {
      return;
    }

    _hasNavigated = true;
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: child,
        duration: const Duration(milliseconds: 400),
      ),
    );
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
    // Same defensive clear as on fresh login - a confirmed valid session
    // shouldn't be showing a leftover error banner from a previous,
    // now-irrelevant session.
    TopNotification.dispose();

    final bool isVerified =
        userData['is_verified'] ?? userData['isEmailVerified'] ?? false;
    final bool isProfileCompleted = userData['is_profile_completed'] ??
        userData['isProfileCompleted'] ??
        false;
    final bool isAnotherEmailVerify =
        userData['is_another_email_verify'] == true;
    final String anotherEmail = (userData['another_email'] ?? '').toString();
    final int signupStep = _parseSignupStep(userData['signup_step']);

    // Fire-and-forget: checks the real profile-completion percentage
    // (same endpoint the profile-completion UI uses) and nudges with a
    // local reminder notification if it's not 100%. Throttled internally
    // so it doesn't fire on every single app open.
    ProfileCompletionReminder.maybeCheckAndShow();

    if (signupStep >= 3 &&
        anotherEmail.trim().isNotEmpty &&
        !isAnotherEmailVerify) {
      _safeNavigate(StayConnectedOTPVerify(
        isEmail: true,
        email: anotherEmail,
      ));
      return;
    }
    if (isProfileCompleted) {
      _safeNavigate(const MyAppFooter(initialIndex: 0));
      return;
    }
    if (signupStep >= 3) {
      _safeNavigate(StayConnectedScreen());
      return;
    }
    if (signupStep == 2) {
      _safeNavigate(const MusicGenresScreen());
      return;
    }
    if (signupStep == 1 && isVerified) {
      _safeNavigate(const CityPreference());
      return;
    }
    if (signupStep == 1 && !isVerified) {
      _safeNavigate(OtpVerify(
        mobile: userData['phone_number']?.toString() ?? '',
        autoSendOtp: false,
      ));
      return;
    }
    _safeNavigate(const LoginScreen());
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    // Request location on app start
    LocationService.requestAndGetLocation().then((position) {
      if (position != null) {
        debugPrint('📍 App start location: ${position.latitude}, ${position.longitude}');
      }
    });

    if (!mounted) return;

    if (SessionManager.authFlowInProgress) {
      print('🔍 DECISION → Auth flow in progress elsewhere, deferring ⏸️');
      return;
    }


    final cachedData = await SessionManager.readCachedUserDetailsMap();
    final cachedToken = SessionManager.extractToken(cachedData);
    print('🔍 CACHE CHECK  → keys: ${cachedData.keys.toList()}');
    print('🔍 HAS AUTH USER → ${SessionManager.hasAuthenticatedUser}');
    print('🔍 TOKEN IN CACHE → ${cachedToken.isEmpty ? "EMPTY ❌" : "${cachedToken.substring(0, cachedToken.length.clamp(0, 20))}... ✅"}');
    print('🔍 TOKEN EXPIRED? → ${cachedToken.isEmpty ? "N/A" : SessionManager.isTokenExpired(cachedToken)}');

    final userController = Provider.of<UserController>(context, listen: false);
    final homeController = Provider.of<HomeController>(context, listen: false);
    final profileController =
    Provider.of<ProfileController>(context, listen: false);
    final swipeProfileController =
    Provider.of<GetMySwipeProfileController>(context, listen: false);

    try {
      // IMPORTANT: `hasAuthenticatedUser` only reflects Firebase Auth's
      // signed-in state. Google/Apple sign-in goes through Firebase, but
      // phone/OTP login (AuthService is never touched there) does NOT -
      // so Firebase never has a signed-in user for those accounts. Treating
      // "no Firebase user" as "not logged in" wiped a perfectly valid
      // backend session on every single app restart for OTP-logged-in
      // users. The backend JWT in cache is the real source of truth for
      // whether the user is logged in; Firebase is only relevant as a way
      // to refresh that JWT for Google/Apple accounts.
      if (SessionManager.hasAuthenticatedUser) {
        print('🔍 DECISION → Firebase user found, refreshing token...');
        try {
          await SessionManager.getFreshFirebaseIdToken(forceRefresh: true);
          print('🔍 TOKEN REFRESH → Success ✅');
        } on SessionExpiredAuthException {
          print('🔍 TOKEN REFRESH → SessionExpiredAuthException ❌');
          if (!mounted) return; // ← GUARD: stop if already navigated away
          await _clearSessionAndNavigateUnauthenticated(
            userController,
            homeController,
            profileController,
            swipeProfileController,
          );
          return;
        }
      } else if (cachedToken.isEmpty) {
        // No Firebase session AND no backend token cached at all - this is
        // a genuinely logged-out state (or first launch).
        print('🔍 DECISION → No Firebase user and no cached token, going to unauthenticated ❌');
        await _clearSessionAndNavigateUnauthenticated(
          userController,
          homeController,
          profileController,
          swipeProfileController,
        );
        return;
      } else {
        print('🔍 DECISION → No Firebase user, but a cached backend token exists (OTP login) - validating it directly ✅');
      }

      if (!mounted) return; // ← GUARD after async Firebase call

      Map<String, dynamic> data =
      await SessionManager.readCachedUserDetailsMap();

      if (data.isNotEmpty) {
        log("userdetails$data");
        String token = SessionManager.extractToken(data);
        print('🔍 EXTRACTED TOKEN → ${token.isEmpty ? "EMPTY ❌" : "Present ✅ (${token.length} chars)"}');

        if (token.isEmpty) {
          print('🔍 DECISION → Token empty after cache read, going unauthenticated ❌');
          if (!mounted) return;
          await _clearSessionAndNavigateUnauthenticated(
            userController,
            homeController,
            profileController,
            swipeProfileController,
          );
          return;
        }

        final isInitiallyExpired = _isTokenExpired(token);
        print('🔍 TOKEN INITIALLY EXPIRED? → $isInitiallyExpired');
        var isStillExpired = isInitiallyExpired;

        if (isInitiallyExpired) {
          print('🔍 Attempting session refresh...');
          // tryRefreshSession() uses the cached refresh_token against the
          // backend directly - it does NOT require a Firebase session, so
          // this works for phone/OTP logins too.
          final didRefresh = await SessionManager.tryRefreshSession();
          print('🔍 SESSION REFRESH → ${didRefresh ? "Success ✅" : "Failed ❌"}');
          if (didRefresh) {
            data = await SessionManager.readCachedUserDetailsMap();
            token = SessionManager.extractToken(data);
            isStillExpired = _isTokenExpired(token);
            print('🔍 TOKEN AFTER REFRESH EXPIRED? → $isStillExpired');
          }
        }

        if (!mounted) return; // ← GUARD after all async refresh calls

        if (token.isEmpty || isStillExpired) {
          print('🔍 DECISION → Token still expired/empty, going unauthenticated ❌');
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

        if (!mounted) return; // ← GUARD before Provider/context access

        Provider.of<SocketProvider>(context, listen: false)
            .setToken(AppConstant.token, authUserId: authUserId);

        if (data['player_id'] != null) {
          AppConstant.playerID = data['player_id'].toString();
        }

        final Map<String, dynamic> userData =
        (data['user'] is Map<String, dynamic>)
            ? Map<String, dynamic>.from(data['user'])
            : data;

        if (!mounted) return; // ← GUARD before navigation

        print('🔍 DECISION → Session valid, routing to Home ✅');
        userController.setUserFromMap(userData);
        _navigateForAuthenticatedUser(userData);
        return; // ← explicit return — nothing runs after navigation
      }

      // Cache was empty but Firebase user exists — go to home
      if (!mounted) return; // ← GUARD before navigation
      print('🔍 DECISION → Cache empty but Firebase user exists, routing to Home footer ✅');
      _safeNavigate(const MyAppFooter(initialIndex: 0));
      return; // ← explicit return — nothing runs after navigation

    } catch (e, stack) {
      print('🔍 ERROR in _checkLoginStatus → $e');
      print('🔍 STACK → $stack');

      // ── CRITICAL FIX ──
      // Only navigate to unauthenticated if we haven't already navigated
      // somewhere else. Without this guard, a dispose exception after a
      // successful navigation would bounce the user back to login.
      if (_hasNavigated) return;
      if (!mounted) return;
    }

    // Only reached if catch block didn't already return
    if (_hasNavigated) return;

    userController.reset();
    homeController.clearAllData();
    profileController.clearProfileData();
    swipeProfileController.resetState();

    print('🔍 DECISION → Fell through to unauthenticated (catch block) ❌');
    await _navigateToUnauthenticatedEntry();
  }

  Future<void> _navigateToUnauthenticatedEntry() async {
    final hasCompletedOnboarding =
        await CacheHelper.get(AppOnboardingScreen.completionStorageKey) ==
            'true';

    if (!mounted) return;
    if (_hasNavigated) return; // ← don't double-navigate

    _safeNavigate(hasCompletedOnboarding
        ? const LoginScreen()
        : const AppOnboardingScreen());
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.asset(
          AppImage.newGif,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}