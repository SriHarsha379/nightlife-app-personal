import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../../controller/my_profile/get_my_swipe_profile_controller.dart';
import '../../provider/darkmode_provider.dart';

class EditSwipeProfile extends StatefulWidget {
  static const String routeName = '/EditSwipeProfile';
  final List<Map<String, String>> galleryItems;
  const EditSwipeProfile({
    super.key,
    this.galleryItems = const [],
  });

  @override
  State<EditSwipeProfile> createState() => _EditSwipeProfileState();
}

class _EditSwipeProfileState extends State<EditSwipeProfile> {
  int selectedIndex = 0;

  late final List<Map<String, String>> _galleryItems;
  Map<String, bool> _visibility = {
    'age': true,
    'height': true,
    'pronouns': true,
    'location': true,
    'hobbies': true,
    'vibes': true,
    'gallery': true,
    'recent_events': true,
    'recent_venues': true,
    'instagram': true,
    'spotify': true,
  };

  int selectedtickmarkIndex = -1;
  int selectedtickmarkIndex1 = -1;

  int selectedtickIndex1 = -1;
  int selectedtickIndex = -1;
  bool isSwitched = true;
  bool isSelected = false;
  Set<int> selectedTickIndexes1 = {};
  Set<int> selectedTickIndexes = {};
  Set<int> selectedTickIndexes2 = {};
  Set<int> selectedTickIndexes3 = {};

