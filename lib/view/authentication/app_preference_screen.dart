import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/view/other/city_Preference/music_genres.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../provider/darkmode_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class AppPreferences extends StatefulWidget {
  const AppPreferences({Key? key}) : super(key: key);

  @override
  State<AppPreferences> createState() => _AppPreferencesState();
}

class _AppPreferencesState extends State<AppPreferences> {
  bool isSelected = true;
  int selectedRadioIndex = 0;
  bool broadenedSwitch = false;
  bool mileageSwitch = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));

    final size = MediaQuery.of(context).size;
    @override
    void initState() {
      super.initState();

      selectedRadioIndex = 0;

    }

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          color: AppColor.primaryColor,
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Text(
                    AppLanguage.mediaVisibilityText[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor,
                    ),
                  ),
                ),
                Container(
                  height: size.height * 0.09, // same card height
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor,
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // 
                    children: [
                      /// LEFT TEXT PART
                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // 👈 center vertically
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.autoDownloadMediaText[language],
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                              ),
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLanguage.mediVisiibilityMsgText[language],
                              style: const TextStyle(
                                color: AppColor.notificationtextColor,
                                fontSize: 13, // 👈 image me chhota hai
                                height: 1.2,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT SWITCH
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
                          trackColor: AppColor.toggleColor,
                        ),
                      ),
                    ],
                  ),
                ),

                /// --- Privacy Policy Heading Added Below ---
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
                      color: AppColor.secondryColor,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 2 / 100),

                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
               

                    return Column(
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 9 / 100,
                            decoration: BoxDecoration(
                              color: AppColor.notificationContainerColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.notificationtextColor,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedRadioIndex = 0;
                                });
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
                                            style: const TextStyle(
                                              color: AppColor.secondryColor,
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            AppLanguage.darkMsgText[language],
                                            style: const TextStyle(
                                              color: AppColor
                                                  .notificationtextColor,
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
                                          color: selectedRadioIndex == 0
                                              ? AppColor.secondryColor
                                              : AppColor.notificationtextColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: size.height * 0.010,
                                          width: size.height * 0.010,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedRadioIndex == 0
                                                ? AppColor.secondryColor
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
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 9 / 100,
                            decoration: BoxDecoration(
                              color: AppColor.notificationContainerColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.notificationtextColor,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                        
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
                                            style: const TextStyle(
                                              color: AppColor.secondryColor,
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            AppLanguage.lightMsgText[language],
                                            style: const TextStyle(
                                              color: AppColor
                                                  .notificationtextColor,
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
                                          color: selectedRadioIndex == 1
                                              ? AppColor.secondryColor
                                              : AppColor.notificationtextColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: size.height * 0.010,
                                          width: size.height * 0.010,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedRadioIndex == 1
                                                ? AppColor.secondryColor
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
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            height:
                                MediaQuery.of(context).size.height * 11 / 100,
                            decoration: BoxDecoration(
                              color: AppColor.notificationContainerColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColor.notificationtextColor,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                      
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
                                            style: const TextStyle(
                                              color: AppColor.secondryColor,
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            AppLanguage
                                                .systemDefaultMsgText[language],
                                            style: const TextStyle(
                                              color: AppColor
                                                  .notificationtextColor,
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
                                          color: selectedRadioIndex == 2
                                              ? AppColor.secondryColor
                                              : AppColor.notificationtextColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: size.height * 0.010,
                                          width: size.height * 0.010,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selectedRadioIndex == 2
                                                ? AppColor.secondryColor
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
                        SizedBox(height: 15),
                        SizedBox(
                          width: size.width * 90 / 100,
                          child: Text(
                            AppLanguage.preferencesText[language],
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.secondryColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

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
                      color: AppColor.notificationContainerColor,
                      // borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor,
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
                              padding: EdgeInsets.only(
                                  left: size.width * 3 / 100), //
                              child: Text(
                                AppLanguage.setupYourPrefText[language],
                                style: const TextStyle(
                                  color: AppColor.secondryColor,
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: size.width * 3 / 100), 

                              child: SizedBox(
                                height: size.width * 8 / 100,
                                width: size.width * 9 / 100,
                                child: Image.asset(
                                  AppImage.frontArrowIcon,
                                  fit: BoxFit.contain,
                                ),
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
