import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:table_calendar/table_calendar.dart';

class LikedvenueDetail extends StatefulWidget {
  static const String routeName = '/LikedvenueDetail';
  const LikedvenueDetail({super.key});

  @override
  State<LikedvenueDetail> createState() => _LikedvenueDetailState();
}

class _LikedvenueDetailState extends State<LikedvenueDetail> {
  int selectedIndex = 0;
  DateTime selectedDay = DateTime.now();
  List<String> disabledDays = [];
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

  bool isDayDisabled(DateTime day) {
    if (disabledDays.isEmpty) return false;

    String dayName = _getDayName(day);
    return disabledDays.any(
        (disabledDay) => disabledDay.toLowerCase() == dayName.toLowerCase());
  }

  List<Map<String, String>> storyImages = [
    {
      "image": "assets/icons/ProfilePhoto.png",
      "name": "Arjun",
      "subname": "opening Act"
    },
    {
      "image": "assets/icons/aadityaIcon.png",
      "name": "Aarav",
      "subname": "Main Act"
    },
    {
      "image": "assets/icons/galleryIcon.png",
      "name": "Bloom Cafe",
      "subname": "Break Act"
    },
    {
      "image": "assets/icons/girlImage.png",
      "name": "Bistro",
      "subname": "Break Act"
    },
    {
      "image": "assets/icons/userprofile.png",
      "name": "olivia",
      "subname": "Break Act"
    },
  ];
  List Likedlist = [
    {
      'image': AppImage.eventimg,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.brewandbloomIcon,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];

  List Bookedlist = [
    {
      'image': AppImage.brewandbloomIcon,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.eventimg,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(AppConstant.systemUiOverlayStyle);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            color: AppColor.secondryColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                


                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: size.width * 100 / 100,
                        child: Column(
                          children: [
                             Stack(
                              children: [
                              Container(
                                width: size.width * 100 / 100,
                                height: size.height * 30 / 100,
                                child: ClipRRect(
                                  child: Image.asset(
                                    AppImage.brewandbloomIcon,
                                    fit: BoxFit.cover,
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
                                    color: AppColor.secondryColor(context),
                                    fit: BoxFit.cover,
                                    height: size.width * 5 / 100,
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: size.height * 1 / 100,
                            ),
                            Container(
                              width: size.width * 90 / 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLanguage
                                                  .Brewbloomcafetext[language],
                                              style:  TextStyle(
                                                  fontSize: 24,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColor.primaryColor(
                                                      context)),
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
                                                        color:
                                                            AppColor.pinkColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          size.width * 2 / 100,
                                                      vertical: 1,
                                                    ),
                                                    child: Text(
                                                      AppLanguage
                                                          .cafe[language],
                                                      style:  TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .primaryColor(
                                                                  context)),
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
                                                        color:
                                                            AppColor.pinkColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          size.width * 2 / 100,
                                                      vertical: 1,
                                                    ),
                                                    child: Text(
                                                      AppLanguage
                                                          .desert[language],
                                                      style:  TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .primaryColor(
                                                                  context)),
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
                                                        color:
                                                            AppColor.pinkColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          size.width * 2 / 100,
                                                      vertical: 1,
                                                    ),
                                                    child: Text(
                                                      AppLanguage
                                                          .Coffee[language],
                                                      style:  TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .primaryColor(
                                                                  context)),
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
                                          
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 3 / 100,
                                  ),
                                  Row(
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2 /
                                                100,
                                      ),
                                      Text(
                                        AppLanguage.datetimeText[language],
                                        style:  TextStyle(
                                            fontSize: 15,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.primaryColor(context)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Row(
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2 /
                                                100,
                                      ),
                                      Text(
                                        AppLanguage.time[language],
                                        style:  TextStyle(
                                            fontSize: 15,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.primaryColor(context)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Row(
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2 /
                                                100,
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child: Text(
                                                AppLanguage.dummylocationText[
                                                    language],
                                                style:  TextStyle(
                                                    fontSize: 15,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColor.primaryColor(
                                                            context)),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  AppLanguage.awaylocationText[
                                                      language],
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: AppColor
                                                          .greyLightColor),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 4 / 100,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        94 /
                                        100,
                                    child: TableCalendar(
                                      availableGestures: AvailableGestures.all,
                                      firstDay: DateTime.now(),
                                      lastDay: DateTime.utc(2030, 8, 14),
                                      focusedDay: selectedDay,
                                      enabledDayPredicate: (day) {
                                        // Disable past dates and off days
                                        if (day.isBefore(DateTime.now()
                                            .subtract(
                                                const Duration(days: 1)))) {
                                          return false;
                                        }
                                        return !isDayDisabled(day);
                                      },
                                     
                                      calendarStyle: CalendarStyle(
                                        selectedDecoration: const BoxDecoration(
                                          gradient: AppColor.backgroundGradient,
                                          // shape: BoxShape.circle,
                                        ),
                                        selectedTextStyle:  TextStyle(
                                          color: AppColor.primaryColor(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        todayDecoration: BoxDecoration(
                                          color: AppColor.statusbar,
                                          shape: BoxShape.circle,
                                        ),
                                    
                                        disabledTextStyle:  TextStyle(
                                          color: AppColor.primaryColor(context),
                                        ),
                                        defaultTextStyle:  TextStyle(
                                            color: AppColor.primaryColor(context)),
                                        weekendTextStyle:  TextStyle(
                                            color: AppColor.primaryColor(context)),
                                        outsideTextStyle:  TextStyle(
                                            color: AppColor.primaryColor(context)),
                                      ),
                                      daysOfWeekStyle: const DaysOfWeekStyle(
                                        weekdayStyle: TextStyle(
                                          color: AppColor.buttonColor,
                                        ),
                                        weekendStyle: TextStyle(
                                            color: AppColor.buttonColor),
                                      ),
                                      headerStyle: const HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                        leftChevronPadding:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        titleTextStyle: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.buttonColor,
                                          fontSize: 18,
                                        ),
                                        leftChevronIcon: Icon(
                                            Icons.chevron_left,
                                            color: AppColor.textcolor),
                                        rightChevronIcon: Icon(
                                            Icons.chevron_right,
                                            color: AppColor.textcolor),
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: size.height * 4 / 100,
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.aboutText[language],
                                      style:  TextStyle(
                                          fontSize: 18,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.primaryColor(context)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 1 / 100,
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.brewBloomstatement[
                                          language],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.normal,
                                          color: AppColor.greyLightColor),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          AppLanguage.GalleryText[language],
                                          style:  TextStyle(
                                              fontSize: 18,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.primaryColor(
                                                  context)),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          AppLanguage.viewAlltext[language],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.pinkColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: size.width * 60 / 100,
                                          height: size.height * 15 / 100,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              AppImage.galleryImg1,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 60 / 100,
                                          height: size.height * 15 / 100,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              AppImage.galleryImg,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                               
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  
                                
                                  SizedBox(
                                    height: size.height * 3 / 100,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          AppLanguage
                                              .upcomingEventstext[language],
                                          style:  TextStyle(
                                              fontSize: 18,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.primaryColor(
                                                  context)),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          AppLanguage.viewAlltext[language],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.pinkColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                 
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                 child:  Row(
                    children: [
                      Image.asset(
                        AppImage.aroundmeIcon,
                        height: size.width * 68 / 100,
                        width: size.width * 50 / 100,
                      ),
                      Image.asset(
                        AppImage.aroundmeIcon1,
                        height: size.width * 68 / 100,
                        width: size.width * 45 / 100,
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
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: AppColor.backgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                4 /
                                                100,
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2 /
                                                100,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    AppLanguage
                                                        .fromText[language],
                                                    style:  TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
                                                  ),
                                                  Text(
                                                    AppLanguage.fourHundredruppeText[
                                                        language],
                                                    style:  TextStyle(
                                                        fontSize: 22,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                width: size.width * 40 / 100,
                                                decoration: BoxDecoration(
                                                    color:
                                                        AppColor.secondryColor(context),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              3 /
                                                              100,
                                                      vertical:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              2 /
                                                              100,
                                                    ),
                                                    child: Text(
                                                      AppLanguage.BookNowText[
                                                          language],
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColor
                                                              .pinkColor),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                6 /
                                                100,
                                          ),
                                          child: Text(
                                            AppLanguage
                                                    .secureYourspotText[
                                                language],
                                            style:  TextStyle(
                                                fontSize: 14,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w400,
                                                color: AppColor.secondryColor(context)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.height * 5 / 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
