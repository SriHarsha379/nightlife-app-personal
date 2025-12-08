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

class UseReferCodeScreen extends StatefulWidget {
  static String routeName = "./UseReferCodeScreen";

  const UseReferCodeScreen({super.key});

  @override
  State<UseReferCodeScreen> createState() => _UseReferCodeScreenState();
}

class _UseReferCodeScreenState extends State<UseReferCodeScreen> {
  TextEditingController referCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //     systemNavigationBarColor: AppColor.primaryColor,
    //     systemNavigationBarIconBrightness: Brightness.light,
    //     statusBarColor: AppColor.transparentColor,
    //     statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;

    return  AnnotatedRegion<SystemUiOverlayStyle>(
      value:  SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration:
              BoxDecoration(gradient: AppColor.backgroundGradientcolor1),
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
                        "Use Refer Code",
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
                  height: size.height *20/100,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                                 width: MediaQuery.of(context).size.width *12/100,
                            height: MediaQuery.of(context).size.width *12/100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.secondryColor,
                            ),
                            child: Center(
                              child: Image.asset(
                                AppImage.inviteIcon,
                  width: MediaQuery.of(context).size.width *7/100,
                            height: MediaQuery.of(context).size.width *7/100,
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
                            width: MediaQuery.of(context).size.width *12/100,
                            height: MediaQuery.of(context).size.width *12/100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.secondryColor,
                            ),
                            child: Center(
                              child: Image.asset(
                                AppImage.giftnewIcon,
                                 width: MediaQuery.of(context).size.width *7/100,
                            height: MediaQuery.of(context).size.width *7/100,
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
              
              
                Container(
                  
                  color: AppColor.refercontainercolor,
                  width: size.width * 88 / 100,
                  child: TextFormField(
                    
                    controller: referCodeController,
                    cursorColor: AppColor.secondryColor,
                    style: TextStyle(
                        color: AppColor.secondryColor,
                        fontFamily: AppFont.fontFamily),
                    decoration: InputDecoration(
                      hintText: "Enter your code here",
                      hintStyle: TextStyle(
                        color: AppColor.hinttextcolor,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(color: AppColor.buttonColor)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColor.buttonColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColor.buttonColor),
                      ),
                    ),
                  ),
                ),
              
                SizedBox(height: size.height * 34 / 100),
              
                // Verify Button
                GestureDetector(
                  onTap: () {
              Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: ProfileDetailsScreen(),
                            duration: const Duration(milliseconds: 600),
                          ),);
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
                        "Verify",
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
