import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_config_provider.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../controller/home/home_controller.dart';
import '../../../../helper/ImagePreviewScreen.dart';
import '../../chats/chat_message_screen.dart';

class LikedMemberDetail extends StatefulWidget {
  static const String routeName = '/LikedMemberDetail';
  final String? memberId;
  const LikedMemberDetail({super.key, this.memberId});

  @override
  State<LikedMemberDetail> createState() => _LikedMemberDetailState();
}

class _LikedMemberDetailState extends State<LikedMemberDetail> {
  Map<String, dynamic>? _memberData;
  bool _isLoading = false;
  Map<String, String>? _swipeResult;
  List<String> _galleryUrls = [];
  List<String> _vibeNames = [];
  List<String> _eventPreferenceNames = [];
  List<Map<String, dynamic>> _recentEvents = [];
  List<Map<String, dynamic>> _recentVenues = [];

  int selectedIndex = 0;

  List Interest = [
    {'id': 1, 'title': 'Music'},
    {'id': 2, 'title': 'Photography'},
    {'id': 3, 'title': 'Social Mixers'},
    {'id': 4, 'title': 'Open Mic'},
    {'id': 5, 'title': 'Comedy Shows'},
  ];

  final List<Map<String, dynamic>> chatUsers = [
    {
      "name": "Priya",
      "username": "@priya",
      "image": "assets/icons/ProfilePhoto.png"
    },
    {
      "name": "Neha",
      "username": "@neha",
      "image": "assets/icons/aadityaIcon.png"
    },
    {
      "name": "Preet",
      "username": "@preet",
      "image": "assets/icons/galleryIcon.png"
    },
    {
      "name": "Rohan",
      "username": "@rohan",
      "image": "assets/icons/girlImage.png"
    },
    {
      "name": "Golu",
      "username": "@golu",
      "image": "assets/icons/userprofile.png"
    },
  ];

