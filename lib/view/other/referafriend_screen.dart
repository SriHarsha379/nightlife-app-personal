import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../provider/content_service.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';

class ReferAFriend extends StatefulWidget {
  static String routeName = "./ReferAFriendScreen";
  const ReferAFriend({super.key});

  @override
  State<ReferAFriend> createState() => _ReferAFriendState();
}

class _ReferAFriendState extends State<ReferAFriend> {
  String referralCode = "";
  String shareAppUrl = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShareAppUrl();
    });
  }

  Future<void> _loadShareAppUrl() async {
    fetchAllContent((List data) {
      String url = "";
      for (final item in data) {
        if (AppConstant.deviceType == 'ios' && item['content_type'] == 3) {
          url = (item['content'] ?? item['content_url'] ?? '').toString();
          break;
        }
        if (AppConstant.deviceType == 'android' && item['content_type'] == 4) {
          url = (item['content'] ?? item['content_url'] ?? '').toString();
          break;
        }
      }
      if (!mounted) return;
      setState(() {
        shareAppUrl = url.trim();
      });
    });
  }

  String _buildShareMessage() {
    final code = referralCode.isEmpty ? "Hii" : referralCode;
    final appUrl = shareAppUrl.isEmpty ? "" : "\nDownload app: $shareAppUrl";
    return "Hey! Join me on Hii app.\n"
        "Use my referral code: $code\n"
        "You and I both can get exclusive rewards.$appUrl";
  }

  Future<void> _copyReferralCode() async {
    final code = referralCode.isEmpty ? "" : referralCode;
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Referral code copied")),
    );
  }

  Future<void> _shareReferral() async {
    final message = _buildShareMessage();
    await Share.share(message);
  }

  void _openShareBottomSheet() {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppColor.backgroundGradientcolor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            size.width * 0.06,
            size.height * 0.02,
            size.width * 0.06,
            size.height * 0.035,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  AppImage.dashIcon,
                  width: size.width * 0.14,
                  height: size.height * 0.008,
                ),
              ),
              SizedBox(height: size.height * 0.025),
              Text(
                "Invite a Friend",
                style: TextStyle(
                  color: AppColor.secondryColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFont.fontFamily,
                ),
              ),
              SizedBox(height: size.height * 0.008),
              Text(
                "Share your referral code and invite friends to join Hii.",
                style: TextStyle(
                  color: AppColor.notificationtextColor(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFont.fontFamily,
                ),
              ),
              SizedBox(height: size.height * 0.025),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _shareReferral();
                },
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.065,
                  decoration: BoxDecoration(
                    color: AppColor.buttonColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Share Invite",
                    style: TextStyle(
                      color: AppColor.secondryColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFont.fontFamily,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.012),
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _copyReferralCode();
                },
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.06,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: AppColor.textfieldfillColor),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Copy Code",
                    style: TextStyle(
                      color: AppColor.secondryColor(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFont.fontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userController = Provider.of<UserController>(context);
    referralCode = userController.getDisplayReferralCode;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 6 / 100),
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
                        color: AppColor.secondryColor(context),
                      ),
                    ),
                    SizedBox(width: size.width * 2 / 100),
                    Text(
                      "Refer a Friend",
                      style: TextStyle(
                        color: AppColor.secondryColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFont.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 2.5 / 100),
              Center(
                child: Text(
                  "Refer a Friend and Get Exclusive Discount Vouchers\neach on in app purchases!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.secondryColor(context),
                    fontSize: 12,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: size.height * 3 / 100),
              Container(
                width: size.width * 0.88,
                padding: EdgeInsets.all(size.width * 3 / 100),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color.fromARGB(255, 36, 29, 36)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _circleIcon(size, AppImage.inviteIcon),
                        SizedBox(width: size.width * 3 / 100),
                        Expanded(
                          child: Text(
                            "Invite your friend to install the app\nvia link or ask to add code during\nsignup",
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontSize: 14,
                              height: 1,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 1 / 100),
                    Row(
                      children: [
                        SizedBox(
                          width: size.width * 0.14,
                          child: Center(
                            child: Column(
                              children: List.generate(
                                3,
                                (index) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 1),
                                  width: 2,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _circleIcon(size, AppImage.giftnewIcon),
                        SizedBox(width: size.width * 3 / 100),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.2,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor(context),
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
              Container(
                width: size.width * 0.85,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 5 / 100,
                  vertical: size.height * 3.5 / 100,
                ),
                decoration: BoxDecoration(
                  color: AppColor.secondryColor(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your referral code",
                            style: TextStyle(
                              color: AppColor.buttonColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: size.height * 0.3 / 100),
                          Text(
                            referralCode.isEmpty ? "" : referralCode,
                            style: TextStyle(
                              color: AppColor.primaryColor(context),
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
                       color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    SizedBox(width: size.width * 3 / 100),
                    GestureDetector(
                      onTap: _copyReferralCode,
                      child: Column(
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
                    ),
                    SizedBox(width: size.width * 2 / 100),
                    GestureDetector(
                      onTap: _copyReferralCode,
                      child: Icon(
                        Icons.copy,
                        color: AppColor.primaryColor(context),
                        size: size.width * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 32 / 100),
              GestureDetector(
                onTap: _openShareBottomSheet,
                child: Container(
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
                      color: Colors.white,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFont.fontFamily,
                    ),
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

  Widget _circleIcon(Size size, String icon) {
    return Container(
      width: size.width * 14 / 100,
      height: size.width * 14 / 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.secondryColor(context),
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
