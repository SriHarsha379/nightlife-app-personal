import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../provider/darkmode_provider.dart';
import '../../utilities/app_button.dart';
import '../other/calender_screen.dart';

class SearchScreen extends StatefulWidget {
  static String routeName = './SearchScreen';
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  int tapBarStatus = 0;

  List trendingSearchList = ["Royal Club", "Arjun Raajpaal", "Music Fest"];
  List cityList = ["Delhi", "Mumbai", "Banglore", "Goa", "Chennai", "Kolkata"];

  final List<Map<String, String>> eventList = [
    {
      "image": "assets/icons/ic_roofimg.png",
      "title": "Live Concert",
      "distance": "5.0 km",
      "location": "Indirapuram"
    },
    {
      "image": "assets/icons/ic_roofimg.png",
      "title": "DJ Night",
      "distance": "7.2 km",
      "location": "Kaushambi"
    },
    // {
    //   "image": "assets/icons/ic_roofimg.png",
    //   "title": "Kitchen Party",
    //   "distance": "9.0 km",
    //   "location": "Noida"
    // },
    {
      "image": "assets/icons/ic_roofimg.png",
      "title": "Kingdom of Dreams",
      "distance": "12.5 km",
      "location": "Gurugram"
    },
  ];

  final List<Map<String, String>> placeList = [
    {
      'image': 'assets/icons/goa.jpg',
      'title': 'Indirapuram Habitat',
      'distance': '5.0 km',
      'location': 'Indirapuram',
    },
    {
      'image': 'assets/icons/goa.jpg',
      'title': 'Pacific Mall',
      'distance': '7.2 km',
      'location': 'Kaushambi',
    },
    {
      'image': 'assets/icons/goa.jpg',
      'title': 'Kingdom of Dreams',
      'distance': '12.0 km',
      'location': 'Gurgaon',
    },
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor:
              isDark ? AppColor.primaryColor : AppColor.secondryColor,
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 100 / 100,
              width: MediaQuery.of(context).size.width * 100 / 100,
              color: isDark ? AppColor.primaryColor : AppColor.secondryColor,
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _openDistanceBottomSheet(context);
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 8 / 100,
                          height: MediaQuery.of(context).size.width * 8 / 100,
                          child: Image.asset(
                            AppImage.locationIcon,
                            color: isDark
                                ? AppColor.secondryColor
                                : AppColor.primaryColor,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 2 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 60 / 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delhi",
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColor.secondryColor
                                    : AppColor.primaryColor,
                              ),
                            ),
                            Text(
                              "Chander Nagar, Surya Nagar, Delhi",
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                color: isDark
                                    ? AppColor.secondryColor
                                    : AppColor.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // bottomSheet(context);
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: CalendarScreen(),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 5 / 100,
                          height: MediaQuery.of(context).size.width * 5 / 100,
                          child: Image.asset(
                            AppImage.calenderImage,
                            fit: BoxFit.cover,
                            color: AppColor.pinkColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 6 / 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40), // pill shape
                    border: Border.all(color: AppColor.secondryColor),
                    //  color: AppColor.secondryColor,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                        blurRadius: 4,
                        color: isDark
                            ? AppColor.primaryColor.withOpacity(0.1)
                            : AppColor.secondryColor,
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: searchController,
                    cursorColor:
                        isDark ? AppColor.secondryColor : AppColor.primaryColor,
                    style: TextStyle(
                        color: isDark
                            ? AppColor.secondryColor
                            : AppColor.primaryColor,
                        fontWeight: FontWeight.w400,
                        fontFamily: AppFont.fontFamily,
                        fontSize: 14),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.width * 4 / 100,
                          vertical: 10,
                        ),
                        child: Image.asset(
                          AppImage.searchIcon,
                          height: MediaQuery.of(context).size.height * 4 / 100,
                          width: MediaQuery.of(context).size.width * 4 / 100,
                          color: isDark
                              ? AppColor.secondryColor
                              : AppColor.primaryColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: AppColor.primaryColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: const BorderSide(
                          color: AppColor.primaryColor,
                          width: 0,
                        ),
                      ),
                      border: InputBorder.none,
                      // hintText: AppLanguage.searchText[language],
                      hintStyle: AppConstant.textFilledStyle1,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: MediaQuery.of(context).size.width * 2 / 100,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                //!====================Tap bar three option===================\\
                SizedBox(
                  width: MediaQuery.of(context).size.width * 75 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //!member option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tapBarStatus = 0;
                          });
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 22 / 100,
                          child: Column(
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 6 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 6 / 100,
                                child: Image.asset(
                                  AppImage.memberIcon,

                                  color: tapBarStatus == 0
                                      ? AppColor.pinkColor
                                      : AppColor.textTapColor,
                                  // fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                // width: MediaQuery.of(context).size.width * 18 / 100,
                                child: Text(
                                  AppLanguage.membersText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: tapBarStatus == 0
                                          ? AppColor.pinkColor
                                          : AppColor.textTapColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //!Venues option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tapBarStatus = 1;
                          });
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 22 / 100,
                          child: Column(
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 6 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 6 / 100,
                                child: Image.asset(
                                  AppImage.venuesIcon,

                                  color: tapBarStatus == 1
                                      ? AppColor.pinkColor
                                      : AppColor.textTapColor,
                                  // fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                //  width: MediaQuery.of(context).size.width * 18 / 100,
                                child: Text(
                                  AppLanguage.venuesText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: tapBarStatus == 1
                                          ? AppColor.pinkColor
                                          : AppColor.textTapColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //!Events option
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            tapBarStatus = 2;
                          });
                        },
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 22 / 100,
                          child: Column(
                            children: [
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 6 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 6 / 100,
                                child: Image.asset(
                                  AppImage.eventsIcon,

                                  color: tapBarStatus == 2
                                      ? AppColor.pinkColor
                                      : AppColor.textTapColor,
                                  // fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                // width: MediaQuery.of(context).size.width * 18 / 100,
                                child: Text(
                                  AppLanguage.eventsText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: tapBarStatus == 2
                                          ? AppColor.pinkColor
                                          : AppColor.textTapColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 75 / 100,
                  alignment: tapBarStatus == 0
                      ? Alignment.centerLeft
                      : tapBarStatus == 1
                          ? Alignment.center
                          : Alignment.centerRight,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5 / 100,
                    width: MediaQuery.of(context).size.width * 22 / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.pinkColor,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2 / 100,
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColor.textTapColor,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.trendingSearchText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.pinkColor),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          Container(
                              width:
                                  MediaQuery.of(context).size.width * 95 / 100,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Wrap(
                                    children: [
                                      ...List.generate(
                                        trendingSearchList.length,
                                        (index) => Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                  color: isDark
                                                      ? AppColor.textTapColor
                                                      : AppColor.primaryColor)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 15),
                                            child: Row(
                                              children: [
                                                Text(
                                                  trendingSearchList[index],
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: isDark
                                                        ? AppColor.secondryColor
                                                        : AppColor.primaryColor,
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      6 /
                                                      100,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      3 /
                                                      100,
                                                  child: Image.asset(
                                                    AppImage.upgradeIcon,
                                                    fit: BoxFit.cover,
                                                    color: isDark
                                                        ? AppColor.secondryColor
                                                        : AppColor
                                                            .primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ))),
                          ////////////////////

                          tapBarStatus == 0
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              3.2 /
                                              100,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Text(
                                        AppLanguage
                                            .premiumMembersText[language],
                                        style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.pinkColor),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              100,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                100 /
                                                100,
                                        child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Wrap(
                                              children: [
                                                ...List.generate(
                                                  3,
                                                  (index) => Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                          border: Border.all(
                                                              color: AppColor
                                                                  .textTapColor)),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                55 /
                                                                100,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                25 /
                                                                100,
                                                            decoration: BoxDecoration(
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black,
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  )
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                                border: Border
                                                                    .all()),
                                                            child: ClipRRect(
                                                              borderRadius: const BorderRadius
                                                                  .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          25),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          25)),
                                                              child:
                                                                  Image.asset(
                                                                'assets/icons/women-img.png',
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                2 /
                                                                100,
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                55 /
                                                                100,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              child: Text(
                                                                "Sarah,26",
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  color: isDark
                                                                      ? AppColor
                                                                          .secondryColor
                                                                      : AppColor
                                                                          .primaryColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                55 /
                                                                100,
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        6 /
                                                                        100,
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        6 /
                                                                        100,
                                                                    child: Image
                                                                        .asset(
                                                                      AppImage
                                                                          .locationBlackicon,
                                                                      color: AppColor
                                                                          .pinkColor,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        1 /
                                                                        100,
                                                                  ),
                                                                  const Text(
                                                                    "2.3 km away",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            AppFont
                                                                                .fontFamily,
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        color: AppColor
                                                                            .pinkColor),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                2 /
                                                                100,
                                                          ),
                                                        ],
                                                      )),
                                                )
                                              ],
                                            ))),

                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              4 /
                                              100,
                                    ),
                                    // dusri list
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Text(
                                        AppLanguage.memberNearyouText[language],
                                        style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColor.pinkColor),
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              100,
                                    ),
                                    Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                100 /
                                                100,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Wrap(
                                            children: [
                                              ...List.generate(
                                                3,
                                                (index) => Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                        border: Border.all(
                                                            color: AppColor
                                                                .textTapColor)),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              55 /
                                                              100,
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              25 /
                                                              100,
                                                          decoration: BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black,
                                                                  blurRadius:
                                                                      10,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 4),
                                                                )
                                                              ],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                              border:
                                                                  Border.all()),
                                                          child: ClipRRect(
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        25),
                                                                topRight: Radius
                                                                    .circular(
                                                                        25)),
                                                            child: Image.asset(
                                                              'assets/icons/men_img.png',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              2 /
                                                              100,
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              55 /
                                                              100,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Text(
                                                              "Sarah,26",
                                                              style: TextStyle(
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: isDark
                                                                    ? AppColor
                                                                        .secondryColor
                                                                    : AppColor
                                                                        .primaryColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              55 /
                                                              100,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      6 /
                                                                      100,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      6 /
                                                                      100,
                                                                  child: Image
                                                                      .asset(
                                                                    AppImage
                                                                        .locationBlackicon,
                                                                    color: AppColor
                                                                        .pinkColor,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      1 /
                                                                      100,
                                                                ),
                                                                const Text(
                                                                  "2.3 km away",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      color: AppColor
                                                                          .pinkColor),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              2 /
                                                              100,
                                                        ),
                                                      ],
                                                    )),
                                              )
                                            ],
                                          ),
                                        )),

                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              6 /
                                              100,
                                    ),
                                  ],
                                )
                              : tapBarStatus == 1
                                  ? Column(children: [
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                100,
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                90 /
                                                100,
                                        child: Text(
                                          "Sponsored",
                                          style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.pinkColor),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                100,
                                      ),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              100 /
                                              100,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child: LikedEventDetail(),
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                ),
                                              );
                                            },
                                            child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Wrap(
                                                  children: [
                                                    ...List.generate(
                                                      3,
                                                      (index) => Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25),
                                                              border: Border.all(
                                                                  color: AppColor
                                                                      .textTapColor)),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    55 /
                                                                    100,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    25 /
                                                                    100,
                                                                decoration: BoxDecoration(
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black,
                                                                        blurRadius:
                                                                            10,
                                                                        offset: const Offset(
                                                                            0,
                                                                            4),
                                                                      )
                                                                    ],
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            25),
                                                                    border: Border
                                                                        .all()),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              25),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              25)),
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/icons/imageforlist.jpg',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    2 /
                                                                    100,
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    55 /
                                                                    100,
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                  child: Text(
                                                                    "Sarah,26",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            AppFont
                                                                                .fontFamily,
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        color: isDark
                                                                            ? AppColor.secondryColor
                                                                            : AppColor.primaryColor),
                                                                  ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    55 /
                                                                    100,
                                                                child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            6 /
                                                                            100,
                                                                        height: MediaQuery.of(context).size.width *
                                                                            6 /
                                                                            100,
                                                                        child: Image
                                                                            .asset(
                                                                          AppImage
                                                                              .locationBlackicon,
                                                                          color:
                                                                              AppColor.pinkColor,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            1 /
                                                                            100,
                                                                      ),
                                                                      const Text(
                                                                        "2.3 km away",
                                                                        style: TextStyle(
                                                                            fontFamily: AppFont
                                                                                .fontFamily,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.w900,
                                                                            color: AppColor.pinkColor),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    2 /
                                                                    100,
                                                              ),
                                                            ],
                                                          )),
                                                    )
                                                  ],
                                                )),
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                5 /
                                                100,
                                      ),
                                      Container(
                                        width: size.width * 90 / 100,
                                        child: Text(
                                          "Places near you",
                                          style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.pinkColor),
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                2 /
                                                100,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                90 /
                                                100,
                                        child: Container(
                                          height: size.height * 30 / 100,
                                          width: double.infinity,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: placeList.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    right:
                                                        size.width * 3 / 100),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: size.height *
                                                          18 /
                                                          100,
                                                      width:
                                                          size.width * 40 / 100,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                              placeList[index]
                                                                  ['image']!),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: size.height *
                                                            1 /
                                                            100),
                                                    Text(
                                                      placeList[index]
                                                          ['title']!,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? AppColor
                                                                .secondryColor
                                                            : AppColor
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: size.height *
                                                            0.5 /
                                                            100),
                                                    Text(
                                                      "${placeList[index]['distance']} | ${placeList[index]['location']}",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: AppColor
                                                            .listTextColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    ])
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              90 /
                                              100,
                                          child: Text(
                                            "Sponsored",
                                            style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColor.pinkColor),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                        ),
                                        Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                90 /
                                                100,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  PageTransition(
                                                    type: PageTransitionType
                                                        .rightToLeftWithFade,
                                                    child: LikedEventDetail(),
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                  ),
                                                );
                                              },
                                              child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Wrap(
                                                    children: [
                                                      ...List.generate(
                                                        3,
                                                        (index) => Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            25),
                                                                border: Border.all(
                                                                    color: AppColor
                                                                        .textTapColor)),
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      55 /
                                                                      100,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      25 /
                                                                      100,
                                                                  decoration: BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.black,
                                                                          blurRadius:
                                                                              10,
                                                                          offset: const Offset(
                                                                              0,
                                                                              4),
                                                                        )
                                                                      ],
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              25),
                                                                      border: Border
                                                                          .all()),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius: const BorderRadius
                                                                        .only(
                                                                        topLeft:
                                                                            Radius.circular(
                                                                                25),
                                                                        topRight:
                                                                            Radius.circular(25)),
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/icons/img.png',
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      2 /
                                                                      100,
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      55 /
                                                                      100,
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    child: Text(
                                                                      "Sarah,26",
                                                                      style: TextStyle(
                                                                          fontFamily: AppFont
                                                                              .fontFamily,
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight: FontWeight
                                                                              .w900,
                                                                          color: isDark
                                                                              ? AppColor.secondryColor
                                                                              : AppColor.primaryColor),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      55 /
                                                                      100,
                                                                  child:
                                                                      Padding(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              6 /
                                                                              100,
                                                                          height: MediaQuery.of(context).size.width *
                                                                              6 /
                                                                              100,
                                                                          child:
                                                                              Image.asset(
                                                                            AppImage.locationBlackicon,
                                                                            color:
                                                                                AppColor.pinkColor,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width: MediaQuery.of(context).size.width *
                                                                              1 /
                                                                              100,
                                                                        ),
                                                                        const Text(
                                                                          "2.3 km away",
                                                                          style: TextStyle(
                                                                              fontFamily: AppFont.fontFamily,
                                                                              fontSize: 14,
                                                                              fontWeight: FontWeight.w900,
                                                                              color: AppColor.pinkColor),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      2 /
                                                                      100,
                                                                ),
                                                              ],
                                                            )),
                                                      )
                                                    ],
                                                  )),
                                            )),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              7 /
                                              100,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              90 /
                                              100,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Events near you",
                                              style: TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColor.pinkColor),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              28 /
                                              100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: eventList.length,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            itemBuilder: (context, index) {
                                              final event = eventList[index];
                                              return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    40 /
                                                    100,
                                                margin: const EdgeInsets.only(
                                                    right: 12),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: isDark
                                                        ? AppColor.primaryColor
                                                        : AppColor
                                                            .secondryColor),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Image.asset(
                                                        event["image"]!,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            12 /
                                                            100,
                                                        width: double.infinity,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            1 /
                                                            100),
                                                    Text(
                                                      event["title"]!,
                                                      style: TextStyle(
                                                        color: isDark
                                                            ? AppColor
                                                                .secondryColor
                                                            : AppColor
                                                                .primaryColor,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            1 /
                                                            100),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          event["distance"]!,
                                                          style: TextStyle(
                                                            color: isDark
                                                                ? AppColor
                                                                    .secondryColor
                                                                : AppColor
                                                                    .primaryColor,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Icon(
                                                          Icons.circle,
                                                          size: 4,
                                                          color: isDark
                                                              ? Colors.white54
                                                              : AppColor
                                                                  .primaryColor,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          event["location"]!,
                                                          style: TextStyle(
                                                            color: isDark
                                                                ? AppColor
                                                                    .secondryColor
                                                                : AppColor
                                                                    .primaryColor,
                                                            fontSize: 10,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      ],
                                    ),

                          //////////////

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 6 / 100,
                          ),

                          // SizedBox(height: MediaQuery.of(context).size.height* 4/100,),
                          // // dusri list
                          // Container(
                          //   width: MediaQuery.of(context).size.width * 90 / 100,
                          //   child: Text(
                          //     AppLanguage.membersText[language],
                          //     style: const TextStyle(
                          //         fontFamily: AppFont.fontFamily,
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.w600,
                          //         color: AppColor.pinkColor),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height:
                          //       MediaQuery.of(context).size.height * 1 / 100,
                          // ),
                          // Container(
                          //     width:
                          //         MediaQuery.of(context).size.width * 100 / 100,
                          //     child: SingleChildScrollView(
                          //         scrollDirection: Axis.horizontal,
                          //         child: Wrap(
                          //           children: [
                          //             ...List.generate(
                          //               3,
                          //               (index) => Container(
                          //                   margin: const EdgeInsets.symmetric(
                          //                       horizontal: 8),
                          //                   decoration: BoxDecoration(
                          //                       borderRadius:
                          //                           BorderRadius.circular(25),
                          //                       border: Border.all(
                          //                           color:
                          //                               AppColor.textTapColor)),
                          //                   child: Column(
                          //                     children: [
                          //                       Container(
                          //                         width: MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             55 /
                          //                             100,
                          //                         height: MediaQuery.of(context)
                          //                                 .size
                          //                                 .height *
                          //                             25 /
                          //                             100,
                          //                         decoration: BoxDecoration(
                          //                             boxShadow: [
                          //                               BoxShadow(
                          //                                 color: Colors.black,
                          //                                 blurRadius: 10,
                          //                                 offset: const Offset(
                          //                                     0, 4),
                          //                               )
                          //                             ],
                          //                             borderRadius:
                          //                                 BorderRadius.circular(
                          //                                     25),
                          //                             border: Border.all()),
                          //                         child: ClipRRect(
                          //                           borderRadius:
                          //                               const BorderRadius.only(
                          //                                   topLeft:
                          //                                       Radius.circular(
                          //                                           25),
                          //                                   topRight:
                          //                                       Radius.circular(
                          //                                           25)),
                          //                           child: Image.asset(
                          //                             AppImage
                          //                                 .swipe_galleryIcon4,
                          //                             fit: BoxFit.cover,
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       SizedBox(
                          //                         height: MediaQuery.of(context)
                          //                                 .size
                          //                                 .height *
                          //                             2 /
                          //                             100,
                          //                       ),
                          //                       Container(
                          //                         width: MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             55 /
                          //                             100,
                          //                         child: const Padding(
                          //                           padding:
                          //                               EdgeInsets.symmetric(
                          //                                   horizontal: 10),
                          //                           child: Text(
                          //                             "Sarah,26",
                          //                             style: TextStyle(
                          //                                 fontFamily: AppFont
                          //                                     .fontFamily,
                          //                                 fontSize: 16,
                          //                                 fontWeight:
                          //                                     FontWeight.w900,
                          //                                 color: AppColor
                          //                                     .secondryColor),
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       Container(
                          //                         width: MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             55 /
                          //                             100,
                          //                         child: Padding(
                          //                           padding:
                          //                               EdgeInsets.symmetric(
                          //                                   horizontal: 10),
                          //                           child: Row(
                          //                             children: [
                          //                               Container(
                          //                                 width: MediaQuery.of(
                          //                                             context)
                          //                                         .size
                          //                                         .width *
                          //                                     6 /
                          //                                     100,
                          //                                 height: MediaQuery.of(
                          //                                             context)
                          //                                         .size
                          //                                         .width *
                          //                                     6 /
                          //                                     100,
                          //                                 child: Image.asset(
                          //                                   AppImage
                          //                                       .locationBlackicon,
                          //                                   color: AppColor
                          //                                       .pinkColor,
                          //                                   fit: BoxFit.cover,
                          //                                 ),
                          //                               ),
                          //                               SizedBox(
                          //                                 width: MediaQuery.of(
                          //                                             context)
                          //                                         .size
                          //                                         .width *
                          //                                     1 /
                          //                                     100,
                          //                               ),
                          //                               const Text(
                          //                                 "2.3 km away",
                          //                                 style: TextStyle(
                          //                                     fontFamily: AppFont
                          //                                         .fontFamily,
                          //                                     fontSize: 14,
                          //                                     fontWeight:
                          //                                         FontWeight
                          //                                             .w900,
                          //                                     color: AppColor
                          //                                         .pinkColor),
                          //                               ),
                          //                             ],
                          //                           ),
                          //                         ),
                          //                       ),
                          //                       SizedBox(
                          //                         height: MediaQuery.of(context)
                          //                                 .size
                          //                                 .height *
                          //                             2 /
                          //                             100,
                          //                       ),
                          //                     ],
                          //                   )),
                          //             )
                          //           ],
                          //         ))),
                        ],
                      ),
                    ))
              ]),
            ),
          ),
        ));
  }

  void _openGuestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.themeColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        List<int> guestList = List.generate(20, (index) => index + 1);
        int selectedGuest = -1;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 6 / 100,
                vertical: size.height * 3 / 100,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- Title ---
                  Row(
                    children: [
                      SizedBox(width: size.width * 3 / 100),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select number of Guest",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 3 / 100),

                  // --- Horizontal Scrollable Chips ---
                  SizedBox(
                    height: size.height * 7 / 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: guestList.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedGuest == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGuest = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 18),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 22),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.pinkColor
                                    : AppColor.textTapColor,
                                width: 1,
                              ),
                              color: isSelected
                                  ? AppColor.pinkColor.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                '${guestList[index]}',
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColor.pinkColor
                                      : AppColor.secondryColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: size.height * 4 / 100),

                  // --- Continue Button ---
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: size.width * 75 / 100,
                      height: size.height * 6 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.secondryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColor.pinkColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openDistanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.themeColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        double _currentDistance = 30;
        bool _isBroadened = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.all(size.width * 5 / 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.5 / 100),
                  Center(
                    child: Container(
                      width: size.width * 15 / 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 4 / 100),
                  Container(
                    width: size.width * 95 / 100,
                    height: size.height * 6 / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColor.filledcolor,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 1),
                          spreadRadius: 0,
                          blurRadius: 0,
                          color: AppColor.transparentColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: searchController,
                      cursorColor: AppColor.secondryColor,
                      style: const TextStyle(color: AppColor.secondryColor),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(
                            left: size.width * 4 / 100,
                            right: size.width * 2 / 100,
                          ),
                          child: Image.asset(
                            AppImage.searchIcon,
                            height: size.width * 4 / 100,
                            width: size.width * 4 / 100,
                            color: AppColor.filledText,
                          ),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: size.width * 12 / 100,
                          minHeight: size.height * 6 / 100,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColor.borderColor,
                            width: 0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColor.borderColor,
                            width: 0,
                          ),
                        ),
                        border: InputBorder.none,
                        hintText: AppLanguage.searchForaCityText[language],
                        hintStyle: AppConstant.textFilledStyle,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: size.height * 2 / 100,
                          horizontal: size.width * 4 / 100,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 3 / 100),
                  Stack(
                    children: [
                      Container(
                        height: size.height * 25 / 100,
                        width: size.width * 100 / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: AssetImage(AppImage.mapImageIcon),
                              fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        // right: 1,
                        left: 100,
                        bottom: 15,
                        child: GestureDetector(
                          child: Container(
                            height: size.height * 3.5 / 100,
                            width: size.width * 45 / 100,
                            decoration: BoxDecoration(
                              color: AppColor.backgroundColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppImage.pinLocationicon,
                                  width: MediaQuery.of(context).size.width *
                                      3 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                  color: AppColor.secondryColor,
                                ),
                                SizedBox(width: size.width * 2 / 100),
                                Text(
                                  AppLanguage.currentLocationText[language],
                                  style: TextStyle(
                                    color: AppColor.secondryColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        1 /
                                        100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 3.5 / 100,
                  ),
                  Text(
                    "Location",
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColor.pinkColor,
                    ),
                  ),
                  SizedBox(height: size.height * 1 / 100),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 10, // space between chips horizontally
                      runSpacing: 12, // space between rows vertically
                      children: List.generate(
                        cityList.length,
                        (index) => Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColor.textTapColor),
                          ),
                          child: Text(
                            cityList[index],
                            style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColor.secondryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 4 / 100),
                  Text(
                    "Distance",
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColor.pinkColor,
                    ),
                  ),
                  SizedBox(height: size.height * 2 / 100),
                  Container(
                    width: size.width * 90 / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColor.darkPurpleColor,
                        width: 1,
                      ),
                      color: Colors.transparent,
                    ),
                    padding: EdgeInsets.all(size.width * 4 / 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 1 / 100),
                        Text(
                          "Upto ${_currentDistance.toInt()} kilometres away",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: AppColor.secondryColor,
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.5 / 100,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Slider(
                            value: _currentDistance,
                            min: 1,
                            max: 100,
                            activeColor: AppColor.pinkColor,
                            inactiveColor: AppColor.lightgreyColor,
                            onChanged: (value) {
                              setState(() {
                                _currentDistance = value;
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "1km",
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: AppColor.secondryColor,
                              ),
                            ),
                            Text(
                              "60km",
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 1 / 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Broaden the vibe zone...",
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: AppColor.greyLightColor,
                              ),
                            ),
                            Switch(
                              value: _isBroadened,
                              onChanged: (value) {
                                setState(() {
                                  _isBroadened = value;
                                });
                              },
                              activeColor: AppColor.pinkColor,
                              inactiveTrackColor: AppColor.secondryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 2 / 100),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
