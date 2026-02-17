import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:night_life/controller/venues/my_venues_controller.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/booked_view_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/past_venue_screeen.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_footer.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../MembersSection/Members.dart';

class MyVenue extends StatefulWidget {
  static const String routeName = '/MyVenue';
  const MyVenue({super.key});

  @override
  State<MyVenue> createState() => _MyVenueState();
}

class _MyVenueState extends State<MyVenue> {
  int selectedIndex = 0;

  // ── Dummy past events (unchanged — API not ready) ──────────────────────────
  final List<Map<String, dynamic>> pastEventlist = [
    {
      'image': AppImage.eventImage3,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
    },
    {
      'image': AppImage.eventImage4,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
    },
    {
      'image': AppImage.eventImage5,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
    },
  ];

  // ── Scroll controllers for load more ──────────────────────────────────────
  late final ScrollController _likedScrollController;
  late final ScrollController _reservedScrollController;

  @override
  void initState() {
    super.initState();

    _likedScrollController = ScrollController()..addListener(_onLikedScroll);
    _reservedScrollController = ScrollController()
      ..addListener(_onReservedScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLiked();
    });
  }

  void _fetchLiked() {
    Provider.of<MyVenuesController>(context, listen: false).fetchMyVenues(
      context,
      type: 'liked',
      page: 0,
      limit: 5,
    );
  }

  void _fetchReserved() {
    Provider.of<MyVenuesController>(context, listen: false).fetchMyVenues(
      context,
      type: 'reserved',
      page: 0,
      limit: 5,
    );
  }

  void _onLikedScroll() {
    if (_likedScrollController.position.pixels >=
        _likedScrollController.position.maxScrollExtent - 200) {
      Provider.of<MyVenuesController>(context, listen: false)
          .loadMoreLiked(context);
    }
  }

  void _onReservedScroll() {
    if (_reservedScrollController.position.pixels >=
        _reservedScrollController.position.maxScrollExtent - 200) {
      Provider.of<MyVenuesController>(context, listen: false)
          .loadMoreReserved(context);
    }
  }

  @override
  void dispose() {
    _likedScrollController.dispose();
    _reservedScrollController.dispose();
    super.dispose();
  }

  // ── Helper: format date string ─────────────────────────────────────────────
  String _formatSlotTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('EEE, dd MMM • h:mm a').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
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
                // ── Status bar spacer ────────────────────────────────────────
                SizedBox(height: size.height * 4.5 / 100),

                // ── App bar ──────────────────────────────────────────────────
                Center(
                  child: SizedBox(
                    width: size.width * 90 / 100,
                    height: size.height * 7 / 100,
                    child: Row(
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: MyAppFooter(initialIndex: 0),
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
                        // Title
                        GestureDetector(
                          onTap: () => documenttypebottomsheet(context),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              AppLanguage.myvenueText[language],
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
                        // Down arrow
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
                        label: AppLanguage.ReservedText[language],
                        index: 1,
                        size: size,
                        onTap: () {
                          setState(() => selectedIndex = 1);
                          _fetchReserved();
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
                      : _buildReservedTab(context, size),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab widget ─────────────────────────────────────────────────────────────
  Widget _buildTab(
    BuildContext context, {
    required String label,
    required int index,
    required Size size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
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

  // ── Tab indicator bar ──────────────────────────────────────────────────────
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
    return Consumer<MyVenuesController>(
      builder: (context, controller, _) {
        if (controller.isLikedVenuesLoading) {
          return Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: AppColor.buttonColor,
              size: 40,
            ),
          );
        }

        final venues = controller.likedVenues;

        if (venues.isEmpty) {
          return Center(
            child: Text(
              'No liked venues yet',
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
          itemCount: venues.length + (controller.isLikedLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Load more indicator at the bottom
            if (index == venues.length) {
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

            final venue = venues[index];
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 1.5 / 100),
              child: _buildLikedVenueCard(context, venue, size),
            );
          },
        );
      },
    );
  }

  Widget _buildLikedVenueCard(
      BuildContext context, Map<String, dynamic> venue, Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: VenuePages(venueId: venue['_id'].toString()),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        width: size.width * 90 / 100,
        decoration: BoxDecoration(
          color: AppColor.primaryColor(context),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // Venue image
            SizedBox(
              width: size.width * 90 / 100,
              height: size.width * 42 / 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: CachedNetworkImage(
                  imageUrl:
                      "${AppConfigProvider.imageUrl}${venue['venue_image']}",
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
                          venue['venue_name'] ?? '',
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
                          color: AppColor.secondryColor(context),
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
                          AppImage.calenderPinkIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: size.width * 1 / 100),
                      Text(
                        venue['date'] ?? '',
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
                          venue['location'] ?? '',
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
                  // Reserve table button
                  Container(
                    height: size.height * 6 / 100,
                    decoration: BoxDecoration(
                      color: AppColor.secondryColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        AppLanguage.ReservedtableText[language],
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

  // RESERVED TAB
  Widget _buildReservedTab(BuildContext context, Size size) {
    return Consumer<MyVenuesController>(
      builder: (context, controller, _) {
        if (controller.isReservedVenuesLoading) {
          return Center(
            child: LoadingAnimationWidget.dotsTriangle(
              color: AppColor.buttonColor,
              size: 40,
            ),
          );
        }

        return SingleChildScrollView(
          controller: _reservedScrollController,
          child: Center(
            child: SizedBox(
              width: size.width * 90 / 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Description ──────────────────────────────────────────
                  Text(
                    AppLanguage.ReserveddetailsText[language],
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.normal,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                  SizedBox(height: size.height * 1.5 / 100),

                  // ── Upcoming reservations heading ─────────────────────────
                  Text(
                    AppLanguage.upcomingReservationsText[language],
                    style: const TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.pinkColor,
                    ),
                  ),
                  SizedBox(height: size.height * 2 / 100),

                  // ── Upcoming list ─────────────────────────────────────────
                  if (controller.upcomingReservations.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: size.height * 2 / 100),
                      child: Text(
                        'No upcoming reservations',
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontFamily: AppFont.fontFamily,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    ...controller.upcomingReservations.map(
                      (booking) => Padding(
                        padding:
                            EdgeInsets.only(bottom: size.height * 1.5 / 100),
                        child: _buildUpcomingCard(context, booking, size),
                      ),
                    ),

                  // ── Load more upcoming button ──────────────────────────────
                  if (controller.hasMoreReserved) ...[
                    if (controller.isReservedLoadingMore)
                      Center(
                        child: Padding(
                          padding:
                              EdgeInsets.only(bottom: size.height * 1.5 / 100),
                          child: LoadingAnimationWidget.dotsTriangle(
                            color: AppColor.buttonColor,
                            size: 30,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 2 / 100),
                        child: GestureDetector(
                          onTap: () => controller.loadMoreReserved(context),
                          child: Container(
                            height: size.height * 5 / 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColor.pinkColor, width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Load more',
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
                      ),
                  ],

                  // ── Past reservations heading ─────────────────────────────
                  SizedBox(height: size.height * 1 / 100),
                  Text(
                    AppLanguage.pastReservationsText[language],
                    style: const TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColor.pinkColor,
                    ),
                  ),
                  SizedBox(height: size.height * 2 / 100),

                  // ── Past list (horizontal) — dummy data, unchanged ────────
                  SizedBox(
                    width: size.width,
                    height: size.height * 28 / 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: pastEventlist.length,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(right: size.width * 4 / 100),
                        child: GestureDetector(
                          onTap: () {},
                          child: _buildPastCard(
                              context, pastEventlist[index], size),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 3 / 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Upcoming reservation card ──────────────────────────────────────────────
  Widget _buildUpcomingCard(
      BuildContext context, Map<String, dynamic> booking, Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: BookedViewDetails(
              image: "${AppConfigProvider.imageUrl}${booking['venue_image']}",
              name: booking['venue_name'] ?? '',
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      },
      child: Container(
        width: size.width * 90 / 100,
        decoration: BoxDecoration(
          color: AppColor.primaryColor(context),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue image
            SizedBox(
              width: size.width * 90 / 100,
              height: size.width * 42 / 100,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl:
                      "${AppConfigProvider.imageUrl}${booking['venue_image']}",
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
                  // Name + booking status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking['venue_name'] ?? '',
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

                  // Slot time
                  Row(
                    children: [
                      SizedBox(
                        width: size.width * 4.5 / 100,
                        height: size.width * 4.5 / 100,
                        child: Image.asset(
                          AppImage.calenderPinkIcon,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: size.width * 1 / 100),
                      Text(
                        _formatSlotTime(booking['slot_time']),
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
                          booking['location'] ?? '',
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
                  SizedBox(height: size.height * 0.8 / 100),

                  // Guests count
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: size.width * 4.5 / 100,
                        color: AppColor.pinkColor,
                      ),
                      SizedBox(width: size.width * 1 / 100),
                      Text(
                        '${booking['number_of_guests'] ?? 0} guests',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: AppColor.secondryColor(context),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 1.5 / 100),

                  // View details button
                  Container(
                    height: size.height * 6 / 100,
                    decoration: BoxDecoration(
                      color: AppColor.secondryColor(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
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

  // ── Past event card (unchanged design) ────────────────────────────────────
  Widget _buildPastCard(
      BuildContext context, Map<String, dynamic> event, Size size) {
    return Container(
      width: size.width * 37 / 100,
      decoration: BoxDecoration(
        color: AppColor.primaryColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.startingscreenColor),
      ),
      child: Column(
        children: [
          // Image
          Container(
            width: size.width * 35 / 100,
            height: size.height * 15 / 100,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.asset(
                event['image'],
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title
          Container(
            width: size.width * 30 / 100,
            child: Text(
              event['title'],
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
                    AppImage.calenderPinkIcon,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: size.width * 1.5 / 100),
                Text(
                  event['date'],
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
                    event['address'],
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
                  child: PastVenueScreen(),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            },
            child: Container(
              height: size.height * 4.5 / 100,
              width: size.width * 35 / 100,
              decoration: BoxDecoration(
                color: AppColor.secondryColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
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

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

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
                : AppColor.greyLightColor,
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
