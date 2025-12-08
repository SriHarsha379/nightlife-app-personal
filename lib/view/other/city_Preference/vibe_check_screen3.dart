// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:image_picker/image_picker.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/view/authentication/notification_screen.dart';
import 'package:night_life/view/authentication/profile.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import 'package:night_life/view/other/MySplashSection/MembersSection/member_liked_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/my_venue.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venue_liked_details.dart';
import 'package:night_life/view/other/chats/chat_message_screen.dart';
import 'package:night_life/view/bottom%20navigation/chats_screen.dart';
import 'package:night_life/view/other/city_Preference/gallery_screen.dart';
import 'package:night_life/view/other/city_Preference/party_preference.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'package:page_transition/page_transition.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class VibeCheckScreen3 extends StatefulWidget {
  static String routeName = './VibeCheckScreen3';

  const VibeCheckScreen3({super.key});

  @override
  State<VibeCheckScreen3> createState() => _VibeCheckScreen3State();
}

class _VibeCheckScreen3State extends State<VibeCheckScreen3> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;


  int reportId = 0;

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
bool isDropdownOpen = false;


List<bool> isOpen = [];

@override
void initState() {
  super.initState();
  isOpen = List.filled(questionList.length, false);
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
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                              width: MediaQuery.of(context).size.width * 5 / 100,
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 5 / 100,
                                child: Image.asset(
                                  AppImage.backArrowIcon,
                                  color: AppColor.secondryColor,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 2 / 100,),

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
                            onTap: (){
                                  Navigator.push(context,
                    PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: GalleryScreen(),
                    duration: const Duration(milliseconds: 600),
                  ),);
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
                      '3/3',
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
                    AppImage.frequencyIncrementlast,
                    width: MediaQuery.of(context).size.width * 20 / 100,
                    height: MediaQuery.of(context).size.width * 10 / 100,
                  ),
                ),
                              SizedBox(height: size.height * 2 / 100),
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
                      hintText:
                          AppLanguage.yourAnswer[language],
                      hintStyle: AppConstant.textFilledStyle1,
                      contentPadding: EdgeInsets.only(
                        right: size.width * 4 / 100,
                      ),
                    ),
                  ),
                ),
            
               
                SizedBox(
                  height: MediaQuery.of(context).size.height * 47 / 100,
                ),
                AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GalleryScreen()));
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
      ),
      // bottomNavigationBar: const AppFooter(
      //     selectedMenu: BottomMenus.home, notificationCount: 0),
    );
  }

  // void documenttypebottomsheet(BuildContext context) {
  //   final size = MediaQuery.of(context).size;

  //   showModalBottomSheet<void>(
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(),
  //     context: context,
  //     builder: (BuildContext context) {
  //       // String? tempSelected = selectedState;

  //       return StatefulBuilder(builder: (context, setStateBottomSheet) {
  //         return Container(
  //           width: MediaQuery.of(context).size.width * 100 / 100,
  //           height: MediaQuery.of(context).size.height * 60 / 100,
  //           color: Colors.transparent,
  //           child: Column(
  //             children: [
  //               Container(
  //                   width: MediaQuery.of(context).size.width * 100 / 100,
  //                   height: MediaQuery.of(context).size.height * 60 / 100,
  //                   // decoration: BoxDecoration(
  //                   //     borderRadius: BorderRadius.only(
  //                   //         topLeft: Radius.circular(50),
  //                   //         topRight: Radius.circular(50)),
  //                   //     color: Colors.transparent),
  //                   child: Column(
  //                     children: [
  //                       Expanded(
  //                         flex: 1,
  //                         child: SingleChildScrollView(
  //                           child: Container(
  //                             decoration: BoxDecoration(
  //                               gradient: AppColor.backgroundGradient,
  //                               // gradient: AppColor.chatContainerColor,
  //                               borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(46),
  //                                 topRight: Radius.circular(46),
  //                               ),
  //                             ),
  //                             width: size.width * 100 / 100,
  //                             height: size.height * 80 / 100,
  //                             child: Column(
  //                               children: [
  //                                 SizedBox(height: size.height * 2 / 100),
  //                                 ...List.generate(chats.length, (index) {
  //                                   final chat = chats[index];
  //                                   return Wrap(
  //                                     children: [
  //                                       Container(
  //                                         width: size.width * 90 / 100,
  //                                         height: size.height * 8.5 / 100,
  //                                         child: ListTile(
  //                                           contentPadding: EdgeInsets.zero,
  //                                           leading: Container(
  //                                             height: size.height * 10 / 100,
  //                                             width: size.width * 13 / 100,
  //                                             decoration: BoxDecoration(
  //                                               shape: BoxShape
  //                                                   .circle, // makes it circular
  //                                               image: DecorationImage(
  //                                                 image:
  //                                                     AssetImage(chat['image']),
  //                                                 fit: BoxFit.cover,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           title: Text(
  //                                             chat['name'],
  //                                             style: TextStyle(
  //                                               fontWeight: FontWeight.w600,
  //                                               fontSize: 16,
  //                                               color: AppColor.secondryColor,
  //                                             ),
  //                                           ),
  //                                           subtitle: Text(
  //                                             chat['lastMessage'],
  //                                             style: TextStyle(
  //                                               fontSize: 14,
  //                                               color: AppColor.secondryColor,
  //                                             ),
  //                                             maxLines: 1,
  //                                             overflow: TextOverflow.ellipsis,
  //                                           ),
  //                                           trailing: Container(
  //                                             padding:
  //                                                 const EdgeInsets.symmetric(
  //                                                     horizontal: 20,
  //                                                     vertical: 8),
  //                                             decoration: BoxDecoration(
  //                                               color: AppColor.secondryColor,
  //                                               borderRadius:
  //                                                   BorderRadius.circular(10),
  //                                               // border: Border.all(

  //                                               //      color : AppColor.primaryColor,
  //                                               // ),
  //                                             ),
  //                                             child: Text(
  //                                               chat['message'],
  //                                               style: TextStyle(
  //                                                 fontSize: 14,
  //                                                 fontWeight: FontWeight.w500,
  //                                                 fontFamily:
  //                                                     AppFont.fontFamily,
  //                                                 color: AppColor.primaryColor,
  //                                               ),
  //                                             ),
  //                                           ),
  //                                           onTap: () {
  //                                             // Handle chat item tap
  //                                             print(
  //                                                 'Tapped on ${chat['name']}');
  //                                             Navigator.push(
  //                                               context,
  //                                               MaterialPageRoute(
  //                                                 builder: (context) =>
  //                                                     ChatMessageScreen(
  //                                                   name: chat['name'],
  //                                                   image: chat['image'],
  //                                                 ),
  //                                               ),
  //                                             );
  //                                           },
  //                                         ),
  //                                       ),
  //                                       if (index < chats.length - 0)
  //                                         // Divider(
  //                                         //   height: 0.2,
  //                                         //   // thickness: 0.5,
  //                                         //   // color: Colors.grey[300],
  //                                         //   indent: 30,
  //                                         // ),
  //                                         if (index < chats.length - 0)
  //                                           SizedBox(
  //                                               height:
  //                                                   size.height * 0.1 / 100),
  //                                     ],
  //                                   );
  //                                 }),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   )),
  //             ],
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }
//
}
