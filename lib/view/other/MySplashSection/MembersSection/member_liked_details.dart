import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/utilities/widgets.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:page_transition/page_transition.dart';

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

  int selectedId = 1;

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
        body: SafeArea(
          child: Container(
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            color: AppColor.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Center(
                //   child:
                //    SizedBox(
                //     width: MediaQuery.of(context).size.width * 90 / 100,
                //     height: MediaQuery.of(context).size.height * 7 / 100,
                //     child: Row(
                //       // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         GestureDetector(
                //           onTap: () {
                //             Navigator.pop(context);
                //           },
                //           child: Container(
                //             height:
                //                 MediaQuery.of(context).size.height * 7 / 100,
                //             alignment: Alignment.center,
                //             child: Image.asset(
                //               AppImage.backarrow,
                //               fit: BoxFit.cover,
                //               color: AppColor.primaryColor,
                //               height:
                //                   MediaQuery.of(context).size.width * 5 / 100,
                //               width:
                //                   MediaQuery.of(context).size.width * 5 / 100,
                //             ),
                //           ),
                //         ),

                //       ],
                //     ),
                //   ),

                // ),
                // SizedBox(height: size.height * 2 / 100),

                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: Container(
                        width: size.width * 100 / 100,
                        child: Column(
                          children: [
                            Stack(children: [
                              Container(
                                width: size.width * 100 / 100,
                                height: size.height * 62 / 100,
                                child: ClipRRect(
                                  child: Image.asset(
                                    AppImage.gauravkapoor,
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
                                              AppLanguage.PeopleYoubothknowText[
                                                  language],
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColor.secondryColor),
                                            ),
                                            SizedBox(
                                              height: size.height * 1 / 100,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showUserPopup(context);
                                              },
                                              child: Container(
                                                width: size.width * 70 / 100,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(15),
                                                      topRight:
                                                          Radius.circular(15),
                                                    ),
                                                    child: Image.asset(
                                                      AppImage.grouplikesIcon,
                                                      fit: BoxFit.cover,
                                                    )),
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.height * 1 / 100,
                                            ),
                                            // Row(
                                            //   children: [
                                            //     Container(
                                            //       decoration: BoxDecoration(
                                            //           border: Border.all(
                                            //             width: 1,
                                            //             color:
                                            //                 AppColor.pinkColor,
                                            //           ),
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   20)),
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.symmetric(
                                            //           horizontal:
                                            //               size.width * 2 / 100,
                                            //           vertical: 1,
                                            //         ),
                                            //         child: Text(
                                            //           AppLanguage
                                            //               .technoText[language],
                                            //           style: const TextStyle(
                                            //               fontSize: 14,
                                            //               fontFamily: AppFont
                                            //                   .fontFamily,
                                            //               fontWeight:
                                            //                   FontWeight.normal,
                                            //               color: AppColor
                                            //                   .primaryColor),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //     SizedBox(
                                            //       width: size.width * 2 / 100,
                                            //     ),
                                            //     Container(
                                            //       decoration: BoxDecoration(
                                            //           border: Border.all(
                                            //             width: 1,
                                            //             color:
                                            //                 AppColor.pinkColor,
                                            //           ),
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   20)),
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.symmetric(
                                            //           horizontal:
                                            //               size.width * 2 / 100,
                                            //           vertical: 1,
                                            //         ),
                                            //         child: Text(
                                            //           AppLanguage.wishkeyText[
                                            //               language],
                                            //           style: const TextStyle(
                                            //               fontSize: 14,
                                            //               fontFamily: AppFont
                                            //                   .fontFamily,
                                            //               fontWeight:
                                            //                   FontWeight.normal,
                                            //               color: AppColor
                                            //                   .primaryColor),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //     SizedBox(
                                            //       width: size.width * 2 / 100,
                                            //     ),
                                            //     Container(
                                            //       decoration: BoxDecoration(
                                            //           border: Border.all(
                                            //             width: 1,
                                            //             color:
                                            //                 AppColor.pinkColor,
                                            //           ),
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   20)),
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.symmetric(
                                            //           horizontal:
                                            //               size.width * 2 / 100,
                                            //           vertical: 1,
                                            //         ),
                                            //         child: Text(
                                            //           AppLanguage
                                            //               .EDMText[language],
                                            //           style: const TextStyle(
                                            //               fontSize: 14,
                                            //               fontFamily: AppFont
                                            //                   .fontFamily,
                                            //               fontWeight:
                                            //                   FontWeight.normal,
                                            //               color: AppColor
                                            //                   .primaryColor),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
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
                                            // Container(
                                            //   child: Text(
                                            //     AppLanguage
                                            //         .like17Text[language],
                                            //     style: TextStyle(
                                            //       fontSize: 14,
                                            //     ),
                                            //   ),
                                            // )
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
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.secondryColor),
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
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.secondryColor),
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
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.secondryColor),
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
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: AppColor.secondryColor),
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
                                          children: [
                                            // Container(
                                            //   child: Text(
                                            //     AppLanguage.dummylocationText[
                                            //         language],
                                            //     style: const TextStyle(
                                            //         fontSize: 15,
                                            //         fontFamily:
                                            //             AppFont.fontFamily,
                                            //         fontWeight: FontWeight.w500,
                                            //         color:
                                            //             AppColor.primaryColor),
                                            //   ),
                                            // ),
                                          ],
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
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.secondryColor),
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
                                  Container(
                                    child: Text(
                                      AppLanguage.interestText[language],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: AppColor.secondryColor),
                                    ),
                                  ),

                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        1 /
                                        100,
                                  ),
                                  Wrap(
                                    spacing:
                                        6, // horizontal space between items
                                    runSpacing:
                                        8, // vertical space between rows
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
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: selectedId ==
                                                      Interest[index]['id']
                                                  ? AppColor.primaryColor
                                                  : AppColor.primaryColor,
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
                                                fontSize: 14,
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
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor),
                                        ),
                                      ),
                                      // Container(
                                      //   child: Text(
                                      //     AppLanguage.viewAlltext[language],
                                      //     style: const TextStyle(
                                      //         fontSize: 16,
                                      //         fontFamily: AppFont.fontFamily,
                                      //         fontWeight: FontWeight.w500,
                                      //         color: AppColor.pinkColor),
                                      //   ),
                                      // ),
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
                                    height: size.height * 2 / 100,
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
                                      // Container(
                                      //   child: Text(
                                      //     AppLanguage.viewAlltext[language],
                                      //     style: const TextStyle(
                                      //         fontSize: 16,
                                      //         fontFamily: AppFont.fontFamily,
                                      //         fontWeight: FontWeight.w500,
                                      //         color: AppColor.pinkColor),
                                      //   ),
                                      // ),
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
                                          width: size.width * 30 / 100,
                                          height: size.height * 20 / 100,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              AppImage.arjunGalleryIcon1,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: size.width * 30 / 100,
                                          height: size.height * 20 / 100,
                                          margin:
                                              const EdgeInsets.only(right: 10),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.asset(
                                              AppImage.arjunGalleryIcon2,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Container(
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
                                      ],
                                    ),
                                  ),

                                  // SizedBox(
                                  //   width: MediaQuery.of(context).size.width,
                                  //   child: SingleChildScrollView(
                                  //     scrollDirection: Axis.horizontal,
                                  //     child: Row(
                                  //       children: List.generate(
                                  //           storyImages.length, (index) {
                                  //         return Padding(
                                  //           padding: const EdgeInsets.symmetric(
                                  //               horizontal: 8.0),
                                  //           child: Column(
                                  //             children: [
                                  //               GestureDetector(
                                  //                 onTap: () {},
                                  //                 child: Container(
                                  //                   width: 70,
                                  //                   height: 70,
                                  //                   decoration: BoxDecoration(
                                  //                     borderRadius:
                                  //                         BorderRadius.circular(
                                  //                             35),
                                  //                     boxShadow: [
                                  //                       BoxShadow(
                                  //                         color: Colors.black
                                  //                             .withOpacity(
                                  //                                 0.25),
                                  //                         blurRadius: 4,
                                  //                         offset: const Offset(
                                  //                             0, 4),
                                  //                       ),
                                  //                     ],
                                  //                   ),
                                  //                   child: ClipRRect(
                                  //                     borderRadius:
                                  //                         BorderRadius.circular(
                                  //                             35),
                                  //                     child: Image.asset(
                                  //                       storyImages[index]
                                  //                               ["image"] ??
                                  //                           "no image",
                                  //                       fit: BoxFit.cover,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //               SizedBox(
                                  //                 height: MediaQuery.of(context)
                                  //                         .size
                                  //                         .height *
                                  //                     2 /
                                  //                     100,
                                  //               ),
                                  //               Text(
                                  //                 storyImages[index]["name"] ??
                                  //                     "No Name",
                                  //                 style: const TextStyle(
                                  //                   color: Colors.black,
                                  //                   fontWeight: FontWeight.w600,
                                  //                   fontSize: 12,
                                  //                 ),
                                  //               ),
                                  //               SizedBox(
                                  //                   // height: MediaQuery.of(context).size.height * 0.2/100,
                                  //                   ),
                                  //               Text(
                                  //                 storyImages[index]
                                  //                         ["subname"] ??
                                  //                     "No Name",
                                  //                 style: const TextStyle(
                                  //                   color:
                                  //                       AppColor.greyLightColor,
                                  //                   fontWeight: FontWeight.w600,
                                  //                   fontSize: 12,
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         );
                                  //       }),
                                  //     ),
                                  //   ),
                                  // ),

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
                                      color: AppColor.capsuleColor,
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
                                        // Image.asset(
                                        //   AppImage.instagramIcon,
                                        //   color: AppColor.primaryColor,
                                        //   width: MediaQuery.of(context)
                                        //           .size
                                        //           .width *
                                        //       5 /
                                        //       100,
                                        //   height: MediaQuery.of(context)
                                        //           .size
                                        //           .height *
                                        //       6 /
                                        //       100,
                                        // ),

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
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.secondryColor,
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
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
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
                                              color: AppColor.secondryColor,
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

                                  // Container(
                                  //   width: size.width * 75 / 100,
                                  //   height: size.height * 7 / 100,
                                  //   decoration: BoxDecoration(
                                  //       color: AppColor.greygreyLightColor,
                                  //       borderRadius:
                                  //           BorderRadius.circular(40)),
                                  //   child: Row(
                                  //     children: [
                                  //       Container(
                                  //         width: size.width * 35 / 100,
                                  //         decoration: BoxDecoration(
                                  //             color: AppColor.pinkColor,
                                  //             borderRadius:
                                  //                 BorderRadius.circular(40)),
                                  //         child: Center(
                                  //           child: Padding(
                                  //             padding: EdgeInsets.symmetric(
                                  //               horizontal:
                                  //                   MediaQuery.of(context)
                                  //                           .size
                                  //                           .width *
                                  //                       3 /
                                  //                       100,
                                  //               vertical: MediaQuery.of(context)
                                  //                       .size
                                  //                       .height *
                                  //                   2 /
                                  //                   100,
                                  //             ),
                                  //             child: Text(
                                  //               AppLanguage
                                  //                   .singledayText[language],
                                  //               style: const TextStyle(
                                  //                   fontSize: 16,
                                  //                   fontFamily:
                                  //                       AppFont.fontFamily,
                                  //                   fontWeight: FontWeight.w500,
                                  //                   color:
                                  //                       AppColor.secondryColor),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       SizedBox(
                                  //         width: MediaQuery.of(context)
                                  //                 .size
                                  //                 .width *
                                  //             3 /
                                  //             100,
                                  //       ),
                                  //       Container(
                                  //         child: Text(
                                  //           AppLanguage.mutidayText[language],
                                  //           style: const TextStyle(
                                  //               fontSize: 16,
                                  //               fontFamily: AppFont.fontFamily,
                                  //               fontWeight: FontWeight.w500,
                                  //               color: AppColor.primaryColor),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  // SingleChildScrollView(
                                  //   scrollDirection: Axis.horizontal,
                                  //   child: Row(
                                  //     children: [
                                  //       Container(
                                  //         width: size.width * 75 / 100,
                                  //         height: size.height * 33 / 100,
                                  //         margin:
                                  //             const EdgeInsets.only(right: 10),
                                  //         decoration: BoxDecoration(
                                  //           borderRadius:
                                  //               BorderRadius.circular(20),
                                  //         ),
                                  //         child: ClipRRect(
                                  //           borderRadius:
                                  //               BorderRadius.circular(20),
                                  //           child: Image.asset(
                                  //             AppImage.divoffer,
                                  //             fit: BoxFit.fill,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Container(
                                  //         width: size.width * 75 / 100,
                                  //         height: size.height * 33 / 100,
                                  //         margin:
                                  //             const EdgeInsets.only(right: 10),
                                  //         decoration: BoxDecoration(
                                  //           borderRadius:
                                  //               BorderRadius.circular(20),
                                  //         ),
                                  //         child: ClipRRect(
                                  //           borderRadius:
                                  //               BorderRadius.circular(20),
                                  //           child: Image.asset(
                                  //             AppImage.divoffer,
                                  //             fit: BoxFit.fill,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: Text(
                                          AppLanguage.recentlyLikedeventsText[
                                              language],
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor),
                                        ),
                                      ),
                                      // Container(
                                      //   child: Text(
                                      //     AppLanguage.viewAlltext[language],
                                      //     style: const TextStyle(
                                      //         fontSize: 16,
                                      //         fontFamily: AppFont.fontFamily,
                                      //         fontWeight: FontWeight.w500,
                                      //         color: AppColor.pinkColor),
                                      //   ),
                                      // ),
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
                                              child: Image.asset(
                                                AppImage.aroundmeIcon,
                                                fit: BoxFit.fill,
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
                                              child: Image.asset(
                                                AppImage.aroundmeIcon,
                                                fit: BoxFit.fill,
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
                                              child: Image.asset(
                                                AppImage.aroundmeIcon,
                                                fit: BoxFit.fill,
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
                                  Container(
                                    width: size.width * 92 / 100,
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: Image.asset(
                                          AppImage.followedVenueIcon,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage
                                          .mytopArtistonspotifyText[language],
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
                                  Row(
                                    children: [
                                      Container(
                                        width: size.width * 23 / 100,
                                        child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                            child: Image.asset(
                                              AppImage.dmxIcon,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      SizedBox(
                                        width: size.width * 2 / 100,
                                      ),
                                      Container(
                                        width: size.width * 40 / 100,
                                        child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                            ),
                                            child: Image.asset(
                                              AppImage.benIcon,
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: size.height * 1.5 / 100,
                                  ),
                                  Container(
                                    width: size.width * 40 / 100,
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                        ),
                                        child: Image.asset(
                                          AppImage.martinICon,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                  SizedBox(
                                    height: size.height * 4 / 100,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: AppColor.buttonColor,
                                          borderRadius:
                                              BorderRadius.circular(50),

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
                                              color: AppColor
                                                  .secondryColor, // optional tint color
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
                                          borderRadius:
                                              BorderRadius.circular(50),
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
                                            borderRadius:
                                                const BorderRadius.only(
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

                                  // Container(
                                  //   width: size.width * 90 / 100,
                                  //   height: size.height * 18 / 100,
                                  //   margin: const EdgeInsets.only(right: 10),
                                  //   decoration: BoxDecoration(
                                  //     color: AppColor.backgroundColor,
                                  //     borderRadius: BorderRadius.circular(20),
                                  //   ),
                                  //   child: Column(
                                  //     children: [
                                  //       Padding(
                                  //         padding: EdgeInsets.symmetric(
                                  //           horizontal: MediaQuery.of(context)
                                  //                   .size
                                  //                   .width *
                                  //               4 /
                                  //               100,
                                  //           vertical: MediaQuery.of(context)
                                  //                   .size
                                  //                   .height *
                                  //               2 /
                                  //               100,
                                  //         ),
                                  //         // child: Row(
                                  //         //   mainAxisAlignment:
                                  //         //       MainAxisAlignment.spaceBetween,
                                  //         //   children: [
                                  //         //     Column(
                                  //         //       children: [
                                  //         //         Text(
                                  //         //           AppLanguage
                                  //         //               .fromText[language],
                                  //         //           style: const TextStyle(
                                  //         //               fontSize: 16,
                                  //         //               fontFamily:
                                  //         //                   AppFont.fontFamily,
                                  //         //               fontWeight:
                                  //         //                   FontWeight.w500,
                                  //         //               color: AppColor
                                  //         //                   .secondryColor),
                                  //         //         ),
                                  //         //         Text(
                                  //         //           AppLanguage.ruppesruppeText[
                                  //         //               language],
                                  //         //           style: const TextStyle(
                                  //         //               fontSize: 22,
                                  //         //               fontFamily:
                                  //         //                   AppFont.fontFamily,
                                  //         //               fontWeight:
                                  //         //                   FontWeight.w500,
                                  //         //               color: AppColor
                                  //         //                   .secondryColor),
                                  //         //         ),
                                  //         //       ],
                                  //         //     ),
                                  //         //     Container(
                                  //         //       width: size.width * 35 / 100,
                                  //         //       decoration: BoxDecoration(
                                  //         //           color:
                                  //         //               AppColor.secondryColor,
                                  //         //           borderRadius:
                                  //         //               BorderRadius.circular(
                                  //         //                   40)),
                                  //         //       child: Center(
                                  //         //         child: Padding(
                                  //         //           padding:
                                  //         //               EdgeInsets.symmetric(
                                  //         //             horizontal:
                                  //         //                 MediaQuery.of(context)
                                  //         //                         .size
                                  //         //                         .width *
                                  //         //                     3 /
                                  //         //                     100,
                                  //         //             vertical:
                                  //         //                 MediaQuery.of(context)
                                  //         //                         .size
                                  //         //                         .height *
                                  //         //                     2 /
                                  //         //                     100,
                                  //         //           ),
                                  //         //           child: Text(
                                  //         //             AppLanguage.BookNowText[
                                  //         //                 language],
                                  //         //             style: const TextStyle(
                                  //         //                 fontSize: 20,
                                  //         //                 fontFamily: AppFont
                                  //         //                     .fontFamily,
                                  //         //                 fontWeight:
                                  //         //                     FontWeight.w600,
                                  //         //                 color: AppColor
                                  //         //                     .pinkColor),
                                  //         //           ),
                                  //         //         ),
                                  //         //       ),
                                  //         //     ),
                                  //         //   ],
                                  //         // ),
                                  //       ),
                                  //       Padding(
                                  //         padding: EdgeInsets.symmetric(
                                  //           horizontal: MediaQuery.of(context)
                                  //                   .size
                                  //                   .width *
                                  //               6 /
                                  //               100,
                                  //         ),
                                  //         child: Text(
                                  //           AppLanguage
                                  //                   .confirmBookeddetailsText[
                                  //               language],
                                  //           style: const TextStyle(
                                  //               fontSize: 14,
                                  //               fontFamily: AppFont.fontFamily,
                                  //               fontWeight: FontWeight.w400,
                                  //               color: AppColor.secondryColor),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
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
              color: AppColor.popupColor,
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
                const SizedBox(height: 8), // Added small spacing after close button
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero, // Remove default ListView padding
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final chat = chatUsers[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6), // Adjusted spacing between items
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
}
