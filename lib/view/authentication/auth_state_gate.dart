import 'package:flutter/material.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/welcomescreens/app_onboarding_screen.dart';

import '../../provider/common_sharedpreferences.dart';
import '../../utilities/auth_session_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: authSessionService.isSignedIn,
      stream: authSessionService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.hasData == false) {
          return loadingChild ?? Splash();
        }

        final signedIn = snapshot.data ?? false;
        if (signedIn) {
          return authenticatedChild ?? Splash();
        }

        final getOnboardingFuture =
            hasCompletedOnboarding ?? _defaultHasCompletedOnboarding;
        return FutureBuilder<bool>(
          future: getOnboardingFuture(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState != ConnectionState.done) {
              return loadingChild ?? Splash();
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
  }
}
