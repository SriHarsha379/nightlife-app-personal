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
      statusBarIconBrightness: Brightness.light,
    ));

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: SafeArea(
          child: Container(
            height: h,
            width: w,
            color: AppColor.primaryColor,
            child: Column(
              children: [
                AppHeader(
                  text: AppLanguage.aboutText[language],
                  onPress: () => Navigator.pop(context),
                ),

                SizedBox(height: h * 0.04),

                Column(
                  children: [
                    /// Logo
                    Image.asset(
                      AppImage.hii,
                      width: w * 0.35,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: h * 0.02),

                    Container(
                      height: h * 0.08,
                      width: w * 0.94,
                      padding: EdgeInsets.symmetric(
                        vertical: h * 0.01,
                        horizontal: w * 0.03,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: w * 0.02,
                        vertical: h * 0.005,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: h * 0.005),
                          Text(
                            "Hii App",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: w * 0.042,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Version 1.021",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: w * 0.038,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.015),

                    /// SECOND CARD (Check for Updates)
                    Container(
                      height: h * 0.06,
                      width: w * 0.94,
                      padding: EdgeInsets.symmetric(
                        vertical: h * 0.01,
                        horizontal: w * 0.03,
                      ),
                      margin: EdgeInsets.symmetric(
                        horizontal: w * 0.02,
                        vertical: h * 0.005,
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
                            "Check for Updates",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: w * 0.042,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: w * 0.08,
                            child: Image.asset(AppImage.frontArrowIcon),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.31),

                    Text(
                      "A product of",
                      style: TextStyle(
                        color: AppColor.secondryColor,
                        fontSize: w * 0.042,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Image.asset(
                      AppImage.amblogo,
                      width: w * 0.40,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: h * 0.01),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
