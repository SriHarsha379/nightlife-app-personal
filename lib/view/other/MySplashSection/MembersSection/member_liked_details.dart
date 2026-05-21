import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_config_provider.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controller/home/home_controller.dart';
import '../../../../helper/ImagePreviewScreen.dart';
import '../../../../commonWidget/invite_members_type_bottomsheet.dart';
import '../../../../provider/darkmode_provider.dart';
import '../EventSection/Liked/liked_event_details.dart';
import '../VenuesSection/venuepages.dart';

class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class LikedMemberDetail extends StatefulWidget {
  static const String routeName = '/LikedMemberDetail';
  final String? memberId;
  final bool forceDislikeOnly;
  final bool deferSwipeActionToParent;
  const LikedMemberDetail({
    super.key,
    this.memberId,
    this.forceDislikeOnly = false,
    this.deferSwipeActionToParent = false,
  });

  @override
  State<LikedMemberDetail> createState() => _LikedMemberDetailState();
}

class _LikedMemberDetailState extends State<LikedMemberDetail> {
  Map<String, dynamic>? _memberData;
  bool _isLoading = false;
  Map<String, String>? _swipeResult;
  List<Map<String, String>> _galleryMedia = [];
  List<String> _galleryUrls = [];
  List<String> _vibeNames = [];
  List<String> _eventPreferenceNames = [];
  List<Map<String, dynamic>> _recentEvents = [];
  List<Map<String, dynamic>> _recentVenues = [];
  int selectedIndex = 0;
  List Interest = [];
  int selectedId = 1;
  List pics = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMemberDetails();
    });
  }

  String _str(dynamic value) => (value ?? '').toString().trim();

  List<dynamic> _toList(dynamic value) => value is List ? value : <dynamic>[];

  String _asUploadUrl(dynamic path) {
    final value = _str(path);
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${AppConfigProvider.imageUrl}$value';
  }

  Map<String, String> _galleryItemFrom(dynamic item) {
    if (item is! Map) return <String, String>{};
    final type =
        _str(item['type']).toLowerCase() == 'video' ? 'video' : 'image';
    final sourceUrl = _asUploadUrl(item['url']);
    final thumbnailUrl = _asUploadUrl(item['thumbnail']);
    final displayUrl = type == 'video'
        ? (thumbnailUrl.isNotEmpty ? thumbnailUrl : sourceUrl)
        : sourceUrl;
    if (displayUrl.isEmpty && sourceUrl.isEmpty) return <String, String>{};
    return <String, String>{
      'type': type,
      'url': displayUrl,
      'source': sourceUrl,
      'thumbnail': thumbnailUrl,
    };
  }

  bool _isVideoGalleryItem(Map<String, String> item) => item['type'] == 'video';

  String _galleryDisplayUrl(Map<String, String> item) =>
      _str(item['url']).isNotEmpty ? _str(item['url']) : _str(item['source']);

  Widget _withoutOverscrollIndicator(Widget child) {
    return ScrollConfiguration(
      behavior: const _NoGlowScrollBehavior().copyWith(scrollbars: false),
      child: child,
    );
  }

  Future<void> _fetchMemberDetails() async {
    final id = _str(widget.memberId);
    if (id.isEmpty) return;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final controller = Provider.of<HomeController>(context, listen: false);
    final data = await controller.fetchMemberDetail(context, memberId: id);
    if (!mounted) return;
    if (data != null) {
      final gallery = _toList(data['gallery']);
      final vibes = _toList(data['vibes']);
      final eventPrefs = _toList(data['event_preferences']);
      final recentEvents = _toList(data['recently_liked_events']);
      final recentVenues = _toList(data['recently_liked_venues']);

      _galleryMedia = gallery
          .map(_galleryItemFrom)
          .where((item) => item.isNotEmpty)
          .toList();
      _galleryUrls = _galleryMedia
          .map(_galleryDisplayUrl)
          .where((e) => e.isNotEmpty)
          .toList();
      if (_galleryMedia.isEmpty) {
        final profile = _asUploadUrl(data['profile_image']);
        if (profile.isNotEmpty) {
          _galleryMedia = [
            {
              'type': 'image',
              'url': profile,
              'source': profile,
              'thumbnail': '',
            }
          ];
          _galleryUrls = [profile];
        }
      }

      _vibeNames = List<String>.generate(
        vibes.length,
        (index) {
          final item = vibes[index];
          if (item is Map) {
            final value = _str(item['name'] ?? item['vibe'] ?? item['title']);
            return value.isEmpty ? 'Vibe ${index + 1}' : value;
          }
          final value = _str(item);
          return value.isEmpty ? 'Vibe ${index + 1}' : value;
        },
      );

      _eventPreferenceNames = eventPrefs
          .map(
              (e) => e is Map ? _str(e['category_name'] ?? e['name']) : _str(e))
          .where((e) => e.isNotEmpty)
          .cast<String>()
          .toList();
      _recentEvents = recentEvents
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      _recentVenues = recentVenues
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (_galleryMedia.isNotEmpty) {
        pics = _galleryMedia;
      }
      if (_eventPreferenceNames.isNotEmpty) {
        Interest = List.generate(
          _eventPreferenceNames.length,
          (index) => {'id': index + 1, 'title': _eventPreferenceNames[index]},
        );
      }
      _memberData = data;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildAdaptiveImage(
    String imagePath, {
    BoxFit fit = BoxFit.cover,
    String fallbackAsset = AppImage.placeHolder2Icon,
  }) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallbackAsset,
          fit: fit,
        ),
      );
    }
    if (imagePath.isEmpty) {
      return Image.asset(
        fallbackAsset,
        fit: fit,
      );
    }
    return Image.asset(
      imagePath,
      fit: fit,
    );
  }

  List<String> get _previewImages {
    if (_galleryUrls.isNotEmpty) return _galleryUrls;
    return [
      AppImage.gellery1,
      AppImage.gellery2,
      AppImage.gellery3,
      AppImage.gellery4,
    ];
  }

  String _memberName() =>
      _str(_memberData?['name']).isNotEmpty ? _str(_memberData?['name']) : "";

  String _memberVibesText() {
    if (_vibeNames.isNotEmpty) return _vibeNames.join(' · ');
    final hobbies = _toList(_memberData?['hobbies'])
        .map((e) => _str(e))
        .where((e) => e.isNotEmpty)
        .toList();
    if (hobbies.isNotEmpty) return hobbies.join(' · ');
    return "";
  }

  String _topProfileImage() {
    final profile = _asUploadUrl(_memberData?['profile_image']);
    if (profile.isNotEmpty) return profile;
    return AppImage.placeHolder2Icon;
  }

  String _targetUserId() {
    final fromData = _str(_memberData?['_id']);
    if (fromData.isNotEmpty) return fromData;
    return _str(widget.memberId);
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    final str = _str(value).toLowerCase();
    return str == 'true' || str == '1';
  }

  bool get _showDislikeOnly =>
      widget.forceDislikeOnly || _toBool(_memberData?['is_liked']);

  Future<void> _submitSwipeAction(String action) async {
    final userId = _targetUserId();
    if (userId.isEmpty) return;
    final normalizedAction = _str(action).toLowerCase();
    if (normalizedAction != 'left' && normalizedAction != 'right') return;

    _swipeResult = {
      'action': normalizedAction, // left | right
      'targetUserId': userId,
    };

    if (widget.deferSwipeActionToParent) {
      Navigator.pop(context, _swipeResult);
      return;
    }

    final homeController = Provider.of<HomeController>(context, listen: false);
    final isSuccess = await homeController.swipeUserAction(
      context,
      targetUserId: userId,
      action: normalizedAction,
    );
    if (!mounted || !isSuccess) return;

    if (_memberData != null) {
      _memberData = Map<String, dynamic>.from(_memberData!)
        ..['is_liked'] = normalizedAction == 'right';
    }

    Navigator.pop(context, _swipeResult);
  }

  Future<void> _handleEventSwipeResult(Map<String, dynamic>? result) async {
    if (result == null) return;
    final action = _str(result['action']).toLowerCase();
    final targetEventId = _str(result['targetEventId']);
    if (targetEventId.isEmpty) return;

    final homeController = Provider.of<HomeController>(context, listen: false);
    if (action == 'dislike') {
      await homeController.dislikeItem(context, targetEventId, 'event');
    } else if (action == 'like') {
      await homeController.likeItem(context, targetEventId, 'event');
    }
  }

  Future<void> _handleVenueSwipeResult(Map<String, dynamic>? result) async {
    if (result == null) return;
    final action = _str(result['action']).toLowerCase();
    final targetVenueId = _str(result['targetVenueId']);
    if (targetVenueId.isEmpty) return;

    final homeController = Provider.of<HomeController>(context, listen: false);
    if (action == 'dislike') {
      await homeController.dislikeItem(context, targetVenueId, 'venue');
    } else if (action == 'like') {
      await homeController.likeItem(context, targetVenueId, 'venue');
    }
  }

  List<String> _extractEventCategoryNames(dynamic categoriesRaw) {
    if (categoriesRaw is! List) return <String>[];
    return categoriesRaw
        .map((item) => item is Map ? _str(item['name']) : _str(item))
        .where((name) => name.isNotEmpty)
        .cast<String>()
        .toList();
  }

  Uri? _instagramUriFromValue(dynamic rawValue) {
    final raw = _str(rawValue);
    if (raw.isEmpty) return null;

    final cleaned = raw.replaceFirst('@', '').trim();
    if (cleaned.isEmpty) return null;

    final parsed = Uri.tryParse(cleaned);
    if (parsed != null && parsed.hasScheme) {
      return parsed;
    }

    if (cleaned.contains('/') || cleaned.contains('.')) {
      return Uri.tryParse('https://$cleaned');
    }

    return Uri.parse('https://www.instagram.com/$cleaned/');
  }

  Future<void> _openInstagramProfile() async {
    final uri = _instagramUriFromValue(_memberData?['instagram_url']);
    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open Instagram profile.')),
      );
    }
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
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
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
                color:
                    AppColor.sendinvitecontainercolor(context).withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
              ),
              width: _showDislikeOnly
                  ? size.width * 52 / 100
                  : size.width * 85 / 100,
              height: size.height * 7 / 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () async {
                        await _submitSwipeAction('left');
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
                            )),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 3 / 100,
                    ),
                    GestureDetector(
                      onTap: () {
                        showInviteMemberstypebottomsheet(
                          context,
                          receiverId: _str(
                            _memberData?['_id'] ?? _memberData?['user_id'],
                          ),
                          receiverName: _str(
                            _memberData?['full_name'] ?? _memberData?['name'],
                          ),
                          receiverImage: _asUploadUrl(
                            _memberData?['profile_image'],
                          ),
                        );
                      },
                      child: Container(
                        width: size.width * 29 / 100,
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
                    SizedBox(
                      width: size.width * 3 / 100,
                    ),
                    if (!_showDislikeOnly)
                      GestureDetector(
                        onTap: () async {
                          await _submitSwipeAction('right');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 33, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColor.buttonColor,
                            borderRadius: BorderRadius.circular(50),

                            // border: Border.all(

                            //      color : AppColor.primaryColor,
                            // ),
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
                ),
              ),
            ),
            body: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColor.buttonColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Loading...",
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: size.width * 100 / 100,
                    height: size.height * 100 / 100,
                    color: AppColor.primaryColor(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 4 / 100),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Center(
                              child: Container(
                                width: size.width * 100 / 100,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: size.height * 2 / 100,
                                    ),
                                    Stack(children: [
                                      Container(
                                        width: double.infinity,
                                        height: 450,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(.5),
                                              blurRadius: 5,
                                              spreadRadius: .5,
                                              offset: Offset(2, 0),
                                            ),
                                          ],
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: Stack(
                                          children: [
                                            // Background image carousel
                                            SizedBox(
                                              height: size.height,
                                              width: size.width,
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: 1,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    width: size.width,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    child: _buildAdaptiveImage(
                                                      _topProfileImage(),
                                                      fit: BoxFit.cover,
                                                      fallbackAsset: AppImage
                                                          .placeHolder2Icon,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                            // Black blur gradient overlay at bottom
                                            Positioned(
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black
                                                          .withOpacity(0.4),
                                                      Colors.black
                                                          .withOpacity(0.8),
                                                      Colors.black
                                                          .withOpacity(0.9),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Back arrow button at top left
                                            Positioned(
                                              top: 26,
                                              left: 16,
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (_swipeResult != null) {
                                                    Navigator.pop(
                                                        context, _swipeResult);
                                                    return;
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(8),
                                                  // decoration: BoxDecoration(
                                                  //   color:
                                                  //       Colors.black.withOpacity(0.3),
                                                  //   shape: BoxShape.circle,
                                                  // ),
                                                  child: Icon(
                                                    Icons.arrow_back_ios_new,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                    size: 24,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Text content at bottom
                                            Positioned(
                                              left: 16,
                                              bottom: 20,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Name
                                                  Text(
                                                    _memberName(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),

                                                  // Hobbies
                                                  Text(
                                                    _memberVibesText(),
                                                    style: TextStyle(
                                                      color: AppColor
                                                          .buttonColor, // Pink color
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  // SizedBox(height: 6),

                                                  // // Question
                                                  // Text(
                                                  //   "Searching for a new coffee spot, wanna join?",
                                                  //   style: TextStyle(
                                                  //     color: Colors.white,
                                                  //     fontSize: 13,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )

                                      // Positioned(
                                      //   top: 26,
                                      //   left: 16,
                                      //   child: GestureDetector(
                                      //     onTap: () {
                                      //       Navigator.pop(context);
                                      //     },
                                      //     child: Image.asset(
                                      //       AppImage.backarrow,
                                      //       color: AppColor.primaryColor(context),
                                      //       fit: BoxFit.cover,
                                      //       height: size.width * 5 / 100,
                                      //     ),
                                      //   ),
                                      // ),
                                    ]),
                                    // SizedBox(
                                    //   height: size.height * 1 / 100,
                                    // ),
                                    Container(
                                      width: size.width * 90 / 100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [],
                                                ),
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.5 /
                                                              100,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          Container(
                                            child: Text(
                                              AppLanguage
                                                  .basicdetailstext[language],
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.secondryColor(
                                                      context)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 1 / 100,
                                          ),
                                          Row(
                                            children: [
                                              /// AGE (show only if exists)
                                              if (_str(_memberData?['age'])
                                                  .isNotEmpty) ...[
                                                Text(
                                                  AppLanguage.ageText[language],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColor.buttonColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1 /
                                                            100),
                                                Text(
                                                  "${_str(_memberData?['age'])} y.o |",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1 /
                                                            100),
                                              ],

                                              /// HEIGHT
                                              if (_str(_memberData?['height'])
                                                  .isNotEmpty) ...[
                                                Text(
                                                  AppLanguage
                                                      .Heighttext[language],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColor.buttonColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1 /
                                                            100),
                                                Text(
                                                  "${_str(_memberData?['height'])} |",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1 /
                                                            100),
                                              ],

                                              /// PRONOUNS
                                              if (_str(_memberData?['pronouns'])
                                                  .isNotEmpty) ...[
                                                Text(
                                                  AppLanguage
                                                      .pronouncsText[language],
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColor.buttonColor,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            1 /
                                                            100),
                                                Text(
                                                  _str(
                                                      _memberData?['pronouns']),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          Builder(
                                            builder: (context) {
                                              final hobbies = _toList(
                                                _memberData?['hobbies'],
                                              )
                                                  .map((e) => _str(e))
                                                  .where((e) => e.isNotEmpty)
                                                  .toList();
                                              final hobbiesText =
                                                  hobbies.join(', ');
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  hobbies.isEmpty
                                                      ? SizedBox()
                                                      : SizedBox(
                                                          height: size.height *
                                                              1 /
                                                              100,
                                                        ),
                                                  hobbies.isEmpty
                                                      ? SizedBox()
                                                      : Container(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  AppLanguage
                                                                          .Hobbiestext[
                                                                      language],
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: AppColor
                                                                          .buttonColor),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    2 /
                                                                    100,
                                                              ),
                                                              Container(
                                                                width:
                                                                    size.width *
                                                                        72 /
                                                                        100,
                                                                child: Text(
                                                                  hobbiesText
                                                                          .isEmpty
                                                                      ? ""
                                                                      : hobbiesText,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color: AppColor
                                                                          .greyLightColor(
                                                                              context)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                ],
                                              );
                                            },
                                          ),
                                          SizedBox(
                                            height: size.height * 1 / 100,
                                          ),
                                          Row(
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
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    _str(_memberData?[
                                                                'city_name'])
                                                            .isEmpty
                                                        ? ""
                                                        : _str(_memberData?[
                                                            'city_name']),
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColor
                                                            .greyLightColor(
                                                                context)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (_str(_memberData?['bio'])
                                              .isNotEmpty)
                                            SizedBox(
                                              height: size.height * 3 / 100,
                                            ),
                                          if (_str(_memberData?['bio'])
                                              .isNotEmpty)
                                            Container(
                                              child: Text(
                                                AppLanguage.bioText[language],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context)),
                                              ),
                                            ),
                                          if (_str(_memberData?['bio'])
                                              .isNotEmpty)
                                            SizedBox(
                                              height: size.height * 1 / 100,
                                            ),
                                          if (_str(_memberData?['bio'])
                                              .isNotEmpty)
                                            Container(
                                              child: Text(
                                                _str(_memberData?['bio'])
                                                        .isEmpty
                                                    ? ""
                                                    : _str(_memberData?['bio']),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColor.greyLightColor(
                                                            context)),
                                              ),
                                            ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text(
                                                  AppLanguage
                                                      .GalleryText[language],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context)),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    PageTransition(
                                                      type: PageTransitionType
                                                          .fade,
                                                      child: ImagePreviewScreen(
                                                        images: _previewImages,
                                                        media: _galleryMedia,
                                                        initialIndex: 0,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  AppLanguage
                                                      .viewAlltext[language],
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColor.pinkColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          _withoutOverscrollIndicator(
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: List.generate(
                                                  pics.length,
                                                  (index) {
                                                    final mediaItem = pics[
                                                                index]
                                                            is Map<String,
                                                                String>
                                                        ? pics[index] as Map<
                                                            String, String>
                                                        : <String, String>{
                                                            'type': 'image',
                                                            'url': pics[index]
                                                                .toString(),
                                                            'source':
                                                                pics[index]
                                                                    .toString(),
                                                            'thumbnail': '',
                                                          };
                                                    final isVideo =
                                                        _isVideoGalleryItem(
                                                            mediaItem);
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .fade,
                                                            child:
                                                                ImagePreviewScreen(
                                                              images:
                                                                  _previewImages,
                                                              media:
                                                                  _galleryMedia,
                                                              initialIndex:
                                                                  index,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width: size.width *
                                                            30 /
                                                            100,
                                                        height: size.height *
                                                            20 /
                                                            100,
                                                        margin: const EdgeInsets
                                                            .only(right: 10),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          child: Stack(
                                                            fit:
                                                                StackFit.expand,
                                                            children: [
                                                              _buildAdaptiveImage(
                                                                _galleryDisplayUrl(
                                                                    mediaItem),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                              if (isVideo)
                                                                Container(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.18),
                                                                ),
                                                              if (isVideo)
                                                                Center(
                                                                  child:
                                                                      Container(
                                                                    width: 34,
                                                                    height: 34,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              0.45),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .play_arrow,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 22,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          Container(
                                            child: Text(
                                              AppLanguage
                                                  .interestText[language],
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.secondryColor(
                                                      context)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1 /
                                                100,
                                          ),
                                          Wrap(
                                            spacing:
                                                7, // horizontal space between items
                                            runSpacing:
                                                10, // vertical space between rows
                                            children: List.generate(
                                              Interest.length,
                                              (index) {
                                                bool isAll =
                                                    Interest[index]['id'] == 1;

                                                return GestureDetector(
                                                  onTap: isAll
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            selectedId =
                                                                Interest[index]
                                                                    ['id'];
                                                          });
                                                        },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: selectedId ==
                                                              Interest[index]
                                                                  ['id']
                                                          ? AppColor
                                                              .primaryColor(
                                                                  context)
                                                          : AppColor
                                                              .primaryColor(
                                                                  context),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50),
                                                      border: Border.all(
                                                        color: selectedId ==
                                                                Interest[index]
                                                                    ['id']
                                                            ? AppColor
                                                                .buttonColor
                                                            : AppColor
                                                                .buttonColor,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      Interest[index]['title'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: selectedId ==
                                                                Interest[index]
                                                                    ['id']
                                                            ? AppColor
                                                                .buttonColor
                                                            : AppColor
                                                                .buttonColor,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                child: Text(
                                                  AppLanguage
                                                      .vibesText[language],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          _buildVibesSection(context),
                                          _str(_memberData?['instagram_url'])
                                                  .isEmpty
                                              ? SizedBox()
                                              : GestureDetector(
                                                  onTap: _openInstagramProfile,
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            12 /
                                                            100,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            90 /
                                                            100,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColor.capsuleColor(
                                                              context),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColor
                                                              .grayColor
                                                              .withOpacity(0.4),
                                                          blurRadius: 2,
                                                          offset: Offset(1, 1),
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              200),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                4 /
                                                                100),

                                                        // Icon
                                                        Image.asset(
                                                          AppImage
                                                              .instagramIcon,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context),
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              5 /
                                                              100,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              6 /
                                                              100,
                                                        ),
                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                2 /
                                                                100),

                                                        // Text + spacing (with Flexible for proper width handling)
                                                        Flexible(
                                                          child: Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                54 /
                                                                100,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  AppLanguage
                                                                          .instagramText[
                                                                      language],
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .secondryColor(
                                                                            context),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _str(_memberData?[
                                                                              'instagram_url'])
                                                                          .isEmpty
                                                                      ? ""
                                                                      : _str(_memberData?[
                                                                          'instagram_url']),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color: AppColor
                                                                        .buttonColor,
                                                                  ),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                2 /
                                                                100),

                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                1 /
                                                                100,
                                                            horizontal:
                                                                MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    5 /
                                                                    100,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: AppColor
                                                                .buttonColor,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            border: Border.all(
                                                                color: AppColor
                                                                    .transparentColor),
                                                          ),
                                                          child: Text(
                                                            AppLanguage
                                                                    .followText[
                                                                language],
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontFamily: AppFont
                                                                  .fontFamily,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                6 /
                                                                100),
                                                      ],
                                                    ),
                                                  )),
                                          // if (_recentEvents.isNotEmpty)
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          if (_recentEvents.isNotEmpty)
                                            SizedBox(
                                              height: size.height * 2 / 100,
                                            ),
                                          if (_recentEvents.isNotEmpty)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    AppLanguage
                                                            .recentlyLikedeventsText[
                                                        language],
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (_recentEvents.isNotEmpty)
                                            SizedBox(
                                              height: size.height * 2 / 100,
                                            ),
                                          if (_recentEvents.isNotEmpty)
                                            SizedBox(
                                              height: size.height * 30 / 100,
                                              child:
                                                  _withoutOverscrollIndicator(
                                                ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: _recentEvents
                                                          .isEmpty
                                                      ? 1
                                                      : _recentEvents.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (_recentEvents.isEmpty) {
                                                      return _recentEventCard(
                                                        image: AppImage
                                                            .eventCardImage,
                                                        name: "",
                                                        time: "",
                                                        tags: [],
                                                        id: "",
                                                        isNetwork: false,
                                                      );
                                                    }
                                                    final item =
                                                        _recentEvents[index];
                                                    return _recentEventCard(
                                                      image: _asUploadUrl(
                                                          item['event_image']),
                                                      name: _str(
                                                          item['event_name']),
                                                      time: _str(item['date']),
                                                      tags:
                                                          _extractEventCategoryNames(
                                                        item['categories'],
                                                      ),
                                                      id: _str(item['_id']),
                                                      isNetwork: true,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          if (_recentVenues.isNotEmpty)
                                            SizedBox(
                                              height: size.height * 3 / 100,
                                            ),
                                          if (_recentVenues.isNotEmpty)
                                            SizedBox(
                                              width: size.width * 80 / 100,
                                              child: Text(
                                                AppLanguage
                                                    .likedVenuestext[language],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context)),
                                              ),
                                            ),
                                          if (_recentVenues.isNotEmpty)
                                            SizedBox(
                                              height: size.height * 2 / 100,
                                            ),
                                          if (_recentVenues.isNotEmpty)
                                            SizedBox(
                                              height: size.height * 18 / 100,
                                              child:
                                                  _withoutOverscrollIndicator(
                                                ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: _recentVenues
                                                          .isEmpty
                                                      ? 3
                                                      : _recentVenues.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    if (_recentVenues.isEmpty) {
                                                      final fallback = [
                                                        AppImage.night,
                                                        AppImage.omnia,
                                                        AppImage.queens,
                                                      ];
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10),
                                                        child: _venueCard(
                                                          fallback[index],
                                                          venueName: "",
                                                          id: "",
                                                        ),
                                                      );
                                                    }
                                                    final item =
                                                        _recentVenues[index];
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: _venueCard(
                                                        _asUploadUrl(item[
                                                            'venue_image']),
                                                        venueName: _str(
                                                            item['venue_name']),
                                                        id: item['_id'],
                                                        isNetwork: true,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          if (_recentVenues.isNotEmpty)
                                            SizedBox(
                                              height: size.height * 3 / 100,
                                            ),
                                          Container(
                                            child: Text(
                                              AppLanguage
                                                      .mytopArtistonspotifyText[
                                                  language],
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.secondryColor(
                                                      context)),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 2 / 100,
                                          ),
                                          _buildTopArtistSection(context),
                                          SizedBox(
                                            height: size.height * 4 / 100,
                                          ),
                                          Divider(
                                            height: 0.2,
                                            thickness: 0.5,
                                            color: AppColor.greyLightColor(
                                                context),
                                            indent: 70,
                                            endIndent: 70,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 15 / 100,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void showInviteMemberstypebottomsheet(
    BuildContext context, {
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    String? conversationId,
  }) =>
      showInviteMembersTypeBottomSheet(
        context,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        conversationId: conversationId,
      );

  Widget _buildVibesSection(BuildContext context) {
    final vibes = _toList(_memberData?['vibes']);
    final items = vibes.map((vibe) {
      if (vibe is Map) {
        return {
          'name': _str(vibe['vibe'] ?? vibe['name']),
          'image': _asUploadUrl(vibe['image']),
        };
      }
      return {'name': _str(vibe), 'image': ''};
    }).toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: _withoutOverscrollIndicator(
        ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final item = items[index];
            final name = _str(item['name']);
            final imageUrl = _str(item['image']);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.themeColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: _buildAdaptiveImage(
                              imageUrl,
                              fit: BoxFit.cover,
                              fallbackAsset: AppImage.dummyImageIcon,
                            ),
                          )
                        : Icon(
                            Icons.music_note,
                            size: 15,
                            color: AppColor.secondryColor(context)
                                .withOpacity(0.3),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _eventChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.eventSmallCardBorder, width: 1),
        color: AppColor.cardFillColor,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _recentEventCard({
    required String image,
    required String name,
    required String time,
    required List<String> tags, // Add tags parameter
    required String id,
    required bool isNetwork,
  }) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: LikedEventDetail(
              eventId: id,
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
        if (!mounted) return;
        await _handleEventSwipeResult(
            result is Map ? Map<String, dynamic>.from(result) : null);
      },
      child: Container(
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

              // Gradient Overlay (more black at bottom)
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

              // Tags at Top Left (Black background type)
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
                left: 7,
                right: 10,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? "" : name,
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
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColor.buttonColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          time.isEmpty ? "-" : time,
                          style: const TextStyle(
                            color: AppColor.buttonColor,
                            fontSize: 11,
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
      ),
    );
  }

  Widget _venueCard(
    String imagePath, {
    String venueName = "",
    String id = '',
    bool isNetwork = false,
  }) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = 125 * size.width / 375;
    final double cardHeight = 150 * size.width / 375;
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: VenuePages(
              venueId: id.toString(),
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
        if (!mounted) return;
        await _handleVenueSwipeResult(
            result is Map ? Map<String, dynamic>.from(result) : null);
      },
      child: Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: AppColor.cardFillColor,
              blurRadius: 10,
              spreadRadius: 0.1,
              offset: const Offset(4, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: isNetwork
                    ? _buildAdaptiveImage(
                        imagePath,
                        fit: BoxFit.cover,
                        fallbackAsset: AppImage.dummyImageIcon,
                      )
                    : Image.asset(
                        AppImage.dummyImageIcon,
                        fit: BoxFit.cover,
                      ),
              ),
              // if (venueName.isNotEmpty)
              //   Padding(
              //     padding: const EdgeInsets.all(8),
              //     child: Text(
              //       venueName,
              //       maxLines: 1,
              //       overflow: TextOverflow.ellipsis,
              //       style: TextStyle(
              //         color: AppColor.secondryColor(context),
              //         fontSize: 12,
              //         fontFamily: AppFont.fontFamily,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopArtistSection(BuildContext context) {
    final topArtist = _memberData?['top_artist'];
    if (topArtist is! Map) return const SizedBox.shrink();

    final artistName = _str(topArtist['name']);
    if (artistName.isEmpty) return const SizedBox.shrink();

    final artistImage = _asUploadUrl(topArtist['image']);
    return _buildArtistChip(context, artistName, artistImage: artistImage);
  }

  Widget _buildArtistChip(
    BuildContext context,
    String artistName, {
    String artistImage = '',
  }) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 2, right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF1CC0),
            ),
            clipBehavior: Clip.antiAlias,
            // child: artistImage.isNotEmpty
            //     ? _buildAdaptiveImage(
            //         artistImage,
            //         fit: BoxFit.cover,
            //         fallbackAsset: AppImage.dummyImageIcon,
            //       )
            //     : null,
          ),
          SizedBox(width: size.width * 0.03),
          // Artist Name
          Text(
            artistName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: AppFont.fontFamily,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
