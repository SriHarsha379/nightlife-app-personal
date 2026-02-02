import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/view/other/block_user_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool isSelected = true;
  List<bool> switches = [
    false,
    false,
  ];
  int selectedRadioIndex = -1;
  bool broadenedSwitch = false;
  bool mileageSwitch = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: AppColor.primaryColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 5 / 100),
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.privacyPolicyText[language],
              ),
              SizedBox(height: size.height * 2 / 100),

              /// --- Visibility Section Heading ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                child: Text(
                  AppLanguage.visibilityText[language],
                  textAlign: TextAlign.left,
                  style:const TextStyle(
                    fontFamily: AppFont.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.secondryColor,
                  ),
                ),
              ),

              /// --- Visibility Container ---
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColor.notificationContainerColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor,
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.showMeonText[language],
                          style: const TextStyle(
                            color: AppColor.secondryColor,
                            fontSize: 15,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
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
                            trackColor: AppColor.toggleColor,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      AppLanguage.allowOthersText[language],
                      style: const TextStyle(
                        color: AppColor.notificationtextColor,
                        fontSize: 14,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
                child: Text(
                  AppLanguage.blockedUsersText[language],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: AppFont.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.secondryColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: BlockUserScreen(),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor,
                    borderRadius: BorderRadius.circular(8),
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
                      SizedBox(width: size.width * 2 / 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLanguage.blockedUsersText[language],
                            style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 16,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: size.width * 8 / 100,
                            width: size.width * 9 / 100,
                            child: Image.asset(
                              AppImage.frontArrowIcon,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
                child: Text(
                  AppLanguage.locationSharingText[language],
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
                height: size.height * 6 / 100,
                width: size.width * 94 / 100,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColor.notificationContainerColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor,
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLanguage.managePermissionsText[language],
                      style: const TextStyle(
                        color: AppColor.secondryColor,
                        fontSize: 16,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: size.width * 8 / 100,
                      width: size.width * 9 / 100,
                      child: Image.asset(
                        AppImage.frontArrowIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
                child: Text(
                  AppLanguage.dataAndsecurity[language],
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
                height: size.height * 7 / 100,
                width: size.width * 94 / 100,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.notificationContainerColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor,
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLanguage.downloadDatatext[language],
                      style: const TextStyle(
                        color: AppColor.secondryColor,
                        fontSize: 16,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: size.width * 8 / 100,
                      width: size.width * 9 / 100,
                      child: Image.asset(
                        AppImage.frontArrowIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: size.height * 7 / 100,
                width: size.width * 94 / 100,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.notificationContainerColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor,
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLanguage.deleteAccount[language],
                      style: const TextStyle(
                        color: AppColor.secondryColor,
                        fontSize: 16,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: size.width * 8 / 100,
                      width: size.width * 9 / 100,
                      child: Image.asset(
                        AppImage.frontArrowIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
            ],
          ),
        ),
      ),
    );
  }
}
