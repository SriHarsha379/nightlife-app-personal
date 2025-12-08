import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails5_screen.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails6_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../../../authentication/notification_screen.dart';
import '../../../authentication/profile.dart';
import '../../chats/chat_message_screen.dart';

class VenuePages extends StatefulWidget {
  static String routeName = './VenuePages';

  const VenuePages({super.key});

  @override
  State<VenuePages> createState() => _VenuePagesState();
}

class _VenuePagesState extends State<VenuePages> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List chats = [
    {
      'id': 1,
      'image': 'assets/icons/ProfilePhoto.png',
      'name': 'Smith Mathew',
      'lastMessage': 'Hi, David. Hope you\'re doing...',
      'time': '09:18',
    },
    {
      'id': 2,
      'image': 'assets/icons/arjunrampalIcon.png',
      'name': 'Merry An.',
      'lastMessage': 'Are you ready for today\'s part..',
      'time': '12:44',
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'John Walton',
      'lastMessage': 'I\'am sending you a parcel rece..',
      'time': '08:06',
    },
    {
      'id': 4,
      'image': 'assets/icons/girlImage.png',
      'name': 'Monica Randawa',
      'lastMessage': 'Hope you\'re doing well today..',
      'time': '09:32',
    },
  ];

  List<dynamic> recent = <dynamic>[
    {
      "image": AppImage.calenderPinkIcon,
      "recent": "Royal Club",
    },
    {
      "image": AppImage.pinkclock,
      "recent": "Arjun Rampal",
    },
    {
      "image": AppImage.locationIcon,
      "recent": "Music Fest",
    },
  ];

  int selectedId = 2;

  List Orders = [
    {'id': 1, 'title': 'Cafe'},
    {'id': 2, 'title': 'Desserts'},
    {'id': 3, 'title': 'Coffee'},
  ];

  List Location = [
    {'id': 1, 'title': 'Delhi NCR'},
    {'id': 2, 'title': 'Mumbai'},
    {'id': 3, 'title': 'Banglore'},
    {'id': 4, 'title': 'Goa'},
    {'id': 5, 'title': 'Chennai'},
    {'id': 6, 'title': 'Kolkata'},
  ];

  List Trending = [
    {
      'id': 1,
      'title': 'Royal Club ',
      "image": AppImage.zigzagArrow,
    },
    {
      'id': 2,
      'title': 'Arjun Rampal',
      "image": AppImage.zigzagArrow,
    },
    {
      'id': 3,
      'title': 'Music Fest',
      "image": AppImage.zigzagArrow,
    },
  ];
  bool isDayDisabled(DateTime day) {
    if (disabledDays.isEmpty) return false;

    String dayName = _getDayName(day);
    return disabledDays.any(
        (disabledDay) => disabledDay.toLowerCase() == dayName.toLowerCase());
  }

  List<List<Map<String, dynamic>>> generateWeeklyCalendar(
      DateTime startDate, int numberOfWeeks) {
    List<List<Map<String, dynamic>>> calendarWeeks = [];

    for (int week = 0; week < numberOfWeeks; week++) {
      List<Map<String, dynamic>> weekDays = [];

      for (int day = 0; day < 7; day++) {
        DateTime currentDate = startDate.add(Duration(days: week * 7 + day));
        weekDays.add({
          'id': currentDate.millisecondsSinceEpoch, // unique id
          'date': currentDate,
          'day': _getWeekdayName(currentDate.weekday), // "Mon", "Tue", etc.
          'title': currentDate.day.toString(), // just the date number
        });
      }

      calendarWeeks.add(weekDays);
    }

    return calendarWeeks;
  }

  String _getWeekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday % 7];
  }

  List<String> disabledDays = [];

  var eventDetailsData = {};
  DateTime selectedDay = DateTime.now();
  String sendDate = DateTime.now().toString();
  // Get day name from DateTime
  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: SafeArea(
          child: Container(
            height: size.height * 100 / 100,
            width: size.width * 100 / 100,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  // SizedBox(height: size.height * 2 / 100),
                  // AppHeader(text: AppLanguage.chatsText[language]),

                  Stack(children: [
                    Container(
                      width: size.width * 100 / 100,
                      height: size.height * 28 / 100,
                      child: ClipRRect(
                        child: Image.asset(
                          AppImage.brewandbloomIcon,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 26,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          AppImage.backarrow,
                          color: AppColor.secondryColor,
                          fit: BoxFit.cover,
                          height: size.width * 5 / 100,
                        ),
                      ),
                    ),
                  ]),

                  SizedBox(height: size.height * 2 / 100),
                  Container(
                    width: size.width * 90 / 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLanguage.Brewbloomcafetext[language],
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.secondryColor),
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: AppColor.pinkColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 3 / 100,
                                            vertical: 1,
                                          ),
                                          child: Text(
                                            AppLanguage.cafe[language],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.secondryColor),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 2 / 100,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: AppColor.pinkColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 2.5 / 100,
                                            vertical: 1,
                                          ),
                                          child: Text(
                                            AppLanguage.desert[language],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.secondryColor),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 2 / 100,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color: AppColor.pinkColor,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 2.5 / 100,
                                            vertical: 1,
                                          ),
                                          child: Text(
                                            AppLanguage.Coffee[language],
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.secondryColor),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: size.width * 12 / 100,
                                    child: Image.asset(
                                      AppImage.likeImage,
                                      fit: BoxFit.cover,
                                      height: size.width * 18 / 100,
                                    ),
                                  ),

                                  // Container(
                                  //   child: Text(
                                  //     AppLanguage.like17Text[language],
                                  //     style: TextStyle(
                                  //       fontSize: 14,
                                  //       fontFamily: AppFont.fontFamily,
                                  //     ),
                                  //   ),
                                  // )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 92 / 100,
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 4.5 / 100,
                          height: size.width * 4.5 / 100,
                          child: ClipRRect(
                            child: Image.asset(
                              AppImage.calenderPinkIcon,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 2 / 100,
                        ),
                        Text(
                          AppLanguage.OpenhourText[language],
                          style: const TextStyle(
                              fontSize: 15,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: AppColor.secondryColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 2 / 100,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 92 / 100,
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 4.5 / 100,
                          height: size.width * 4.5 / 100,
                          child: ClipRRect(
                            child: Image.asset(
                              AppImage.clock,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 2 / 100,
                        ),
                        Text(
                          AppLanguage.time[language],
                          style: const TextStyle(
                              fontSize: 15,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                              color: AppColor.secondryColor),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 2 / 100,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 92 / 100,
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 4.5 / 100,
                          height: size.width * 4.5 / 100,
                          child: ClipRRect(
                            child: Image.asset(
                              AppImage.locationIcon,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 2 / 100,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Text(
                                  AppLanguage.koregaonParkText[language],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.secondryColor),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    AppLanguage.kmawayText[language],
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.greyLightColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 3 / 100,
                  ),
                  SizedBox(
                    width: size.width * 90 / 100,
                    child: Text(
                      AppLanguage.GalleryText[language],
                      style: const TextStyle(
                          fontSize: 18,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          color: AppColor.secondryColor),
                    ),
                  ),

                  SizedBox(
                    height: size.height * 2 / 100,
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 55 / 100,
                          height: size.height * 15 / 100,
                          margin: const EdgeInsets.only(left: 19, right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              AppImage.galleryImg1,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          width: size.width * 55 / 100,
                          height: size.height * 15 / 100,
                          margin: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              AppImage.galleryImg,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: Text(
                      AppLanguage.aboutText[language],
                      style: const TextStyle(
                        color: AppColor.secondryColor,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    child: RichText(
                      text: TextSpan(
                        text: AppLanguage.brewBloomstatement[language]
                            .split('Read More')[0],
                        style: const TextStyle(
                          fontSize: 18,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.normal,
                          color: AppColor.greyLightColor,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Read More...',
                            style: TextStyle(
                                fontSize: 15,
                                color: AppColor.buttonColor,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppFont.fontFamily),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.height * 2 / 100,
                  ),

                  SizedBox(
                    width: size.width * 92 / 100,
                    child: Text(
                      AppLanguage.upcomingEventstext[language],
                      style: const TextStyle(
                          fontSize: 18,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                          color: AppColor.secondryColor),
                    ),
                  ),

                  SizedBox(
                    height: size.height * 2 / 100,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: LikedEventDetail(),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Image.asset(
                            AppImage.aroundmeIcon,
                            height: size.width * 68 / 100,
                            width: size.width * 50 / 100,
                          ),
                          Image.asset(
                            AppImage.aroundmeIcon,
                            height: size.width * 68 / 100,
                            width: size.width * 45 / 100,
                          ),
                          // SizedBox(
                          //     width: MediaQuery.of(context).size.width *
                          //         0.01), // spacing between icon and text
                          Image.asset(
                            AppImage.aroundmeIcon,
                            height: size.width * 68 / 100,
                            width: size.width * 50 / 100,
                          ),
                          Image.asset(
                            AppImage.aroundmeIcon,
                            height: size.width * 68 / 100,
                            width: size.width * 47 / 100,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.height * 3 / 100,
                  ),
                  SizedBox(
                    width: size.width * 88 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            AppLanguage.TicketText[language],
                            style: const TextStyle(
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                color: AppColor.secondryColor),
                          ),
                        ),
                        Container(
                          child: Text(
                            AppLanguage.endinText[language],
                            style: const TextStyle(
                                fontSize: 12,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                color: AppColor.textcolor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: size.height * 2 / 100,
                  ),
                  Container(
                    width: size.width * 90 / 100,
                    height: size.height * 18 / 100,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: AppColor.backgroundColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 4 / 100,
                            vertical:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: size.width * 25 / 100,
                                    child: Text(
                                      AppLanguage.reservationsText[language],
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.secondryColor),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 25 / 100,
                                    child: Text(
                                      AppLanguage
                                          .fourHundredruppeText[language],
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.secondryColor),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BookTable()));
                                },
                                child: Container(
                                  width: size.width * 45 / 100,
                                  decoration: BoxDecoration(
                                      color: AppColor.secondryColor,
                                      borderRadius: BorderRadius.circular(40)),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                3 /
                                                100,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                1.5 /
                                                100,
                                      ),
                                      child: Text(
                                        AppLanguage.BookNowText[language],
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.pinkColor),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 6 / 100,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.secureYourspotText[language],
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.secondryColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 5 / 100,
                  ),
Center(
  child: Container(
    width: 180,  // adjust size as needed
    height: 1,
    color: AppColor.lightgreyColor,
  ),
),   SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor,
                          borderRadius: BorderRadius.circular(50),

                          // border: Border.all(

                          //      color : AppColor.primaryColor,
                          // ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImage.heartImg,
                              height: 20,
                              width: 20,
                              color:
                                  AppColor.secondryColor, // optional tint color
                            ),
                            Text(
                              AppLanguage.likeText[language],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: size.width * 3 / 100,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: AppColor.buttonColor,
                          ),
                        ),
                        child: Text(
                          AppLanguage.sendInviteText[language],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 3 / 100,
                      ),
                      Container(
                        width: size.width * 12 / 100,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.asset(
                              AppImage.crossIcon,
                              fit: BoxFit.cover,
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _openGuestBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: AppColor.themeColor,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
  //     ),
  //     isScrollControlled: true,
  //     builder: (context) {
  //       final size = MediaQuery.of(context).size;
  //       List<int> guestList = List.generate(20, (index) => index + 1);
  //       int selectedGuest = -1;

  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Padding(
  //             padding: EdgeInsets.symmetric(
  //               horizontal: size.width * 6 / 100,
  //               vertical: size.height * 3 / 100,
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 // --- Title ---
  //                 Row(
  //                   children: [
  //                     SizedBox(width: size.width * 3 / 100),
  //                     Align(
  //                       alignment: Alignment.centerLeft,
  //                       child: Text(
  //                         "Select number of Guest",
  //                         style: TextStyle(
  //                           fontFamily: AppFont.fontFamily,
  //                           fontWeight: FontWeight.w700,
  //                           fontSize: 16,
  //                           color: AppColor.secondryColor,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),

  //                 SizedBox(height: size.height * 3 / 100),

  //                 // --- Horizontal Scrollable Chips ---
  //                 SizedBox(
  //                   height: size.height * 7 / 100,
  //                   child: ListView.builder(
  //                     scrollDirection: Axis.horizontal,
  //                     itemCount: guestList.length,
  //                     itemBuilder: (context, index) {
  //                       final isSelected = selectedGuest == index;
  //                       return GestureDetector(
  //                         onTap: () {
  //                           setState(() {
  //                             selectedGuest = index;
  //                           });
  //                         },
  //                         child: Container(
  //                           margin: const EdgeInsets.symmetric(horizontal: 18),
  //                           padding: const EdgeInsets.symmetric(
  //                               vertical: 10, horizontal: 22),
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(10),
  //                             border: Border.all(
  //                               color: isSelected
  //                                   ? AppColor.pinkColor
  //                                   : AppColor.textTapColor,
  //                               width: 1,
  //                             ),
  //                             color: isSelected
  //                                 ? AppColor.pinkColor.withOpacity(0.2)
  //                                 : Colors.transparent,
  //                           ),
  //                           child: Center(
  //                             child: Text(
  //                               '${guestList[index]}',
  //                               style: TextStyle(
  //                                 fontFamily: AppFont.fontFamily,
  //                                 fontWeight: FontWeight.w500,
  //                                 fontSize: 14,
  //                                 color: isSelected
  //                                     ? AppColor.pinkColor
  //                                     : AppColor.secondryColor,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),

  //                 SizedBox(height: size.height * 4 / 100),

  //                 // --- Continue Button ---
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.push(
  //                       context,
  //                       PageTransition(
  //                         type: PageTransitionType.rightToLeftWithFade,
  //                         child: BookTable(),
  //                         duration: const Duration(milliseconds: 500),
  //                       ),
  //                     );
  //                   },
  //                   child: Container(
  //                     width: size.width * 75 / 100,
  //                     height: size.height * 6 / 100,
  //                     decoration: BoxDecoration(
  //                       color: AppColor.secondryColor,
  //                       borderRadius: BorderRadius.circular(30),
  //                     ),
  //                     alignment: Alignment.center,
  //                     child: Text(
  //                       "Continue",
  //                       style: TextStyle(
  //                         fontFamily: AppFont.fontFamily,
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 15,
  //                         color: AppColor.pinkColor,
  //                       ),
  //                     ),
  //                   ),
  //                 ),

  //                 SizedBox(height: size.height * 2 / 100),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
