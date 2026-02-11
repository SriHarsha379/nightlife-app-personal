import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../helper/ImagePreviewScreen.dart';
import '../../../../utilities/app_footer.dart';
import '../../chats/chat_message_screen.dart';

class LikedMemberDetail extends StatefulWidget {
  static const String routeName = '/LikedMemberDetail';
  const LikedMemberDetail({super.key});

  @override
  State<LikedMemberDetail> createState() => _LikedMemberDetailState();
}

class _LikedMemberDetailState extends State<LikedMemberDetail> {
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

  List Interest = [
    {'id': 1, 'title': 'Music'},
    {'id': 2, 'title': 'Photography'},
    {'id': 3, 'title': 'Social Mixers'},
    {'id': 4, 'title': 'Open Mic'},
    {'id': 5, 'title': 'Comedy Shows'},
  ];

  final List<Map<String, dynamic>> chatUsers = [
    {
      "name": "Priya",
      "username": "@priya",
      "image": "assets/icons/ProfilePhoto.png"
    },
    {
      "name": "Neha",
      "username": "@neha",
      "image": "assets/icons/aadityaIcon.png"
    },
    {
      "name": "Preet",
      "username": "@preet",
      "image": "assets/icons/galleryIcon.png"
    },
    {
      "name": "Rohan",
      "username": "@rohan",
      "image": "assets/icons/girlImage.png"
    },
    {
      "name": "Golu",
      "username": "@golu",
      "image": "assets/icons/userprofile.png"
    },
  ];

