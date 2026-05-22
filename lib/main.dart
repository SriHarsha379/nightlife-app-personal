import 'dart:async';
import 'firebase_options.dart';
import 'package:night_life/firebase_options.dart';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider/app_providers.dart';
import 'provider/darkmode_provider.dart';
import 'utilities/app_theme.dart';
import 'utilities/fcm_token_service.dart';
import 'utilities/local_notification_service.dart';
import 'view/authentication/notification_screen.dart';
import 'view/other/MySplashSection/EventSection/Liked/booked_event_details.dart';
import 'view/other/MySplashSection/EventSection/Liked/liked_event_details.dart';
import 'view/other/MySplashSection/MembersSection/member_liked_details.dart';
import 'view/other/MySplashSection/VenuesSection/venue_booking_details.dart';
import 'view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'view/other/chats/chat_message_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalNotificationService.initialize();
  print("Handling background message: ${message.messageId}");
  final String? title = message.notification?.title?.trim();
  final String? body = message.notification?.body?.trim();
  final bool hasSystemContent =
      (title != null && title.isNotEmpty) || (body != null && body.isNotEmpty);

  if (!hasSystemContent) {
    await LocalNotificationService.showFromRemoteMessage(message);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
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
  late final List<SingleChildWidget> _appProviders;
  StreamSubscription<Uri>? _deepLinkSub;
  Uri? _lastHandledDeepLink;
  static const String _handledInitialRedirectsKey =
      'handled_initial_redirects_v1';
  static const int _maxHandledInitialRedirects = 40;

  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _appProviders = buildAppProviders();
    _initDeepLinks();
    _initNotificationRedirections();
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        final bool shouldHandle = await _markInitialRedirectIfNew(
          'deeplink:${initialUri.toString()}',
        );
        if (shouldHandle) {
          _dispatchDeepLink(initialUri);
        }
      }
    } catch (_) {}

    _deepLinkSub = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _dispatchDeepLink(uri);
        }
      },
      onError: (_) {},
    );
  }

  void _dispatchDeepLink(Uri uri) {
    if (_lastHandledDeepLink?.toString() == uri.toString()) return;
    _lastHandledDeepLink = uri;
    _handleDeepLink(uri);
  }

  Future<void> _initNotificationRedirections() async {
    LocalNotificationService.setOnNotificationTapHandler(
      _handleLocalNotificationTapPayload,
    );
    final String? pendingLocalPayload =
        LocalNotificationService.consumePendingLaunchPayload();
    if (pendingLocalPayload != null && pendingLocalPayload.trim().isNotEmpty) {
      final bool shouldHandle = await _markInitialRedirectIfNew(
        'local:${pendingLocalPayload.trim()}',
      );
      if (shouldHandle) {
        _handleLocalNotificationTapPayload(pendingLocalPayload);
      }
    }
    FcmTokenService.setupNotificationTapRedirection(_handlePushRedirect);

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      final bool shouldHandle = await _markInitialRedirectIfNew(
        _buildInitialMessageKey(initialMessage),
      );
      if (shouldHandle) {
        _handlePushRedirect(initialMessage);
      }
    }
  }

  String _buildInitialMessageKey(RemoteMessage message) {
    final String id = (message.messageId ?? '').trim();
    if (id.isNotEmpty) return 'fcm_id:$id';
    return 'fcm_data:${jsonEncode(message.data)}';
  }

  Future<bool> _markInitialRedirectIfNew(String key) async {
    final String normalized = key.trim();
    if (normalized.isEmpty) return false;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> handled =
        prefs.getStringList(_handledInitialRedirectsKey) ?? <String>[];
    if (handled.contains(normalized)) {
      return false;
    }

    handled.add(normalized);
    if (handled.length > _maxHandledInitialRedirects) {
      final int removeCount = handled.length - _maxHandledInitialRedirects;
      handled.removeRange(0, removeCount);
    }
    await prefs.setStringList(_handledInitialRedirectsKey, handled);
    return true;
  }

  void _handleLocalNotificationTapPayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      _openNotificationScreen();
      return;
    }

    try {
      final dynamic decoded = jsonDecode(payload);
      if (decoded is Map) {
        final map = decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
        _routeFromNotificationData(map);
        return;
      }
    } catch (_) {}

    _openNotificationScreen();
  }

  void _handlePushRedirect(RemoteMessage message) {
    _routeFromNotificationData(message.data);
  }

  String _str(dynamic value) => (value ?? '').toString().trim();

  String _firstNonEmpty(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final String value = _str(map[key]);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  Map<String, dynamic> _extractActionJson(Map<String, dynamic> data) {
    final dynamic raw = data['action_json'];
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.map((key, value) => MapEntry(key.toString(), value));
        }
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  void _routeFromNotificationData(Map<String, dynamic> data) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _routeFromNotificationData(data);
      });
      return;
    }

    final String action = _str(data['action']).toLowerCase();
    final String type = _str(data['type']).toLowerCase();
    final Map<String, dynamic> actionJson = _extractActionJson(data);

    if (action == 'new_message' || type == 'new_message') {
      final Map<String, dynamic> src =
          actionJson.isNotEmpty ? actionJson : data;
      final String otherUserId = _firstNonEmpty(
        src,
        <String>['other_user_id', 'sender_id', 'senderId'],
      );
      final String conversationId = _firstNonEmpty(
        src,
        <String>['conversation_id', 'conversationId'],
      );
      final String senderName = _firstNonEmpty(
        src,
        <String>['sender_name', 'title', 'name'],
      );
      final String senderImage = _firstNonEmpty(
        src,
        <String>['sender_image', 'profile_image', 'image'],
      );

      if (otherUserId.isEmpty) {
        _openNotificationScreen();
        return;
      }

      navigator.push(
        MaterialPageRoute(
          builder: (_) => ChatMessageScreen(
            name: senderName.isEmpty ? 'User' : senderName,
            image: senderImage,
            receiverId: otherUserId,
            conversationId: conversationId.isEmpty ? null : conversationId,
            autoSendSharedEvent: false,
          ),
        ),
      );
      return;
    }

    if (action == 'someone_liked_you' || action == 'its_match') {
      final String memberId = _firstNonEmpty(
        actionJson.isNotEmpty ? actionJson : data,
        <String>['senderId', 'other_user_id', 'target_user_id', 'user_id'],
      );
      if (memberId.isEmpty) {
        _openNotificationScreen();
        return;
      }
      navigator.push(
        MaterialPageRoute(
          builder: (_) => LikedMemberDetail(memberId: memberId),
        ),
      );
      return;
    }

    if (action == 'event_booking_confirmed') {
      final String bookingId = _firstNonEmpty(
        actionJson.isNotEmpty ? actionJson : data,
        <String>['booking_id', 'event_booking_id'],
      );
      if (bookingId.isNotEmpty) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => BookedEventDetails(bookingId: bookingId),
          ),
        );
        return;
      }

      final String eventId = _firstNonEmpty(
        actionJson.isNotEmpty ? actionJson : data,
        <String>['event_id'],
      );
      if (eventId.isNotEmpty) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => LikedEventDetail(eventId: eventId),
          ),
        );
        return;
      }

      _openNotificationScreen();
      return;
    }

    if (action == 'venue_booking_confirmed' ||
        action == 'venue_booking_details') {
      final String bookingId = _firstNonEmpty(
        actionJson.isNotEmpty ? actionJson : data,
        <String>['booking_id', 'venue_booking_id', 'venue_id'],
      );
      if (bookingId.isEmpty) {
        _openNotificationScreen();
        return;
      }
      navigator.push(
        MaterialPageRoute(
          builder: (_) => VenueBookedDetails(venueId: bookingId),
        ),
      );
      return;
    }

    // welcome / signup / unknown actions -> Notifications screen
    _openNotificationScreen();
  }

  void _openNotificationScreen() {
    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const Notifications(),
      ),
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
      providers: _appProviders,
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
