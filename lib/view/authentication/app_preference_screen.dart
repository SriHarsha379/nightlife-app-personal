import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../provider/darkmode_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_language.dart';
import '../other/city_Preference/music_genres.dart';
// Import your MusicGenresScreen path
// import 'package:night_life/view/other/city_Preference/music_genres.dart';

class AppPreferences extends StatefulWidget {
  const AppPreferences({Key? key}) : super(key: key);

  @override
  State<AppPreferences> createState() => _AppPreferencesState();
}

class _AppPreferencesState extends State<AppPreferences> {
  bool mileageSwitch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppColor.primaryColor(context),
      systemNavigationBarIconBrightness:
          Theme.of(context).brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
      statusBarColor: AppColor.primaryColor(context),
      statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          color: AppColor.primaryColor(context),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 2 / 100),
                AppHeader(
                  onPress: () => Navigator.pop(context),
                  text: AppLanguage.appPreferences[language],
                ),
                SizedBox(height: size.height * 2 / 100),

                // Media Visibility Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Text(
                    AppLanguage.mediaVisibilityText[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),
                Container(
                  height: size.height * 0.09,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor(context),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor(context).withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.autoDownloadMediaText[language],
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                              ),
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLanguage.mediVisiibilityMsgText[language],
                              style: TextStyle(
                                color: AppColor.notificationtextColor(context),
                                fontSize: 13,
                                height: 1.2,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.80,
                        child: CupertinoSwitch(
                          value: mileageSwitch,
                          onChanged: (value) {
                            setState(() {
                              mileageSwitch = value;
                            });
                          },
                          activeColor: AppColor.pinkColor,
                          thumbColor: Colors.white,
                          trackColor: AppColor.toggleColor(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Themes Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.themesText[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 2 / 100),

                // Theme Options
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Column(
                      children: [
                        // Dark Theme Option
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 9 / 100,
                            decoration: BoxDecoration(
                              color:
                                  AppColor.notificationContainerColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.notificationtextColor(context),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                themeProvider.toggleTheme(true);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 3.5 / 100),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLanguage.darkText[language],
                                            style: TextStyle(
                                              color: AppColor.secondryColor(
                                                  context),
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            AppLanguage.darkMsgText[language],
                                            style: TextStyle(
                                              color: AppColor
                                                  .notificationtextColor(
                                                      context),
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: size.height * 0.02,
                                      width: size.height * 0.02,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: themeProvider.themeMode ==
                                                  ThemeMode.dark
                                              ? AppColor.pinkColor
                                              : AppColor.notificationtextColor(
                                                  context),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: size.height * 0.010,
                                          width: size.height * 0.010,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeProvider.themeMode ==
                                                    ThemeMode.dark
                                                ? AppColor.pinkColor
                                                : Colors.transparent,
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
                        SizedBox(height: size.height * 1.5 / 100),

                        // Light Theme Option
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 9 / 100,
                            decoration: BoxDecoration(
                              color:
                                  AppColor.notificationContainerColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.notificationtextColor(context),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                themeProvider.toggleTheme(false);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 3.5 / 100),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLanguage.lightText[language],
                                            style: TextStyle(
                                              color: AppColor.secondryColor(
                                                  context),
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            AppLanguage.lightMsgText[language],
                                            style: TextStyle(
                                              color: AppColor
                                                  .notificationtextColor(
                                                      context),
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: size.height * 0.02,
                                      width: size.height * 0.02,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: themeProvider.themeMode ==
                                                  ThemeMode.light
                                              ? AppColor.pinkColor
                                              : AppColor.notificationtextColor(
                                                  context),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: size.height * 0.010,
                                          width: size.height * 0.010,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeProvider.themeMode ==
                                                    ThemeMode.light
                                                ? AppColor.pinkColor
                                                : Colors.transparent,
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
                        SizedBox(height: size.height * 1.5 / 100),

                        // System Default Option
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 11 / 100,
                            decoration: BoxDecoration(
                              color:
                                  AppColor.notificationContainerColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.notificationtextColor(context),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                themeProvider.setSystemDefault();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 3.5 / 100),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppLanguage
                                                .systemDefaultText[language],
                                            style: TextStyle(
                                              color: AppColor.secondryColor(
                                                  context),
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            AppLanguage
                                                .systemDefaultMsgText[language],
                                            style: TextStyle(
                                              color: AppColor
                                                  .notificationtextColor(
                                                      context),
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: size.height * 0.02,
                                      width: size.height * 0.02,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: themeProvider.themeMode ==
                                                  ThemeMode.system
                                              ? AppColor.pinkColor
                                              : AppColor.notificationtextColor(
                                                  context),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: size.height * 0.010,
                                          width: size.height * 0.010,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: themeProvider.themeMode ==
                                                    ThemeMode.system
                                                ? AppColor.pinkColor
                                                : Colors.transparent,
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
                        const SizedBox(height: 15),

                        // Preferences Section
                        SizedBox(
                          width: size.width * 90 / 100,
                          child: Text(
                            AppLanguage.preferencesText[language],
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Setup Your Preference Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: MusicGenresScreen(),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.notificationContainerColor(context),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColor.primaryColor(context).withOpacity(0.3),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(left: size.width * 3 / 100),
                              child: Text(
                                AppLanguage.setupYourPrefText[language],
                                style: TextStyle(
                                  color: AppColor.secondryColor(context),
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.only(right: size.width * 3 / 100),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: AppColor.secondryColor(context),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