  List chats = [
    {
      'id': 1,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Brew&Bloom',
      'lastMessage': '@Brew&BloomCafÃ©',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Techno',
      'lastMessage': '@Techno',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/eventstory3.png',
      'name': 'SUNBURN',
      'lastMessage': '@Sunburn',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/eventstory1.jpg',
      'name': 'Mitro',
      'lastMessage': '@Mitro',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Razberry',
      'lastMessage': '@Razberry',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/eventstory3.png',
      'name': 'CCD',
      'lastMessage': '@CCD',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
  ];

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

      _galleryUrls = gallery
          .map((e) => e is Map ? _asUploadUrl(e['url']) : '')
          .where((e) => e.isNotEmpty)
          .cast<String>()
          .toList();
      if (_galleryUrls.isEmpty) {
        final profile = _asUploadUrl(data['profile_image']);
        if (profile.isNotEmpty) {
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

      if (_galleryUrls.isNotEmpty) {
        pics = _galleryUrls;
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

  Future<void> _submitSwipeAction(String action) async {
    final userId = _targetUserId();
    if (userId.isEmpty) return;

    _swipeResult = {
      'action': action, // left | right
      'targetUserId': userId,
    };
    Navigator.pop(context, _swipeResult);
  }

  List<String> _extractEventCategoryNames(dynamic categoriesRaw) {
    if (categoriesRaw is! List) return <String>[];
    return categoriesRaw
        .map((item) => item is Map ? _str(item['name']) : _str(item))
        .where((name) => name.isNotEmpty)
        .cast<String>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
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
              width: size.width * 85 / 100,
              height: size.height * 7 / 100,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
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
                        documenttypebottomsheet(context);
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
                    SizedBox(
                      width: size.width * 3 / 100,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _submitSwipeAction('right');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 10),
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
                              color: AppColor.secondryColor(
                                  context), // optional tint color
                            ),
                            Text(
                              AppLanguage.likeText[language],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor(context),
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
                                                    color: Colors.black,
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
                                              Container(
                                                child: Text(
                                                  AppLanguage.ageText[language],
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColor.buttonColor),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                              ),
                                              Text(
                                                "${_str(_memberData?['age']).isEmpty ? '52' : _str(_memberData?['age'])} y.o | ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context)),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                              ),
                                              _str(_memberData?['height'])
                                                      .isEmpty
                                                  ? SizedBox()
                                                  : Container(
                                                      child: Text(
                                                        AppLanguage.Heighttext[
                                                            language],
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: AppColor
                                                                .buttonColor),
                                                      ),
                                                    ),
                                              _str(_memberData?['height'])
                                                      .isEmpty
                                                  ? SizedBox()
                                                  : SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1 /
                                                              100,
                                                    ),
                                              Text(
                                                _str(_memberData?['height'])
                                                        .isEmpty
                                                    ? ""
                                                    : _str(
                                                        _memberData?['height']),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context)),
                                              ),
                                              Container(
                                                child: Text(
                                                  AppLanguage
                                                      .pronouncsText[language],
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColor.buttonColor),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1 /
                                                    100,
                                              ),
                                              Text(
                                                _str(_memberData?['pronouns'])
                                                        .isEmpty
                                                    ? ""
                                                    : _str(_memberData?[
                                                        'pronouns']),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context)),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.height * 1 / 100,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                child: Text(
                                                  AppLanguage
                                                      .Hobbiestext[language],
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColor.buttonColor),
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    2 /
                                                    100,
                                              ),
                                              Text(
                                                _toList(_memberData?['hobbies'])
                                                        .map((e) => _str(e))
                                                        .where(
                                                            (e) => e.isNotEmpty)
                                                        .join(', ')
                                                        .isEmpty
                                                    ? ""
                                                    : _toList(_memberData?[
                                                            'hobbies'])
                                                        .map((e) => _str(e))
                                                        .where(
                                                            (e) => e.isNotEmpty)
                                                        .join(', '),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColor
                                                        .greyLightColor),
                                              ),
                                            ],
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
                                                        ? "Lane 7, Koregaon Park"
                                                        : _str(_memberData?[
                                                            'city_name']),
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColor
                                                            .greyLightColor),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [],
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_str(_memberData?['bio'])
                                              .isNotEmpty)
                                            SizedBox(
                                              height: size.height * 4 / 100,
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
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColor
                                                        .greyLightColor),
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
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: List.generate(
                                                pics.length,
                                                (index) => InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      PageTransition(
                                                        type: PageTransitionType
                                                            .fade,
                                                        child:
                                                            ImagePreviewScreen(
                                                          images:
                                                              _previewImages,
                                                          initialIndex: index,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    width:
                                                        size.width * 30 / 100,
                                                    height:
                                                        size.height * 20 / 100,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child:
                                                          _buildAdaptiveImage(
                                                        pics[index].toString(),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
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
                                              : Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      12 /
                                                      100,
                                                  width: MediaQuery.of(context)
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
                                                        AppImage.instagramIcon,
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
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontFamily: AppFont
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
                                                                fontSize: 12,
                                                                fontFamily: AppFont
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
                                                                  .circular(50),
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
                                                                FontWeight.w600,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
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
                                                ),
                                          if (_recentEvents.isNotEmpty)
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
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: _recentEvents.isEmpty
                                                    ? 1
                                                    : _recentEvents.length,
                                                itemBuilder: (context, index) {
                                                  if (_recentEvents.isEmpty) {
                                                    return _recentEventCard(
                                                      image: AppImage
                                                          .eventCardImage,
                                                      name: "",
                                                      time: "",
                                                      tags: [], // Add tags
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
                                                    isNetwork: true,
                                                  );
                                                },
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
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: _recentVenues.isEmpty
                                                    ? 3
                                                    : _recentVenues.length,
                                                itemBuilder: (context, index) {
                                                  if (_recentVenues.isEmpty) {
                                                    final fallback = [
                                                      AppImage.night,
                                                      AppImage.omnia,
                                                      AppImage.queens,
                                                    ];
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: _venueCard(
                                                        fallback[index],
                                                        venueName: "",
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
                                                      _asUploadUrl(
                                                          item['venue_image']),
                                                      venueName: _str(
                                                          item['venue_name']),
                                                      isNetwork: true,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
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
                                            color: AppColor.greyLightColor,
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

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * size.height * 0.3),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 60 / 100,
              color: Colors.transparent,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    height: MediaQuery.of(context).size.height * 60 / 100,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                                  AppColor.backgroundGradientcolor(context),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(46),
                                topRight: Radius.circular(46),
                              ),
                            ),
                            width: size.width * 100 / 100,
                            height: size.height * 80 / 100,
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 2 / 100),

                                /// -------- DRAG INDICATOR --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 0.8 + (0.2 * value),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    AppImage.dashIcon,
                                    height: size.height * 0.5 / 100,
                                    width: size.width * 28 / 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),

                                /// -------- TABS (EVENTS & VENUES) --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -20 * (1 - value)),
                                      child: Opacity(
                                        opacity: value.clamp(0.0, 1.0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: AppColor.transparentColor,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        8 /
                                        100,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 5 / 100,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// -------- EVENTS TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 0;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 0
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 0
                                                      ? AppColor.secondryColor(
                                                          context)
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 0
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .eventsText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// -------- VENUES TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 1;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 1
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 1
                                                      ? AppColor.secondryColor(
                                                          context)
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 1
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .venuesText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// -------- TAB INDICATOR (FULL WIDTH) --------
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: 2,
                                  child: Stack(
                                    children: [
                                      // Background line (full width)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 2,
                                        color: AppColor.greyLightColor
                                            .withOpacity(0.3),
                                      ),
                                      // Animated indicator
                                      AnimatedAlign(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        alignment: selectedIndex == 0
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color:
                                                AppColor.secondryColor(context),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColor.secondryColor(
                                                        context)
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),
                                SizedBox(height: size.height * 1 / 100),

                                /// -------- CONTACTS LIST --------
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.1, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: SingleChildScrollView(
                                      key: ValueKey<int>(selectedIndex),
                                      child: Column(
                                        children: [
                                          ...List.generate(
                                            selectedIndex == 0
                                                ? chats.length
                                                : chats.length,
                                            (index) {
                                              final chat = selectedIndex == 0
                                                  ? chats[index]
                                                  : chats[index];
                                              final isSend = selectedIndex == 0
                                                  ? (chats[index]['isSend'] ==
                                                      true)
                                                  : (chats[index]['isSend'] ==
                                                      true);

                                              return TweenAnimationBuilder<
                                                  double>(
                                                tween:
                                                    Tween(begin: 0.0, end: 1.0),
                                                duration: Duration(
                                                    milliseconds:
                                                        300 + (index * 50)),
                                                curve: Curves.easeOutBack,
                                                builder:
                                                    (context, value, child) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                        30 * (1 - value), 0),
                                                    child: Opacity(
                                                      opacity:
                                                          value.clamp(0.0, 1.0),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: Wrap(
                                                  children: [
                                                    Container(
                                                      width:
                                                          size.width * 90 / 100,
                                                      height: size.height *
                                                          8.5 /
                                                          100,
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        leading: Container(
                                                          height: size.height *
                                                              10 /
                                                              100,
                                                          width: size.width *
                                                              13 /
                                                              100,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  chat['image'] ??
                                                                      ''),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        title: Row(
                                                          children: [
                                                            Text(
                                                              chat['name'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    size.width *
                                                                        2 /
                                                                        100),
                                                            // Bordered label for Event/Venue
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    size.width *
                                                                        2 /
                                                                        100,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppColor
                                                                      .pinkColor,
                                                                  width: .3,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Text(
                                                                selectedIndex ==
                                                                        0
                                                                    ? AppLanguage
                                                                            .eventsText[
                                                                        language]
                                                                    : AppLanguage
                                                                            .venuesText[
                                                                        language],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 8,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  color: AppColor
                                                                      .secondryColor(
                                                                          context),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        subtitle: Text(
                                                          chat['lastMessage'] ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        trailing:
                                                            GestureDetector(
                                                          onTap: () {
                                                            setStateBottomSheet(
                                                                () {
                                                              if (selectedIndex ==
                                                                  0) {
                                                                chats[index][
                                                                        'isSend'] =
                                                                    true;
                                                              } else {
                                                                chats[index][
                                                                        'isSend'] =
                                                                    true;
                                                              }
                                                            });

                                                            Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                              () {
                                                                Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                    type: PageTransitionType
                                                                        .bottomToTop,
                                                                    child:
                                                                        ChatMessageScreen(
                                                                      name: chat[
                                                                              'name'] ??
                                                                          '',
                                                                      image:
                                                                          chat['image'] ??
                                                                              '',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        17,
                                                                    vertical:
                                                                        7),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSend
                                                                  ? AppColor
                                                                      .logoutContainerColor(
                                                                          context)
                                                                  : AppColor
                                                                      .secondryColor(
                                                                          context),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: isSend
                                                                  ? Border.all(
                                                                      color: AppColor
                                                                          .buttonColor,
                                                                      width: 1)
                                                                  : null,
                                                            ),
                                                            child: Text(
                                                              isSend
                                                                  ? (chat['message1']
                                                                          ?.toString() ??
                                                                      'Send')
                                                                  : (chat['message']
                                                                          ?.toString() ??
                                                                      'Send'),
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                color: isSend
                                                                    ? AppColor
                                                                        .secondryColor(
                                                                            context)
                                                                    : AppColor
                                                                        .primaryColor(
                                                                            context),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (index <
                                                        (selectedIndex == 0
                                                                ? chats.length
                                                                : chats
                                                                    .length) -
                                                            1)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.1 /
                                                              100),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        });
      },
    );
  }

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
      child: ListView.separated(
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
                          color:
                              AppColor.secondryColor(context).withOpacity(0.3),
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
                      border:
                          Border.all(color: const Color(0xFF9C27B0), width: 2),
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
                      const SizedBox(width: 6),
                      Text(
                        time.isEmpty ? "-" : time,
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

  Widget _venueCard(
    String imagePath, {
    String venueName = "",
    bool isNetwork = false,
  }) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = 125 * size.width / 375;
    final double cardHeight = 150 * size.width / 375;
    return Container(
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
