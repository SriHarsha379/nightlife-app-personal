import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails8_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../../utilities/app_footer.dart';
import '../../../../../utilities/app_image_media_viewer.dart';
import '../../../chats/chat_message_screen.dart';
import 'view_all_image.dart';

class LikedEventDetail extends StatefulWidget {
  static const String routeName = '/LikedEventDetail';
  const LikedEventDetail({super.key});

  @override
  State<LikedEventDetail> createState() => _LikedEventDetailState();
}

class _LikedEventDetailState extends State<LikedEventDetail> {
  int selectedIndex = 0;
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
  List<dynamic> galleryImagesList = [
    {
      "media_type": 1,
      "workshop_media": AppImage.gallImg1,
    },
    {
      "media_type": 1,
      "workshop_media": AppImage.gallImg2,
    },
    {
      "media_type": 1,
      "workshop_media": AppImage.gallImg3,
    },
    {
      "media_type": 1,
      "workshop_media": AppImage.gallImg4,
    },
    {
      "media_type": 1,
      "workshop_media": AppImage.eventImage1,
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

  List chats = [
    {
      'id': 1,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Brew&Bloom',
      'lastMessage': '@Brew&BloomCafé',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Techno',
      'lastMessage': '@Techno',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/eventstory3.png',
      'name': 'SUNBURN',
      'lastMessage': '@Sunburn',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/eventstory1.jpg',
      'name': 'Mitro',
      'lastMessage': '@Mitro',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Razberry',
      'lastMessage': '@Razberry',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/eventstory3.png',
      'name': 'CCD',
      'lastMessage': '@CCD',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
  ];

  List chatsLists = [
    {
      'id': 1,
      'image': 'assets/icons/ProfilePhoto.png',
      'name': 'Gaurav Kapoor',
      'lastMessage': '@gkapoor02',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/riya.png',
      'name': 'Riya',
      'lastMessage': '@riya00',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Café',
      'lastMessage': '@cafebloom34',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/aadityaIcon.png',
      'name': 'Aaditya',
      'lastMessage': '@aadi54',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/rushi.png',
      'name': 'Rushi',
      'lastMessage': '@rushi87',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 6,
      'image': AppImage.soham,
      'name': 'soham',
      'lastMessage': '@soham23',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
  ];

  final List<String> shareIcons = [
    AppImage.shareIcon,
    AppImage.whatsappIcon,
    AppImage.instaIcon,
    AppImage.snapIcon,
  ];

  void showMediaViewerBottomSheet({
    required BuildContext context,
    required List<dynamic> mediaList,
    required int initialIndex,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent.withOpacity(0.4),
      barrierColor: Colors.transparent.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.98,
          child: MediaViewerBottomSheet(
            mediaList: mediaList,
            initialIndex: initialIndex,
          ),
        );
      },
    );
  }

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
          floatingActionButton: Container(
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
                        type: PageTransitionType.leftToRightWithFade,
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
                    eventstypebottomsheet(context);
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
          body: Container(
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            color: AppColor.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 3 / 100),
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
                                      AppImage.eventimg,
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
                                      color: AppColor.secondryColor,
                                      fit: BoxFit.cover,
                                      height: size.width * 5 / 100,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                                  .BassDropFridaytext[language],
                                              style: const TextStyle(
                                                  fontSize: 24,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w700,
                                                  color:
                                                      AppColor.secondryColor),
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
                                                          .technoText[language],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .secondryColor),
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
                                                      AppLanguage.wishkeyText[
                                                          language],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .secondryColor),
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
                                                          .EDMText[language],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: AppColor
                                                              .secondryColor),
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
                                        AppLanguage.datydateText[language],
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.secondryColor),
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
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.secondryColor),
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
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColor.secondryColor),
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          AppLanguage.GalleryText[language],
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.secondryColor),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // showMediaViewerBottomSheet(
                                          //     context: context,
                                          //     mediaList: galleryImagesList,
                                          //     initialIndex: 0);
                                          _openGalleryBottomSheet(context);
                                        },
                                        child: Container(
                                          child: Text(
                                            AppLanguage.viewAlltext[language],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.pinkColor),
                                          ),
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
                                              AppImage.eventimg,
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
                                              AppImage.eventimg,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 4 / 100,
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.aboutText[language],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.secondryColor),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 1 / 100,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: AppLanguage
                                              .getReadystatement[language],
                                          style: const TextStyle(
                                            fontSize: 16.5,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.textcolor,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              "\nmidnight. Dance till the sun comes up with the best techno and EDM DJs...",
                                          style: const TextStyle(
                                            fontSize: 16.5,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.textcolor,
                                          ),
                                        ),
                                        TextSpan(
                                          text: " Read More",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor
                                                .pinkColor, // ✅ Pink color
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          AppLanguage.LineupText[language],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          AppLanguage.viewAlltext[language],
                                          style: const TextStyle(
                                              fontSize: 14,
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
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(
                                            storyImages.length, (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.25),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                      child: Image.asset(
                                                        storyImages[index]
                                                                ["image"] ??
                                                            "no image",
                                                        fit: BoxFit.cover,
                                                      ),
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
                                                Text(
                                                  storyImages[index]["name"] ??
                                                      "No Name",
                                                  style: const TextStyle(
                                                    color:
                                                        AppColor.secondryColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                SizedBox(
                                                    // height: MediaQuery.of(context).size.height * 0.2/100,
                                                    ),
                                                Text(
                                                  storyImages[index]
                                                          ["subname"] ??
                                                      "No Name",
                                                  style: const TextStyle(
                                                    color:
                                                        AppColor.secondryColor,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 3 / 100,
                                  ),
                                  SizedBox(
                                    width: size.width * 88 / 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                    height: size.height * 3 / 100,
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
                                                  SizedBox(
                                                    width:
                                                        size.width * 15 / 100,
                                                    child: Text(
                                                      AppLanguage
                                                          .fromText[language],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: AppColor
                                                              .secondryColor),
                                                    ),
                                                  ),
                                                  Text(
                                                    AppLanguage.ruppesruppeText[
                                                        language],
                                                    style: const TextStyle(
                                                        fontSize: 24,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColor
                                                            .secondryColor),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: ((context) =>
                                                              BookEvent())));
                                                },
                                                child: Container(
                                                  width: size.width * 45 / 100,
                                                  decoration: BoxDecoration(
                                                      color: AppColor
                                                          .secondryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40)),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal:
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                3 /
                                                                100,
                                                        vertical: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            1.8 /
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
                                            vertical: 4,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              AppLanguage
                                                  .secureYourspotText[language],
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w400,
                                                  color:
                                                      AppColor.secondryColor),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        4 /
                                        100,
                                  ),
                                  Center(
                                    child: Container(
                                      width: 180, // adjust size as needed
                                      height: 1,
                                      color: AppColor.lightgreyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.height * 12 / 100,
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

  void eventstypebottomsheet(BuildContext context) {
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
                              Center(
                                child: SizedBox(
                                  width: size.width * 90 / 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: List.generate(shareIcons.length,
                                        (index) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 3 / 100,
                                            vertical: size.height * 2 / 100),
                                        child: Image.asset(
                                          shareIcons[index],
                                          width: size.width * 14 / 100,
                                          height: size.width * 14 / 100,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 0.2,
                                thickness: 0.5,
                                color: AppColor.secondryColor,
                                indent: 28,
                                endIndent: 28,
                              ),
                              SizedBox(height: size.height * 2 / 100),
                              SizedBox(height: size.height * 1 / 100),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...List.generate(chats.length, (index) {
                                        final chat = chatsLists[index];
                                        final isSend =
                                            chats[index]['isSend'] == true;

                                        return Wrap(
                                          children: [
                                            Container(
                                              width: size.width * 90 / 100,
                                              height: size.height * 8.5 / 100,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Container(
                                                  height:
                                                      size.height * 10 / 100,
                                                  width: size.width * 13 / 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          chat['image'] ?? ''),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  chat['name'] ?? '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color:
                                                        AppColor.secondryColor,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  chat['lastMessage'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColor.secondryColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: () {
                                                    setStateBottomSheet(() {
                                                      chats[index]['isSend'] =
                                                          true;
                                                    });

                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 200),
                                                        () {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .bottomToTop,
                                                          child:
                                                              ChatMessageScreen(
                                                            name: chats[index]
                                                                    ['name'] ??
                                                                '',
                                                            image: chats[index]
                                                                    ['image'] ??
                                                                '',
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: isSend
                                                          ? AppColor
                                                              .logoutContainerColor
                                                          : AppColor
                                                              .secondryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: isSend
                                                          ? Border.all(
                                                              color: AppColor
                                                                  .buttonColor,
                                                              width: 1)
                                                          : null,
                                                    ),
                                                    child: Text(
                                                      isSend
                                                          ? (chats[index][
                                                                      'message1']
                                                                  ?.toString() ??
                                                              'Send')
                                                          : (chats[index][
                                                                      'message']
                                                                  ?.toString() ??
                                                              'Send'),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        color: isSend
                                                            ? AppColor
                                                                .secondryColor
                                                            : AppColor
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (index < chats.length - 0)
                                              if (index < chats.length - 0)
                                                SizedBox(
                                                    height: size.height *
                                                        0.1 /
                                                        100),
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
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: BookEvent(),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
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

  void _openGalleryBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    PageController pageController = PageController();
    int currentPage = 0;

    List<String> galleryImages = [
      AppImage.gallImg1,
      AppImage.gallImg2,
      AppImage.gallImg3,
      // AppImage.gallImg4,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: size.height * 0.8,
              decoration: BoxDecoration(
                color: AppColor.transparentColor.withOpacity(.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  /// -------- TITLE & CLOSE BUTTON --------
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColor.secondryColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),

                  /// -------- MAIN IMAGE WITH ARROWS --------
                  Container(
                    height: size.height * 0.35,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: pageController,
                          itemCount: galleryImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 3 / 100),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  galleryImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),

                        /// -------- LEFT ARROW --------
                        if (currentPage > 0)
                          Positioned(
                            left: size.width * 5 / 100,
                            top: size.height * 0.20,
                            child: GestureDetector(
                              onTap: () {
                                pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                        /// -------- RIGHT ARROW --------
                        if (currentPage < galleryImages.length - 1)
                          Positioned(
                            right: size.width * 5 / 100,
                            top: size.height * 0.20,
                            child: GestureDetector(
                              onTap: () {
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),

                  /// -------- GALLERY TEXT --------

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 5 / 100),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: galleryImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage = index;
                              });
                              pageController.animateToPage(
                                index,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: currentPage == index
                                      ? AppColor.pinkColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.asset(
                                  galleryImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
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
}
