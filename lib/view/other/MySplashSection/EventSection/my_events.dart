import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../provider/darkmode_provider.dart';
import '/controller/home/home_controller.dart';
import '/controller/likedAndBookedEvents/like_booked_event_controller.dart';
import '/utilities/app_color.dart';
import '/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_footer.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../MembersSection/Members.dart';
import '../VenuesSection/my_venue.dart';
import 'Liked/booked_event_details.dart';

class MyEvents extends StatefulWidget {
  static const String routeName = '/MyEvents';
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  int selectedIndex = 0;
  List pastEventlist = [
    {
      'image': AppImage.eventImage3,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.eventImage4,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.eventImage5,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];
  bool isDropdownOpen = false;

  late final ScrollController _likedScrollController;
  late final ScrollController _bookedScrollController;
  late final ScrollController _pastHorizontalScrollController;

  @override
  void initState() {
    super.initState();
    _likedScrollController = ScrollController()..addListener(_onLikedScroll);
    _bookedScrollController = ScrollController()..addListener(_onBookedScroll);
    _pastHorizontalScrollController = ScrollController()
      ..addListener(_onPastHorizontalScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLiked();
    });
  }

  void _fetchLiked() {
    Provider.of<LikedBookedEventController>(context, listen: false)
        .fetchMyEvents(
      context,
      type: 'liked',
      page: 0,
      limit: 10,
    );
  }

  void _fetchBooked() {
    Provider.of<LikedBookedEventController>(context, listen: false)
        .fetchMyEvents(
      context,
      type: 'booked',
      page: 0,
      limit: 10,
    );
  }

  Future<void> _handleEventDetailResult(dynamic result) async {
    if (result is! Map) return;

    final action = (result['action'] ?? '').toString().trim().toLowerCase();
    final targetEventId = (result['targetEventId'] ?? '').toString().trim();
    if (targetEventId.isEmpty) return;

    final homeController = Provider.of<HomeController>(context, listen: false);
    if (action == 'dislike') {
      await homeController.dislikeItem(context, targetEventId, 'event');
    } else if (action == 'like') {
      await homeController.likeItem(context, targetEventId, 'event');
    } else {
      return;
    }

    if (!mounted) return;
    await Provider.of<LikedBookedEventController>(context, listen: false)
        .fetchMyEvents(
      context,
      type: 'liked',
      page: 0,
      limit: 10,
    );
  }

  void _onLikedScroll() {
    if (_likedScrollController.position.pixels >=
        _likedScrollController.position.maxScrollExtent - 200) {
      Provider.of<LikedBookedEventController>(context, listen: false)
          .loadMoreLiked(context);
    }
  }

  void _onBookedScroll() {}

  void _onPastHorizontalScroll() {
    if (_pastHorizontalScrollController.position.pixels >=
        _pastHorizontalScrollController.position.maxScrollExtent - 150) {
      Provider.of<LikedBookedEventController>(context, listen: false)
          .loadMorePast(context);
    }
  }

  @override
  void dispose() {
    _likedScrollController.dispose();
    _bookedScrollController.dispose();
    super.dispose();
  }

  String _formatSlotTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('EEE, dd MMM • h:mm a').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  bool _isDarkMode(BuildContext context) {
    return context.read<ThemeProvider>().isDarkMode;
  }

