import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/controller/home/home_controller.dart';
import 'package:night_life/controller/venues/venues_details_controller.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/book_venue_table.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utilities/app_color.dart';
import '../../../../commonWidget/artist_image_preview.dart';
import '../../../../commonWidget/event_types_bottomsheet.dart';
import '../../../../commonWidget/show_images_bottomsheet.dart';
import '../../../../provider/darkmode_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../../../../utilities/app_config_provider.dart';

class VenuePages extends StatefulWidget {
  static String routeName = './VenuePages';
  final String? venueId;
  final bool forceDislikeOnly;

  const VenuePages({
    super.key,
    this.venueId,
    this.forceDislikeOnly = false,
  });

  @override
  State<VenuePages> createState() => _VenuePagesState();
}

class _VenuePagesState extends State<VenuePages> {
  late TextEditingController searchController;
  Map<String, String>? _swipeResult;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Helper method to safely extract string
  String _str(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  Future<void> _openVenueLocationInMaps(Map<String, dynamic> venueData) async {
    final latitude = venueData['latitude'];
    final longitude = venueData['longitude'];
    final address = _str(venueData['address']).trim();

    Uri? uri;
    if (latitude != null && longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
    } else if (address.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    }

    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open location')),
      );
    }
  }

  // Helper method to build image URL
  String _asUploadUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${AppConfigProvider.imageUrl}$path';
  }

  // Extract category names from categories list
  List<String> _extractCategoryNames(dynamic categories) {
    if (categories == null) return [];
    if (categories is List) {
      return categories
          .where((cat) => cat is Map && cat['name'] != null)
          .map((cat) => cat['name'].toString())
          .toList();
    }
    return [];
  }

  // Extract event category names
  List<String> _extractEventCategoryNames(dynamic categories) {
    if (categories == null) return [];
    if (categories is List) {
      return categories
          .where((cat) => cat is Map && cat['name'] != null)
          .map((cat) => cat['name'].toString())
          .take(3) // Limit to 3 tags
          .toList();
    }
    return [];
  }

  void _openLineupImagePreview(
    BuildContext context,
    String imagePath,
  ) {
    if (imagePath.trim().isEmpty) return;

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: LineupArtistPreviewScreen(imagePath: imagePath),
      ),
    );
  }

  // Build adaptive image (network or asset fallback)
  Widget _buildAdaptiveImage(String url,
      {BoxFit fit = BoxFit.cover, String? fallbackAsset}) {
    if (url.isEmpty) {
      return Image.asset(fallbackAsset ?? AppImage.dummyImageIcon, fit: fit);
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(fallbackAsset ?? AppImage.dummyImageIcon, fit: fit);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: AppColor.buttonColor,
          ),
        );
      },
    );
  }

  int selectedId = 2;

  List shareIcons = [
    "assets/icons/shareIcon.png",
    "assets/icons/whatsappIcon.png",
    "assets/icons/instaIcon.png",
    "assets/icons/snapIcon.png",
  ];

  List<String> disabledDays = [];

  // Get recent events list
  List<dynamic> get _recentEvents {
    final controller =
        Provider.of<VenuesDetailsController>(context, listen: false);
    final venueData = controller.getVenuesDetail;
    if (venueData != null && venueData['upcoming_events'] is List) {
      return venueData['upcoming_events'];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    // Fetch venue details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<VenuesDetailsController>(context, listen: false);
      controller.fetchVenuesDetail(context, venueId: widget.venueId.toString());
    });
  }

  String _targetVenueId(dynamic venueDataId) {
    final fromData = _str(venueDataId).trim();
    if (fromData.isNotEmpty) return fromData;
    return _str(widget.venueId).trim();
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    final str = _str(value).trim().toLowerCase();
    return str == 'true' || str == '1';
  }

  Future<void> _submitVenueSwipeAction(
    String action, {
    required String targetVenueId,
  }) async {
    if (targetVenueId.isEmpty) return;
    _swipeResult = {
      'action': action, // like | dislike
      'targetVenueId': targetVenueId,
    };
    if (!mounted) return;
    Navigator.pop(context, _swipeResult);
  }

  Future<void> _handleEventSwipeResult(Map<String, dynamic>? result) async {
    if (result == null) return;
    final action = _str(result['action']).trim().toLowerCase();
    final targetEventId = _str(result['targetEventId']).trim();
    if (targetEventId.isEmpty) return;

    final homeController = Provider.of<HomeController>(context, listen: false);
    if (action == 'dislike') {
      await homeController.dislikeItem(context, targetEventId, 'event');
    } else if (action == 'like') {
      await homeController.likeItem(context, targetEventId, 'event');
    }
  }

  Future<void> _openLikedEventDetail(String eventId) async {
    if (eventId.trim().isEmpty) return;
    final result = await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: LikedEventDetail(
          eventId: eventId,
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
    if (!mounted) return;
    await _handleEventSwipeResult(
        result is Map ? Map<String, dynamic>.from(result) : null);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<VenuesDetailsController>(
      builder: (context, controller, child) {
        final venueData = controller.getVenuesDetail;
        final isLoading = controller.isVenuesDetailLoading;

        // Show loading indicator
        if (isLoading) {
          return Scaffold(
            backgroundColor: AppColor.primaryColor(context),
            body: Center(
              child: CircularProgressIndicator(
                color: AppColor.buttonColor,
              ),
            ),
          );
        }

        // Show error if no data
        if (venueData == null) {
          return Scaffold(
            backgroundColor: AppColor.primaryColor(context),
            body: Center(
              child: Text(
                'Failed to load venue details',
                style: TextStyle(
                  color: AppColor.secondryColor(context),
                  fontSize: 16,
                  fontFamily: AppFont.fontFamily,
                ),
              ),
            ),
          );
        }

        final venueName = _str(venueData['venue_name']);
        final venueImage = _asUploadUrl(_str(venueData['venue_image']));
        final categories = _extractCategoryNames(venueData['categories']);
        final totalLikes = venueData['total_likes'] ?? 0;
        final openDays = _str(venueData['open_days']);
        final timing = _str(venueData['timing']);
        final address = _str(venueData['address']);
        final distanceKm = venueData['distance_km'];
        final gallery = venueData['gallery'] as List? ?? [];
        final about = _str(venueData['about']);
        final tickets = venueData['tickets'] as Map<String, dynamic>? ?? {};
        final reservationFee = tickets['reservation_fee'] ?? 0;
        final isLiked = _toBool(venueData['is_liked']);
        final showDislikeOnly = widget.forceDislikeOnly || isLiked;
        final targetVenueId = _targetVenueId(venueData['_id']);

        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDark = themeProvider.isDarkMode;
        return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  isDark ? Brightness.dark : Brightness.light, // iOS
            ),
            child: WillPopScope(
              onWillPop: () async {
                if (_swipeResult != null) {
                  Navigator.pop(context, _swipeResult);
                  return false;
                }
                return true;
              },
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,
                  floatingActionButton: Container(
                    decoration: BoxDecoration(
                      color: AppColor.sendinvitecontainercolor(context)
                          .withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: showDislikeOnly
                        ? size.width * 52 / 100
                        : size.width * 85 / 100,
                    height: size.height * 7 / 100,
                    child: Row(
                      children: [
                        SizedBox(width: size.width * 3 / 100),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            await _submitVenueSwipeAction(
                              'dislike',
                              targetVenueId: targetVenueId,
                            );
                          },
                          child: Container(
                            width: size.width * 12 / 100,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              ),
                              child: Image.asset(
                                AppImage.crossIcon,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 3 / 100),
                        GestureDetector(
                          onTap: () {
                            documenttypebottomsheet(
                              context,
                              sharedVenueData:
                                  Map<String, dynamic>.from(venueData),
                            );
                          },
                          child: Container(
                            width: size.width * 30 / 100,
                            height: size.height * 4.6 / 100,
                            decoration: BoxDecoration(
                              color: AppColor.secondryColor(context),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                AppLanguage.sendInviteText[language],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.pinkColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (!showDislikeOnly) ...[
                          SizedBox(width: size.width * 3 / 100),
                          GestureDetector(
                            onTap: () async {
                              await _submitVenueSwipeAction(
                                'like',
                                targetVenueId: targetVenueId,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColor.buttonColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppImage.heartImg,
                                    height: 20,
                                    width: 20,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    AppLanguage.likeText[language],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontFamily,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  backgroundColor: AppColor.primaryColor(context),
                  body: Container(
                    height: size.height * 100 / 100,
                    width: size.width * 100 / 100,
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 4 / 100),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _openLineupImagePreview(
                                    context,
                                    (venueImage).toString(),
                                  );
                                },
                                child: Container(
                                  width: size.width * 100 / 100,
                                  height: size.height * 28 / 100,
                                  child: ClipRRect(
                                    child: venueImage.isNotEmpty
                                        ? _buildAdaptiveImage(
                                            venueImage,
                                            fit: BoxFit.fill,
                                            fallbackAsset:
                                                AppImage.dummyImageIcon,
                                          )
                                        : Image.asset(
                                            AppImage.dummyImageIcon,
                                            fit: BoxFit.fill,
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 26,
                                left: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_swipeResult != null) {
                                      Navigator.pop(context, _swipeResult);
                                      return;
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Image.asset(
                                    AppImage.backarrow,
                                    color: AppColor.secondryColor(context),
                                    fit: BoxFit.cover,
                                    height: size.width * 5 / 100,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 2 / 100),
                          Container(
                            width: size.width * 90 / 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: size.width * 75 / 100,
                                            child: Text(
                                              venueName,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w700,
                                                color: AppColor.secondryColor(
                                                    context),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: size.height * 2 / 100),
                                          Row(
                                            children: categories
                                                .take(3)
                                                .map((category) => Container(
                                                      margin: EdgeInsets.only(
                                                          right: size.width *
                                                              2 /
                                                              100),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 1,
                                                          color: AppColor
                                                              .pinkColor,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal:
                                                              size.width *
                                                                  3 /
                                                                  100,
                                                          vertical: 1,
                                                        ),
                                                        child: Text(
                                                          category,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
                                                          ),
                                                        ),
                                                      ),
                                                    ))
                                                .toList(),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            width: size.width * 13 / 100,
                                            height: size.width * 13 / 100,
                                            child: Image.asset(
                                              AppImage.likeimg,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Text(
                                            totalLikes >= 1000
                                                ? "${(totalLikes / 1000).toStringAsFixed(1)}K"
                                                : totalLikes.toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  AppColor.spancolor(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 3 / 100),
                          SizedBox(
                            width: size.width * 92 / 100,
                            child: Row(
                              children: [
                                Container(
                                  width: size.width * 4.5 / 100,
                                  height: size.width * 4.5 / 100,
                                  child: ClipRRect(
                                    child: Image.asset(
                                      AppImage.calenderPinkIcon,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 2 / 100),
                                Text(
                                  "Open Hours: $openDays",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 2 / 100),
                          SizedBox(
                            width: size.width * 92 / 100,
                            child: Row(
                              children: [
                                Container(
                                  width: size.width * 4.5 / 100,
                                  height: size.width * 4.5 / 100,
                                  child: ClipRRect(
                                    child: Image.asset(
                                      AppImage.clock,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 2 / 100),
                                Text(
                                  timing,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 2 / 100),
                          GestureDetector(
                            onTap: address.trim().isEmpty
                                ? null
                                : () => _openVenueLocationInMaps(venueData),
                            child: SizedBox(
                              width: size.width * 92 / 100,
                              child: Row(
                                children: [
                                  Container(
                                    width: size.width * 4.5 / 100,
                                    height: size.width * 4.5 / 100,
                                    child: ClipRRect(
                                      child: Image.asset(
                                        AppImage.locationIcon,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 2 / 100),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          address,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                        if (distanceKm != null)
                                          Text(
                                            "$distanceKm km away",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.greyLightColor(
                                                  context),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 3 / 100),
                          if (gallery.isNotEmpty) ...[
                            SizedBox(
                              width: size.width * 90 / 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLanguage.GalleryText[language],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Open gallery bottom sheet with API images
                                      final List<String> galleryImagesList =
                                          gallery
                                              .map((img) => _str(img))
                                              .toList();

                                      GalleryBottomSheet.show(
                                        context,
                                        galleryImages: galleryImagesList,
                                        initialIndex: 0,
                                      );
                                    },
                                    child: Container(
                                      child: Text(
                                        AppLanguage.viewAlltext[language],
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
                            SizedBox(height: size.height * 2 / 100),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: gallery.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final imageUrl =
                                      _asUploadUrl(_str(entry.value));
                                  return GestureDetector(
                                    onTap: () {
                                      // Open gallery bottom sheet at clicked image index
                                      final List<String> galleryImagesList =
                                          gallery
                                              .map((img) => _str(img))
                                              .toList();

                                      GalleryBottomSheet.show(
                                        context,
                                        galleryImages: galleryImagesList,
                                        initialIndex: index,
                                      );
                                    },
                                    child: Container(
                                      width: size.width * 55 / 100,
                                      height: size.height * 15 / 100,
                                      margin: EdgeInsets.only(
                                        left: index == 0 ? 19 : 10,
                                        right: 10,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: imageUrl.isNotEmpty
                                            ? _buildAdaptiveImage(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                fallbackAsset:
                                                    AppImage.dummyImageIcon,
                                              )
                                            : Image.asset(
                                                AppImage.dummyImageIcon,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: size.height * 0.04),
                          ],
                          if (about.isNotEmpty) ...[
                            SizedBox(
                              width: size.width * 0.90,
                              child: Text(
                                AppLanguage.aboutText[language],
                                style: TextStyle(
                                  color: AppColor.secondryColor(context),
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 1 / 100),
                            SizedBox(
                              width: size.width * 90 / 100,
                              child: ReadMoreText(
                                about,
                                trimLines: 3,
                                trimMode: TrimMode.Line,
                                trimCollapsedText: 'Read More',
                                trimExpandedText: ' Read Less',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.normal,
                                  color: AppColor.greyLightColor(context),
                                ),
                                moreStyle: const TextStyle(
                                  fontSize: 15,
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                ),
                                lessStyle: const TextStyle(
                                  fontSize: 15,
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 2 / 100),
                          ],
                          SizedBox(
                            width: size.width * 92 / 100,
                            child: Text(
                              AppLanguage.upcomingEventstext[language],
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 2 / 100),
                          SizedBox(
                            height: size.height * 30 / 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(left: 19),
                              itemCount: _recentEvents.isEmpty
                                  ? 1
                                  : _recentEvents.length,
                              itemBuilder: (context, index) {
                                if (_recentEvents.isEmpty) {
                                  return _recentEventCard(
                                    image: AppImage.eventCardImage,
                                    name: "No upcoming events",
                                    time: "",
                                    tags: [],
                                    isNetwork: false,
                                  );
                                }
                                final item = _recentEvents[index];
                                final eventId = _str(item['_id']);
                                return GestureDetector(
                                  onTap: () async {
                                    await _openLikedEventDetail(eventId);
                                  },
                                  child: _recentEventCard(
                                    image: _asUploadUrl(item['event_image']),
                                    name: _str(item['event_name']),
                                    time: _str(item['date']),
                                    tags: [], // Events don't have categories in the response
                                    isNetwork: true,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: size.height * 3 / 100),
                          SizedBox(
                            width: size.width * 88 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Text(
                                    AppLanguage.TicketText[language],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 2 / 100),
                          Container(
                            width: size.width * 90 / 100,
                            height: size.height * 18 / 100,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: BoxDecoration(
                              color: AppColor.backgroundColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 4 / 100,
                                    vertical: size.height * 2 / 100,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            width: size.width * 25 / 100,
                                            child: Text(
                                              AppLanguage
                                                  .reservationsText[language],
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: size.width * 25 / 100,
                                            child: Text(
                                              "₹$reservationFee",
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeftWithFade,
                                              child: BookTable(
                                                venueId: widget.venueId,
                                                // venueName: venueName.toString(),
                                                // venueAddress: address,
                                                // // venueImage: venueImage,
                                                // venueLikes: totalLikes,
                                              ),
                                              duration: const Duration(
                                                  milliseconds: 500),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: size.width * 45 / 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    size.width * 3 / 100,
                                                vertical:
                                                    size.height * 1.5 / 100,
                                              ),
                                              child: Text(
                                                AppLanguage
                                                    .BookNowText[language],
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.pinkColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 6 / 100,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      AppLanguage.secureYourspotText[language],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 5 / 100),
                          Center(
                            child: Container(
                              width: 180,
                              height: 1,
                              color: AppColor.lightgreyColor,
                            ),
                          ),
                          SizedBox(height: size.height * 12 / 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
      },
    );
  }

  Widget _recentEventCard({
    required String image,
    required String name,
    required String time,
    required List<String> tags,
    required bool isNetwork,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 50 / 100,
      height: size.height * 30 / 100,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: isNetwork
                  ? _buildAdaptiveImage(
                      image,
                      fit: BoxFit.cover,
                      fallbackAsset: AppImage.dummyImageIcon,
                    )
                  : Image.asset(
                      AppImage.dummyImageIcon,
                      fit: BoxFit.cover,
                    ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Tags at Top Left
            if (tags.isNotEmpty)
              Positioned(
                left: 10,
                top: 10,
                child: Row(
                  children: tags.map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColor.themeColor.withOpacity(.7),
                        border: Border.all(
                            color: const Color(0xFF9C27B0), width: 2),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Event Name and Time at Bottom
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? "No events" : name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  if (time.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColor.buttonColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            color: AppColor.buttonColor,
                            fontSize: 12,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void documenttypebottomsheet(
    BuildContext context, {
    Map<String, dynamic>? sharedVenueData,
  }) =>
      showEventTypesBottomSheet(
        context,
        type: 'venue',
        id: _str(widget.venueId),
        sharedEventData: sharedVenueData,
      );
}
