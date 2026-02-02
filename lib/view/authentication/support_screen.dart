import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_button.dart';
import 'package:night_life/view/authentication/report_problem.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../content_screen/content_screen.dart';
import 'chat_support.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

List<Map<String, dynamic>> faqList = [
  {
    "heading": "How do I create an account?",
    "message":
        "To create an account, download the app, tap 'Sign Up', and follow the prompts. You'll need to provide your email, create a password, and agree to our terms.",
    "image": AppImage.downArrow,
  },
  {
    "heading": "What are the community guidelines?",
    "message":
        "Our community guidelines help keep the platform safe and respectful for everyone.",
    "image": AppImage.downArrow,
  },
  {
    "heading": "How can I reset my password?",
    "message":
        "Go to login screen, tap on 'Forgot Password', enter your registered email and follow instructions.",
    "image": AppImage.downArrow,
  },
];

class _SupportScreenState extends State<SupportScreen> {
  List<bool> expanded = [];

  @override
  void initState() {
    super.initState();
    expanded = List.generate(faqList.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
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
                  text: AppLanguage.supportText[language],
                ),
                SizedBox(height: size.height * 2 / 100),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Text(
                    AppLanguage.frequenctlyAskedquestions[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor,
                    ),
                  ),
                ),

                Column(
                  children: faqList.asMap().entries.map((entry) {
                    int index = entry.key;
                    var item = entry.value;

                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: size.width * 4 / 100,
                        vertical: size.height * 0.8 / 100,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 4 / 100,
                        vertical: size.height * 1.8 / 100,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.notificationContainerColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withOpacity(0.6),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expanded[index] = !expanded[index];
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item["heading"],
                                    style: const TextStyle(
                                      color: AppColor.secondryColor,
                                      fontSize: 14,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: expanded[index] ? 0 : 3.14,
                                  child: Image.asset(
                                    item["image"],
                                    height: size.width * 5 / 100,
                                    width: size.width * 5 / 100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (expanded[index]) ...[
                            SizedBox(height: size.height * 1 / 100),
                            Text(
                              item["message"],
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                color: AppColor.notificationtextColor,
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.contactSupportText[language],
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
                        type: PageTransitionType.topToBottom,
                        child: ChatSupport(),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * 8 / 100,
                              width: size.width * 12 / 100,
                              child: Image.asset(
                                AppImage.messageChatsicon,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: size.width * 2 / 100),
                            Text(
                              AppLanguage.chatWithus[language],
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    documenttypebottomsheet(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * 8 / 100,
                          width: size.width * 12 / 100,
                          child: Image.asset(
                            AppImage.headphoneIcon,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: size.width * 2 / 100),
                        Text(
                          AppLanguage.liveSupport[language],
                          style: const TextStyle(
                            color: AppColor.secondryColor,
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// --- Privacy Policy Heading Added Below ---

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.reportAproblemText[language],
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
                        type: PageTransitionType.rightToLeft,
                        child: ReportProblemScreen(),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * 8 / 100,
                              width: size.width * 12 / 100,
                              child: Image.asset(
                                AppImage.flagIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: size.width * 2 / 100),
                            Text(
                              AppLanguage.reportAproblemText[language],
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.legalText[language],
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
                      MaterialPageRoute(
                        builder: (_) => ContentScreen(
                          contenttype: "termscondition",
                          header: AppLanguage.termsConditionText[language],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * 8 / 100,
                              width: size.width * 12 / 100,
                              child: Image.asset(
                                AppImage.termsConditionIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: size.width * 2 / 100),
                            Text(
                              AppLanguage.termsConditionText[language],
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * .2 / 100),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentScreen(
                          contenttype: "privacypolicy",
                          header: AppLanguage.privacypoliciesText[language],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * 8 / 100,
                          width: size.width * 12 / 100,
                          child: Image.asset(
                            AppImage.privacyPolicyIcon,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: size.width * 2 / 100),
                        Text(
                          AppLanguage.privacyPolicy[language],
                          style: const TextStyle(
                            color: AppColor.secondryColor,
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
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

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 95 / 100,
            height: MediaQuery.of(context).size.height * 40 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 95 / 100,
                  height: MediaQuery.of(context).size.height * 40 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          width: size.width * 1.0,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Container(
                                width: size.width * 0.88,
                                child: Column(
                                  children: [
                                    // First Image

                                    Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        AppImage.dashIcon,
                                        height: size.height * 0.5 / 100,
                                        width: size.width * 22 / 100,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 4 / 100),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .contactSupportText[language],
                                        style: const TextStyle(
                                          color: AppColor.secondryColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 1 / 100),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .contactSupportHintText[language],
                                        style: const TextStyle(
                                          color: AppColor.secondryColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.04),

                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 4 / 100,
                                          vertical: size.height * 1.6 / 100,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              AppImage.email,
                                              height: size.width * 5 / 100,
                                              width: size.width * 6 / 100,
                                              fit: BoxFit.contain,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                                width: size.width * 3 / 100),
                                            Text(
                                              "Mail Id: hii.app@support",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: AppFont.fontFamily,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: size.height * 0.03),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                85 /
                                                100,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                6.5 /
                                                100,
                                        decoration: const BoxDecoration(
                                          color: AppColor.buttonColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40)),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          AppLanguage
                                              .contactSupportText[language],
                                          style: const TextStyle(
                                              color: AppColor.secondryColor,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
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
          );
        });
      },
    ).then((_) {});
  }
}
