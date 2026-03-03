import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../controller/home/home_controller.dart';
import '../../controller/notification/notification_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../other/MySplashSection/EventSection/Liked/booked_event_details.dart';
import '../other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import '../other/MySplashSection/MembersSection/member_liked_details.dart';
import '../other/MySplashSection/VenuesSection/venue_booking_details.dart';

class Notifications extends StatefulWidget {
  static String routeName = './Notifications';
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  static const int _pageLimit = 6;

  String _str(dynamic value) => (value ?? '').toString().trim();

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  String _firstNonEmpty(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = _str(map[key]);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  String _ctaText(String action) {
    switch (action) {
      case 'someone_liked_you':
        return 'See Who';
      case 'event_booking_confirmed':
      case 'venue_booking_details':
      case 'venue_booking_confirmed':
        return 'View details';
      default:
        return '';
    }
  }

  String _formatRelativeTime(String value) {
    final raw = value.toLowerCase().trim();
    if (raw.isEmpty) return value;
    if (raw.contains('minutes')) {
      final n = RegExp(r'\d+').firstMatch(raw)?.group(0) ?? '';
      return n.isEmpty ? value : '${n}m ago';
    }
    if (raw.contains('hour')) {
      final n = RegExp(r'\d+').firstMatch(raw)?.group(0);
      if (n != null && n.isNotEmpty) return '${n}h ago';
      return '1h ago';
    }
    if (raw.contains('day')) {
      final n = RegExp(r'\d+').firstMatch(raw)?.group(0) ?? '';
      return n.isEmpty ? value : '${n}d ago';
    }
    if (raw.contains('week')) {
      final n = RegExp(r'\d+').firstMatch(raw)?.group(0) ?? '';
      return n.isEmpty ? value : '${n}w ago';
    }
    if (raw.contains('month')) {
      final n = RegExp(r'\d+').firstMatch(raw)?.group(0) ?? '';
      return n.isEmpty ? value : '${n}mo ago';
    }
    if (raw == 'just now') return 'now';
    return value;
  }

  List<String> _splitMessage(dynamic item) {
    final map = _map(item);
    final message = _str(map['message']);
    final apiTime = _str(map['time']);
    if (apiTime.isNotEmpty) return <String>[message, apiTime];

    if (message.contains('. ')) {
      final parts = message.split('. ');
      if (parts.length > 1) {
        return <String>[
          '${parts.first}.',
          parts.sublist(1).join('. ').trim(),
        ];
      }
    }
    if (message.contains(' - ')) {
      final parts = message.split(' - ');
      if (parts.length > 1) {
        return <String>[
          parts.first.trim(),
          '- ${parts.sublist(1).join(' - ').trim()}'
        ];
      }
    }
    if (message.contains(' – ')) {
      final parts = message.split(' – ');
      if (parts.length > 1) {
        return <String>[
          parts.first.trim(),
          '– ${parts.sublist(1).join(' – ').trim()}'
        ];
      }
    }
    return <String>[message, ''];
  }

  void _handleNotificationTap(Map<String, dynamic> item) {
    final action = _str(item['action']).toLowerCase();
    final actionJson = _map(item['action_json']);

    switch (action) {
      case 'someone_liked_you' || 'its_match':
        final memberId =
            _firstNonEmpty(actionJson, <String>['senderId', 'other_user_id']);
        if (memberId.isEmpty) return;
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: LikedMemberDetail(memberId: memberId),
            duration: const Duration(milliseconds: 500),
          ),
        );
        break;

      case 'event_booking_confirmed':
        final bookingId = _firstNonEmpty(
          actionJson,
          <String>['booking_id', 'event_booking_id'],
        );
        if (bookingId.isNotEmpty) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.bottomToTop,
              child: BookedEventDetails(bookingId: bookingId),
              duration: const Duration(milliseconds: 500),
            ),
          );
          break;
        }

        final eventId = _firstNonEmpty(
          actionJson,
          <String>['event_id'],
        );
        if (eventId.isEmpty) return;
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: LikedEventDetail(eventId: eventId),
            duration: const Duration(milliseconds: 500),
          ),
        );
        break;

      case 'venue_booking_details':
      case 'venue_booking_confirmed':
        final bookingId = _firstNonEmpty(
          actionJson,
          <String>['booking_id', 'venue_booking_id', 'venue_id'],
        );
        if (bookingId.isEmpty) return;
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.bottomToTop,
            child: VenueBookedDetails(venueId: bookingId),
            duration: const Duration(milliseconds: 500),
          ),
        );
        break;

      default:
        break;
    }
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final icon = _str(item['icon']);
    final title = _str(item['title']);
    final split = _splitMessage(item);
    final message = split[0];
    final messageTime = split[1];
    final lastSeen = _formatRelativeTime(_str(item['createtime']));
    final action = _str(item['action']).toLowerCase();
    final viewText = _ctaText(action);

    return GestureDetector(
      onTap: () => _handleNotificationTap(item),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColor.profilesettignrowColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.transparent.withOpacity(0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 13 / 100,
                  height: MediaQuery.of(context).size.width * 13 / 100,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    icon.isEmpty ? '•' : icon,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1 / 100,
                ),
                Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 60 / 100,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontSize: 14,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 15 / 100,
                          alignment: Alignment.centerRight,
                          child: Text(
                            lastSeen,
                            style: const TextStyle(
                              color: AppColor.textcolor,
                              fontSize: 11,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 75 / 100,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        message,
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 14,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 75 / 100,
                      child: Text(
                        messageTime,
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (viewText.isNotEmpty)
                      Container(
                        width: MediaQuery.of(context).size.width * 75 / 100,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          viewText,
                          style: const TextStyle(
                            color: AppColor.buttonColor,
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(
    Map<String, dynamic> item,
    NotificationController controller,
  ) {
    final notificationId = _str(item['notification_id']);
    final key = notificationId.isNotEmpty
        ? ValueKey<String>(notificationId)
        : ValueKey<String>('notification_${item.hashCode}');

    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset(
          AppImage.deleteIcon,
          width: 22,
          height: 22,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (_) async {
        if (notificationId.isEmpty) return false;
        return controller.deleteSingleNotification(
          context,
          notificationId: notificationId,
        );
      },
      child: _notificationCard(item),
    );
  }

  bool _onScrollNotification(
    ScrollNotification notification,
    NotificationController controller,
  ) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 120) {
      controller.loadMoreNotifications(context, limit: _pageLimit);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeController>().clearNotificationStatus();
      context
          .read<NotificationController>()
          .fetchNotifications(context, limit: _pageLimit);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          color: AppColor.primaryColor(context),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.notificationText[language],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
              Expanded(
                child: Consumer<NotificationController>(
                  builder: (context, controller, _) {
                    final recent = controller.recentNotifications;
                    final older = controller.olderNotifications;

                    return RefreshIndicator(
                      onRefresh: () => controller.refreshNotifications(context,
                          limit: _pageLimit),
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) =>
                            _onScrollNotification(notification, controller),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              if (controller.isLoading &&
                                  recent.isEmpty &&
                                  older.isEmpty)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17.0),
                                    child: Text(
                                      AppLanguage.newtext[language],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                ),
                              if (controller.isLoading &&
                                  recent.isEmpty &&
                                  older.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(),
                                ),
                              if (!controller.isLoading &&
                                  recent.isEmpty &&
                                  older.isEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 250),
                                  child: Text(
                                    'No notifications found',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      color: AppColor.secondryColor(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (recent.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recent.length,
                                  itemBuilder: (context, index) {
                                    final item = _map(recent[index]);
                                    return _buildDismissibleCard(
                                      item,
                                      controller,
                                    );
                                  },
                                ),
                              if (older.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 17.0,
                                    vertical: 8.0,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Earlier',
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                ),
                              if (older.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: older.length,
                                  itemBuilder: (context, index) {
                                    final item = _map(older[index]);
                                    return _buildDismissibleCard(
                                      item,
                                      controller,
                                    );
                                  },
                                ),
                              if (controller.isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    12 /
                                    100,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
