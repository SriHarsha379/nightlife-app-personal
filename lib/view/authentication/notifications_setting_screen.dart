import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:night_life/utils/app_color.dart';
// import 'package:night_life/utils/app_font.dart';
// import 'package:night_life/utils/app_image.dart';
// import 'package:night_life/utils/app_language.dart';
// import 'package:night_life/widgets/app_header1.dart';

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
      "image": AppImage.eventRemaindericon,
      "notification": "Event Reminders",
      "message": "Get notified about upcoming events you're interested in.",
    },
    {
      "image": AppImage.friendsInviteIcon,
      "notification": "Friend Invites",
      "message": "Receive notifications when friends invite you to events.",
    },
    {
      "image": AppImage.messageChatsicon,
      "notification": "Messages & Chats",
      "message": "Get notified about new messages and chats. ",
    },
    {
      "image": AppImage.updatesIcon,
      "notification": "Club/Organizer Updates",
      "message": "Stay informed about updates from clubs and organizers.",
    },
    {
      "image": AppImage.giftIcon,
      "notification": "Promotions & Offers",
      "message": "Receive notifications about special offers and promotions.",
  
    },
  ];
  List<bool> switches = [false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.secondryColor,
      body: SafeArea(
        child: Container(
          width: size.width,
          color: AppColor.primaryColor,
          child: Column(
            children: [
              SizedBox(height: size.height * 2 / 100),
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.notificationText[language],
              ),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 1 / 100),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (BuildContext context, int index) {
                          List<Widget> widgets = [];

                          widgets.add(
                              notificationCard(context, notifications[index] ,index));

                          //  Add headings conditionally
                          if (index == 0) {
                            widgets.add(sectionHeading("Social"));
                          } else if (index == 2) {
                            widgets.add(sectionHeading("Updates"));
                          } else if (index == 3) {
                            widgets.add(sectionHeading("Promotion"));
                          }

                          return Column(children: widgets);
                        },
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
            color: AppColor.secondryColor,
          ),
        ),
      ),
    );
  }

  Widget notificationCard(
      BuildContext context, Map<String, dynamic> notification, int index) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: size.width * 15 / 100,
            height: size.width * 15 / 100,
            child: Image.asset(notification["image"], fit: BoxFit.contain),
          ),
          SizedBox(width: size.width * 2 / 100),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notification['notification'],
                        style: const TextStyle(
                            color: AppColor.secondryColor,
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w600)),
                     Transform.scale(
                      scale: 0.80,
                      child: CupertinoSwitch(
                        value: switches[index],
                        onChanged: (value) {
                          setState(() {
                            switches[index] = value;
                          });
                        },
                        activeColor: AppColor.pinkColor,
                        thumbColor: Colors.white,
                        trackColor: AppColor.toggleColor,
                      ),
                    ),
                  ],
                ),
                Text(notification['message'],
                    style: const TextStyle(
                        color: AppColor.notificationtextColor,
                        fontSize: 14,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
