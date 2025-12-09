import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/view/other/MySplashSection/MembersSection/member_liked_details.dart';

import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class EditSwipeProfile extends StatefulWidget {
  static const String routeName = '/EditSwipeProfile';
  const EditSwipeProfile({super.key});

  @override
  State<EditSwipeProfile> createState() => _EditSwipeProfileState();
}

class _EditSwipeProfileState extends State<EditSwipeProfile> {
  int selectedIndex = 0;
  List Followinglist = [
    {
      'image': AppImage.menimg,
      'title': 'Gaurav kapoor',
      'date': 'Members since 2 yrs',
      'address': 'Lane 7, IT Park + 1.8 km',
    },
    {
      'image': AppImage.womenimg,
      'title': 'Anaya Joshi',
      'date': 'Members since 2 yrs',
      'address': 'Lane 7, IT Park + 1.8 km',
    },
  ];

  List connectionlist = [
    {
      'image': AppImage.womenimg,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.menimg,
      'title': 'Base Drop Fridays',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];

  List<String> uploadedimages1 = [
    AppImage.uploadedimg1,
    AppImage.uploadedimg2,
    AppImage.uploadedimg3,
  ];

  List<String> uploadedimages2 = [
    AppImage.uploadedimg4,
    AppImage.uploadedimg5,
    AppImage.uploadedimg6,
  ];
  List<bool> switches = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  List galleryList = [
    {
      'image': AppImage.womenimg,
    },
    {
      'image': AppImage.menimg,
    },
  ];
  int selectedtickmarkIndex = -1;
  int selectedtickmarkIndex1 = -1;

  int selectedtickIndex1 = -1;
  int selectedtickIndex = -1;
  bool isSwitched = true;
  bool isSelected = false;
  Set<int> selectedTickIndexes1 = {};
  Set<int> selectedTickIndexes = {};
  Set<int> selectedTickIndexes2 = {};
  Set<int> selectedTickIndexes3 = {};

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // SystemChrome.setSystemUIOverlayStyle(AppConstant.systemUiOverlayStyle);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
              body: Container(
              color:AppColor.primaryColor,
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 4 / 100),
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
                            width: MediaQuery.of(context).size.width * 2 / 100,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 80 / 100,
                              child: Text(
                                AppLanguage.editSwipeprofileText[language],
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: AppColor.secondryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 2 / 100),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 70 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor, 
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4),
                            // spreadRadius: 1,
                            blurRadius: 2, 
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        // borderSide: const BorderSide(
                        //   color: AppColor.textfieldfillColor,
                        //   width: 0,
                        // ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 86 / 100,
                              child: Text(
                                  AppLanguage.basicdetailstext[language],
                                  style: const TextStyle(
                                      color: AppColor.hinttextcolor,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(AppLanguage.ageText1[language],
                                        style: const TextStyle(
                                            color: AppColor.hinttextcolor,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: switches[4],
                                      onChanged: (value) {
                                        setState(() {
                                          switches[4] = value;
                                        });
                                      },
                                      activeColor: AppColor.secondryColor,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor:
                                          AppColor.secondryColor,
                                      inactiveTrackColor:
                                          AppColor.greyLightColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.heightText[language],
                                        style: const TextStyle(
                                            color: AppColor.hinttextcolor,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: switches[5],
                                      onChanged: (value) {
                                        setState(() {
                                          switches[5] = value;
                                        });
                                      },
                                      activeColor: AppColor.secondryColor,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor:
                                          AppColor.secondryColor,
                                      inactiveTrackColor:
                                          AppColor.greyLightColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.pronouncsText[language],
                                        style: const TextStyle(
                                            color: AppColor.hinttextcolor,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: switches[6],
                                      onChanged: (value) {
                                        setState(() {
                                          switches[6] = value;
                                        });
                                      },
                                      activeColor: AppColor.secondryColor,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor:
                                          AppColor.secondryColor,
                                      inactiveTrackColor:
                                          AppColor.greyLightColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.hobbiesText[language],
                                        style: const TextStyle(
                                            color: AppColor.hinttextcolor,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: switches[7],
                                      onChanged: (value) {
                                        setState(() {
                                          switches[7] = value;
                                        });
                                      },
                                      activeColor: AppColor.secondryColor,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor:
                                          AppColor.secondryColor,
                                      inactiveTrackColor:
                                          AppColor.greyLightColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        AppLanguage.nearbyLocation[language],
                                        style: const TextStyle(
                                            color: AppColor.hinttextcolor,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: switches[8],
                                      onChanged: (value) {
                                        setState(() {
                                          switches[8] = value;
                                        });
                                      },
                                      activeColor: AppColor.secondryColor,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor:
                                          AppColor.secondryColor,
                                      inactiveTrackColor:
                                          AppColor.greyLightColor,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 14 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.themeColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                        // borderSide: const BorderSide(
                        //   color: AppColor.textfieldfillColor,
                        //   width: 0,
                        // ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 78 / 100,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(AppLanguage.interestsText[language],
                                  style: const TextStyle(
                                      color: AppColor.secondryColor,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 9 / 100,
                            height:
                                MediaQuery.of(context).size.height * 4 / 100,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Switch(
                                value: switches[9],
                                onChanged: (value) {
                                  setState(() {
                                    switches[9] = value;
                                  });
                                },
                                activeColor: AppColor.secondryColor,
                                activeTrackColor: AppColor.pinkColor,
                                inactiveThumbColor: AppColor.secondryColor,
                                inactiveTrackColor: AppColor.greyLightColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19.0),
                    child: Container(
                      height: MediaQuery.of(context).size.width * 14 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.themeColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16),
                        // borderSide: const BorderSide(
                        //   color: AppColor.textfieldfillColor,
                        //   width: 0,
                        // ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 78 / 100,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Text(AppLanguage.vibesText[language],
                                  style: const TextStyle(
                                      color: AppColor.secondryColor,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 9 / 100,
                            height:
                                MediaQuery.of(context).size.height * 4 / 100,
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Switch(
                                value: switches[10],
                                onChanged: (value) {
                                  setState(() {
                                    switches[10] = value;
                                  });
                                },
                                activeColor: AppColor.secondryColor,
                                activeTrackColor: AppColor.pinkColor,
                                inactiveThumbColor: AppColor.secondryColor,
                                inactiveTrackColor: AppColor.greyLightColor,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.width * 132 / 100,
                        width: MediaQuery.of(context).size.width * 92 / 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColor.themeColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.grayColor.withOpacity(0.4),
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          // borderSide: const BorderSide(
                          //   color: AppColor.textfieldfillColor,
                          //   width: 0,
                          // ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(AppLanguage.GalleryText[language],
                                    style: const TextStyle(
                                        color: AppColor.secondryColor,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(AppLanguage.uploadedText[language],
                                    style: const TextStyle(
                                        color: AppColor.textcolor,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(3, (index) {
                                  // bool isSelected = selectedtickmarkIndex == index;
                                  bool isSelected =
                                      selectedTickIndexes2.contains(index);

                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedTickIndexes2.remove(index);
                                        } else {
                                          selectedTickIndexes2.add(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 26 / 100,
                                      height: size.height * 18 / 100,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              uploadedimages1[index],
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              right: 7,
                                              bottom: 7,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected
                                                      ? AppColor.buttonColor
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : Colors.white,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 12,
                                                        color: AppColor
                                                            .primaryColor,
                                                      )
                                                    : null,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(3, (index) {
                                  // bool isSelected = selectedtickmarkIndex1 == index;
                                  bool isSelected =
                                      selectedTickIndexes3.contains(index);

                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedTickIndexes3.remove(index);
                                        } else {
                                          selectedTickIndexes3.add(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 26 / 100,
                                      height: size.height * 18 / 100,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              uploadedimages2[index],
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              right: 7,
                                              bottom: 7,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected
                                                      ? AppColor.buttonColor
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : Colors.white,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 12,
                                                        color: AppColor
                                                            .primaryColor,
                                                      )
                                                    : null,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),

                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100),

                            Center(
                              child: SizedBox(
                                child: Image.asset(
                                  AppImage.uploadButton,
                                  color: AppColor.primaryColor,
                                  height: MediaQuery.of(context).size.height *
                                      6 /
                                      100,
                                  width: MediaQuery.of(context).size.width *
                                      45 /
                                      100,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            // SizedBox(
                            //     height:
                            //         MediaQuery.of(context).size.height * 8 / 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.width * 126 / 100,
                        width: MediaQuery.of(context).size.width * 92 / 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColor.themeColor, // background color
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.grayColor
                                  .withOpacity(0.4), // shadow color
                              // spreadRadius: 1,
                              blurRadius: 2, // blur effect
                              offset: Offset(1, 1),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20),
                          // borderSide: const BorderSide(
                          //   color: AppColor.textfieldfillColor,
                          //   width: 0,
                          // ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Container(
                              width:
                                  MediaQuery.of(context).size.width * 92 / 100,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(AppLanguage.eventsText[language],
                                    style: const TextStyle(
                                        color: AppColor.secondryColor,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),

                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(3, (index) {
                                  // bool isSelected = selectedtickIndex1 == index;
                                  bool isSelected =
                                      selectedTickIndexes.contains(index);

                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedTickIndexes.remove(index);
                                        } else {
                                          selectedTickIndexes.add(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 28 / 100,
                                      height: size.height * 20 / 100,
                                      margin: const EdgeInsets.only(right: 3.8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              index == 0
                                                  ? AppImage.aroundmeIcon1
                                                  : AppImage.divWithouttick,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              right: 7,
                                              bottom: 7,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected
                                                      ? AppColor.buttonColor
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : Colors.white,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 14,
                                                        color: AppColor
                                                            .primaryColor,
                                                      )
                                                    : null,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(3, (index) {
                                  // bool isSelected = selectedtickIndex == index;
                                  bool isSelected =
                                      selectedTickIndexes1.contains(index);

                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedTickIndexes1.remove(index);
                                        } else {
                                          selectedTickIndexes1.add(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 28 / 100,
                                      height: size.height * 20 / 100,
                                      margin: const EdgeInsets.only(right: 3.8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.asset(
                                              index == 0
                                                  ? AppImage.aroundmeIcon1
                                                  : AppImage.divWithouttick,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              right: 7,
                                              bottom: 7,
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected
                                                      ? AppColor.buttonColor
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.transparent
                                                        : Colors.white,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(
                                                        Icons.check,
                                                        size: 12,
                                                        color: AppColor
                                                            .primaryColor,
                                                      )
                                                    : null,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100),

                            Center(
                              child: SizedBox(
                                child: Image.asset(
                                  AppImage.viewAllbutton,
                                  height: MediaQuery.of(context).size.height *
                                      6 /
                                      100,
                                  width: MediaQuery.of(context).size.width *
                                      45 /
                                      100,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            // SizedBox(
                            //     height:
                            //         MediaQuery.of(context).size.height * 8 / 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 4 / 100),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 30 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.themeColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        // borderSide: const BorderSide(
                        //   color: AppColor.textfieldfillColor,
                        //   width: 0,
                        // ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 2 / 100),
                          Container(
                            width: MediaQuery.of(context).size.width * 81 / 100,
                            child: Text(AppLanguage.eventsText[language],
                                style: const TextStyle(
                                    color: AppColor.secondryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.2 /
                                  100),
                          Container(
                            width: size.width * 95 / 100,
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
                          Center(
                            child: SizedBox(
                              child: Image.asset(
                                AppImage.viewAllbutton,
                                height: MediaQuery.of(context).size.height *
                                    6 /
                                    100,
                                width: MediaQuery.of(context).size.width *
                                    45 /
                                    100,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 30 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.themeColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        // borderSide: const BorderSide(
                        //   color: AppColor.textfieldfillColor,
                        //   width: 0,
                        // ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                        AppLanguage.instagramText[language],
                                        style: const TextStyle(
                                            color: AppColor.secondryColor,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: switches[3],
                                      onChanged: (value) {
                                        setState(() {
                                          switches[3] = value;
                                        });
                                      },
                                      activeColor: AppColor.secondryColor,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor:
                                          AppColor.secondryColor,
                                      inactiveTrackColor:
                                          AppColor.greyLightColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Center(
                              child: SizedBox(
                                child: Image.asset(
                                  AppImage.connectButton,
                                  height: MediaQuery.of(context).size.height *
                                      6 /
                                      100,
                                  width: MediaQuery.of(context).size.width *
                                      45 /
                                      100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                  Center(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 30 / 100,
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColor.themeColor, // background color
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor
                                .withOpacity(0.4), // shadow color
                            // spreadRadius: 1,
                            blurRadius: 2, // blur effect
                            offset: Offset(1, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                        // borderSide: const BorderSide(
                        //   color: AppColor.textfieldfillColor,
                        //   width: 0,
                        // ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // SizedBox(
                            //     height:
                            //         MediaQuery.of(context).size.height * 1 / 100),
                            Row(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      78 /
                                      100,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: Text(
                                        AppLanguage.spotifyText[language],
                                        style: const TextStyle(
                                            color: AppColor.secondryColor,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      9 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: Switch(
                                      value: switches[4],
                                      onChanged: (value) {
                                        setState(() {
                                          switches[4] = value;
                                        });
                                      },
                                      activeColor: AppColor.secondryColor,
                                      activeTrackColor: AppColor.pinkColor,
                                      inactiveThumbColor:
                                          AppColor.secondryColor,
                                      inactiveTrackColor:
                                          AppColor.greyLightColor,
                                    ),
                                  ),
                                )
                              ],
                            ),

                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),

                            Center(
                              child: SizedBox(
                                child: Image.asset(
                                  AppImage.connectButton,
                                  height: MediaQuery.of(context).size.height *
                                      6 /
                                      100,
                                  width: MediaQuery.of(context).size.width *
                                      45 /
                                      100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100),
                ],
              ),
            ),
          ))),
    );
  }
}
