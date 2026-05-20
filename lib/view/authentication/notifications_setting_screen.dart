import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controller/notification/notification_setting_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  List<dynamic> notifications = <dynamic>[
    {
      "type": "event_reminder_notify",
      "image": AppImage.eventRemaindericon,
      "notification": "Event Reminders",
      "message": "Get notified about upcoming\nevents you're interested in.",
    },
    {
      "type": "friend_invites_notify",
      "image": AppImage.friendsInviteIcon,
      "notification": "Friend Invites",
      "message": "Receive notifications when friends\ninvite you to events.",
    },
    {
      "type": "msg_chats_notify",
      "image": AppImage.messageChatsicon,
      "notification": "Messages & Chats",
      "message": "Get notified about new messages\nand chats. ",
    },
    {
      "type": "club_organizer_notify",
      "image": AppImage.updatesIcon,
      "notification": "Club/Organizer Updates",
      "message": "Stay informed about updates from\nclubs and organizers.",
    },
    {
      "type": "promotion_offers_notify",
      "image": AppImage.giftIcon,
      "notification": "Promotions & Offers",
      "message": "Receive notifications about special\noffers and promotions.",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<NotificationSettingController>()
          .fetchNotificationSettings(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        color: AppColor.primaryColor(context),
        child: Column(
          children: [
            SizedBox(height: size.height * 5 / 100),
            AppHeader(
              onPress: () => Navigator.pop(context),
              text: AppLanguage.notificationText[language],
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 1 / 100),
                    SizedBox(height: size.height * 2 / 100),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 17.0),
                        child: Text(
                          AppLanguage.eventRemaindersText[language],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    Consumer<NotificationSettingController>(
                      builder: (context, controller, _) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            List<Widget> widgets = [];
                            final Map<String, dynamic> item =
                                notifications[index] as Map<String, dynamic>;
                            final String type = item['type']?.toString() ?? '';
                            final bool switchValue =
                                controller.settings[type] ?? false;
                            final bool isUpdating =
                                controller.isUpdatingType(type);

                            widgets.add(
                              notificationCard(
                                context,
                                item,
                                switchValue,
                                isUpdating,
                                (value) async {
                                  await context
                                      .read<NotificationSettingController>()
                                      .updateNotificationSetting(
                                        context,
                                        type: type,
                                        value: value,
                                      );
                                },
                              ),
                            );

                            if (index == 0) {
                              widgets.add(sectionHeading("Social"));
                            } else if (index == 2) {
                              widgets.add(sectionHeading("Updates"));
                            } else if (index == 3) {
                              widgets.add(sectionHeading("Promotions"));
                            }

                            return Column(children: widgets);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionHeading(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: AppFont.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColor.secondryColor(context),
          ),
        ),
      ),
    );
  }

  Widget notificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
    bool switchValue,
    bool isUpdating,
    ValueChanged<bool> onChanged,
  ) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width * 100 / 100,
      height: size.height * 10 / 100,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: size.width * 3.8 / 100,
          ),
          Image.asset(
            notification["image"],
            width: size.width * 11 / 100,
            height: size.width * 11 / 100,
            fit: BoxFit.contain,
          ),
          SizedBox(width: size.width * 4 / 100),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['notification'],
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                      ),
                      style: TextStyle(
                        color: AppColor.secondryColor(context),
                        fontSize: 16,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.8 / 100,
                    ),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        color: AppColor.notificationtextColor(context),
                        fontSize: 15.6,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Transform.scale(
              scale: 0.90,
              child: CupertinoSwitch(
                value: switchValue,
                onChanged: isUpdating ? null : onChanged,
                activeColor: AppColor.pinkColor,
                thumbColor: Colors.white,
                trackColor: AppColor.toggleColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
