import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/app_preference_screen.dart';
import 'package:night_life/view/authentication/delete_account_screen.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/authentication/notifications_setting_screen.dart';
import 'package:night_life/view/authentication/privacy_and_security.dart';
import 'package:night_life/view/authentication/support_screen.dart';
import 'package:night_life/controller/my_profile/profile_indicator_controller.dart';
import 'package:night_life/view/other/about/aboutscreen.dart';
import 'package:night_life/view/other/referafriend_screen.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import '../../animation/purple_screen.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_comman_setting.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_loader.dart';
import 'edit_profile_screen.dart';

class Profile extends StatefulWidget {
  static String routeName = './Profile';
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<MyProfleCompltetionController>()
          .fetchMyProfleCompltetion(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggingOut = context.watch<PostApiProvider>().secondaryLoading;
    final userController = context.watch<UserController>();
    final profileCompletionController =
        context.watch<MyProfleCompltetionController>();
    final profileCompletionPercent =
        profileCompletionController.profileCompletionPercentage;
    final profileCompletionValue =
        (profileCompletionPercent.clamp(0, 100) / 100.0);
    final profileImageSize = MediaQuery.of(context).size.width * 33 / 100;
    final completionTasks = profileCompletionController.completionMessages;
    final fallbackTasks = [
      // AppLanguage.addthreeMoreTExt[language],
      // AppLanguage.completeBio[language],
      // AppLanguage.connectInstagramtext[language],
      // AppLanguage.addHobbyText[language],
    ];
    final tasksToShow =
        completionTasks.isNotEmpty ? completionTasks : fallbackTasks;
    final completionText = profileCompletionController.hasLoadedOnce
        ? '$profileCompletionPercent% complete'
        : AppLanguage.seventySevencompleteText[language];
    final fullName = userController.getUserName.trim().isNotEmpty
        ? userController.getUserName
        : "User";
    final profileImage = userController.getUserImage.trim();
    final hasNetworkImage = profileImage.isNotEmpty;
    final profileImageUrl = hasNetworkImage
        ? (profileImage.startsWith('http')
            ? profileImage
            : '${AppConfigProvider.imageUrl}$profileImage')
        : '';
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: ProgressHUD(
        isLoading: isLoggingOut,
        loadingText: "Logging out...",
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColor.backgroundGradientcolor(context),
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 3.5 / 100),
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.accountText[language],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Image
                            // Profile Image with animated gradient indicator
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: const EditProfile(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.only(top: 15, left: 5),
                                    width: profileImageSize + 8,
                                    height: profileImageSize + 12,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Animated Gradient Circular Progress Indicator
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: 0,
                                              end: profileCompletionValue),
                                          duration: const Duration(
                                              milliseconds: 1500),
                                          curve: Curves.easeInOutCubic,
                                          builder: (context, value, child) {
                                            return SizedBox(
                                              width: profileImageSize + 10,
                                              height: profileImageSize + 10,
                                              child: CustomPaint(
                                                painter:
                                                    GradientCircularProgressPainter(
                                                  progress: value,
                                                  strokeWidth: 8,
                                                  gradientColors: const [
                                                    Color.fromARGB(255, 236, 58,
                                                        97), // Light pink
                                                    Color.fromARGB(255, 91, 32,
                                                        187), // Purple
                                                    Color.fromARGB(255, 212,
                                                        121, 85), // Orange
                                                    Color.fromARGB(
                                                        255, 201, 59, 106),
                                                  ],
                                                  backgroundColor: Colors.white
                                                      .withOpacity(0.18),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Profile Image
                                        SizedBox(
                                          width: profileImageSize,
                                          height: profileImageSize,
                                          child: ClipOval(
                                            child: hasNetworkImage
                                                ? Image.network(
                                                    profileImageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Image.asset(
                                                        AppImage.userprofile,
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.asset(
                                                    AppImage.placeHolder2Icon,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    5 /
                                    100),

                            // Profile Text
                            Expanded(
                              child: Container(
                                // color: AppColor.blueTextColor,
                                // width: MediaQuery.of(context).size.width * 0.80,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                        height: profileCompletionPercent == 100
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                7 /
                                                100
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1 /
                                                100),
                                    Text(
                                      fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppFont.fontFamily,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                100),
                                    ...List.generate(tasksToShow.length,
                                        (index) {
                                      const colors = [
                                        Colors.pinkAccent,
                                        Colors.orangeAccent,
                                        Colors.purpleAccent,
                                        Colors.redAccent,
                                      ];
                                      return buildTaskRow(
                                        tasksToShow[index],
                                        colors[index % colors.length],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.84,
                        child: Row(
                          children: [
                            Text(
                              AppLanguage.profileCompleteText[language],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.5 /
                                    100),
                            Text(
                              completionText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100),

                      // Settings List
                      Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.settingsText[language],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingprofile,
                            title: AppLanguage.accountSetting[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const EditProfile(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingsecurity,
                            title: AppLanguage.privacyPolicyText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const PrivacySecurityScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingNotification,
                            title: AppLanguage.notificationText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const NotificationSettingScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingApppreference,
                            title: AppLanguage.appPreferences[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const AppPreferences(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.referIcon,
                            title: AppLanguage.referaFriText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const ReferAFriend(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingSupport,
                            title: AppLanguage.supportText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const SupportScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blacksettingAbout,
                            title: AppLanguage.aboutText[language],
                            onPress: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: const AboutScreen(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          SettingRow(
                            leadingIcon: AppImage.blackdeleteIcon,
                            title: AppLanguage.deleteAccounttext[language],
                            onPress: () {
                              _showDeleteConfirmBottomSheet(context);
                            },
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 100),
                          GestureDetector(
                            onTap: () async {
                              final apiProvider = Provider.of<PostApiProvider>(
                                context,
                                listen: false,
                              );
                              await apiProvider.logOutApiCalling(context);
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                  type: PageTransitionType.bottomToTop,
                                  child: const PurpleScreen(
                                    nextScreen: LoginScreen(),
                                  ),
                                  duration: const Duration(milliseconds: 400),
                                ),
                                (route) => false,
                              );
                            },
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 18),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(36),
                                color: AppColor.logoutContainerColor(context),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // ✅ center horizontally
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // ✅ center vertically
                                children: [
                                  Image.asset(
                                    AppImage.logoutIcon,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        1 /
                                        100,
                                  ),
                                  Text(
                                    AppLanguage.logoutText[language],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColor.secondryColor(context),
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTaskRow(String text, Color color) {
    return Row(
      children: [
        Icon(Icons.fiber_manual_record, size: 14, color: color),
        SizedBox(width: MediaQuery.of(context).size.width * 2 / 100),
        SizedBox(height: MediaQuery.of(context).size.height * 3 / 100),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFont.fontFamily,
              color: AppColor.secondryColor(context),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ActionBottomSheet(
          heading: "Are you sure?",
          subheading:
              "After deleting the account, the same mobile number cannot be used to log in. This action cannot be undone.",
          otherButton: "Cancel",
          mainButton: "Delete",
          onTapOtherButton: () {
            Navigator.pop(context);
          },
          onTapMainButton: () {
            Navigator.pop(context);
            Navigator.push(
              this.context,
              PageTransition(
                type: PageTransitionType.rightToLeftWithFade,
                child: const DeleteAccountScreen(),
                duration: const Duration(milliseconds: 500),
              ),
            );
          },
        );
      },
    );
  }
}

class ActionBottomSheet extends StatelessWidget {
  final String heading;
  final String subheading;
  final String otherButton;
  final String mainButton;
  final Function() onTapMainButton;
  final Function() onTapOtherButton;

  const ActionBottomSheet({
    super.key,
    required this.heading,
    required this.subheading,
    required this.otherButton,
    required this.mainButton,
    required this.onTapMainButton,
    required this.onTapOtherButton,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height * 28.5 / 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        color: AppColor.notificationContainerColor(context),
      ),
      child: Column(
        children: [
          SizedBox(height: size.height * 2.8 / 100),
          Text(
            heading,
            style: TextStyle(
              fontFamily: AppFont.fontFamily,
              fontSize: 21,
              fontWeight: FontWeight.w600,
              color: AppColor.secondryColor(context),
            ),
          ),
          SizedBox(height: size.height * 1 / 100),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 8 / 100),
            child: Text(
              subheading,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFont.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColor.notificationtextColor(context),
              ),
            ),
          ),
          SizedBox(height: size.height * 4 / 100),
          Row(
            children: [
              const Spacer(),
              _ActionSheetButton(
                text: otherButton,
                onTap: onTapOtherButton,
                width: size.width * 38 / 100,
                backgroundColor: Colors.transparent,
                borderColor: AppColor.textfieldfillColor,
                textColor: AppColor.secondryColor(context),
              ),
              SizedBox(width: size.width * 4 / 100),
              _ActionSheetButton(
                text: mainButton,
                onTap: onTapMainButton,
                width: size.width * 38 / 100,
                backgroundColor: AppColor.buttonColor,
                borderColor: AppColor.buttonColor,
                textColor: Colors.white,
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionSheetButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double width;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const _ActionSheetButton({
    required this.text,
    required this.onTap,
    required this.width,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: MediaQuery.of(context).size.height * 6.4 / 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          border: Border.all(color: borderColor, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontFamily: AppFont.fontFamily,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    if (progress > 0) {
      final gradient = SweepGradient(
        startAngle: -90 * (3.14159 / 180),
        endAngle: -90 * (3.14159 / 180) + (2 * 3.14159 * progress),
        colors: gradientColors,
        tileMode: TileMode.repeated,
      );

      final gradientPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        90 * (3.14159 / 180),
        2 * 3.14159 * progress,
        false,
        gradientPaint,
      );

      if (progress < 1.0) {
        final shimmerPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.white.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: const [0.0, 0.3],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        // Draw a small white arc at the progress edge for shimmer effect
        final shimmerStartAngle =
            -90 * (3.14159 / 180) + (2 * 3.14159 * progress) - 0.1;
        final shimmerSweepAngle = 0.2;

        canvas.drawArc(
          rect,
          shimmerStartAngle,
          shimmerSweepAngle,
          false,
          shimmerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GradientCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
