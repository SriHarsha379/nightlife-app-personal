import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../../controller/home/home_controller.dart';
import '../../../../controller/my_profile/get_my_profile.dart';
import '../../../../controller/venues/my_venues_controller.dart';
import '../../../../provider/darkmode_provider.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_header.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import 'venuepages.dart';

class ViewAllVenuesScreen extends StatefulWidget {
  static String routeName = './ViewAllVenuesScreen';
  const ViewAllVenuesScreen({super.key});
  @override
  State<ViewAllVenuesScreen> createState() => _ViewAllVenuesScreenState();
}

class _ViewAllVenuesScreenState extends State<ViewAllVenuesScreen> {
  final ScrollController _likedScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initial fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<MyVenuesController>(context, listen: false);
      controller.fetchMyVenues(context, type: 'liked', page: 0, limit: 10);
    });

    // Load more on scroll
    _likedScrollController.addListener(() {
      final controller =
          Provider.of<MyVenuesController>(context, listen: false);
      if (_likedScrollController.position.pixels >=
              _likedScrollController.position.maxScrollExtent - 200 &&
          controller.hasMoreLiked &&
          !controller.isLikedLoadingMore) {
        controller.loadMoreLiked(context, limit: 10);
      }
    });
  }

  @override
  void dispose() {
    _likedScrollController.dispose();
    super.dispose();
  }

  bool _isDarkMode(BuildContext context) {
    return context.read<ThemeProvider>().isDarkMode;
  }

  BoxDecoration _venueCardDecoration(
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

  BoxDecoration _venueActionButtonDecoration(
    BuildContext context, {
    double radius = 10,
  }) {
    final isDark = _isDarkMode(context);
    return BoxDecoration(
      color: isDark
          ? AppColor.secondryColor(context).withOpacity(0.08)
          : AppColor.pinkColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColor.pinkColor.withOpacity(isDark ? 0.3 : 0.6),
        width: 1.2,
      ),
    );
  }

  Future<void> _handleVenueDetailResult(dynamic result) async {
    if (result is! Map) return;

    final action = (result['action'] ?? '').toString().trim().toLowerCase();
    final targetVenueId = (result['targetVenueId'] ?? '').toString().trim();
    if (targetVenueId.isEmpty) return;

    final homeController = Provider.of<HomeController>(context, listen: false);
    if (action == 'dislike') {
      await homeController.dislikeItem(context, targetVenueId, 'venue');
    } else if (action == 'like') {
      await homeController.likeItem(context, targetVenueId, 'venue');
    } else {
      return;
    }

    if (!mounted) return;
    final controller = Provider.of<MyVenuesController>(context, listen: false);
    await controller.fetchMyVenues(context, type: 'liked', page: 0, limit: 10);
    final profileController =
        Provider.of<ProfileController>(context, listen: false);
    profileController.fetchProfileData(context);
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
                SizedBox(height: size.height * 5 / 100),
                AppHeader(
                  onPress: () => Navigator.pop(context),
                  text: AppLanguage.likedVenues1text[language],
                ),
                SizedBox(height: size.height * 2 / 100),
                Expanded(
                  child: Consumer<MyVenuesController>(
                    builder: (context, controller, _) {
                      // ── Initial loading ──────────────────────────────────
                      if (controller.isLikedVenuesLoading) {
                        return Center(
                          child: LoadingAnimationWidget.dotsTriangle(
                            color: AppColor.buttonColor,
                            size: 40,
                          ),
                        );
                      }

                      final venues = controller.likedVenues;

                      // ── Empty state ──────────────────────────────────────
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

                      // ── List ─────────────────────────────────────────────
                      return ListView.builder(
                        controller: _likedScrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 5 / 100,
                        ),
                        itemCount: venues.length +
                            (controller.isLikedLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Load-more spinner at the bottom
                          if (index == venues.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: size.height * 2 / 100),
                              child: Center(
                                child: LoadingAnimationWidget.dotsTriangle(
                                  color: AppColor.buttonColor,
                                  size: 30,
                                ),
                              ),
                            );
                          }

                          final venue = venues[index] as Map<String, dynamic>;
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: size.height * 1.5 / 100),
                            child: _buildLikedVenueCard(context, venue, size),
                          );
                        },
                      );
                    },
                  ),
                ),
                SizedBox(height: size.height * 1.5 / 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLikedVenueCard(
      BuildContext context, Map<String, dynamic> venue, Size size) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: VenuePages(
              venueId: venue['_id'].toString(),
              forceDislikeOnly: true,
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
        await _handleVenueDetailResult(result);
      },
      child: Container(
        width: size.width * 90 / 100,
        decoration: _venueCardDecoration(context),
        child: Column(
          children: [
            // Venue image
            SizedBox(
              width: size.width * 90 / 100,
              height: size.height * 26 / 100,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
}
