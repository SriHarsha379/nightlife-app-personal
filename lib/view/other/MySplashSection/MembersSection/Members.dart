import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/my_events.dart';
import 'package:night_life/view/other/MySplashSection/MembersSection/member_liked_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/my_venue.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class splashMembers extends StatefulWidget {
  static const String routeName = '/splashMembers';
  const splashMembers({super.key});

  @override
  State<splashMembers> createState() => _splashMembersState();
}

class _splashMembersState extends State<splashMembers> {
  int selectedIndex = 0;
  List Followinglist = [
    {
      'image': AppImage.menimg,
      'title': 'Gaurav kapoor',
      'date': 'Member since 2 yrs',
      'address': 'Lane 7, IT Park + 1.8 km',
    },
    {
      'image': AppImage.womenimg,
      'title': 'Anaya Joshi',
      'date': 'Member since 2 yrs',
      'address': 'Lane 7, IT Park + 1.8 km',
    },
  ];

  List connectionlist = [
    {
      'image': AppImage.arjunRoyicon,
      'title': 'Arjun Ray',
      'date': 'Member since 2 yrs',
      'address': 'Lane 7, Koregaon Park • 1.8 km',
      'text': 'Mark',
    },
    {
      'image': AppImage.karanRoy,
      'title': 'Karan Ray',
      'date': 'Member since 2 yrs',
      'address': 'Lane 7, Koregaon Park • 1.8 km',
      'text': 'Mark',
    },
  ];
  bool isDropdownOpen = false;

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
            color: AppColor.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 90 / 100,
                    height: MediaQuery.of(context).size.height * 7 / 100,
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
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
                          width: MediaQuery.of(context).size.width * 26 / 100,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            AppLanguage.membersText[language],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                        ),
                    
                        SizedBox(width: size.width * 2 / 100),

                        GestureDetector(
                          onTap: () {
                            showPopupDropdown(context);
                            setState(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Transform.rotate(
                            angle: isDropdownOpen ? 0 : 3.14,
                            child: Image.asset(
                              AppImage.downArrow,
                              fit: BoxFit.cover,
                              color: AppColor.secondryColor,
                              height:
                                  MediaQuery.of(context).size.width * 5 / 100,
                            ),
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
                                  fontSize: 15,
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
                                AppLanguage.myconectionstext[language],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: selectedIndex == 1
                                      ? AppColor.pinkColor
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
                            if (selectedIndex == 0)
                              Wrap(
                                runSpacing: 10,
                                children: List.generate(
                                  Followinglist.length,
                                  (index) => GestureDetector(
                                    onTap: () {},
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
                                                  Followinglist[index]['image'],
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
                                                      Followinglist[index]
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
                                                      Followinglist[index]
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
                                                    SizedBox(
                                                      width: size.width *
                                                          0.8 /
                                                          100,
                                                    ),
                                                    Text(
                                                      Followinglist[index]
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
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeftWithFade,
                                                        child:
                                                            LikedMemberDetail(),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            6 /
                                                            100,
                                                    decoration: BoxDecoration(
                                                        color: AppColor
                                                            .secondryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Center(
                                                      child: Text(
                                                        AppLanguage
                                                                .viewProfiletext[
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
                            if (selectedIndex == 1)
                              Container(
                                child: Text(
                                  AppLanguage.ReserveddetailsText[language],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.secondryColor),
                                ),
                              ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100,
                            ),
                            Wrap(
                              runSpacing: 10,
                              children: List.generate(
                                Followinglist.length,
                                (index) => GestureDetector(
                                  onTap: () {},
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
                                                connectionlist[index]['image'],
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
                                                    connectionlist[index]
                                                        ['title'],
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColor
                                                            .secondryColor),
                                                  ),
                                                  Container(
                                                    width: size.width * 8 / 100,
                                                    height:
                                                        size.width * 8 / 100,
                                                    decoration:
                                                        const BoxDecoration(
                                                            boxShadow: []),
                                                    child: ClipRRect(
                                                        child: Image.asset(
                                                      AppImage.liked_heart_icon,
                                                      fit: BoxFit.cover,
                                                      color: AppColor
                                                          .secondryColor,
                                                    )),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: size.height * 0.4 / 100,
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width:
                                                        size.width * 4.5 / 100,
                                                    height:
                                                        size.width * 4.5 / 100,
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
                                                    connectionlist[index]
                                                        ['date'],
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            AppFont.fontFamily,
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
                                                    width: size.width * 5 / 100,
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
                                                  SizedBox(
                                                    width:
                                                        size.width * 0.8 / 100,
                                                  ),
                                                  Text(
                                                    connectionlist[index]
                                                        ['address'],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                            AppFont.fontFamily,
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
                                                    color:
                                                        AppColor.secondryColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Center(
                                                  child: Text(
                                                    AppLanguage
                                                        .messageText[language],
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            AppColor.pinkColor),
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

// Ye function use karo - koi key ki zarurat nahi
  void showPopupDropdown(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.black54),
              ),
              Positioned(
                top: 100, // AppBar ke niche adjust karo
                left: MediaQuery.of(context).size.width / 2 -
                    100, // center horizontally
                child: Container(
                  width: 202,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(15), // four side radius
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4), // shadow bottom
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      dropdownItem(
                          "Events",
                          () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyEvents(),
                                ),
                              ),
                          false),
                      divider(),
                      dropdownItem(
                          "Venues", () =>  Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyVenue(),
                                ),
                              ),
                          false),
                      divider(),
                      dropdownItem(
                          "Members", () => Navigator.pop(context), true),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget dropdownItem(String text, VoidCallback onTap, bool isActive) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