  // ✅ Card decoration — same as MyVenue
  BoxDecoration _eventCardDecoration(
    BuildContext context, {
    double radius = 15,
  }) {
    final isDark = _isDarkMode(context);
    return BoxDecoration(
      color: AppColor.primaryColor(context),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.35)
              : Colors.black.withOpacity(0.13),
          blurRadius: isDark ? 10 : 18,
          spreadRadius: isDark ? 0 : 1,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ✅ White button decoration — same as MyVenue
  BoxDecoration _eventActionButtonDecoration({double radius = 12}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            width: size.width,
            height: size.height,
            color: AppColor.primaryColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 4.5 / 100),

                // ── App bar ──────────────────────────────────────────────────
                Center(
                  child: SizedBox(
                    width: size.width * 90 / 100,
                    height: size.height * 7 / 100,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: const MyAppFooter(initialIndex: 0),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: SizedBox(
                            height: size.height * 7 / 100,
                            child: Align(
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImage.backarrow,
                                fit: BoxFit.cover,
                                color: AppColor.secondryColor(context),
                                height: size.width * 5 / 100,
                                width: size.width * 5 / 100,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 25 / 100),
                        GestureDetector(
                          onTap: () => documenttypebottomsheet(context),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              AppLanguage.myeventText[language],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 2 / 100),
                        GestureDetector(
                          onTap: () => documenttypebottomsheet(context),
                          child: Image.asset(
                            AppImage.downArrow,
                            fit: BoxFit.cover,
                            color: AppColor.secondryColor(context),
                            height: size.width * 5 / 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 2 / 100),

                // ── Tab bar ──────────────────────────────────────────────────
                Container(
                  color: AppColor.primaryColor(context),
                  width: size.width,
                  height: size.height * 8 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTab(
                        context,
                        label: AppLanguage.likedText[language],
                        index: 0,
                        size: size,
                        onTap: () {
                          setState(() => selectedIndex = 0);
                          _fetchLiked();
                        },
                      ),
                      _buildTab(
                        context,
                        label: AppLanguage.BookedText[language],
                        index: 1,
                        size: size,
                        onTap: () {
                          setState(() => selectedIndex = 1);
                          _fetchBooked();
                        },
                      ),
                    ],
                  ),
                ),

                // ── Tab indicator ────────────────────────────────────────────
                Row(
                  children: [
                    _buildTabIndicator(context, tabIndex: 0, size: size),
                    _buildTabIndicator(context, tabIndex: 1, size: size),
                  ],
                ),

                SizedBox(height: size.height * 2 / 100),

                // ── Tab content ──────────────────────────────────────────────
                Expanded(
                  child: selectedIndex == 0
                      ? _buildLikedTab(context, size)
                      : _buildBookedTab(context, size),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context, {
    required String label,
    required int index,
    required Size size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: size.width * 50 / 100,
        height: size.height * 8 / 100,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: selectedIndex == index
                  ? AppColor.pinkColor
                  : AppColor.secondryColor(context),
              fontSize: 16,
              fontFamily: AppFont.fontFamily,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabIndicator(
    BuildContext context, {
    required int tabIndex,
    required Size size,
  }) {
    return Container(
      width: size.width * 50 / 100,
      height: size.height * 0.3 / 100,
      color: selectedIndex == tabIndex
          ? AppColor.pinkColor
          : AppColor.secondryColor(context),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LIKED TAB
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildLikedTab(BuildContext context, Size size) {
    return Consumer<LikedBookedEventController>(
      builder: (context, controller, _) {
        if (controller.isLikedEventsLoading) {
          return Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: AppColor.buttonColor,
              size: 40,
            ),
          );
        }

        final events = controller.likedEvents;

        if (events.isEmpty) {
          return Center(
            child: Text(
              'No liked events yet',
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontFamily: AppFont.fontFamily,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _likedScrollController,
          padding: EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
          itemCount: events.length + (controller.isLikedLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == events.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 2 / 100),
                child: Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: AppColor.buttonColor,
                    size: 30,
                  ),
                ),
              );
            }

            final event = events[index];
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 1.5 / 100),
              child: _buildLikedVenueCard(context, event, size),
            );
          },
        );
      },
    );
  }

