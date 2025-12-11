import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_header.dart';
import '../../../utilities/app_image.dart';

class AboutScreen extends StatefulWidget {
  static String routeName = './AboutScreen';
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 100 / 100,
            width: MediaQuery.of(context).size.width * 100 / 100,
            color: AppColor.primaryColor,
            child: Column(
              children: [
                AppHeader(
                  text: AppLanguage.aboutText[language],
                  onPress: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                Container(
                  child: Column(
                    children: [
                      Image.asset(
  AppImage.hii,
  width: 125,   
  // height: 111,
  fit: BoxFit.contain,
),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 14 / 100,
                      ),
                      Container(
                        height: size.height * 8 / 100,
                        width: size.width * 94 / 100,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.5 /
                                  100,
                            ),
                            Text(
                              "Hii App",
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Version 1.021",
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1.5 / 100,
                      ),
                      Container(
                        height: size.height * 6 / 100,
                        width: size.width * 94 / 100,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Check for Updates",
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w500,
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
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 22 / 100,
                      ),
                      Text(
                        "A product of",
                        style: const TextStyle(
                          color: AppColor.secondryColor,
                          fontSize: 16,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Image.asset(
                        AppImage.amblogo,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.height * 20 / 100,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
