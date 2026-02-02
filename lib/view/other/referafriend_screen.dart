import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';

class ReferAFriend extends StatefulWidget {
  static String routeName = "./ReferAFriendScreen";
  const ReferAFriend({super.key});

  @override
  State<ReferAFriend> createState() => _ReferAFriendState();
}

class _ReferAFriendState extends State<ReferAFriend> {
  final String referralCode = "03AERET78";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 6 / 100),

              /// ---------- HEADER ----------
              SizedBox(
                width: size.width * 0.9,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        AppImage.backarrow,
                        width: size.width * 5 / 100,
                        height: size.width * 5 / 100,
                        color: AppColor.secondryColor,
                      ),
                    ),
                    SizedBox(width: size.width * 2 / 100),
                    Text(
                      "Refer a Friend",
                      style: TextStyle(
                        color: AppColor.secondryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFont.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 2.5 / 100),

              /// ---------- DESCRIPTION ----------
              Center(
                child: Text(
                  "Refer a Friend and Get Exclusive Discount Vouchers\neach on in app purchases!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.secondryColor,
                    fontSize: 12,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: size.height * 3 / 100),

              /// ---------- INFO CARD ----------
              Container(
                width: size.width * 0.88,
                padding: EdgeInsets.all(size.width * 3 / 100),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 36, 29, 36),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    /// First Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _circleIcon(
                          size,
                          AppImage.inviteIcon,
                        ),
                        SizedBox(width: size.width * 3 / 100),
                        Expanded(
                          child: Text(
                            "Invite your friend to install the app\nvia link or ask to add code during\nsignup",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 14,
                              height: 1,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 1 / 100),

                    /// Dotted Line
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.14,
                          child: Center(
                            child: Column(
                              children: List.generate(
                                3,
                                (index) => Container(
                                  margin: EdgeInsets.symmetric(vertical: 1),
                                  width: 2,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // SizedBox(height: size.height * 1 / 100),

                    /// Second Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _circleIcon(
                          size,
                          AppImage.giftnewIcon,
                        ),
                        SizedBox(width: size.width * 3 / 100),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.2,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                              children: const [
                                TextSpan(
                                  text:
                                      "When your friend signup's you will get\n",
                                ),
                                TextSpan(
                                  text: "Exclusive Discount Coupons for each!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 3.5 / 100),

              /// ---------- REFERRAL CODE CARD ----------
              Container(
                width: size.width * 0.85,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 5 / 100,
                  vertical: size.height * 3.5 / 100,
                ),
                decoration: BoxDecoration(
                  color: AppColor.secondryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    /// LEFT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your referral code",
                            style: TextStyle(
                              color: AppColor.buttonColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: size.height * 0.3 / 100),
                          Text(
                            referralCode,
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: size.height * 0.05,
                      width: 1,
                      color: Colors.grey.withOpacity(0.5),
                    ),

                    SizedBox(width: size.width * 3 / 100),

                    /// RIGHT
                    Column(
                      children: [
                        Text(
                          "Copy",
                          style: TextStyle(
                            color: AppColor.buttonColor,
                            fontSize: size.width * 0.038,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Code",
                          style: TextStyle(
                            color: AppColor.buttonColor,
                            fontSize: size.width * 0.038,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: size.width * 2 / 100),

                    Icon(
                      Icons.copy,
                      color: AppColor.primaryColor,
                      size: size.width * 0.06,
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 32 / 100),

              /// ---------- INVITE BUTTON ----------
              Container(
                width: size.width * 0.88,
                height: size.height * 6 / 100,
                decoration: BoxDecoration(
                  color: AppColor.buttonColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Invite a Friend",
                  style: TextStyle(
                    color: AppColor.secondryColor,
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
              ),

              SizedBox(height: size.height * 3 / 100),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------- ICON CIRCLE ----------
  Widget _circleIcon(Size size, String icon) {
    return Container(
      width: size.width * 14 / 100,
      height: size.width * 14 / 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.secondryColor,
      ),
      child: Center(
        child: Image.asset(
          icon,
          width: size.width * 8 / 100,
          height: size.width * 8 / 100,
        ),
      ),
    );
  }
}
