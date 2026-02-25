import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/splash_screen.dart';
import 'package:provider/provider.dart';
import 'provider/app_providers.dart';
import 'provider/darkmode_provider.dart';
import 'utilities/app_theme.dart';
import 'utilities/fcm_token_service.dart';
import 'utilities/local_notification_service.dart';
import 'view/other/MySplashSection/EventSection/Liked/liked_event_details.dart';
import 'view/other/MySplashSection/VenuesSection/venuepages.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FcmTokenService.generateAndStoreToken();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _deepLinkSub;

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _deepLinkSub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (_) {},
    );
  }

  void _handleDeepLink(Uri uri) {
    final String hostType = uri.host.trim().toLowerCase();
    final List<String> segments = uri.pathSegments
        .where((segment) => segment.trim().isNotEmpty)
        .toList(growable: false);

    String type = (uri.queryParameters['type'] ?? '').trim().toLowerCase();
    String id = (uri.queryParameters['id'] ?? '').trim();

    if (type.isEmpty) {
      if (hostType.isNotEmpty) {
        type = hostType;
      } else if (segments.isNotEmpty) {
        type = segments.first.trim().toLowerCase();
      }
    }

    if (id.isEmpty) {
      if (hostType.isNotEmpty && segments.isNotEmpty) {
        id = segments.first.trim();
      } else if (segments.length > 1) {
        id = segments[1].trim();
      }
    }

    if ((type != 'event' && type != 'venue') || id.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;

      if (type == 'event') {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => LikedEventDetail(eventId: id),
          ),
        );
      } else {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => VenuePages(venueId: id),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: "Hii",
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            darkTheme: AppThemeConfig.darkTheme,
            theme: AppThemeConfig.lightTheme,
            home: Splash(),
          );
        },
      ),
    );
  }
}
