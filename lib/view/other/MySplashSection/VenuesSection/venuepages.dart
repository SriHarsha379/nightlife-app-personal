
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails5_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_footer.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
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

  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton:Container(
            decoration: BoxDecoration(
              color: AppColor.sendinvitecontainercolor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            width: size.width * 85 / 100,
            height: size.height * 7 / 100,
            child: Row(
              children: [
                   SizedBox(
                  width: size.width * 3 / 100,
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
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
                ),
                SizedBox(
                  width: size.width * 3 / 100,
                ),
                GestureDetector(
                  onTap: () {
                    documenttypebottomsheet(context);
                  },
                  child: Container(
                  width: size.width * 30 / 100,
                                    height: size.height * 4.6 / 100,

                    decoration: BoxDecoration(
                      color: AppColor.secondryColor,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: AppColor.secondryColor,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppLanguage.sendInviteText[language],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFont.fontFamily,
                          color: AppColor.pinkColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 3 / 100,
                ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.buttonColor,
                      borderRadius: BorderRadius.circular(50),

              
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppImage.heartImg,
                          height: 20,
                          width: 20,
                          color: AppColor.secondryColor, // optional tint color
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
                ),
              ],
            ),
          ),
          backgroundColor: AppColor.primaryColor,
          body: Container(
            height: size.height * 100 / 100,
            width: size.width * 100 / 100,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: size.height * 3 / 100),
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
                      width: 180, // adjust size as needed
                      height: 1,
                      color: AppColor.lightgreyColor,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 12 / 100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
void documenttypebottomsheet(BuildContext context) {
  final size = MediaQuery.of(context).size;

  showModalBottomSheet<void>(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setStateBottomSheet) {
        return Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 60 / 100,
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 100 / 100,
                height: MediaQuery.of(context).size.height * 60 / 100,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColor.backgroundGradientcolor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(46),
                            topRight: Radius.circular(46),
                          ),
                        ),
                        width: size.width * 100 / 100,
                        height: size.height * 80 / 100,
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 2 / 100),
                            Image.asset(
                              AppImage.dashIcon,
                              height: size.height * 0.5 / 100,
                              width: size.width * 28 / 100,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(height: size.height * 2 / 100),
                            Container(
                              color: AppColor.transparentColor,
                              width: MediaQuery.of(context).size.width * 100 / 100,
                              height: MediaQuery.of(context).size.height * 8 / 100,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setStateBottomSheet(() {
                                          selectedIndex = 0;
                                        });
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 50 / 100,
                                        child: Center(
                                          child: Text(
                                            AppLanguage.eventsText[language],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: selectedIndex == 0
                                                  ? AppColor.secondryColor
                                                  : AppColor.secondryColor,
                                              fontSize: 15,
                                              fontFamily: AppFont.fontFamily,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setStateBottomSheet(() {
                                          selectedIndex = 1;
                                        });
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width * 50 / 100,
                                        child: Center(
                                          child: Text(
                                            AppLanguage.venuesText[language],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: selectedIndex == 1
                                                  ? AppColor.greyLightColor
                                                  : AppColor.secondryColor,
                                              fontSize: 15,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setStateBottomSheet(() {
                                        selectedIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.44,
                                      height: MediaQuery.of(context).size.height * 0.003,
                                      color: selectedIndex == 0
                                          ? AppColor.secondryColor
                                          : AppColor.secondryColor,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setStateBottomSheet(() {
                                        selectedIndex = 1;
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.36,
                                      height: MediaQuery.of(context).size.height * 0.003,
                                      color: selectedIndex == 1
                                          ? AppColor.greyLightColor
                                          : AppColor.secondryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.height * 2 / 100),
                            SizedBox(height: size.height * 1 / 100),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    ...List.generate(chats.length, (index) {
                                      final chat = chats[index];
                                      final isSend = chats[index]['isSend'] == true;
                                      
                                      return Wrap(
                                        children: [
                                          Container(
                                            width: size.width * 90 / 100,
                                            height: size.height * 8.5 / 100,
                                            child: ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: Container(
                                                height: size.height * 10 / 100,
                                                width: size.width * 13 / 100,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                    image: AssetImage(chat['image'] ?? ''),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                chat['name'] ?? '',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                  color: AppColor.secondryColor,
                                                ),
                                              ),
                                              subtitle: Text(
                                                chat['lastMessage'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColor.secondryColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: GestureDetector(
                                                onTap: () {
                                                  setStateBottomSheet(() {
                                                    chats[index]['isSend'] = true;
                                                  });

                                                  Future.delayed(
                                                    const Duration(milliseconds: 200), 
                                                    () {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                          type: PageTransitionType.bottomToTop,
                                                          child: ChatMessageScreen(
                                                            name: chats[index]['name'] ?? '',
                                                            image: chats[index]['image'] ?? '',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 8
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isSend
                                                        ? AppColor.logoutContainerColor
                                                        : AppColor.secondryColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: isSend
                                                        ? Border.all(
                                                            color: AppColor.buttonColor,
                                                            width: 1
                                                          )
                                                        : null,
                                                  ),
                                                  child: Text(
                                                    isSend
                                                        ? (chats[index]['message1']?.toString() ?? 'Send')
                                                        : (chats[index]['message']?.toString() ?? 'Send'),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: AppFont.fontFamily,
                                                      color: isSend
                                                          ? AppColor.secondryColor
                                                          : AppColor.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (index < chats.length - 0)
                                            if (index < chats.length - 0)
                                              SizedBox(height: size.height * 0.1 / 100),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
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
  );
}


}
