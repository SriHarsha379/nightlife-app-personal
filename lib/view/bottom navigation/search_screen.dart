// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:night_life/controller/home/home_controller.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/book_venue_table.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../controller/search/search_filter_controller.dart';
import '../../../provider/common_api_helper.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_config_provider.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/user_controller.dart';
import '../other/calender_screen.dart';
import '../other/location_filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  static String routeName = './SearchScreen';
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const List<String> _defaultTrendingKeywords = [
    // "Royal Club",
    // "Arjun Raajpaal",
    // "Music Fest",
  ];

  TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _searchScrollController = ScrollController();
  Timer? _searchDebounce;

  final GlobalKey _venueFeaturedKey = GlobalKey();
  final GlobalKey _venueNearbyKey = GlobalKey();
  final GlobalKey _venueRecommendedKey = GlobalKey();
  final GlobalKey _eventFeaturedKey = GlobalKey();
  final GlobalKey _eventNearbyKey = GlobalKey();
  final GlobalKey _eventRecommendedKey = GlobalKey();

  int tapBarStatus = 0;
  bool _isInitialLoading = true;
  String cityName = '';
  double latitude = 0.0;
  double longitude = 0.0;
  double _selectedRadiusKm = 15.0;

  List<String> trendingSearchList = [..._defaultTrendingKeywords];
  List<String> venueTrendingSearchList = [];
  List<String> eventTrendingSearchList = [];
  List<Map<String, String>> eventList = [];
  List<Map<String, String>> placeList = [];
  List<Map<String, String>> items = [];
  List<Map<String, String>> venueFeaturedList = [];
  List<Map<String, String>> eventFeaturedList = [];
  List<Map<String, String>> venueRecommendedList = [];
  List<Map<String, String>> eventRecommendedList = [];

  @override
  void initState() {
    super.initState();
    tapBarStatus = 1;

    _searchFocusNode.addListener(() {
      footerVisibilityNotifier.value = !_searchFocusNode.hasFocus;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _loadTrendingKeywords(type: 'venue');
        await _loadTrendingKeywords(type: 'event');
        if (!mounted) return;
        final userController = context.read<UserController>();
        await userController.getUserDetails();
        final cityData = userController.getEffectiveSearchCityData;

        if (!mounted) return;
        setState(() {
          cityName = (cityData['city_name'] ?? "").toString();
          latitude = _parseDouble(cityData['latitude'], 22.7196);
          longitude = _parseDouble(cityData['longitude'], 75.8577);
          _selectedRadiusKm = _parseDouble(cityData['radius'], 15.0);
        });

        await _loadSearchData(type: 'venue');
        await _loadSearchData(type: 'event');

        if (!mounted) return;
        setState(() {
          final controller = context.read<SearchFilterController>();
          venueFeaturedList = controller.venueFeaturedList;
          placeList = controller.venueNearbyList;
          venueRecommendedList = controller.venueRecommendedList;
          eventFeaturedList = controller.eventFeaturedList;
          eventList = controller.eventNearbyList;
          eventRecommendedList = controller.eventRecommendedList;
          items = venueRecommendedList;
          trendingSearchList = venueTrendingSearchList.isNotEmpty
              ? venueTrendingSearchList
              : [..._defaultTrendingKeywords];
        });
      } finally {
        if (mounted) {
          setState(() {
            _isInitialLoading = false;
          });
        }
      }
    });
  }

  double _parseDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  String _locationLabel(String distance, String location) {
    if (distance.isEmpty) return location;
    if (location.isEmpty) return distance;
    return "$distance | $location";
  }

  Future<void> _loadSearchData({required String type}) async {
    final controller = context.read<SearchFilterController>();
    final searchQuery = searchController.text.trim();

    await controller.fetchFilterEventsVenues(
      context,
      latitude: latitude,
      longitude: longitude,
      type: type,
      radius: _selectedRadiusKm.toInt(),
      search: searchQuery,
    );

    if (!mounted) return;
    setState(() {
      if (type == 'venue') {
        venueFeaturedList = controller.venueFeaturedList;
        placeList = controller.venueNearbyList;
        venueRecommendedList = controller.venueRecommendedList;
        if (tapBarStatus == 1) {
          items = venueRecommendedList;
        }
      } else {
        eventFeaturedList = controller.eventFeaturedList;
        eventList = controller.eventNearbyList;
        eventRecommendedList = controller.eventRecommendedList;
        if (tapBarStatus == 2) {
          items = eventRecommendedList;
        }
      }
    });

    if (searchQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToMatchedSection(type);
      });
    }
  }

  void _scrollToMatchedSection(String type) {
    GlobalKey? key;
    if (type == 'venue') {
      if (venueFeaturedList.isNotEmpty) {
        key = _venueFeaturedKey;
      } else if (placeList.isNotEmpty) {
        key = _venueNearbyKey;
      } else if (venueRecommendedList.isNotEmpty) {
        key = _venueRecommendedKey;
      }
    } else {
      if (eventFeaturedList.isNotEmpty) {
        key = _eventFeaturedKey;
      } else if (eventList.isNotEmpty) {
        key = _eventNearbyKey;
      } else if (eventRecommendedList.isNotEmpty) {
        key = _eventRecommendedKey;
      }
    }

    final targetContext = key?.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      await _loadSearchData(type: tapBarStatus == 1 ? 'venue' : 'event');
    });
  }

  Future<void> _loadTrendingKeywords({required String type}) async {
    final token = AppConstant.token;
    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['authorization'] = 'Bearer $token';
    }

    final response = await getData(
      'common/get_trending_keywords?type=$type',
      context,
      headers: headers.isEmpty ? null : headers,
    );

    if (response == null || response['success'] != true) return;

    final keywords = _extractTrendingKeywords(response['data']);
    if (!mounted) return;

    setState(() {
      if (type == 'venue') {
        venueTrendingSearchList = keywords;
        if (tapBarStatus == 1) {
          trendingSearchList = venueTrendingSearchList.isNotEmpty
              ? venueTrendingSearchList
              : [..._defaultTrendingKeywords];
        }
      } else {
        eventTrendingSearchList = keywords;
        if (tapBarStatus == 2) {
          trendingSearchList = eventTrendingSearchList.isNotEmpty
              ? eventTrendingSearchList
              : [..._defaultTrendingKeywords];
        }
      }
    });
  }

  List<String> _extractTrendingKeywords(dynamic data) {
    final result = <String>[];

    if (data is List) {
      for (final item in data) {
        if (item is String && item.trim().isNotEmpty) {
          result.add(item.trim());
        } else if (item is Map) {
          final mapItem = Map<String, dynamic>.from(item);
          final value = _readKeywordFromMap(mapItem);
          if (value.isNotEmpty) {
            result.add(value);
          }
        }
      }
      return result.toSet().toList();
    }

    if (data is Map) {
      final mapData = Map<String, dynamic>.from(data);
      for (final key in ['keywords', 'trending_keywords', 'items', 'list']) {
        final value = mapData[key];
        if (value is List) {
          return _extractTrendingKeywords(value);
        }
      }
      final single = _readKeywordFromMap(mapData);
      if (single.isNotEmpty) {
        return [single];
      }
    }

    return result;
  }

  String _readKeywordFromMap(Map<String, dynamic> item) {
    for (final key in ['keyword', 'name', 'title', 'search', 'text']) {
      final value = item[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  Future<void> _onTrendingKeywordTap(String keyword) async {
    searchController.text = keyword;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );
    _searchDebounce?.cancel();
    await _loadSearchData(type: tapBarStatus == 1 ? 'venue' : 'event');
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
    await _loadSearchData(type: 'event');
  }

  Future<void> _openVenueDetail(String venueId) async {
    if (venueId.trim().isEmpty) return;
    final result = await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: VenuePages(
          venueId: venueId,
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
    if (!mounted) return;
    await _handleVenueDetailResult(result);
  }

  Future<void> _openEventDetail(
    String eventId, {
    PageTransitionType transitionType = PageTransitionType.rightToLeftWithFade,
  }) async {
    if (eventId.trim().isEmpty) return;
    final result = await Navigator.push(
      context,
      PageTransition(
        type: transitionType,
        child: LikedEventDetail(
          eventId: eventId,
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
    if (!mounted) return;
    await _handleEventDetailResult(result);
  }

  @override
  void dispose() {
    footerVisibilityNotifier.value = true;
    _searchFocusNode.dispose();
    _searchDebounce?.cancel();
    _searchScrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Widget _buildCachedSearchImage({
    required String imageName,
    required BoxFit fit,
    BorderRadius? borderRadius,
    double? width,
    double? height,
  }) {
    final imageUrl = "${AppConfigProvider.imageUrl}$imageName";

    // Fallback dummy image widget
    Widget dummyImage() => Image.asset(
          AppImage.dummyImageIcon,
          fit: fit,
          width: width,
          height: height,
        );

    // If imageName is empty, show dummy immediately
    if (imageName.trim().isEmpty) {
      if (borderRadius == null) return dummyImage();
      return ClipRRect(borderRadius: borderRadius, child: dummyImage());
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 350),
      placeholderFadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.black12,
      ),
      errorWidget: (context, url, error) => dummyImage(),
    );

    if (borderRadius == null) return imageWidget;
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageWidget,
    );
  }

  Widget _buildEmptySectionText(String text) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 90 / 100,
          // padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppFont.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColor.listTextColor(context),
            ),
          ),
        ),
        SizedBox(
          height: 25,
        )
      ],
    );
  }

  Widget _buildSectionLoader() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 90 / 100,
      height: MediaQuery.of(context).size.height * 8 / 100,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2.2),
      ),
    );
  }

  Color _featuredCardBorderColor(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return isDark
        ? AppColor.greyLightColor(context).withOpacity(0.18)
        : AppColor.greyLightColor(context).withOpacity(0.55);
  }

  List<BoxShadow> _featuredCardShadow(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.35)
            : Colors.black.withOpacity(0.10),
        blurRadius: isDark ? 10 : 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  BoxDecoration _featuredTagDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: AppColor.pinkColor.withOpacity(0.18),
      border: Border.all(
        color: AppColor.pinkColor,
        width: 1.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final searchFilterProvider = context.watch<SearchFilterController>();
    bool isDark = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          setState(() {
            AppConstant.selectFooterIndex = 0;
          });
        },
        child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Scaffold(
              backgroundColor: AppColor.primaryColor(context),
              body: SafeArea(
                child: _isInitialLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppColor.pinkColor,
                        ),
                      )
                    : Container(
                        height: MediaQuery.of(context).size.height * 100 / 100,
                        width: MediaQuery.of(context).size.width * 100 / 100,
                        color: AppColor.primaryColor(context),
                        child: Column(children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          GestureDetector(
                            onTap: () {
                              _openDistanceBottomSheet(context);
                            },
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _openDistanceBottomSheet(context);
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          8 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              8 /
                                              100,
                                      child: Image.asset(
                                        AppImage.locationIcon,
                                        color: AppColor.secondryColor(context),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        2 /
                                        100,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        60 /
                                        100,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cityName,
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                        // Text(
                                        //   "Chander Nagar, Surya Nagar, Delhi",
                                        //   style: TextStyle(
                                        //     fontFamily: AppFont.fontFamily,
                                        //     fontSize: 11,
                                        //     fontWeight: FontWeight.w300,
                                        //     color: isDark
                                        //         ? AppColor.secondryColor(context)
                                        //         : AppColor.primaryColor(context),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      // bottomSheet(context);
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: CalendarScreen(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          5 /
                                          100,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              5 /
                                              100,
                                      child: Image.asset(
                                        AppImage.calenderImage,
                                        fit: BoxFit.cover,
                                        color: AppColor.pinkColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 6 / 100,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(40), // pill shape
                              border: Border.all(
                                  color: AppColor.secondryColor(context)),
                              //  color: AppColor.secondryColor(context),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  color: AppColor.greyLightColor(context)
                                      .withOpacity(0.4),
                                ),
                                BoxShadow(
                                  offset: const Offset(0, 1),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  color: Colors.black.withOpacity(0.15),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: searchController,
                              focusNode: _searchFocusNode,
                              onChanged: _onSearchChanged,
                              onFieldSubmitted: (_) {
                                _searchDebounce?.cancel();
                                _loadSearchData(
                                    type:
                                        tapBarStatus == 1 ? 'venue' : 'event');
                              },
                              cursorColor: AppColor.secondryColor(context),
                              style: TextStyle(
                                  color: AppColor.secondryColor(context),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 14),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            4 /
                                            100,
                                    vertical: 10,
                                  ),
                                  child: Image.asset(
                                    AppImage.searchIcon,
                                    height: MediaQuery.of(context).size.height *
                                        4 /
                                        100,
                                    width: MediaQuery.of(context).size.width *
                                        4 /
                                        100,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    color: AppColor.primaryColor(context),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    color: AppColor.primaryColor(context),
                                    width: 0,
                                  ),
                                ),
                                border: InputBorder.none,
                                hintText: AppLanguage.searchText[language],
                                hintStyle: AppConstant.textFilledStyle(context),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          2 /
                                          100,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          //!====================Tap bar three option===================\\
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 75 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Venues option
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tapBarStatus = 1;
                                      items = venueRecommendedList;
                                      trendingSearchList =
                                          venueTrendingSearchList.isNotEmpty
                                              ? venueTrendingSearchList
                                              : [..._defaultTrendingKeywords];
                                    });
                                    if (venueTrendingSearchList.isEmpty) {
                                      _loadTrendingKeywords(type: 'venue');
                                    }
                                    if (searchController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _loadSearchData(type: 'venue');
                                    } else if (venueFeaturedList.isEmpty &&
                                        placeList.isEmpty &&
                                        !context
                                            .read<SearchFilterController>()
                                            .isVenueLoading) {
                                      _loadSearchData(type: 'venue');
                                    }
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        22 /
                                        100,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          child: Image.asset(
                                            AppImage.venuesIcon,
                                            color: tapBarStatus == 1
                                                ? AppColor.pinkColor
                                                : AppColor.textTapColor(
                                                    context),
                                          ),
                                        ),
                                        Text(
                                          AppLanguage.venuesText[language],
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: tapBarStatus == 1
                                                ? AppColor.pinkColor
                                                : AppColor.textTapColor(
                                                    context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Events option
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tapBarStatus = 2;
                                      items = eventRecommendedList;
                                      trendingSearchList =
                                          eventTrendingSearchList.isNotEmpty
                                              ? eventTrendingSearchList
                                              : [..._defaultTrendingKeywords];
                                    });
                                    if (eventTrendingSearchList.isEmpty) {
                                      _loadTrendingKeywords(type: 'event');
                                    }
                                    if (searchController.text
                                        .trim()
                                        .isNotEmpty) {
                                      _loadSearchData(type: 'event');
                                    } else if (eventFeaturedList.isEmpty &&
                                        eventList.isEmpty &&
                                        !context
                                            .read<SearchFilterController>()
                                            .isEventLoading) {
                                      _loadSearchData(type: 'event');
                                    }
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        22 /
                                        100,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          child: Image.asset(
                                            AppImage.eventsIcon,
                                            color: tapBarStatus == 2
                                                ? AppColor.pinkColor
                                                : AppColor.textTapColor(
                                                    context),
                                          ),
                                        ),
                                        Text(
                                          AppLanguage.eventsText[language],
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: tapBarStatus == 2
                                                ? AppColor.pinkColor
                                                : AppColor.textTapColor(
                                                    context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),

                          Container(
                            width: MediaQuery.of(context).size.width * 55 / 100,
                            alignment: tapBarStatus == 1
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              height: MediaQuery.of(context).size.height *
                                  0.5 /
                                  100,
                              width:
                                  MediaQuery.of(context).size.width * 22 / 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColor.pinkColor,
                              ),
                            ),
                          ),

                          Container(
                            height:
                                MediaQuery.of(context).size.height * 0.2 / 100,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.textTapColor(context),
                            ),
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                controller: _searchScrollController,
                                child: Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Text(
                                        AppLanguage
                                            .trendingSearchText[language],
                                        style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.pinkColor),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                95 /
                                                100,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Wrap(
                                              children: [
                                                ...List.generate(
                                                  trendingSearchList.length,
                                                  (index) => GestureDetector(
                                                    onTap: () =>
                                                        _onTrendingKeywordTap(
                                                      trendingSearchList[index],
                                                    ),
                                                    child: Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          border: Border.all(
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
                                                          )),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 8,
                                                                horizontal: 15),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              trendingSearchList[
                                                                  index],
                                                              style: TextStyle(
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context),
                                                              ),
                                                            ),
                                                            Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  6 /
                                                                  100,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  3 /
                                                                  100,
                                                              child:
                                                                  Image.asset(
                                                                AppImage
                                                                    .upgradeIcon,
                                                                fit: BoxFit
                                                                    .cover,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ))),
                                    ////////////////////

                                    tapBarStatus == 1
                                        ? Column(children: [
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  2 /
                                                  100,
                                            ),
                                            Container(
                                              key: _venueFeaturedKey,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  90 /
                                                  100,
                                              child: Text(
                                                "Featured",
                                                style: const TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor.pinkColor),
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  2 /
                                                  100,
                                            ),
                                            (searchFilterProvider
                                                        .isVenueLoading &&
                                                    venueFeaturedList.isEmpty)
                                                ? _buildSectionLoader()
                                                : venueFeaturedList.isEmpty
                                                    ? _buildEmptySectionText(
                                                        "No featured venues found")
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            96 /
                                                            100,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            // Navigator.push(
                                                            //   context,
                                                            //   PageTransition(
                                                            //     type: PageTransitionType
                                                            //         .rightToLeftWithFade,
                                                            //     child:
                                                            //         LikedEventDetail(),
                                                            //     duration:
                                                            //         const Duration(
                                                            //             milliseconds:
                                                            //                 500),
                                                            //   ),
                                                            // );
                                                          },
                                                          child:
                                                              SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  child: Wrap(
                                                                    children: [
                                                                      ...List
                                                                          .generate(
                                                                        venueFeaturedList
                                                                            .length,
                                                                        (index) {
                                                                          final categoryList = (venueFeaturedList[index]['categories'] ?? '')
                                                                              .split('||')
                                                                              .map((value) => value.trim())
                                                                              .where((value) => value.isNotEmpty)
                                                                              .take(3)
                                                                              .toList();
                                                                          return Container(
                                                                              margin: const EdgeInsets.symmetric(horizontal: 8),
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                  border: Border.all(
                                                                                    color: AppColor.pinkColor,
                                                                                    width: 0.5,
                                                                                  )),
                                                                              child: GestureDetector(
                                                                                onTap: () async {
                                                                                  await _openVenueDetail(
                                                                                    venueFeaturedList[index]['id'].toString(),
                                                                                  );
                                                                                },
                                                                                child: Column(
                                                                                  children: [
                                                                                    Stack(
                                                                                      children: [
                                                                                        Container(
                                                                                          width: MediaQuery.of(context).size.width * 55 / 100,
                                                                                          height: MediaQuery.of(context).size.height * 28 / 100,
                                                                                          decoration: BoxDecoration(
                                                                                            boxShadow: _featuredCardShadow(context),
                                                                                            borderRadius: BorderRadius.circular(25),
                                                                                            // border: Border.all(
                                                                                            //     // color: _featuredCardBorderColor(context),
                                                                                            //     ),
                                                                                          ),
                                                                                          child: ClipRRect(
                                                                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                                                                                            child: _buildCachedSearchImage(
                                                                                              imageName: venueFeaturedList[index]['image']!,
                                                                                              fit: BoxFit.cover,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        if (categoryList.isNotEmpty)
                                                                                          Positioned(
                                                                                            left: 10,
                                                                                            top: 10,
                                                                                            child: Row(
                                                                                              children: categoryList.map((tag) {
                                                                                                return Container(
                                                                                                  margin: const EdgeInsets.only(right: 6),
                                                                                                  padding: const EdgeInsets.symmetric(
                                                                                                    horizontal: 10,
                                                                                                    vertical: 5,
                                                                                                  ),
                                                                                                  decoration: _featuredTagDecoration(),
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
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: MediaQuery.of(context).size.height * 2 / 100,
                                                                                    ),
                                                                                    Container(
                                                                                      width: MediaQuery.of(context).size.width * 55 / 100,
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                        child: Text(
                                                                                          venueFeaturedList[index]['title'] ?? "",
                                                                                          style: TextStyle(
                                                                                            fontFamily: AppFont.fontFamily,
                                                                                            fontSize: 16,
                                                                                            fontWeight: FontWeight.w700,
                                                                                            color: AppColor.secondryColor(context),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Container(
                                                                                      width: MediaQuery.of(context).size.width * 55 / 100,
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 6),
                                                                                        child: Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              width: MediaQuery.of(context).size.width * 6 / 100,
                                                                                              height: MediaQuery.of(context).size.width * 6 / 100,
                                                                                              child: Image.asset(
                                                                                                AppImage.locationBlackicon,
                                                                                                color: AppColor.pinkColor,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: MediaQuery.of(context).size.width * 0.1 / 100,
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: Text(
                                                                                                venueFeaturedList[index]['location'] ?? "",
                                                                                                maxLines: 1,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                style: const TextStyle(
                                                                                                  fontFamily: AppFont.fontFamily,
                                                                                                  fontSize: 12,
                                                                                                  fontWeight: FontWeight.w400,
                                                                                                  color: AppColor.pinkColor,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: MediaQuery.of(context).size.height * 2 / 100,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ));
                                                                        },
                                                                      )
                                                                    ],
                                                                  )),
                                                        )),
                                            SizedBox(
                                              height: venueFeaturedList.isEmpty
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0 /
                                                      100
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      4 /
                                                      100,
                                            ),
                                            Container(
                                              key: _venueNearbyKey,
                                              width: size.width * 90 / 100,
                                              child: Text(
                                                "Places near you",
                                                style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColor.pinkColor),
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  2.5 /
                                                  100,
                                            ),
                                            (searchFilterProvider
                                                        .isVenueLoading &&
                                                    placeList.isEmpty)
                                                ? _buildSectionLoader()
                                                : placeList.isEmpty
                                                    ? _buildEmptySectionText(
                                                        "No nearby venues found")
                                                    : GestureDetector(
                                                        onTap: () {},
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              90 /
                                                              100,
                                                          child: Container(
                                                            height:
                                                                size.height *
                                                                    22 /
                                                                    100,
                                                            width:
                                                                double.infinity,
                                                            child: ListView
                                                                .builder(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              itemCount:
                                                                  placeList
                                                                      .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Padding(
                                                                  padding: EdgeInsets.only(
                                                                      right: size
                                                                              .width *
                                                                          3 /
                                                                          100),
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap:
                                                                        () async {
                                                                      await _openVenueDetail(
                                                                        placeList[index]['id']
                                                                            .toString(),
                                                                      );
                                                                    },
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height: size.height *
                                                                              12 /
                                                                              100,
                                                                          width: size.width *
                                                                              42 /
                                                                              100,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          child:
                                                                              _buildCachedSearchImage(
                                                                            imageName:
                                                                                placeList[index]['image'] ?? "",
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height: size.height *
                                                                                1 /
                                                                                100),
                                                                        SizedBox(
                                                                          width: size.width *
                                                                              42 /
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            placeList[index]['title'] ??
                                                                                "",
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: AppFont.fontFamily,
                                                                              fontSize: 13.5,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: AppColor.secondryColor(context),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                            height: size.height *
                                                                                0.5 /
                                                                                100),
                                                                        SizedBox(
                                                                          width: size.width *
                                                                              42 /
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            _locationLabel(
                                                                              placeList[index]['distance'] ?? "",
                                                                              placeList[index]['location'] ?? "",
                                                                            ),
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: AppFont.fontFamily,
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: AppColor.listTextColor(context),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                            Container(
                                              key: _venueRecommendedKey,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  90 /
                                                  100,
                                              child: Text(
                                                "Recommended",
                                                style: const TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor.pinkColor),
                                              ),
                                            ),

                                            SizedBox(height: 16),

                                            // List builder 2 per row
                                            (searchFilterProvider
                                                        .isVenueLoading &&
                                                    items.isEmpty)
                                                ? _buildSectionLoader()
                                                : items.isEmpty
                                                    ? _buildEmptySectionText(
                                                        "No recommended venues found")
                                                    : Container(
                                                        width: size.width *
                                                            90 /
                                                            100,
                                                        child: ListView.builder(
                                                          itemCount:
                                                              (items.length / 2)
                                                                  .ceil(),
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          itemBuilder:
                                                              (context, index) {
                                                            final i1 =
                                                                index * 2;
                                                            final i2 = i1 + 1;
                                                            final size =
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size;

                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 14,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  // ---------- FIRST CARD ----------
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      log("bfjkdbafbdkfbdk${items[i1]['id'].toString()}");
                                                                      _openVenueDetail(items[i1]
                                                                              [
                                                                              'id']
                                                                          .toString());
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      width: size
                                                                              .width *
                                                                          0.42,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: isDark
                                                                            ? Colors.black
                                                                            : Colors.white10,
                                                                        borderRadius:
                                                                            BorderRadius.circular(14),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            child:
                                                                                _buildCachedSearchImage(
                                                                              imageName: items[i1]["image"] ?? "",
                                                                              height: 100,
                                                                              width: size.width * 0.42,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Text(
                                                                              items[i1]["title"] ?? "",
                                                                              style: TextStyle(
                                                                                color: isDark ? Colors.white : Colors.black,
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w600,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 2),
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.centerLeft,
                                                                            child:
                                                                                Text(
                                                                              items[i1]["location"] ?? "",
                                                                              style: TextStyle(
                                                                                fontSize: 12,
                                                                                color: isDark ? Colors.white60 : Colors.black54,
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8),
                                                                          Container(
                                                                            width:
                                                                                size.width * 0.41,
                                                                            height:
                                                                                32,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: Text(
                                                                                "Reserve",
                                                                                style: TextStyle(
                                                                                  fontSize: 14,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.04),

                                                                  // ---------- SECOND CARD (IF EXISTS) ----------
                                                                  if (i2 <
                                                                      items
                                                                          .length)
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {},
                                                                      child:
                                                                          Container(
                                                                        width: size.width *
                                                                            0.42,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: isDark
                                                                              ? Colors.black
                                                                              : Colors.white10,
                                                                          borderRadius:
                                                                              BorderRadius.circular(14),
                                                                        ),
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            // Navigator.push(
                                                                            //   context,
                                                                            //   PageTransition(
                                                                            //     type: PageTransitionType.rightToLeftWithFade,
                                                                            //     child: VenuePages(
                                                                            //       venueId: items[i2]['id'].toString(),
                                                                            //     ),
                                                                            //     duration: const Duration(milliseconds: 500),
                                                                            //   ),
                                                                            // );
                                                                            _openVenueDetail(items[i2]['id'].toString());
                                                                          },
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                child: _buildCachedSearchImage(
                                                                                  imageName: items[i2]["image"] ?? "",
                                                                                  height: 100,
                                                                                  width: size.width * 0.42,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  items[i2]["title"] ?? "",
                                                                                  style: TextStyle(
                                                                                    color: isDark ? Colors.white : Colors.black,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 2),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  items[i2]["location"] ?? "",
                                                                                  style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    color: isDark ? Colors.white60 : Colors.black54,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                              Container(
                                                                                width: size.width * 0.41,
                                                                                height: 32,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    "Reserve",
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (i2 >=
                                                                      items
                                                                          .length)
                                                                    SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.42,
                                                                    ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                          ])
                                        : Column(
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    2 /
                                                    100,
                                              ),
                                              Container(
                                                key: _eventFeaturedKey,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    90 /
                                                    100,
                                                child: Text(
                                                  "Featured",
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColor.pinkColor),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    2 /
                                                    100,
                                              ),
                                              (searchFilterProvider
                                                          .isEventLoading &&
                                                      eventFeaturedList.isEmpty)
                                                  ? _buildSectionLoader()
                                                  : eventFeaturedList.isEmpty
                                                      ? _buildEmptySectionText(
                                                          "No featured events found")
                                                      : Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              96 /
                                                              100,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              // Navigator.push(
                                                              //   context,
                                                              //   PageTransition(
                                                              //     type: PageTransitionType
                                                              //         .rightToLeftWithFade,
                                                              //     child:
                                                              //         LikedEventDetail(
                                                              //           eventId: eventFeaturedList[index]
                                                              //               [
                                                              //               'categories']
                                                              //           .toString(),
                                                              //         ),
                                                              //     duration: const Duration(
                                                              //         milliseconds:
                                                              //             500),
                                                              //   ),
                                                              // );
                                                            },
                                                            child:
                                                                SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Wrap(
                                                                      children: [
                                                                        ...List
                                                                            .generate(
                                                                          eventFeaturedList
                                                                              .length,
                                                                          (index) {
                                                                            final categoryList =
                                                                                (eventFeaturedList[index]['categories'] ?? '').split('||').map((value) => value.trim()).where((value) => value.isNotEmpty).take(3).toList();
                                                                            return Container(
                                                                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                                                                decoration: BoxDecoration(
                                                                                    borderRadius: BorderRadius.circular(25),
                                                                                    border: Border.all(
                                                                                      color: AppColor.pinkColor,
                                                                                      width: 0.5,
                                                                                    )),
                                                                                child: GestureDetector(
                                                                                  onTap: () async {
                                                                                    await _openEventDetail(
                                                                                      eventFeaturedList[index]['id'].toString(),
                                                                                    );
                                                                                  },
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Stack(
                                                                                        children: [
                                                                                          Container(
                                                                                            width: MediaQuery.of(context).size.width * 55 / 100,
                                                                                            height: MediaQuery.of(context).size.height * 28 / 100,
                                                                                            decoration: BoxDecoration(
                                                                                              boxShadow: _featuredCardShadow(context),
                                                                                              borderRadius: BorderRadius.circular(25),
                                                                                              // border: Border.all(
                                                                                              //   color: _featuredCardBorderColor(context),
                                                                                              // ),
                                                                                            ),
                                                                                            child: ClipRRect(
                                                                                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                                                                                              child: _buildCachedSearchImage(
                                                                                                imageName: eventFeaturedList[index]['image']!,
                                                                                                fit: BoxFit.cover,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          if (categoryList.isNotEmpty)
                                                                                            Positioned(
                                                                                              left: 10,
                                                                                              top: 10,
                                                                                              child: Row(
                                                                                                children: categoryList.map((tag) {
                                                                                                  return Container(
                                                                                                    margin: const EdgeInsets.only(right: 6),
                                                                                                    padding: const EdgeInsets.symmetric(
                                                                                                      horizontal: 10,
                                                                                                      vertical: 5,
                                                                                                    ),
                                                                                                    decoration: _featuredTagDecoration(),
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
                                                                                        ],
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: MediaQuery.of(context).size.height * 2 / 100,
                                                                                      ),
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width * 55 / 100,
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                          child: Text(
                                                                                            eventFeaturedList[index]['title'] ?? "",
                                                                                            style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 16.5, fontWeight: FontWeight.w700, color: AppColor.secondryColor(context)),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        width: MediaQuery.of(context).size.width * 55 / 100,
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Container(
                                                                                                width: MediaQuery.of(context).size.width * 5 / 100,
                                                                                                height: MediaQuery.of(context).size.width * 5 / 100,
                                                                                                child: Image.asset(
                                                                                                  AppImage.clock,
                                                                                                  color: AppColor.pinkColor,
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: MediaQuery.of(context).size.width * 1 / 100,
                                                                                              ),
                                                                                              Expanded(
                                                                                                child: Text(
                                                                                                  eventFeaturedList[index]['event_date'] ?? "",
                                                                                                  maxLines: 1,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  style: const TextStyle(fontFamily: AppFont.fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: AppColor.pinkColor),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: MediaQuery.of(context).size.height * 2 / 100,
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ));
                                                                          },
                                                                        )
                                                                      ],
                                                                    )),
                                                          )),
                                              SizedBox(
                                                height:
                                                    eventFeaturedList.isEmpty
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0 /
                                                            100
                                                        : MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            4 /
                                                            100,
                                              ),
                                              Container(
                                                key: _eventNearbyKey,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    90 /
                                                    100,
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "Events near you",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColor.pinkColor),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    3 /
                                                    100,
                                              ),
                                              (searchFilterProvider
                                                          .isEventLoading &&
                                                      eventList.isEmpty)
                                                  ? _buildSectionLoader()
                                                  : eventList.isEmpty
                                                      ? _buildEmptySectionText(
                                                          "No nearby events found")
                                                      : GestureDetector(
                                                          onTap: () {},
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                90 /
                                                                100,
                                                            child: Container(
                                                              height:
                                                                  size.height *
                                                                      22 /
                                                                      100,
                                                              width: double
                                                                  .infinity,
                                                              child: ListView
                                                                  .builder(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                itemCount:
                                                                    eventList
                                                                        .length,
                                                                itemBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right: size.width *
                                                                            3 /
                                                                            100),
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await _openEventDetail(
                                                                          eventList[index]['id']
                                                                              .toString(),
                                                                        );
                                                                      },
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            height: size.height *
                                                                                12 /
                                                                                100,
                                                                            width: size.width *
                                                                                42 /
                                                                                100,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                            ),
                                                                            child:
                                                                                _buildCachedSearchImage(
                                                                              imageName: eventList[index]['image'] ?? "",
                                                                              fit: BoxFit.cover,
                                                                              borderRadius: BorderRadius.circular(12),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size.height * 1 / 100),
                                                                          SizedBox(
                                                                            width: size.width *
                                                                                42 /
                                                                                100,
                                                                            child:
                                                                                Text(
                                                                              eventList[index]['title'] ?? "",
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                fontFamily: AppFont.fontFamily,
                                                                                fontSize: 13.5,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: AppColor.secondryColor(context),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: size.height * 0.5 / 100),
                                                                          SizedBox(
                                                                            width: size.width *
                                                                                42 /
                                                                                100,
                                                                            child:
                                                                                Text(
                                                                              _locationLabel(
                                                                                eventList[index]['distance'] ?? "",
                                                                                eventList[index]['location'] ?? "",
                                                                              ),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                fontFamily: AppFont.fontFamily,
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w400,
                                                                                color: AppColor.listTextColor(context),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                              Container(
                                                key: _eventRecommendedKey,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    90 /
                                                    100,
                                                child: Text(
                                                  "Recommended",
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColor.pinkColor),
                                                ),
                                              ),

                                              SizedBox(
                                                  height:
                                                      size.height * 2.5 / 100),

                                              // List builder 2 per row
                                              (searchFilterProvider
                                                          .isEventLoading &&
                                                      items.isEmpty)
                                                  ? _buildSectionLoader()
                                                  : items.isEmpty
                                                      ? _buildEmptySectionText(
                                                          "No recommended events found")
                                                      : Container(
                                                          width: size.width *
                                                              90 /
                                                              100,
                                                          child:
                                                              ListView.builder(
                                                            itemCount:
                                                                (items.length /
                                                                        2)
                                                                    .ceil(),
                                                            shrinkWrap: true,
                                                            physics:
                                                                NeverScrollableScrollPhysics(),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final i1 =
                                                                  index * 2;
                                                              final i2 = i1 + 1;
                                                              final size =
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size;

                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            14),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    // ---------- FIRST CARD ----------
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        await _openEventDetail(
                                                                          eventRecommendedList[i1]['id']
                                                                              .toString(),
                                                                          transitionType:
                                                                              PageTransitionType.bottomToTop,
                                                                        );
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width: size.width *
                                                                            0.42,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: isDark
                                                                              ? Colors.black
                                                                              : Colors.white10,
                                                                          borderRadius:
                                                                              BorderRadius.circular(14),
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              child: _buildCachedSearchImage(
                                                                                imageName: items[i1]["image"] ?? "",
                                                                                height: 100,
                                                                                width: size.width * 0.42,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 8),
                                                                            Align(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                items[i1]["title"] ?? "",
                                                                                style: TextStyle(
                                                                                  color: isDark ? Colors.white : Colors.black,
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 2),
                                                                            Align(
                                                                              alignment: Alignment.centerLeft,
                                                                              child: Text(
                                                                                items[i1]["location"] ?? "",
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: isDark ? Colors.white60 : Colors.black54,
                                                                                ),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 8),
                                                                            Container(
                                                                              width: size.width * 0.41,
                                                                              height: 32,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(8),
                                                                              ),
                                                                              child: const Center(
                                                                                child: Text(
                                                                                  "Book Now",
                                                                                  style: TextStyle(
                                                                                    fontSize: 14,
                                                                                    color: Colors.black,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 8),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        width: size.width *
                                                                            0.04),

                                                                    // ---------- SECOND CARD (IF EXISTS) ----------
                                                                    if (i2 <
                                                                        items
                                                                            .length)
                                                                      GestureDetector(
                                                                        onTap:
                                                                            () async {
                                                                          await _openEventDetail(
                                                                            eventRecommendedList[i2]['id'].toString(),
                                                                            transitionType:
                                                                                PageTransitionType.bottomToTop,
                                                                          );
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              size.width * 0.42,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: isDark
                                                                                ? Colors.black
                                                                                : Colors.white10,
                                                                            borderRadius:
                                                                                BorderRadius.circular(14),
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            children: [
                                                                              ClipRRect(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  10,
                                                                                ),
                                                                                child: _buildCachedSearchImage(
                                                                                  imageName: items[i2]["image"] ?? "",
                                                                                  height: 100,
                                                                                  width: size.width * 0.42,
                                                                                  fit: BoxFit.cover,
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  items[i2]["title"] ?? "",
                                                                                  style: TextStyle(
                                                                                    color: isDark ? Colors.white : Colors.black,
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 2),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  items[i2]["location"] ?? "",
                                                                                  style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    color: isDark ? Colors.white60 : Colors.black54,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                              Container(
                                                                                width: size.width * 0.41,
                                                                                height: 32,
                                                                                decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                                child: const Center(
                                                                                  child: Text(
                                                                                    "Book Now",
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.w600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 8),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    if (i2 >=
                                                                        items
                                                                            .length)
                                                                      SizedBox(
                                                                        width: size.width *
                                                                            0.42,
                                                                      ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          )),
                                            ],
                                          ),

                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              20 /
                                              100,
                                    ),
                                  ],
                                ),
                              ))
                        ]),
                      ),
              ),
            )),
      ),
    );
  }

  Future<void> _openDistanceBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<LocationFilterResult>(
      context: context,
      backgroundColor: AppColor.themeColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (_) => LocationFilterBottomSheet(
        initialCityName: cityName,
        initialLatitude: latitude,
        initialLongitude: longitude,
        initialRadiusKm: _selectedRadiusKm,
      ),
    );

    if (result == null || !mounted) return;
    final userController = context.read<UserController>();
    await userController.saveSelectedSearchLocation(
      cityName: result.cityName,
      latitude: result.latitude,
      longitude: result.longitude,
      radius: result.radiusKm,
    );

    setState(() {
      cityName = result.cityName;
      latitude = result.latitude;
      longitude = result.longitude;
      _selectedRadiusKm = result.radiusKm;
    });

    await _loadSearchData(type: 'venue');
    await _loadSearchData(type: 'event');
  }
}
