import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/view/authentication/edit_Swipe_profile.dart';
import 'package:night_life/view/authentication/edit_profile_screen.dart';
import 'package:night_life/view/authentication/signup.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:page_transition/page_transition.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_comman_setting.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';
import '../authentication/profile.dart';

class Profile1 extends StatefulWidget {
  static String routeName = './Profile1';
  const Profile1({super.key});

  @override
  State<Profile1> createState() => _Profile1State();
}

TextEditingController mobileNumberTextEditingController =
    TextEditingController();
TextEditingController bioController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController genderController = TextEditingController();
TextEditingController usernameController = TextEditingController();
List Interest = [
  {'id': 1, 'title': 'Add new'},
  {'id': 2, 'title': 'Photography'},
  {'id': 3, 'title': 'Social Mixers'},
  {'id': 4, 'title': 'Open Mic'},
  {'id': 5, 'title': 'Comedy Shows'},
];
int selectedId = 1;

class _Profile1State extends State<Profile1> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.themeColor,
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // backgroundColor: AppColor.secondryColor,
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor1),
          child: SingleChildScrollView(
            child: Column(
              children: [
             
                SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 88 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLanguage.yourProfileText[language],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFont.fontFamily,
                          color: AppColor.secondryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: Profile(),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: Image.asset(
                          AppImage.settingIcon,
                          color: AppColor.secondryColor,
                          width: MediaQuery.of(context).size.width * 5 / 100,
                          height: MediaQuery.of(context).size.height * 6 / 100,
                        ),
                      ),


                       
                    ],
                  ),


                ),
                SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
                SizedBox(
                   width: MediaQuery.of(context).size.width * 91 / 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Container(
                        width: MediaQuery.of(context).size.width * 39 / 100,
                        height: MediaQuery.of(context).size.height * 25 / 100,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(30),
                            top: Radius.circular(30),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(30),
                            top: Radius.circular(30),
                          ),
                          child: Image.asset(
                            AppImage.editUserprofile,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // SizedBox(
                      //     width: MediaQuery.of(context).size.width * 0.2 / 100),
                  
                      // Profile Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100),
                            Text(
                              AppLanguage.sanjanaRoytext[language],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.2 /
                                    100),
                            Text(
                              AppLanguage.foodieExplorecreativeText[language],
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.buttonColor,
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100),
                            Row(
                              children: [
                                Text(
                                  AppLanguage.onetwentyText[language],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.secondryColor,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.5 /
                                        100),
                                Text(
                                  AppLanguage.friends[language],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.secondryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.5 /
                                    100),
                            Row(
                              children: [
                                Text(
                                  AppLanguage.fiveSixtyText[language],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.secondryColor,
                                  ),
                                ),
                                Text(
                                  AppLanguage.likes[language],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.secondryColor,
                                  ),
                                ),
                              ],
                            ),
                  
                            // buildTaskRow(
                            //     AppLanguage.foodieExplorecreativeText[language],
                            //     Colors.purpleAccent),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: EditProfile(),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  child: SizedBox(
                     width: MediaQuery.of(context).size.width * 95 / 100,
                    child: Row(
                      children: [
                        Container(
                          padding:  EdgeInsets.symmetric(
                              horizontal: 33, vertical: 12),
                          margin: const EdgeInsets.only(left: 11),
                          decoration: BoxDecoration(
                            color: AppColor.statusbar,
                            borderRadius: BorderRadius.circular(50),
                    
                            // border: Border.all(
                    
                            //      color : AppColor.primaryColor,
                            // ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppImage.editIcon,
                                height: 20,
                                width: 20,
                                color:
                                    AppColor.secondryColor,
                              ),
                              SizedBox(
                                width: size.width * 1 / 100,
                              ),
                              Text(
                                AppLanguage.editDetailsText[language],
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
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: EditSwipeProfile(),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          child: Container(
                            padding:  EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColor.buttonColor,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: AppColor.transparentColor,
                              ),
                            ),
                            child: Text(
                              AppLanguage.editSwipeprofileText[language],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Completion Text
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
                              
                                SizedBox(
                                  height: size.height * 1 / 100,
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
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                          top: Radius.circular(30),
                        ),
                        child: Image.asset(
                          AppImage.lineIcon,
                          fit: BoxFit.cover,
                          color: AppColor.secondryColor,
                        ),
                      ),
                   
                      SizedBox(
                        height: size.height * 1 / 100,
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
                        height: size.height * 1 / 100,
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                          top: Radius.circular(30),
                        ),
                        child: Image.asset(
                          AppImage.lineIcon,
                          color: AppColor.secondryColor,
                          fit: BoxFit.cover,
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
                        height: size.height * 1 / 100,
                      ),
                      Wrap(
                        spacing: 6, // horizontal space between items
                        runSpacing: 8, // vertical space between rows
                        children: List.generate(
                          Interest.length,
                          (index) {
                            bool isAll = Interest[index]['id'] == 1;
                            bool isSelected =
                                selectedId == Interest[index]['id'];

                            return GestureDetector(
                              onTap: isAll
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedId = Interest[index]['id'];
                                      });
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isAll
                                      ? AppColor
                                          .primaryColor // grey background for id=1
                                      : (isSelected
                                          ? AppColor.primaryColor
                                          : AppColor.primaryColor),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: isAll
                                        ? AppColor
                                            .greyLightColor // grey border for id=1
                                        : (isSelected
                                            ? AppColor.buttonColor
                                            : AppColor.buttonColor),
                                  ),
                                ),
                                child: Text(
                                  Interest[index]['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isAll
                                        ? Colors.grey // grey text for id=1
                                        : (isSelected
                                            ? AppColor.buttonColor
                                            : AppColor.buttonColor),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100,
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                          top: Radius.circular(30),
                        ),
                        child: Image.asset(
                          AppImage.lineIcon,
                          fit: BoxFit.cover,
                          color: AppColor.secondryColor,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 2 / 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                              AppLanguage.vibe[language],
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
                        height: size.height * 1 / 100,
                      ),
                      Container(
                        width: size.width * 85 / 100,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.asset(
                              AppImage.vibesIcon,
                              fit: BoxFit.fill,
                            )),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                          top: Radius.circular(30),
                        ),
                        child: Image.asset(
                          AppImage.lineIcon,
                          fit: BoxFit.cover,
                          color: AppColor.secondryColor,
                        ),
                      ),
                      SizedBox(
                        height: size.height * 2 / 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              height: size.height * 18 / 100,
                              margin: const EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  AppImage.plusImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              width: size.width * 30 / 100,
                              height: size.height * 18 / 100,
                              margin: const EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  AppImage.dogImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              width: size.width * 30 / 100,
                              height: size.height * 18.5 / 100,
                              margin: const EdgeInsets.only(left: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  AppImage.blackGirlicon,
                                  fit: BoxFit.cover,
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
                        height: MediaQuery.of(context).size.width * 12 / 100,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        decoration: BoxDecoration(
                          color: AppColor.capsuleColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.grayColor.withOpacity(0.4),
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(200),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    4 /
                                    100),

                            // Icon
                            Image.asset(
                              AppImage.instagramIcon,
                              color: AppColor.secondryColor,
                              width:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100,
                            ),

                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    2 /
                                    100),

                            // Text + spacing
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLanguage.instagramText[language],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.secondryColor,
                                    ),
                                  ),
                                  Text(
                                    AppLanguage.kapoorg[language],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: AppFont.fontFamily,
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
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: AppColor.transparentColor),
                              ),
                              child: Text(
                                AppLanguage.connectedText[language],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.secondryColor,
                                ),
                              ),
                            ),

                            SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    6 /
                                    100),
                          ],
                        ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                              AppLanguage.likedEvents[language],
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.secondryColor),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: LikedEventDetail(),
                                  duration: const Duration(milliseconds: 400),
                                ),
                              );
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: LikedEventDetail(),
                              duration: const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                width: size.width * 40 / 100,
                                height: size.height * 30 / 100,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    AppImage.aroundmeIcon,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Container(
                                width: size.width * 40 / 100,
                                height: size.height * 30 / 100,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    AppImage.aroundmeIcon1,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              Container(
                                width: size.width * 40 / 100,
                                height: size.height * 30 / 100,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Text(
                              AppLanguage.followedVenuestext[language],
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.secondryColor),
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
                        height: size.height * 0.2 / 100,
                      ),
                      Container(
                        width: size.width * 98 / 100,
                        height: size.height * 17 / 100,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.asset(
                            AppImage.followedVenueIcon,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          AppLanguage.mytopArtistonspotifyText[language],
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
                                borderRadius: const BorderRadius.only(
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
                                borderRadius: const BorderRadius.only(
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
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 10 / 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTaskRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(Icons.fiber_manual_record, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontFamily: AppFont.fontFamily,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
