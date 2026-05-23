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

  Widget _buildUnauthenticatedWidget() {
    return FutureBuilder<bool>(
      future: (hasCompletedOnboarding ?? _defaultHasCompletedOnboarding)(),
      builder: (context, onboardingSnapshot) {
        if (onboardingSnapshot.connectionState != ConnectionState.done) {
          return loadingChild ?? const Splash();
        }
        final completed = onboardingSnapshot.data == true;
        if (completed) {
          return loginChild ?? const LoginScreen();
        }
        return onboardingChild ?? const AppOnboardingScreen();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: authSessionService.authStateChanges(),
      builder: (context, snapshot) {
        // Wait for the first Firebase emission before routing.
        // Using a synchronous initialData can return false on hot-restart
        // because Firebase restores its auth state asynchronously; this
        // would flash the login screen even for a fully authenticated user.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingChild ?? const Splash();
        }

        // On stream error treat the user as unauthenticated so the app does
        // not hang on the loading screen indefinitely.
        if (snapshot.hasError || !snapshot.hasData) {
          if (snapshot.hasError) {
            debugPrint('AuthStateGate auth stream error: ${snapshot.error}');
          }
          return _buildUnauthenticatedWidget();
        }

        final signedIn = snapshot.data ?? false;
        if (signedIn) {
          return authenticatedChild ?? const Splash();
        }

        return _buildUnauthenticatedWidget();
      },
    );
  }
}
