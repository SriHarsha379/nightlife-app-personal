import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class Notifications extends StatefulWidget {
  static String routeName = './Notifications';
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<dynamic> notifications = <dynamic>[
    {
      "image": AppImage.blackCalendericon,
      "notification": "Upcoming Event Reminder",
      "message": "you have an event tomorrow",
      "time": "at 7PM ⏰",
      "lastseen": "2h ago",
      "view": "View Event",
      "type": "event" // <-- FIXED
    },
    {
      "image": AppImage.blackHearticon,
      "notification": "Someone Liked You",
      "message": "Someone right swiped your profile -",
      "time": "Check out who liked you! 👀",
      "view": "See Who",
      "lastseen": "4h ago",
      "type": "chat"
    },
    {
      "image": AppImage.blackMicicon,
      "notification": "New Event Posted",
      "message": "Venues you follow posted an event ",
      "time": "– Explore now ✨",
      "view": "Explore",
      "lastseen": "1d ago",
      "type": "event"
    },
    {
      "image": AppImage.blackTicketconfirmedicon,
      "notification": "Ticket Confirmed",
      "message": "your Ticket for jazz Night has been confirmed.",
      "time": "Just Now",
      "view": "View details",
      "lastseen": "1w ago",
      "type": "payment"
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
      backgroundColor: AppColor.primaryColor,

      // ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          color: AppColor.primaryColor,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.notificationText[language],

             
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
              Align(
                alignment:
                    Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Text(
                    AppLanguage.newtext[language], 
                    textAlign: TextAlign
                        .left, 
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColor.secondryColor,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),

                  
                      SizedBox(
                        width: double.infinity,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            // Create the notification container
                            Widget notificationCard = GestureDetector(
                              onTap: () {
                                final item = notifications[index]
                                    as Map<String, dynamic>;
                                final type = item["type"]
                                        ?.toString()
                                        .trim()
                                        .toLowerCase() ??
                                    "event";

                                if (type == "none") {
                                  print("No TYPE present in item: $item");
                                  return;
                                }

                                switch (type) {
                                  case "profile":
                                    break;

                                  case "chat":
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        child: MyAppFooter(initialIndex: 3),
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );

                                    break;

                                  case "event":
                                    Navigator.push(
                                        context,
                                      PageTransition(
                                          type: PageTransitionType.bottomToTop,
                                          child: LikedEventDetail(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),);
                                    break;

                                  case "payment":
                                    break;
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColor.profilesettignrowColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.transparent.withOpacity(0.2),
                                      spreadRadius: 3,
                                      blurRadius: 7,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              15 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              15 /
                                              100,
                                          child: Image.asset(
                                            notifications[index]["image"],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              2 /
                                              100,
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      60 /
                                                      100,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    notifications[index]
                                                        ['notification'],
                                                    style: const TextStyle(
                                                      color: AppColor
                                                          .secondryColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      13 /
                                                      100,
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    notifications[index]
                                                        ['lastseen'],
                                                    style: const TextStyle(
                                                      color: AppColor.textcolor,
                                                      fontSize: 12,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  72 /
                                                  100,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                notifications[index]['message'],
                                                style: const TextStyle(
                                                  color: AppColor.secondryColor,
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                      
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  72 /
                                                  100,
                                              child: Text(
                                                notifications[index]['time'],
                                                style: const TextStyle(
                                                  color: AppColor.secondryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  72 /
                                                  100,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                notifications[index]['view'],
                                                style: const TextStyle(
                                                  color: AppColor.buttonColor,
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (index == 2) {
                              return Column(
                                children: [
                                  notificationCard,
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17.0, vertical: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Earlier",
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.secondryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return notificationCard;
                            }
                          },
                        ),
                      ),

                      SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 12 / 100),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
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
}
