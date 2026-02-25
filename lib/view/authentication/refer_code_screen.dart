import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/profile_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../provider/darkmode_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_validation.dart';

class UseReferCodeScreen extends StatefulWidget {
  static String routeName = "./UseReferCodeScreen";

  const UseReferCodeScreen({super.key});

  @override
  State<UseReferCodeScreen> createState() => _UseReferCodeScreenState();
}

class _UseReferCodeScreenState extends State<UseReferCodeScreen> {
  TextEditingController referCodeController = TextEditingController();

  void referCodeValidation() {
    if (Validation.isFieldEmpty(context,
        value: referCodeController.text, fieldName: "Refer Code")) return;
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: ProfileDetailsScreen(
          screen: "refer",
          refercode: referCodeController.text.toUpperCase(),
        ),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
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
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 2 / 100),
                      Text(
                        "Use Refer Code",
                        style: TextStyle(
                            color: AppColor.secondryColor(context),
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
                    color: AppColor.secondryColor(context),
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),

                SizedBox(height: size.height * 4 / 100),

                // Icon Card
                Container(
                  width: size.width * 88 / 100,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔹 LEFT SIDE (ICONS + LINE)
                      SizedBox(
                        width: size.width * 12 / 100,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Positioned(
                              top: size.width * 5 / 100,
                              child: Image.asset(
                                AppImage.Line,
                                color: Colors.white,
                                width: size.width * 12 / 100,
                                height: size.width * 12 / 100,
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  width: size.width * 12 / 100,
                                  height: size.width * 12 / 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.secondryColor(context),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      AppImage.inviteIcon,
                                      width: size.width * 7 / 100,
                                      height: size.width * 7 / 100,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 3 / 100),
                                Container(
                                  width: size.width * 12 / 100,
                                  height: size.width * 12 / 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColor.secondryColor(context),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      AppImage.giftnewIcon,
                                      width: size.width * 7 / 100,
                                      height: size.width * 7 / 100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: size.width * 4 / 100),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enter the invite code shared to you\nby your friend.",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.3,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                            SizedBox(height: size.height * 4.5 / 100),
                            Text(
                              "Complete the Signup process and\nboth will receive a discount coupon\non your mail.",
                              style: TextStyle(
                                fontSize: 13.6,
                                height: 1.3,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 5 / 100),

                Container(
                  width: size.width * 88 / 100,
                  decoration: BoxDecoration(
                    color: AppColor.refercontainercolor(context),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextFormField(
                    controller: referCodeController,
                    maxLength: 8,
                    cursorColor: AppColor.secondryColor(context),
                    style: TextStyle(
                      color: AppColor.secondryColor(context),
                      fontFamily: AppFont.fontFamily,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter your code here",
                      counterText: "",
                      hintStyle: TextStyle(
                        color: AppColor.hinttextcolor(context),
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),

                      // ✅ DEFAULT BORDER KE SAATH RADIUS
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: AppColor.buttonColor),
                      ),
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

                SizedBox(height: size.height * 30 / 100),

                // Verify Button
                GestureDetector(
                  onTap: () {
                    referCodeValidation();
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
                          color: AppColor.secondryColor(context),
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
