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
import 'package:night_life/view/other/city_Preference/party_preference.dart';
import 'package:night_life/view/other/city_Preference/vibe_check_screen2.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class VibeCheckScreen extends StatefulWidget {
  static String routeName = './VibeCheckScreen';

  const VibeCheckScreen({super.key});

  @override
  State<VibeCheckScreen> createState() => _VibeCheckScreenState();
}

class _VibeCheckScreenState extends State<VibeCheckScreen> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;


  int reportId = 0;
bool isDropdownOpen = false;
int selectedIndex = -1;

  int selectedId = 2;
  List Orders = [
    {'id': 1, 'title': 'Delhi'},
    {'id': 2, 'title': 'Banglore'},
    {'id': 3, 'title': 'Gurgaon'},
    {'id': 4, 'title': 'Mumbai'},
  ];
  List<Map<String, dynamic>> imageList = [
    {
      "image": AppImage.div3,
    },
    {
      "image": AppImage.div,
    },
    {
      "image": AppImage.div2,
    },
  ];
  TextEditingController searchController = TextEditingController();

List<Map<String, String>> questionList = [
  {
    "title": "What's your perfect night out?",
    "subtitle": "Describe your ideal evening in a few words.",
  },
  {
    "title": "Go–to drink?",
    "subtitle": "What do you usually order at the bar?",
  },

    {
    "title": "Something interesting about you?",
    "subtitle": "Tell something interesting about yourself",
  },
   {
    "title": "What's your perfect night out?",
    "subtitle": "Describe your ideal evening in a few words.",
  },
    {
    "title": "Go–to drink?",
    "subtitle": "What do you usually order at the bar?",
  },
   {
    "title": "Something interesting about you?",
    "subtitle": "Tell something interesting about yourself",
  },
];

List<bool> isOpen = [];

@override
void initState() {
  super.initState();
  isOpen = List.filled(questionList.length, false);
}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.themeColor,
        statusBarIconBrightness: Brightness.light));

    // ignore: deprecated_member_use
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
      
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: SingleChildScrollView(
            child: Column(
              children: [
                    SizedBox(
                            height: MediaQuery.of(context).size.height * 4 / 100,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            width: MediaQuery.of(context).size.width * 2 / 100,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 73 / 100,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLanguage.vibeCheck[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          VibeCheckScreen2()));
                            },
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.skip[language],
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColor.greyLightColor,
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
        
                SizedBox(height: size.height * 2 / 100),
        
                SizedBox(
                  width: MediaQuery.of(context).size.width * 88 / 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textAlign: TextAlign.center,
                      '1/3',
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondryColor,
                      ),
                    ),
                  ),
                ),
        
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Image.asset(
                    AppImage.frequencyOneicon,
                    width: MediaQuery.of(context).size.width * 20 / 100,
                    height: MediaQuery.of(context).size.width * 10 / 100,
                  ),
                ),
                SizedBox(height: size.height * 2 / 100),
        
                //
        GestureDetector(
          onTap: () {
            setState(() {
              isDropdownOpen = !isDropdownOpen;
            });
          },
          child: Container(
            width: size.width * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.only(
        topLeft: Radius.circular(50),
        topRight: Radius.circular(50),
        bottomLeft: Radius.circular(isDropdownOpen ? 0 : 50),
        bottomRight: Radius.circular(isDropdownOpen ? 0 : 50),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "What's your perfect night out?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Describe your ideal evening in a few words.",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xffB7AFC9),
              ),
            ),
          ],
        ),
        AnimatedRotation(
          turns: isDropdownOpen ? 0.5 : 0,
          duration: Duration(milliseconds: 200),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
          ),
        ),
              ],
            ),
          ),
        ),
        
        
        // ===== DROPDOWN LIST (VISIBLE WHEN CLICKED) =====
        if (isDropdownOpen)
          Container(
            width: size.width * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            margin: const EdgeInsets.only(top: 0),
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(50),
        bottomRight: Radius.circular(50),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questionList.length,
              itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            print("Selected: ${questionList[index]["title"]}");
            setState(() {
              isDropdownOpen = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  questionList[index]["title"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  questionList[index]["subtitle"]!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffB7AFC9),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
              },
            ),
          ),
        
        
        
        
                SizedBox(height: size.height * 4 / 100),
        
        
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
                      // enabledBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(12),
                      //   borderSide: const BorderSide(
                      //     color: AppColor.borderColor,
                      //     width: 2,
                      //   ),
                      // ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(12),
                      //   borderSide: const BorderSide(
                      //     color: AppColor.borderColor,
                      //     width: 2,
                      //   ),
                      // ),
                      border: InputBorder.none,
                      hintText: AppLanguage.myperfectNight[language],
                      hintStyle: AppConstant.textFilledStyle1,
                      contentPadding: EdgeInsets.only(
                        right: size.width * 4 / 100,
                      ),
                    ),
                  ),
                ),
        
                SizedBox(
                  height: MediaQuery.of(context).size.height * 46 / 100,
                ),
                AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VibeCheckScreen2()));
                    }),
        
                //       Image.asset(
                //         AppImage.undo,
                //         width: MediaQuery.of(context).size.width * 64 / 100,
                //         height: MediaQuery.of(context).size.height * 8 / 100,
                //       ),
                //     ],
                //   ),
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
