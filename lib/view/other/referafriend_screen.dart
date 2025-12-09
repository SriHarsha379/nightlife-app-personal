import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/profile_details.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class ReferAFriend extends StatefulWidget {
  static String routeName = "./ReferAFriendScreen";

  const ReferAFriend({super.key});

  @override
  State<ReferAFriend> createState() => _ReferAFriendState();
}

class _ReferAFriendState extends State<ReferAFriend> {
  TextEditingController referCodeController = TextEditingController();
  bool isCodeGenerated = false;
  String referralCode = "03AERET78"; // demo code

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          color: AppColor.primaryColor,
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 5 / 100),
                SizedBox(
                  width: size.width * 90 / 100,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            AppImage.backarrow,
                            width: MediaQuery.of(context).size.width * 5 / 100,
                            height:
                                MediaQuery.of(context).size.height * 5 / 100,
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 2 / 100),
                      Text(
                        "Refer a Friend",
                        style: TextStyle(
                            color: AppColor.secondryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontFamily),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 5 / 100),

                Text(
                  "Enter a Refer Code shared by your friend to get\nexclusive gifts!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColor.secondryColor,
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),

                SizedBox(height: size.height * 4 / 100),

                // Icon Card
                Container(
                  width: size.width * 88 / 100,
                  height: size.height * 20 / 100,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 12 / 100,
                            height:
                                MediaQuery.of(context).size.width * 12 / 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.secondryColor,
                            ),
                            child: Center(
                              child: Image.asset(
                                AppImage.inviteIcon,
                                width:
                                    MediaQuery.of(context).size.width * 7 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 7 / 100,
                              ),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "Enter the invite code shared to you\nby your friend.",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.3,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 12 / 100,
                            height:
                                MediaQuery.of(context).size.width * 12 / 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.secondryColor,
                            ),
                            child: Center(
                              child: Image.asset(
                                AppImage.giftnewIcon,
                                width:
                                    MediaQuery.of(context).size.width * 7 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 7 / 100,
                              ),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              "Complete the Signup process and\nboth will receive a discount coupon\non your mail.",
                              style: TextStyle(
                                fontSize: 14,
                                // height: 1.3,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 5 / 100),

                SizedBox(height: size.height * 4 / 100),

                if (isCodeGenerated)
                  Container(
                    width: size.width * 80 / 100,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColor.secondryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  "Your referral code",
                                  style: TextStyle(
                                      color: AppColor.buttonColor,
                                      fontSize: 17.30,
                                      fontWeight: FontWeight.w400),
                                ),
                                SizedBox(width: size.width * 15 / 100),
                                Text("Copy",
                                    style: TextStyle(
                                        color: AppColor.buttonColor,
                                        fontSize: 17.30,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  referralCode,
                                  style: TextStyle(
                                    color: AppColor.primaryColor,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: size.width * 18 / 100),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: referralCode));
                                  },
                                  child: Text("Code",
                                      style: TextStyle(
                                          color: AppColor.buttonColor,
                                          fontSize: 17.30,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.copy,
                            color: AppColor.primaryColor, size: 25),
                      ],
                    ),
                  ),

                isCodeGenerated
                    ? SizedBox(height: size.height * 25 / 100)
                    : SizedBox(height: size.height * 1 / 100),

                    isCodeGenerated?
                GestureDetector(
                  onTap: () {
                    if (!isCodeGenerated) {
                      setState(() {
                        isCodeGenerated = true;
                      });
                    } else {
                      // invite action
                    }
                  },
                  
                  child: Container(
                    width: size.width * 88 / 100,
                    height: size.height * 6 / 100,
                    decoration: BoxDecoration(
                      color: AppColor.buttonColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        isCodeGenerated ? "Invite a Friend" : "Generate Code",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: AppColor.secondryColor,
                        ),
                      ),
                    ),
                  ),
                )
:
             GestureDetector(
                  onTap: () {
                    if (!isCodeGenerated) {
                      setState(() {
                        isCodeGenerated = true;
                      });
                    } else {
                      // invite action
                    }
                  },
                  
                  child: Container(
                    width: size.width * 50 / 100,
                    height: size.height * 6 / 100,
                    decoration: BoxDecoration(
                      color: AppColor.buttonColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        isCodeGenerated ? "Invite a Friend" : "Generate Code",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: AppColor.secondryColor,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 4 / 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
