// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:image_picker/image_picker.dart';
import 'package:night_life/view/authentication/notification_screen.dart';
import 'package:night_life/view/authentication/profile.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:night_life/view/other/MySplashSection/MembersSection/member_liked_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/my_venue.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venue_liked_details.dart';
import 'package:night_life/view/other/chats/chat_message_screen.dart';
import 'package:night_life/view/bottom%20navigation/chats_screen.dart';
import 'package:night_life/view/other/city_Preference/badge_screen.dart';
import 'package:night_life/view/other/city_Preference/event_preference.dart';
import 'package:night_life/view/other/city_Preference/vibe_check_screen.dart';
import 'package:night_life/view/other/city_Preference/vibe_preference.dart';
import 'package:night_life/view/other/upload_id_screen.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'package:page_transition/page_transition.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class MusicGenresScreen extends StatefulWidget {
  static String routeName = './MusicGenresScreen';

  const MusicGenresScreen({super.key});

  @override
  State<MusicGenresScreen> createState() => _MusicGenresScreenState();
}

class _MusicGenresScreenState extends State<MusicGenresScreen> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;

  @override
  void initState() {
    super.initState();
  }

  int reportId = 0;
  int? selectedImageIndex;
  int selectedId = 2;
  List Orders = [
    {'id': 1, 'image1': AppImage.GenreCard1, 'image2': AppImage.GenreCard2},
    {'id': 2, 'image1': AppImage.GenreCard3, 'image2': AppImage.GenreCard4},
    {'id': 3, 'image1': AppImage.GenreCard5, 'image2': AppImage.GenreCard6},
    {'id': 4, 'image1': AppImage.GenreCard7, 'image2': AppImage.GenreCard8},
    {'id': 5, 'image1': AppImage.GenreCard9, 'image2': AppImage.GenreCard10},
    {'id': 6, 'image1': AppImage.GenreCard11, 'image2': AppImage.GenreCard12},
  ];
  List<Map<String, dynamic>> selectedItems = [];
  int maxSelection = 5;
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  int selectedindex = -1;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.themeColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: AppButton(
            text: '${AppLanguage.continueText[language]}',
            onPress: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: EventPreference(),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            },
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: SingleChildScrollView(
            child: Column(
              children: [
                  SizedBox(
                            height: MediaQuery.of(context).size.height * 3 / 100,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 4 / 100,
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                child: Image.asset(
                                  AppImage.backArrowIcon,
                                  color: AppColor.secondryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLanguage.musicGenres[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              
                      // Row(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => const Notifications()),
                      //         );
                      //       },
                      //       child: SizedBox(
                      //         height:
                      //             MediaQuery.of(context).size.height * 3 / 100,
                      //         child: Image.asset(
                      //           AppImage.bellicon,
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(
                      //       width: size.width * 2 / 100,
                      //     ),
                      //     GestureDetector(
                      //       onTap: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (context) => const Profile()),
                      //         );
                      //       },
                      //       child: SizedBox(
                      //         height:
                      //             MediaQuery.of(context).size.height * 5 / 100,
                      //         child: Image.asset(
                      //           AppImage.userimage,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
                  ),
                ),
              
                SizedBox(
                  width: MediaQuery.of(context).size.width * 80 / 100,
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.pickUpgenreText[language],
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondryColor,
                      ),
                    ),
                  ),
                ),
              
                SizedBox(height: size.height * 2 / 100),
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
                        borderSide: const BorderSide(
                          color: AppColor.borderColor,
                          width: 0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColor.borderColor,
                          width: 0,
                        ),
                      ),
                      border: InputBorder.none,
                      hintText: AppLanguage.searchGenresText[language],
                      hintStyle: AppConstant.textFilledStyle1,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: size.height * 2 / 100,
                        horizontal: size.width * 4 / 100,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 2 / 100,
                      ),
                      Image.asset(
                        AppImage.fireIcon,
                        height: size.width * 4 / 100,
                        width: size.width * 4 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 2 / 100,
                      ),
                      SizedBox(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            textAlign: TextAlign.center,
                            AppLanguage.topPicksforText[language],
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColor.secondryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      Orders.length,
                      (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // First Image
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Map<String, dynamic> item = {
                                        "id": Orders[index]['id'],
                                        "img": 1, // For image1
                                      };
              
                                      bool alreadySelected = selectedItems.any(
                                          (e) =>
                                              e['id'] == Orders[index]['id'] &&
                                              e['img'] == 1);
              
                                      if (alreadySelected) {
                                        selectedItems.removeWhere((e) =>
                                            e['id'] == Orders[index]['id'] &&
                                            e['img'] == 1);
                                      } else {
                                        if (selectedItems.length <
                                            maxSelection) {
                                          selectedItems.add(item);
                                        } else {
                                          
                                        }
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Orders[index]['image1'] != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: selectedItems.any((e) =>
                                                        e['id'] ==
                                                            Orders[index]
                                                                ['id'] &&
                                                        e['img'] == 1)
                                                    ? AppColor.buttonColor
                                                    : Colors.transparent,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.asset(
                                                Orders[index]['image1'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Map<String, dynamic> item = {
                                        "id": Orders[index]['id'],
                                        "img": 2,
                                      };
              
                                      bool alreadySelected = selectedItems.any(
                                          (e) =>
                                              e['id'] == Orders[index]['id'] &&
                                              e['img'] == 2);
              
                                      if (alreadySelected) {
                                        selectedItems.removeWhere((e) =>
                                            e['id'] == Orders[index]['id'] &&
                                            e['img'] == 2);
                                      } else {
                                        if (selectedItems.length <
                                            maxSelection) {
                                          selectedItems.add(item);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    "Max 5 selections allowed")),
                                          );
                                        }
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Orders[index]['image2'] != null
                                        ? Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: selectedItems.any((e) =>
                                                        e['id'] ==
                                                            Orders[index]
                                                                ['id'] &&
                                                        e['img'] == 2)
                                                    ? AppColor.buttonColor
                                                    : Colors.transparent,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.asset(
                                                Orders[index]['image2'],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.otherGenretexts[language],
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 2 / 100),
                Container(
                  width: size.width * 90 / 100,
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
                        // child: Image.asset(
                        //   AppImage.searchIcon,
                        //   height: size.width * 4 / 100,
                        //   width: size.width * 4 / 100,
                        //   color: AppColor.filledText,
                        // ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: size.width * 2 / 100,
                        minHeight: size.height * 6 / 100,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColor.borderColor,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColor.borderColor,
                          width: 2,
                        ),
                      ),
                      border: InputBorder.none,
                      hintText:
                          AppLanguage.typeYourfavouritegenreText[language],
                      hintStyle: AppConstant.textFilledStyle1,
                      contentPadding: EdgeInsets.only(
                        right: size.width * 4 / 100,
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 4 / 100,
                // ),
                // AppButton(
                //     text: AppLanguage.continueText[language],
                //     onPress: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => EventPreference()));
                //     }),
              
                SizedBox(
                  height: MediaQuery.of(context).size.height * 18 / 100,
                ),
              
                // ),
              
                // Container(
              
                //   margin: EdgeInsets.symmetric(horizontal: 90, vertical: 1),
                //   width: MediaQuery.of(context).size.width * 100 / 100,
                //   height: MediaQuery.of(context).size.width *20 / 100,
                //   child: Image.asset(
                //     AppImage.undo,
                //     fit: BoxFit.contain,
                //   ),
                // ),
              
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 2 / 100,
                // ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: const AppFooter(
        //     selectedMenu: BottomMenus.home, notificationCount: 0),
      ),
    );
  }
}
