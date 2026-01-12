import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/view/authentication/app_preference_screen.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/authentication/notifications_setting_screen.dart';
import 'package:night_life/view/authentication/privacy_and_security.dart';
import 'package:night_life/view/authentication/support_screen.dart';
import 'package:night_life/view/other/about/aboutscreen.dart';
import 'package:night_life/view/other/referafriend_screen.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:night_life/utilities/app_comman_setting.dart' show SettingRow;
import '../../utilities/app_color.dart';
import '../../utilities/app_comman_setting.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'edit_profile_screen.dart';

class Profile extends StatefulWidget {
  static String routeName = './Profile';
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {


    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        // backgroundColor: AppColor.purpleColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppColor.backgroundGradientcolor,
          ),
          child: Column(
            children: [
                   SizedBox(
                          height: MediaQuery.of(context).size.height * 3.5 / 100),
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.accountText[language],
             
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Image
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: const EditProfile(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                    
                                      Image.asset(
                                        AppImage.halfCircleicon,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                34 /
                                                100,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                35 /
                                                100,
                                      ),
        
                                      // Profile image
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                31 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                15 /
                                                100,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.userprofile),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    8 /
                                    100),
        
                            // Profile Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              100),
                                  Text(
                                    AppLanguage.sanjanaText[language],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontFamily,
                                      color: AppColor.secondryColor,
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2 /
                                              100),
                                  buildTaskRow(
                                      AppLanguage.addthreeMoreTExt[language],
                                      Colors.pinkAccent),
                                  buildTaskRow(
                                      AppLanguage.completeBio[language],
                                      Colors.orangeAccent),
                                  buildTaskRow(
                                      AppLanguage
                                          .connectInstagramtext[language],
                                      Colors.purpleAccent),
                                  buildTaskRow(
                                      AppLanguage.addFivevedios[language],
                                      Colors.redAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.84,
                        child: Row(
                          children: [
                            Text(
                              AppLanguage.profileCompleteText[language],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.5 /
                                    100),
                            Text(
                              AppLanguage.seventySevencompleteText[language],
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100),
        
                      // Settings List
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.settingsText[language],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingprofile,
                            title: AppLanguage.accountSetting[language],
                            onPress: () {
                              AppConstant.selectFooterIndex = 4;
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const MyAppFooter(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingsecurity,
                            title: AppLanguage.privacyPolicyText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const PrivacySecurityScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingNotification,
                            title: AppLanguage.notificationText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const NotificationSettingScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingApppreference,
                            title: AppLanguage.appPreferences[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const AppPreferences(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                           SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),

                            SettingRow(
                            leadingIcon: AppImage.referIcon,
                            title: AppLanguage.referaFriText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const ReferAFriend(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingSupport,
                            title: AppLanguage.supportText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const SupportScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingAbout,
                            title: AppLanguage.aboutText[language],
                            onPress: () {
                               Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const AboutScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blackdeleteIcon,
                            title: AppLanguage.deleteAccounttext[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const LoginScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 100),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const LoginScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                color: AppColor.logoutContainerColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // ✅ center horizontally
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // ✅ center vertically
                                children: [
                                  Image.asset(
                                    AppImage.logoutIcon,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        1 /
                                        100,
                                  ),
                                  Text(
                                    AppLanguage.logoutText[language],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColor.secondryColor,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTaskRow(String text, Color color) {
    return Row(
      children: [
        Icon(Icons.fiber_manual_record, size: 14, color: color),
        SizedBox(width: MediaQuery.of(context).size.width * 2 / 100),
        SizedBox(height: MediaQuery.of(context).size.height * 3 / 100),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: AppFont.fontFamily,
              color: AppColor.secondryColor,
            ),
          ),
        ),
      ],
    );
  }
}