  List chats = [
    {
      'id': 1,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Brew&Bloom',
      'lastMessage': '@Brew&BloomCafé',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Techno',
      'lastMessage': '@Techno',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/eventstory3.png',
      'name': 'SUNBURN',
      'lastMessage': '@Sunburn',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/eventstory1.jpg',
      'name': 'Mitro',
      'lastMessage': '@Mitro',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Razberry',
      'lastMessage': '@Razberry',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/eventstory3.png',
      'name': 'CCD',
      'lastMessage': '@CCD',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
  ];

  int selectedId = 1;
  List pics = [
    "assets/icons/gauravpic.png",
    "assets/icons/gauravpic2.png",
    "assets/icons/gauravpic3.png",
  ];

  List shareIcons = [
    "assets/icons/shareIcon.png",
    "assets/icons/whatsappIcon.png",
    "assets/icons/instaIcon.png",
    "assets/icons/snapIcon.png",
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
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
              color:
                  AppColor.sendinvitecontainercolor(context).withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
            ),
            width: size.width * 85 / 100,
            height: size.height * 7 / 100,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                children: [
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
                        color: AppColor.secondryColor(context),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppColor.secondryColor(context),
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
                            color: AppColor.secondryColor(
                                context), // optional tint color
                          ),
                          Text(
                            AppLanguage.likeText[language],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            color: AppColor.primaryColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 4 / 100),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: size.width * 100 / 100,
                        child: Column(
                          children: [
                            SizedBox(
                              height: size.height * 2 / 100,
                            ),
                            Stack(children: [
                              Container(
                                width: double.infinity,
                                height: 450,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      height: size.height,
                                      width: size.width,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: pics.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: size.width,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                pics[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    /// BOTTOM IMAGE (overlay image)
                                    Stack(
                                      children: [
                                        /// 🔹 Main description image (your bottom image)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Image.asset(
                                            "assets/icons/gauravkapoordesciption.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            height: 1, // shadow height
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white,
                                                  blurRadius: 2,

                                                  spreadRadius:
                                                      0.6, // how wide shadow spreads
                                                  offset: Offset(1,
                                                      1), // pushes shadow downward
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                                    color: AppColor.primaryColor(context),
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
                                          children: [],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5 /
                                                  100,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.basicdetailstext[language],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 1 / 100,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          AppLanguage.ageText[language],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.buttonColor),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1 /
                                                100,
                                      ),
                                      Text(
                                        AppLanguage.agefiftytwo[language],
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.secondryColor(
                                                context)),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1 /
                                                100,
                                      ),
                                      Container(
                                        child: Text(
                                          AppLanguage.Heighttext[language],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.buttonColor),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1 /
                                                100,
                                      ),
                                      Text(
                                        AppLanguage.heightSize[language],
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.secondryColor(
                                                context)),
                                      ),
                                      Container(
                                        child: Text(
                                          AppLanguage.pronouncsText[language],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.buttonColor),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1 /
                                                100,
                                      ),
                                      Text(
                                        AppLanguage.hehimText[language],
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.secondryColor(
                                                context)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 1 / 100,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        child: Text(
                                          AppLanguage.Hobbiestext[language],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.buttonColor),
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                2 /
                                                100,
                                      ),
                                      Text(
                                        AppLanguage
                                            .workingPaintingText[language],
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.greyLightColor),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 1 / 100,
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
                                                1 /
                                                100,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            AppLanguage
                                                .koregaonParkText[language],
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w400,
                                                color: AppColor.greyLightColor),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 4 / 100,
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.bioText[language],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 1 / 100,
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.bioStatementtext[language],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          color: AppColor.greyLightColor),
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
                                          AppLanguage.GalleryText[language],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor(
                                                  context)),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              type: PageTransitionType.fade,
                                              child: ImagePreviewScreen(
                                                images: [
                                                  AppImage.gellery1,
                                                  AppImage.gellery2,
                                                  AppImage.gellery3,
                                                  AppImage.gellery4,
                                                ],
                                                initialIndex: 0,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          AppLanguage.viewAlltext[language],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color: AppColor.pinkColor,
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
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType.fade,
                                                child: const ImagePreviewScreen(
                                                  images: [
                                                    AppImage.gellery1,
                                                    AppImage.gellery2,
                                                    AppImage.gellery3,
                                                    AppImage.gellery4,
                                                  ],
                                                  initialIndex: 0,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: size.width * 30 / 100,
                                            height: size.height * 20 / 100,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.asset(
                                                AppImage.arjunGalleryIcon1,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType.fade,
                                                child: ImagePreviewScreen(
                                                  images: [
                                                    AppImage.gellery1,
                                                    AppImage.gellery2,
                                                    AppImage.gellery3,
                                                    AppImage.gellery4,
                                                  ],
                                                  initialIndex: 0,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: size.width * 30 / 100,
                                            height: size.height * 20 / 100,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.asset(
                                                AppImage.arjunGalleryIcon2,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType.fade,
                                                child: ImagePreviewScreen(
                                                  images: [
                                                    AppImage.gellery1,
                                                    AppImage.gellery2,
                                                    AppImage.gellery3,
                                                    AppImage.gellery4,
                                                  ],
                                                  initialIndex: 0,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: size.width * 30 / 100,
                                            height: size.height * 20 / 100,
                                            margin:
                                                const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Image.asset(
                                                AppImage.arjunGalleryIcon3,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.interestText[language],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        1 /
                                        100,
                                  ),
                                  Wrap(
                                    spacing:
                                        7, // horizontal space between items
                                    runSpacing:
                                        10, // vertical space between rows
                                    children: List.generate(
                                      Interest.length,
                                      (index) {
                                        bool isAll = Interest[index]['id'] == 1;

                                        return GestureDetector(
                                          onTap: isAll
                                              ? null
                                              : () {
                                                  setState(() {
                                                    selectedId =
                                                        Interest[index]['id'];
                                                  });
                                                },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: selectedId ==
                                                      Interest[index]['id']
                                                  ? AppColor.primaryColor(
                                                      context)
                                                  : AppColor.primaryColor(
                                                      context),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                color: selectedId ==
                                                        Interest[index]['id']
                                                    ? AppColor.buttonColor
                                                    : AppColor.buttonColor,
                                              ),
                                            ),
                                            child: Text(
                                              Interest[index]['title'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: selectedId ==
                                                        Interest[index]['id']
                                                    ? AppColor.buttonColor
                                                    : AppColor.buttonColor,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
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
                                          AppLanguage.vibeCheck[language],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor(
                                                  context)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Container(
                                    width: size.width * 80 / 100,
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: Image.asset(
                                          AppImage.viewCheckicon,
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                  SizedBox(
                                    height: size.height * 3 / 100,
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.width *
                                        12 /
                                        100,
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    decoration: BoxDecoration(
                                      color: AppColor.capsuleColor(context),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.grayColor
                                              .withOpacity(0.4),
                                          blurRadius: 2,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(200),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                4 /
                                                100),

                                        // Icon
                                        Image.asset(
                                          AppImage.instagramIcon,
                                          color:
                                              AppColor.secondryColor(context),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              5 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              6 /
                                              100,
                                        ),

                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                2 /
                                                100),

                                        // Text + spacing
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLanguage
                                                    .instagramText[language],
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.secondryColor(
                                                      context),
                                                ),
                                              ),
                                              Text(
                                                AppLanguage.kapoorg[language],
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.buttonColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1 /
                                                  100,
                                              horizontal: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  5 /
                                                  100),
                                          decoration: BoxDecoration(
                                            color: AppColor.buttonColor,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                color:
                                                    AppColor.transparentColor),
                                          ),
                                          child: Text(
                                            AppLanguage.followText[language],
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                6 /
                                                100),
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
                                          AppLanguage.recentlyLikedeventsText[
                                              language],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor(
                                                  context)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: LikedEventDetail(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: size.width * 50 / 100,
                                            height: size.height * 33 / 100,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Stack(
                                                children: [
                                                  /// BACKGROUND IMAGE
                                                  Positioned.fill(
                                                    child: Image.asset(
                                                      AppImage.eventCardImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),

                                                  /// DARK GRADIENT OVERLAY
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.25),
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.7),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  /// TOP CHIPS (Techno / Whiskey)
                                                  Positioned(
                                                    top: 12,
                                                    left: 12,
                                                    child: Row(
                                                      children: [
                                                        _eventChip("Techno"),
                                                        SizedBox(
                                                            width: size.width *
                                                                2 /
                                                                100),
                                                        _eventChip("Whiskey"),
                                                      ],
                                                    ),
                                                  ),

                                                  /// BOTTOM TEXT
                                                  Positioned(
                                                    left: 14,
                                                    right: 14,
                                                    bottom: 16,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Bass Drop Fridays",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Row(
                                                          children: const [
                                                            Icon(
                                                                Icons
                                                                    .access_time,
                                                                size: 14,
                                                                color: Colors
                                                                    .pinkAccent),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              "Fri, 10 PM – 4 AM",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .pinkAccent,
                                                                fontSize: 12,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                          ),
                                          Container(
                                            width: size.width * 50 / 100,
                                            height: size.height * 33 / 100,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Stack(
                                                children: [
                                                  /// BACKGROUND IMAGE
                                                  Positioned.fill(
                                                    child: Image.asset(
                                                      AppImage.eventCardImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),

                                                  /// DARK GRADIENT OVERLAY
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.25),
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.7),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  /// TOP CHIPS (Techno / Whiskey)
                                                  Positioned(
                                                    top: 12,
                                                    left: 12,
                                                    child: Row(
                                                      children: [
                                                        _eventChip("Techno"),
                                                        SizedBox(
                                                            width: size.width *
                                                                2 /
                                                                100),
                                                        _eventChip("Whiskey"),
                                                      ],
                                                    ),
                                                  ),

                                                  /// BOTTOM TEXT
                                                  Positioned(
                                                    left: 14,
                                                    right: 14,
                                                    bottom: 16,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Bass Drop Fridays",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Row(
                                                          children: const [
                                                            Icon(
                                                                Icons
                                                                    .access_time,
                                                                size: 14,
                                                                color: Colors
                                                                    .pinkAccent),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              "Fri, 10 PM – 4 AM",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .pinkAccent,
                                                                fontSize: 12,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                          ),
                                          Container(
                                            width: size.width * 50 / 100,
                                            height: size.height * 33 / 100,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Stack(
                                                children: [
                                                  /// BACKGROUND IMAGE
                                                  Positioned.fill(
                                                    child: Image.asset(
                                                      AppImage.eventCardImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),

                                                  /// DARK GRADIENT OVERLAY
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.25),
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.7),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  /// TOP CHIPS (Techno / Whiskey)
                                                  Positioned(
                                                    top: 12,
                                                    left: 12,
                                                    child: Row(
                                                      children: [
                                                        _eventChip("Techno"),
                                                        SizedBox(
                                                            width: size.width *
                                                                2 /
                                                                100),
                                                        _eventChip("Whiskey"),
                                                      ],
                                                    ),
                                                  ),

                                                  /// BOTTOM TEXT
                                                  Positioned(
                                                    left: 14,
                                                    right: 14,
                                                    bottom: 16,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Bass Drop Fridays",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Row(
                                                          children: const [
                                                            Icon(
                                                                Icons
                                                                    .access_time,
                                                                size: 14,
                                                                color: Colors
                                                                    .pinkAccent),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              "Fri, 10 PM – 4 AM",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .pinkAccent,
                                                                fontSize: 12,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                          ),
                                          Container(
                                            width: size.width * 50 / 100,
                                            height: size.height * 33 / 100,
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: Stack(
                                                children: [
                                                  /// BACKGROUND IMAGE
                                                  Positioned.fill(
                                                    child: Image.asset(
                                                      AppImage.eventCardImage,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),

                                                  /// DARK GRADIENT OVERLAY
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.25),
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.7),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  /// TOP CHIPS (Techno / Whiskey)
                                                  Positioned(
                                                    top: 12,
                                                    left: 12,
                                                    child: Row(
                                                      children: [
                                                        _eventChip("Techno"),
                                                        SizedBox(
                                                            width: size.width *
                                                                2 /
                                                                100),
                                                        _eventChip("Whiskey"),
                                                      ],
                                                    ),
                                                  ),

                                                  /// BOTTOM TEXT
                                                  Positioned(
                                                    left: 14,
                                                    right: 14,
                                                    bottom: 16,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Bass Drop Fridays",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Row(
                                                          children: const [
                                                            Icon(
                                                                Icons
                                                                    .access_time,
                                                                size: 14,
                                                                color: Colors
                                                                    .pinkAccent),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              "Fri, 10 PM – 4 AM",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .pinkAccent,
                                                                fontSize: 12,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 3 / 100,
                                  ),
                                  SizedBox(
                                    width: size.width * 80 / 100,
                                    child: Text(
                                      AppLanguage.followedVenuestext[language],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Container(
                                    width: size.width * 92 / 100,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _venueCard(AppImage.night),
                                        _venueCard(AppImage.omnia),
                                        _venueCard(AppImage.queens),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage
                                          .mytopArtistonspotifyText[language],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: size.width * 0.28,
                                        height: size.height * 0.045,
                                        decoration: BoxDecoration(
                                          color: AppColor.darkGreyColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// PERFECT PINK CIRCLE
                                            Container(
                                              width: size.width * 0.089,
                                              height: size.width * 0.089,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFF2DA1),
                                                shape: BoxShape.circle,
                                              ),
                                            ),

                                            SizedBox(width: size.width * 0.03),

                                            /// TEXT
                                            const Text(
                                              "DMX", // image ke according
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: size.width * 2 / 100,
                                      ),
                                      Container(
                                        width: size.width * 0.38,
                                        height: size.height * 0.045,
                                        decoration: BoxDecoration(
                                          color: AppColor.darkGreyColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            /// PERFECT PINK CIRCLE
                                            Container(
                                              width: size.width * 0.089,
                                              height: size.width * 0.089,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFF2DA1),
                                                shape: BoxShape.circle,
                                              ),
                                            ),

                                            SizedBox(width: size.width * 0.03),

                                            /// TEXT
                                            Text(
                                              "Ben Böhmer", // image ke according
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 1.5 / 100,
                                  ),
                                  Container(
                                    width: size.width * 0.38,
                                    height: size.height * 0.045,
                                    decoration: BoxDecoration(
                                      color: AppColor.darkGreyColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        /// PERFECT PINK CIRCLE
                                        Container(
                                          width: size.width * 0.089,
                                          height: size.width * 0.089,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF2DA1),
                                            shape: BoxShape.circle,
                                          ),
                                        ),

                                        SizedBox(width: size.width * 0.03),

                                        /// TEXT
                                        Text(
                                          "Martin Garrix", // image ke according
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 4 / 100,
                                  ),
                                  Divider(
                                    height: 0.2,
                                    thickness: 0.5,
                                    color: AppColor.greyLightColor,
                                    indent: 70,
                                    endIndent: 70,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: size.height * 15 / 100,
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

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * size.height * 0.3),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
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
                              gradient:
                                  AppColor.backgroundGradientcolor(context),
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

                                /// -------- DRAG INDICATOR --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 0.8 + (0.2 * value),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    AppImage.dashIcon,
                                    height: size.height * 0.5 / 100,
                                    width: size.width * 28 / 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),

                                /// -------- TABS (EVENTS & VENUES) --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -20 * (1 - value)),
                                      child: Opacity(
                                        opacity: value.clamp(0.0, 1.0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: AppColor.transparentColor,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        8 /
                                        100,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 5 / 100,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// -------- EVENTS TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 0;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 0
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 0
                                                      ? AppColor.secondryColor(
                                                          context)
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 0
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .eventsText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// -------- VENUES TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 1;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 1
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 1
                                                      ? AppColor.secondryColor(
                                                          context)
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 1
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .venuesText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// -------- TAB INDICATOR (FULL WIDTH) --------
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: 2,
                                  child: Stack(
                                    children: [
                                      // Background line (full width)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 2,
                                        color: AppColor.greyLightColor
                                            .withOpacity(0.3),
                                      ),
                                      // Animated indicator
                                      AnimatedAlign(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        alignment: selectedIndex == 0
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color:
                                                AppColor.secondryColor(context),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColor.secondryColor(
                                                        context)
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),
                                SizedBox(height: size.height * 1 / 100),

                                /// -------- CONTACTS LIST --------
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.1, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: SingleChildScrollView(
                                      key: ValueKey<int>(selectedIndex),
                                      child: Column(
                                        children: [
                                          ...List.generate(
                                            selectedIndex == 0
                                                ? chats.length
                                                : chats.length,
                                            (index) {
                                              final chat = selectedIndex == 0
                                                  ? chats[index]
                                                  : chats[index];
                                              final isSend = selectedIndex == 0
                                                  ? (chats[index]['isSend'] ==
                                                      true)
                                                  : (chats[index]['isSend'] ==
                                                      true);

                                              return TweenAnimationBuilder<
                                                  double>(
                                                tween:
                                                    Tween(begin: 0.0, end: 1.0),
                                                duration: Duration(
                                                    milliseconds:
                                                        300 + (index * 50)),
                                                curve: Curves.easeOutBack,
                                                builder:
                                                    (context, value, child) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                        30 * (1 - value), 0),
                                                    child: Opacity(
                                                      opacity:
                                                          value.clamp(0.0, 1.0),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: Wrap(
                                                  children: [
                                                    Container(
                                                      width:
                                                          size.width * 90 / 100,
                                                      height: size.height *
                                                          8.5 /
                                                          100,
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        leading: Container(
                                                          height: size.height *
                                                              10 /
                                                              100,
                                                          width: size.width *
                                                              13 /
                                                              100,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  chat['image'] ??
                                                                      ''),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        title: Row(
                                                          children: [
                                                            Text(
                                                              chat['name'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    size.width *
                                                                        2 /
                                                                        100),
                                                            // Bordered label for Event/Venue
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    size.width *
                                                                        2 /
                                                                        100,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppColor
                                                                      .pinkColor,
                                                                  width: .3,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Text(
                                                                selectedIndex ==
                                                                        0
                                                                    ? AppLanguage
                                                                            .eventsText[
                                                                        language]
                                                                    : AppLanguage
                                                                            .venuesText[
                                                                        language],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 8,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  color: AppColor
                                                                      .secondryColor(
                                                                          context),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        subtitle: Text(
                                                          chat['lastMessage'] ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        trailing:
                                                            GestureDetector(
                                                          onTap: () {
                                                            setStateBottomSheet(
                                                                () {
                                                              if (selectedIndex ==
                                                                  0) {
                                                                chats[index][
                                                                        'isSend'] =
                                                                    true;
                                                              } else {
                                                                chats[index][
                                                                        'isSend'] =
                                                                    true;
                                                              }
                                                            });

                                                            Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                              () {
                                                                Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                    type: PageTransitionType
                                                                        .bottomToTop,
                                                                    child:
                                                                        ChatMessageScreen(
                                                                      name: chat[
                                                                              'name'] ??
                                                                          '',
                                                                      image:
                                                                          chat['image'] ??
                                                                              '',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        17,
                                                                    vertical:
                                                                        7),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSend
                                                                  ? AppColor
                                                                      .logoutContainerColor(
                                                                          context)
                                                                  : AppColor
                                                                      .secondryColor(
                                                                          context),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
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
                                                                  ? (chat['message1']
                                                                          ?.toString() ??
                                                                      'Send')
                                                                  : (chat['message']
                                                                          ?.toString() ??
                                                                      'Send'),
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                color: isSend
                                                                    ? AppColor
                                                                        .secondryColor(
                                                                            context)
                                                                    : AppColor
                                                                        .primaryColor(
                                                                            context),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (index <
                                                        (selectedIndex == 0
                                                                ? chats.length
                                                                : chats
                                                                    .length) -
                                                            1)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.1 /
                                                              100),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
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
            ),
          );
        });
      },
    );
  }

  void showUserPopup(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: size.width * 0.75,
            height: size.height * 0.50,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColor.popupColor(context),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    )
                  ],
                ),
                const SizedBox(
                    height: 8), // Added small spacing after close button
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero, // Remove default ListView padding
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final chat = chatUsers[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6), // Adjusted spacing between items
                        child: Row(
                          children: [
                            Container(
                              height: size.height * 0.07,
                              width: size.width * 0.13,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(chat['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(chat['name'],
                                    style: TextStyle(color: Colors.white)),
                                Text(
                                  chat['username'],
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6)),
                                ),
                              ],
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 28,
                              width: 60,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Edit",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim, child: child),
        );
      },
    );
  }

  Widget _eventChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.eventSmallCardBorder, width: 1),
        color: AppColor.cardFillColor,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _venueCard(String imagePath) {
    final size = MediaQuery.of(context).size;
    final double cardWidth = 105 * size.width / 375;
    final double cardHeight = 105 * size.width / 375;
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColor.cardFillColor,
            blurRadius: 12,
            spreadRadius: 0.1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
