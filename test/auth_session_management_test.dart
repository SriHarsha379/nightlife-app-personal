import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:night_life/utilities/auth_session_service.dart';
import 'package:night_life/utilities/session_manager.dart';
import 'package:night_life/view/authentication/auth_state_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthSessionService implements AuthSessionService {
  bool _signedIn;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  final String? _tokenToReturn;
  final Exception? _tokenException;
  bool signOutCalled = false;

  _FakeAuthSessionService({
    required bool signedIn,
    String? tokenToReturn,
    Exception? tokenException,
  })  : _signedIn = signedIn,
        _tokenToReturn = tokenToReturn,
        _tokenException = tokenException;

  @override
  bool get isSignedIn => _signedIn;

  @override
  Stream<bool> authStateChanges() => _controller.stream;

  @override
  Future<String?> getFreshIdToken({bool forceRefresh = true}) async {
    if (_tokenException != null) throw _tokenException!;
    return _tokenToReturn;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _signedIn = false;
    _controller.add(false);
  }

  void emitAuthState(bool value) {
    _signedIn = value;
    _controller.add(value);
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    SessionManager.setAuthSessionServiceForTesting(null);
  });

  testWidgets(
    'routes to app content when valid session exists on launch',
    (WidgetTester tester) async {
      final authService = _FakeAuthSessionService(signedIn: true);
      await tester.pumpWidget(
        MaterialApp(
          home: AuthStateGate(
            authSessionService: authService,
            authenticatedChild: const Text('home', key: Key('home')),
            loginChild: const Text('login', key: Key('login')),
            onboardingChild:
                const Text('onboarding', key: Key('onboarding')),
            hasCompletedOnboarding: () async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home')), findsOneWidget);
      expect(find.byKey(const Key('login')), findsNothing);
      await authService.dispose();
    },
  );

  testWidgets(
    'routes to login when no session exists on launch',
    (WidgetTester tester) async {
      final authService = _FakeAuthSessionService(signedIn: false);
      await tester.pumpWidget(
        MaterialApp(
          home: AuthStateGate(
            authSessionService: authService,
            authenticatedChild: const Text('home', key: Key('home')),
            loginChild: const Text('login', key: Key('login')),
            onboardingChild:
                const Text('onboarding', key: Key('onboarding')),
            hasCompletedOnboarding: () async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login')), findsOneWidget);
      expect(find.byKey(const Key('home')), findsNothing);
      await authService.dispose();
    },
  );

  test(
    'expired or revoked token flow clears local state and signs out',
    () async {
      final authService = _FakeAuthSessionService(
        signedIn: true,
        tokenException: SessionExpiredAuthException('user-token-expired'),
      );
      SessionManager.setAuthSessionServiceForTesting(authService);

      SharedPreferences.setMockInitialValues({
        'user_details': '{"token":"abc"}',
        'session_refresh_token': 'refresh',
        'session_token_expiry_epoch': '123',
      });

      expect(
        () => SessionManager.getFreshFirebaseIdToken(forceRefresh: true),
        throwsA(isA<SessionExpiredAuthException>()),
      );

      await SessionManager.clearAuthSession(
        signOutFromFirebase: true,
        clearAllPreferences: true,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
      expect(authService.signOutCalled, isTrue);
      await authService.dispose();
    },
  );

  testWidgets(
    'foreground resume auth re-check keeps user logged in when session remains valid',
    (WidgetTester tester) async {
      final authService = _FakeAuthSessionService(signedIn: true);
      await tester.pumpWidget(
        MaterialApp(
          home: AuthStateGate(
            authSessionService: authService,
            authenticatedChild: const Text('home', key: Key('home')),
            loginChild: const Text('login', key: Key('login')),
            onboardingChild:
                const Text('onboarding', key: Key('onboarding')),
            hasCompletedOnboarding: () async => true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home')), findsOneWidget);

      authService.emitAuthState(true);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home')), findsOneWidget);
      expect(find.byKey(const Key('login')), findsNothing);
      await authService.dispose();
    },
  );
}
