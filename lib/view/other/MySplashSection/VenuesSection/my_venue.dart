
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/past_venue_screeen.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_footer.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../EventSection/my_events.dart';
import '../MembersSection/Members.dart';

class MyVenue extends StatefulWidget {
  static const String routeName = '/MyVenue';
  const MyVenue({super.key});

  @override
  State<MyVenue> createState() => _MyVenueState();
}

class _MyVenueState extends State<MyVenue> {
  int selectedIndex = 0;
  List Likedlist = [
    {
      'image': AppImage.roofimg,
      'title': 'Rustic Rooftop Lounge',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.brewandbloomIcon,
      'title': 'The Brew Corner',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.img3,
      'title': 'Summer Music Festival 2025',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];

  List Reservedlist = [
    {
      'image': AppImage.brewandbloomIcon,
      'title': 'Urban Bites Café ',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.eventimg,
      'title': 'The Street Co.',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];
  List pastEventlist = [
    {
      'image': AppImage.eventImage3,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.eventImage4,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.eventImage5,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];

  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            color: AppColor.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4.5 / 100,
                ),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    height: MediaQuery.of(context).size.height * 7 / 100,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: MyAppFooter(initialIndex: 0),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: Container(
                            height:
                                MediaQuery.of(context).size.height * 7 / 100,
                            alignment: Alignment.center,
                            child: Image.asset(
                              AppImage.backarrow,
                              fit: BoxFit.cover,
                              color: AppColor.secondryColor,
                              height:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              width:
                                  MediaQuery.of(context).size.width * 5 / 100,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 25 / 100,
                        ),
                        GestureDetector(
                          onTap: () {
                            documenttypebottomsheet(context);
                          },
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              AppLanguage.myvenueText[language],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColor.secondryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 2 / 100),
                        GestureDetector(
                          onTap: () {
                            documenttypebottomsheet(context);
                          },
                          child: Image.asset(
                            AppImage.downArrow,
                            fit: BoxFit.cover,
                            color: AppColor.secondryColor,
                            height: MediaQuery.of(context).size.width * 5 / 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 2 / 100),
                Container(
                  color: AppColor.primaryColor,
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 0;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 50 / 100,
                            // height:
                            //     MediaQuery.of(context).size.height * 6 / 100,
                            child: Center(
                              child: Text(
                                AppLanguage.likedText[language],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: selectedIndex == 0
                                      ? AppColor.pinkColor
                                      : AppColor.secondryColor,
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = 1;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 50 / 100,
                            // height:
                            //     MediaQuery.of(context).size.height * 6 / 100,
                            child: Center(
                              child: Text(
                                AppLanguage.ReservedText[language],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: selectedIndex == 1
                                      ? AppColor.pinkColor
                                      : AppColor.secondryColor,
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 50 / 100,
                          height:
                              MediaQuery.of(context).size.height * 0.3 / 100,
                          color: selectedIndex == 0
                              ? AppColor.pinkColor
                              : AppColor.secondryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 50 / 100,
                          height:
                              MediaQuery.of(context).size.height * 0.3 / 100,
                          color: selectedIndex == 1
                              ? AppColor.pinkColor
                              : AppColor.secondryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: size.width * 90 / 100,
                        child: Column(
                          children: [
                            if (selectedIndex == 0) ...[
                              Wrap(
                                runSpacing: 10,
                                children: List.generate(
                                  Likedlist.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: VenuePages(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: size.width * 90 / 100,
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: size.width * 3 / 100,
                                          ),
                                          Container(
                                            width: size.width * 90 / 100,
                                            height: size.width * 42 / 100,
                                            decoration: const BoxDecoration(),
                                            child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                                child: Image.asset(
                                                  Likedlist[index]['image'],
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                          SizedBox(
                                            width: size.width * 3 / 100,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 3 / 100,
                                              vertical: size.height * 1 / 100,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      Likedlist[index]['title'],
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColor
                                                              .secondryColor),
                                                    ),
                                                    Container(
                                                      width:
                                                          size.width * 8 / 100,
                                                      height:
                                                          size.width * 8 / 100,
                                                      decoration:
                                                          const BoxDecoration(
                                                              boxShadow: []),
                                                      child: ClipRRect(
                                                          child: Image.asset(
                                                        AppImage
                                                            .liked_heart_icon,
                                                        fit: BoxFit.cover,
                                                        color: AppColor
                                                            .secondryColor,
                                                      )),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      size.height * 0.4 / 100,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: size.width *
                                                          4.5 /
                                                          100,
                                                      height: size.width *
                                                          4.5 /
                                                          100,
                                                      decoration:
                                                          const BoxDecoration(
                                                              boxShadow: []),
                                                      child: ClipRRect(
                                                        child: Image.asset(
                                                          AppImage
                                                              .calenderPinkIcon,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1 /
                                                              100,
                                                    ),
                                                    Text(
                                                      Likedlist[index]['date'],
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .secondryColor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 1 / 100,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width:
                                                          size.width * 5 / 100,
                                                      height:
                                                          size.width * 5 / 100,
                                                      decoration:
                                                          const BoxDecoration(
                                                              boxShadow: []),
                                                      child: ClipRRect(
                                                          child: Image.asset(
                                                        AppImage.locationIcon,
                                                        fit: BoxFit.cover,
                                                      )),
                                                    ),
                                                    Text(
                                                      Likedlist[index]
                                                          ['address'],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .secondryColor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      1.5 /
                                                      100,
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      6 /
                                                      100,
                                                  decoration: BoxDecoration(
                                                      color: AppColor
                                                          .secondryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                      AppLanguage
                                                              .ReservedtableText[
                                                          language],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .pinkColor),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (selectedIndex == 1) ...[
                              Container(
                                child: Text(
                                  AppLanguage.ReserveddetailsText[language],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.normal,
                                      color: AppColor.secondryColor),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              // if(selectedIndex !=0)
                              Wrap(
                                runSpacing: 10,
                                children: List.generate(
                                  Reservedlist.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: VenuePages(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: size.width * 90 / 100,
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: size.width * 3 / 100,
                                          ),
                                          Container(
                                            width: size.width * 90 / 100,
                                            height: size.width * 42 / 100,
                                            decoration: const BoxDecoration(),
                                            child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                                child: Image.asset(
                                                  Reservedlist[index]['image'],
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                          SizedBox(
                                            width: size.width * 3 / 100,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 3 / 100,
                                              vertical: size.height * 1 / 100,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      Reservedlist[index]
                                                          ['title'],
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColor
                                                              .secondryColor),
                                                    ),
                                                    Container(
                                                      width:
                                                          size.width * 8 / 100,
                                                      height:
                                                          size.width * 8 / 100,
                                                      decoration:
                                                          const BoxDecoration(
                                                              boxShadow: []),
                                                      child: ClipRRect(
                                                          child: Image.asset(
                                                        AppImage
                                                            .liked_heart_icon,
                                                        fit: BoxFit.cover,
                                                        color: AppColor
                                                            .secondryColor,
                                                      )),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      size.height * 0.4 / 100,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: size.width *
                                                          4.5 /
                                                          100,
                                                      height: size.width *
                                                          4.5 /
                                                          100,
                                                      decoration:
                                                          const BoxDecoration(
                                                              boxShadow: []),
                                                      child: ClipRRect(
                                                        child: Image.asset(
                                                          AppImage
                                                              .calenderPinkIcon,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              1 /
                                                              100,
                                                    ),
                                                    Text(
                                                      Reservedlist[index]
                                                          ['date'],
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .secondryColor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: size.height * 1 / 100,
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width:
                                                          size.width * 5 / 100,
                                                      height:
                                                          size.width * 5 / 100,
                                                      decoration:
                                                          const BoxDecoration(
                                                              boxShadow: []),
                                                      child: ClipRRect(
                                                          child: Image.asset(
                                                        AppImage.locationIcon,
                                                        fit: BoxFit.cover,
                                                      )),
                                                    ),
                                                    Text(
                                                      Reservedlist[index]
                                                          ['address'],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .secondryColor),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      1.5 /
                                                      100,
                                                ),
                                                Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      6 /
                                                      100,
                                                  decoration: BoxDecoration(
                                                      color: AppColor
                                                          .secondryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Center(
                                                    child: Text(
                                                      AppLanguage
                                                              .viewDetailstext[
                                                          language],
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .pinkColor),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              // if(selectedIndex != 0)
                              Container(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                child: Text(
                                  AppLanguage.pastReservationsText[language],
                                  style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColor.pinkColor),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              // if(selectedIndex != 0)

                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    100 /
                                    100,
                                height: size.height *
                                    28 /
                                    100, // Fixed height for horizontal list
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: pastEventlist.length,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0 / 100),
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                        right: size.width * 4 / 100),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        width:
                                            size.width * 37 / 100, // Card width
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color:
                                                  AppColor.startingscreenColor),
                                        ),

                                        child: Column(
                                          children: [
                                            // Image section
                                            Container(
                                              width: size.width * 35 / 100,
                                              height: size.height * 15 / 100,
                                              decoration: const BoxDecoration(),
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                ),
                                                child: Image.asset(
                                                  pastEventlist[index]['image'],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  30 /
                                                  100,
                                              child: Text(
                                                pastEventlist[index]['title'],
                                                style: const TextStyle(
                                                  fontSize: 9,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColor.secondryColor,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5 /
                                                  100,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  30 /
                                                  100,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        size.width * 2.5 / 100,
                                                    height:
                                                        size.width * 2.5 / 100,
                                                    child: Image.asset(
                                                      AppImage.calenderPinkIcon,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width *
                                                          1.5 /
                                                          100),
                                                  Text(
                                                    pastEventlist[index]
                                                        ['date'],
                                                    style: const TextStyle(
                                                      fontSize: 7,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: AppColor
                                                          .secondryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5 /
                                                  100,
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  30 /
                                                  100,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        size.width * 2.5 / 100,
                                                    height:
                                                        size.width * 2.5 / 100,
                                                    child: Image.asset(
                                                      AppImage.locationIcon,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width *
                                                          1.5 /
                                                          100),
                                                  Text(
                                                    pastEventlist[index]
                                                        ['address'],
                                                    style: const TextStyle(
                                                      fontSize: 7,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: AppColor
                                                          .secondryColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  2 /
                                                  100,
                                            ),

                                            // View Details button
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageTransition(
                                                    type: PageTransitionType
                                                        .rightToLeftWithFade,
                                                    child: PastVenueScreen(),
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: size.height * 4.5 / 100,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    35 /
                                                    100,
                                                decoration: BoxDecoration(
                                                  color: AppColor.secondryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "Review",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: AppColor.pinkColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Content section
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                            ],
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

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 78 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 78 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          width: size.width * 1.0,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Container(
                                width: size.width * 0.88,
                                child: Column(
                                  children: [
                                    // First Image

                                    Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        AppImage.dashIcon,
                                        height: size.height * 0.5 / 100,
                                        width: size.width * 22 / 100,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 4 / 100),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage.myspacetext[language],
                                        style: const TextStyle(
                                          color: AppColor.secondryColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .eventStatementtext[language],
                                        style: const TextStyle(
                                          color: AppColor.secondryColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.04),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: splashMembers(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.memberBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: size.height *
                                            0.02), // spacing between images
                                    // Second Image
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: MyVenue(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.venuesBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: MyEvents(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.eventsBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //     height: size.height * 0.06),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    ).then((_) {
      // Reset selected index when bottom sheet is dismissed
      // Optional: uncomment if you want to reset to previous page
      // setState(() {
      //   selectedIndex = pageController.page?.round() ?? 0;
      // });
    });
  }

  Widget dropdownItem(String text, VoidCallback onTap, bool isActive) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColor.dropdownColor : Colors.transparent,
          borderRadius: isActive
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                )
              : BorderRadius.zero,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? AppColor.secondryColor : AppColor.greyLightColor,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget divider() {
    return const Divider(
      color: Colors.grey,
      height: 1,
      thickness: 0.5,
    );
  }
}