  Widget _buildLikedVenueCard(
      BuildContext context, Map<String, dynamic> event, Size size) {
    return GestureDetector(
      onTap: () async {},
      child: Container(
        width: size.width * 90 / 100,
        decoration: _eventCardDecoration(context),
        child: Column(
          children: [
            // Event image
            SizedBox(
              width: size.width * 90 / 100,
              height: size.height * 26 / 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl:
                      "${AppConfigProvider.imageUrl}${event['event_image']}",
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    AppImage.dummyImageIcon,
                    fit: BoxFit.cover,
                  ),
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.dotsTriangle(
                      color: AppColor.buttonColor,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
            // Details
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 3 / 100,
                vertical: size.height * 1 / 100,
              ),
              child: Column(
                children: [
                  // Name + heart icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['event_name'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: size.width * 8 / 100,
                        height: size.width * 8 / 100,
                        child: Image.asset(
                          AppImage.liked_heart_icon,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.4 / 100),
                  // Time
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 4.5 / 100,
                        height: size.width * 4.5 / 100,
                        child: Image.asset(
                          AppImage.newCalenderPinkIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: size.width * 1.5 / 100),
                      Text(
                        event['date'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: AppColor.secondryColor(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 1 / 100),
                  // Address
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 5 / 100,
                        height: size.width * 5 / 100,
                        child: Image.asset(
                          AppImage.locationIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          event['address'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: AppColor.secondryColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 1.5 / 100),
                  // View Details button
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: LikedEventDetail(
                            eventId: event["_id"],
                          ),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                      await _handleEventDetailResult(result);
                    },
                    child: Container(
                      height: size.height * 6 / 100,
                      decoration: _eventActionButtonDecoration(),
                      child: Center(
                        child: Text(
                          AppLanguage.viewDetailstext[language],
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: AppColor.pinkColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  // ══════════════════════════════════════════════════════════════════════════
  // BOOKED TAB
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildBookedTab(BuildContext context, Size size) {
    return Consumer<LikedBookedEventController>(
      builder: (context, controller, _) {
        if (controller.isBookedEventsLoading) {
          return Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: AppColor.buttonColor,
              size: 40,
            ),
          );
        }

        return SingleChildScrollView(
          controller: _bookedScrollController,
          child: Center(
            child: SizedBox(
              width: size.width * 90 / 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.upcomingEvents.isNotEmpty)
                    Text(
                      AppLanguage.confirmBookeddetailsText[language],
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.normal,
                        color: AppColor.secondryColor(context),
                      ),
                    ),
                  SizedBox(height: size.height * 1.5 / 100),
                  if (controller.upcomingEvents.isNotEmpty)
                    Text(
                      AppLanguage.upcomingEventstext[language],
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.pinkColor,
                      ),
                    ),
                  SizedBox(height: size.height * 2 / 100),
                  if (controller.upcomingEvents.isEmpty)
                    SizedBox(
                      height: size.height * 30 / 100,
                      child: Center(
                        child: Text(
                          'No upcoming events',
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...controller.upcomingEvents.map(
                      (booking) => Padding(
                        padding:
                            EdgeInsets.only(bottom: size.height * 1.5 / 100),
                        child: _buildUpcomingCard(context, booking, size),
                      ),
                    ),
                  if (controller.pastBookings.isNotEmpty ||
                      controller.isPastLoadingMore) ...[
                    SizedBox(height: size.height * 1 / 100),
                    Text(
                      AppLanguage.pastEventsText[language],
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.pinkColor,
                      ),
                    ),
                    SizedBox(height: size.height * 2 / 100),
                    SizedBox(
                      width: size.width,
                      height: size.height * 28 / 100,
                      child: ListView.builder(
                        controller: _pastHorizontalScrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.pastBookings.length +
                            (controller.isPastLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.pastBookings.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 4 / 100),
                              child: Center(
                                child: LoadingAnimationWidget.dotsTriangle(
                                  color: AppColor.buttonColor,
                                  size: 30,
                                ),
                              ),
                            );
                          }

                          final pastEvent = controller.pastBookings[index];
                          return Padding(
                            padding:
                                EdgeInsets.only(right: size.width * 4 / 100),
                            child: GestureDetector(
                              onTap: () {},
                              child: _buildPastCard(context, pastEvent, size),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: size.height * 3 / 100),
                  ] else if (controller.upcomingEvents.isEmpty) ...[
                    SizedBox(height: size.height * 1 / 100),
                    Text(
                      AppLanguage.pastEventsText[language],
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColor.pinkColor,
                      ),
                    ),
                    SizedBox(height: size.height * 2 / 100),
                    Text(
                      'No past bookings',
                      style: TextStyle(
                        color: AppColor.secondryColor(context),
                        fontFamily: AppFont.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: size.height * 3 / 100),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Upcoming events card ───────────────────────────────────────────────────
  Widget _buildUpcomingCard(
      BuildContext context, Map<String, dynamic> booking, Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: BookedEventDetails(
              bookingId: booking['booking_id'].toString(),
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        width: size.width * 90 / 100,
        decoration: _eventCardDecoration(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            SizedBox(
              width: size.width * 90 / 100,
              height: size.height * 26 / 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl:
                      "${AppConfigProvider.imageUrl}${booking['event_image']}",
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    AppImage.dummyImageIcon,
                    fit: BoxFit.cover,
                  ),
                  placeholder: (context, url) => Center(
                    child: LoadingAnimationWidget.dotsTriangle(
                      color: AppColor.buttonColor,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),

            // Details section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 3 / 100,
                vertical: size.height * 1 / 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking['event_name'] ?? '',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.8 / 100),

                  // Date
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 4.5 / 100,
                        height: size.width * 4.5 / 100,
                        child: Image.asset(
                          AppImage.newCalenderPinkIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: size.width * 1.5 / 100),
                      Text(
                        _formatSlotTime(booking['date']),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: AppColor.secondryColor(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.8 / 100),

                  // Location
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 5 / 100,
                        height: size.width * 5 / 100,
                        child: Image.asset(
                          AppImage.locationIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          booking['address'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                            color: AppColor.secondryColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 1.5 / 100),

                  // View details button
                  Container(
                    height: size.height * 6 / 100,
                    decoration: _eventActionButtonDecoration(),
                    child: Center(
                      child: Text(
                        AppLanguage.viewDetailstext[language],
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: AppColor.pinkColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Past event card ────────────────────────────────────────────────────────
  Widget _buildPastCard(
      BuildContext context, Map<String, dynamic> pastEvent, Size size) {
    return Container(
      width: size.width * 37 / 100,
      decoration: _eventCardDecoration(context, radius: 10),
      child: Column(
        children: [
          // Image
          SizedBox(
            width: size.width * 35 / 100,
            height: size.height * 15 / 100,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: CachedNetworkImage(
                imageUrl:
                    "${AppConfigProvider.imageUrl}${pastEvent['event_image']}",
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  AppImage.dummyImageIcon,
                  fit: BoxFit.cover,
                ),
                placeholder: (context, url) => Center(
                  child: LoadingAnimationWidget.dotsTriangle(
                    color: AppColor.buttonColor,
                    size: 35,
                  ),
                ),
              ),
            ),
          ),

          // Title
          Container(
            width: size.width * 30 / 100,
            child: Text(
              pastEvent['event_name'] ?? "",
              style: TextStyle(
                fontSize: 9,
                fontFamily: AppFont.fontFamily,
                fontWeight: FontWeight.w600,
                color: AppColor.secondryColor(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: size.height * 0.5 / 100),

          // Date
          Container(
            width: size.width * 30 / 100,
            child: Row(
              children: [
                SizedBox(
                  width: size.width * 2.5 / 100,
                  height: size.width * 2.5 / 100,
                  child: Image.asset(
                    AppImage.newCalenderPinkIcon,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: size.width * 1.5 / 100),
                Text(
                  pastEvent['date'] ?? "",
                  style: TextStyle(
                    fontSize: 7,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                    color: AppColor.secondryColor(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.5 / 100),

          // Address
          Container(
            width: size.width * 30 / 100,
            child: Row(
              children: [
                SizedBox(
                  width: size.width * 2.5 / 100,
                  height: size.width * 2.5 / 100,
                  child: Image.asset(
                    AppImage.locationIcon,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: size.width * 1.5 / 100),
                Expanded(
                  child: Text(
                    pastEvent['address'] ?? "",
                    style: TextStyle(
                      fontSize: 7,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      color: AppColor.secondryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 2 / 100),

          // Review button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: BookedEventDetails(
                    bookingId: pastEvent['booking_id'],
                    isRating: true,
                  ),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            },
            child: Container(
              height: size.height * 4.5 / 100,
              width: size.width * 35 / 100,
              decoration: _eventActionButtonDecoration(radius: 8),
              child: const Center(
                child: Text(
                  "Review",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w500,
                    color: AppColor.pinkColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 78 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 78 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor(context),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          width: size.width * 1.0,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Container(
                                width: size.width * 0.88,
                                child: Column(
                                  children: [
                                    // First Image

                                    Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        AppImage.dashIcon,
                                        height: size.height * 0.5 / 100,
                                        width: size.width * 22 / 100,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 4 / 100),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage.myspacetext[language],
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .eventStatementtext[language],
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.04),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: splashMembers(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.memberBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: size.height *
                                            0.02), // spacing between images
                                    // Second Image
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: MyVenue(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.venuesBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: MyVenue(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.eventsBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //     height: size.height * 0.06),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    ).then((_) {});
  }

  Widget dropdownItem(String text, VoidCallback onTap, bool isActive) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color:
              isActive ? AppColor.dropdownColor(context) : Colors.transparent,
          borderRadius: isActive
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                )
              : BorderRadius.zero,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive
                ? AppColor.secondryColor(context)
                : AppColor.greyLightColor(context),
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget divider() {
    return const Divider(
      color: Colors.grey,
      height: 1,
      thickness: 0.5,
    );
  }
}
