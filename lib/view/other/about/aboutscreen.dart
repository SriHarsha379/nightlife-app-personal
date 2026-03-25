import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/content_service.dart';
import '../../../provider/darkmode_provider.dart';
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
  String rateappurl = '';
  String appVersion = _fallbackAppVersion();

  static String _fallbackAppVersion() {
    const buildName = String.fromEnvironment('FLUTTER_BUILD_NAME');
    if (buildName.isEmpty) return '1.0.0';
    return buildName;
  }

  @override
  void initState() {
    super.initState();
    loadContentData();
    loadAppVersion();
  }

  loadContentData() {
    fetchAllContent((List data) {
      for (var item in data) {
        // iOS App Store Link (content_type: 3)
        if (item['content_type'] == 3) {
          var iosurl = item['content'];
          setState(() {
            if (AppConstant.deviceType == 'ios') {
              rateappurl = iosurl;
            }
          });
        }

        // Android Play Store Link (content_type: 4)
        if (item['content_type'] == 4) {
          var androidurl = item['content'];
          setState(() {
            if (AppConstant.deviceType == 'android') {
              rateappurl = androidurl;
            }
          });
        }
      }
    });
  }

  Future<void> loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.trim();
      if (!mounted) return;
      setState(() {
        appVersion = version.isNotEmpty ? version : _fallbackAppVersion();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        appVersion = _fallbackAppVersion();
      });
    }
  }

  Future openUrl({
    required String url,
    bool inApp = false,
  }) async {
    print('Opening URL: $url');

    // Check if the URL starts with http:// or https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: inApp,
        forceWebView: inApp,
        enableJavaScript: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: SafeArea(
          child: Container(
            height: h,
            width: w,
            color: AppColor.primaryColor(context),
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
                      color: AppColor.secondryColor(context),
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
                        color: AppColor.notificationContainerColor(context),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor(context),
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
                              color: AppColor.secondryColor(context),
                              fontSize: w * 0.042,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Version $appVersion",
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
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
                    GestureDetector(
                      onTap: () {
                        openUrl(url: rateappurl);
                      },
                      child: Container(
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
                          color: AppColor.notificationContainerColor(context),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.primaryColor(context),
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
                                color: AppColor.secondryColor(context),
                                fontSize: w * 0.042,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              width: w * 0.08,
                              child: Image.asset(
                                AppImage.frontArrowIcon,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.31),

                    Text(
                      "A product of",
                      style: TextStyle(
                        color: AppColor.secondryColor(context),
                        fontSize: w * 0.042,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Image.asset(
                      AppImage.amblogo,
                      width: w * 0.40,
                      fit: BoxFit.contain,
                      color: AppColor.secondryColor(context),
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
