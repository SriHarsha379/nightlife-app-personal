import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../content_screen/content_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

List<Map<String, dynamic>> imageList = [
  {
    "heading": "How do I create an account?",
    "message":
        "To create an account, download the app, tap 'Sign Up', and follow the prompts. You'll need to provide your email, create a password, and agree to our terms.",
    "image": AppImage.downArrow,
  },
];
List<Map<String, dynamic>> itemList = [
  {
    "heading": "What are the community guidelines?",
    "image": AppImage.downArrow,
  },
];

List<Map<String, dynamic>> listitem = [
  {
    "heading": "How do I create an account?",
    "image": AppImage.downArrow,
  },
];

class _SupportScreenState extends State<SupportScreen> {
  List<bool> expanded = [];
  @override
  void initState() {
    super.initState(); // NOW valid
    expanded = List.generate(imageList.length, (index) => false);
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
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
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: imageList.asMap().entries.map((entry) {
                      int index = entry.key;
                      var item = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expanded[index] = !expanded[index];
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    width: size.width * 5 / 100,
                                    height: size.width * 5 / 100,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (expanded[index]) ...[
                            SizedBox(height: 10),
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
                            SizedBox(height: 10),
                          ],
                        ],
                      );
                    }).toList(),
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor,
                    borderRadius: BorderRadius.circular(12),
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
                    children: itemList.map((items) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  items["heading"],
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    color: AppColor.secondryColor,
                                    fontSize: 14,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.width * 5 / 100,
                                width: size.width * 5 / 100,
                                child: Image.asset(
                                  items["image"],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor,
                    borderRadius: BorderRadius.circular(12),
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
                    children: listitem.map((list) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  list["heading"],
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    color: AppColor.secondryColor,
                                    fontSize: 14,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.width * 5 / 100,
                                width: size.width * 5 / 100,
                                child: Image.asset(
                                  list["image"],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ),
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
                Container(
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
                Container(
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
                Container(
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
}
