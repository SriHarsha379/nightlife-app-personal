import 'package:flutter/material.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/welcomescreens/app_onboarding_screen.dart';

import '../../provider/common_sharedpreferences.dart';
import '../../utilities/auth_session_service.dart';
import '../../utilities/session_manager.dart';
import 'splash_screen.dart';

class AuthStateGate extends StatelessWidget {
  final AuthSessionService authSessionService;
  final Widget? authenticatedChild;
  final Widget? loadingChild;
  final Widget? loginChild;
  final Widget? onboardingChild;
  final Future<bool> Function()? hasCompletedOnboarding;

  const AuthStateGate({
    super.key,
    required this.authSessionService,
    this.authenticatedChild,
    this.loadingChild,
    this.loginChild,
    this.onboardingChild,
    this.hasCompletedOnboarding,
  });

  Future<bool> _defaultHasCompletedOnboarding() async {
    return await CacheHelper.get(AppOnboardingScreen.completionStorageKey) ==
        'true';
  }

  /// Phone/OTP and email+password logins in this app never sign into
  /// Firebase Auth (only Google/Apple do) - so `authSessionService.isSignedIn`
  /// being false does NOT mean the user is logged out. The backend JWT
  /// cached locally is the real source of truth. If one exists, defer to
  /// Splash (which knows how to validate/refresh it) instead of assuming
  /// a logged-out state and jumping straight to the login screen.
  Future<bool> _hasCachedBackendToken() async {
    final cachedData = await SessionManager.readCachedUserDetailsMap();
    final token = SessionManager.extractToken(cachedData);
    return token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: authSessionService.isSignedIn,
      stream: authSessionService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.hasData == false) {
          return loadingChild ?? const Splash();
        }

        final signedIn = snapshot.data ?? false;
        if (signedIn) {
          return authenticatedChild ?? const Splash();
        }

        return FutureBuilder<bool>(
          future: _hasCachedBackendToken(),
          builder: (context, tokenSnapshot) {
            if (tokenSnapshot.connectionState != ConnectionState.done) {
              return loadingChild ?? const Splash();
            }

            if (tokenSnapshot.data == true) {
              // A backend session is cached even though Firebase has no
              // signed-in user (phone/OTP/email login case). Let Splash
              // validate it and route appropriately instead of forcing
              // a re-login.
              return loadingChild ?? const Splash();
            }

            final getOnboardingFuture =
                hasCompletedOnboarding ?? _defaultHasCompletedOnboarding;
            return FutureBuilder<bool>(
              future: getOnboardingFuture(),
              builder: (context, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState !=
                    ConnectionState.done) {
                  return loadingChild ?? const Splash();
                }
                final completed = onboardingSnapshot.data == true;
                if (completed) {
                  return loginChild ?? const LoginScreen();
                }
                return onboardingChild ?? const AppOnboardingScreen();
              },
            );
          },
        );
      },
    );
  }
}