  @override
  void initState() {
    super.initState();
    _galleryItems = widget.galleryItems
        .where((item) =>
            (item['url'] ?? '').isNotEmpty ||
            (item['thumbnail'] ?? '').isNotEmpty)
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller =
          Provider.of<GetMySwipeProfileController>(context, listen: false);
      await controller.fetchProfileVisibility(context);
      if (!mounted) return;
      setState(() {
        _visibility = controller.visibility;
      });
    });
  }

  String _galleryUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '${AppConfigProvider.imageUrl}$trimmed';
  }

  bool _isVisible(String key) {
    return _visibility[key] ?? true;
  }

  Future<void> _updateVisibility(String key, bool value) async {
    setState(() {
      _visibility[key] = value;
    });
    final controller =
        Provider.of<GetMySwipeProfileController>(context, listen: false);
    await controller.updateProfileVisibility(
      context,
      key: key,
      value: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = AppColor.pastbookeventcontainercolor(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
              body: Container(
            color: AppColor.primaryColor(context),
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 4 / 100),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      height: MediaQuery.of(context).size.height * 7 / 100,
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 7 / 100,
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImage.backarrow,
                                fit: BoxFit.cover,
                                color: AppColor.secondryColor(context),
                                height:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                width:
                                    MediaQuery.of(context).size.width * 5 / 100,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 2 / 100,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 80 / 100,
                              child: Text(
                                AppLanguage.editSwipeprofileText[language],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColor.secondryColor(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 1 / 100),

                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Text(
                          "Turn on to make these details visible to members. Turn off to keep them hidden.",
                          style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontFamily: AppFont.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 68 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor.withOpacity(0.4),
                            // spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0 /
                                    100),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 86 / 100,
                              child: Text(
                                  AppLanguage.basicdetailstext[language],
                                  style: TextStyle(
                                      color: AppColor.hinttextcolor(context),
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(AppLanguage.ageText1[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.hinttextcolor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('age'),
                                      onChanged: (value) {
                                        _updateVisibility('age', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.heightText[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.hinttextcolor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('height'),
                                      onChanged: (value) {
                                        _updateVisibility('height', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.pronouncsText[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.hinttextcolor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('pronouns'),
                                      onChanged: (value) {
                                        _updateVisibility('pronouns', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.hobbiesText[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.hinttextcolor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('hobbies'),
                                      onChanged: (value) {
                                        _updateVisibility('hobbies', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.nearbyLocation[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.hinttextcolor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('location'),
                                      onChanged: (value) {
                                        _updateVisibility('location', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 14 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cardColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 78 / 100,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(AppLanguage.vibesText[language],
                                  style: TextStyle(
                                      color: AppColor.secondryColor(context),
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 9 / 100,
                            height:
                                MediaQuery.of(context).size.height * 4 / 100,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Switch(
                                value: _isVisible('vibes'),
                                onChanged: (value) {
                                  _updateVisibility('vibes', value);
                                },
                                activeColor: Colors.white,
                                activeTrackColor: AppColor.pinkColor,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: isDark
                                    ? const Color(0xFF6E6E6E)
                                    : const Color(0xFFBDBDBD),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),

                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: Container(
                        // height: MediaQuery.of(context).size.width * 132 / 100,
                        width: MediaQuery.of(context).size.width * 92 / 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.grayColor.withOpacity(0.4),
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12, left: 12),
                                    child: Text(
                                      AppLanguage.GalleryText[language],
                                      style: TextStyle(
                                        color: AppColor.secondryColor(context),
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('gallery'),
                                      onChanged: (value) {
                                        _updateVisibility('gallery', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            if (_galleryItems.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: Text(
                                  'No gallery images found',
                                  style: TextStyle(
                                    color: AppColor.secondryColor(context),
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: (size.width * 26 / 100) /
                                        (size.height * 18 / 100),
                                  ),
                                  itemCount: _galleryItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _galleryItems[index];
                                    final type = item['type'] ?? 'image';
                                    final url = item['url'] ?? '';
                                    final thumb = item['thumbnail'] ?? '';
                                    final displayUrl = type == 'video'
                                        ? (thumb.isNotEmpty
                                            ? _galleryUrl(thumb)
                                            : '')
                                        : _galleryUrl(url);

                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          displayUrl.isNotEmpty
                                              ? Image.network(
                                                  displayUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.asset(
                                                      AppImage.dogImage,
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                )
                                              : Image.asset(
                                                  AppImage.dogImage,
                                                  fit: BoxFit.cover,
                                                ),
                                          if (type == 'video')
                                            const Positioned.fill(
                                              child: Icon(
                                                Icons.play_circle_outline,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),

//==================Recent events==========//
                  Center(
                    child: Container(
                      // height: MediaQuery.of(context).size.width * 30 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor.withOpacity(0.4),
                            // spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12, left: 12, top: 8),
                                    child: Text(
                                        AppLanguage.recentEventsText[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.secondryColor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        9 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        4 /
                                        100,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Switch(
                                        value: _isVisible('recent_events'),
                                        onChanged: (value) {
                                          _updateVisibility(
                                              'recent_events', value);
                                        },
                                        activeColor: Colors.white,
                                        activeTrackColor: AppColor.pinkColor,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: isDark
                                            ? const Color(0xFF6E6E6E)
                                            : const Color(0xFFBDBDBD),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 84 / 100,
                              child: Text(
                                  AppLanguage.recentEventsinstText[language],
                                  style: const TextStyle(
                                      color: AppColor.textcolor,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),

//=======================recent venues===========//
                  Center(
                    child: Container(
                      // height: MediaQuery.of(context).size.width * 30 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor.withOpacity(0.4),
                            // spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 12, left: 12, top: 8),
                                    child: Text(
                                        AppLanguage.recentVenueText[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.secondryColor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        9 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        4 /
                                        100,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Switch(
                                        value: _isVisible('recent_venues'),
                                        onChanged: (value) {
                                          _updateVisibility(
                                              'recent_venues', value);
                                        },
                                        activeColor: Colors.white,
                                        activeTrackColor: AppColor.pinkColor,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: isDark
                                            ? const Color(0xFF6E6E6E)
                                            : const Color(0xFFBDBDBD),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 84 / 100,
                              child: Text(
                                  AppLanguage.recentVenueinstText[language],
                                  style: const TextStyle(
                                      color: AppColor.textcolor,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),

                  Center(
                    child: Container(
                      // height: MediaQuery.of(context).size.width * 30 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cardColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                        AppLanguage.instagramText[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.secondryColor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('instagram'),
                                      onChanged: (value) {
                                        _updateVisibility('instagram', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 7 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cardColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: Text(
                                        AppLanguage.spotifyText[language],
                                        style: TextStyle(
                                            color:
                                                AppColor.secondryColor(context),
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: _isVisible('spotify'),
                                      onChanged: (value) {
                                        _updateVisibility('spotify', value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: isDark
                                          ? const Color(0xFF6E6E6E)
                                          : const Color(0xFFBDBDBD),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                ],
              ),
            ),
          ))),
    );
  }
}
