// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:night_life/view/other/MySplashSection/EventSection/my_events.dart';
// import 'package:night_life/view/other/MySplashSection/MembersSection/Members.dart';
// import 'package:night_life/view/other/friends_list_screen.dart';
// import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';
// import 'package:page_transition/page_transition.dart';
// import '../../../../utilities/app_color.dart';
// import '../../../utilities/app_constant.dart';
// import '../../../utilities/app_font.dart';
// import '../../../utilities/app_image.dart';
// import '../../../utilities/app_language.dart';
// import '../../authentication/notification_screen.dart';
// import '../../authentication/profile.dart';
// import '../chats/chat_message_screen.dart';
// import 'VenuesSection/my_venue.dart';

// class MySplashScreen extends StatefulWidget {
//   static String routeName = './MySplashScreen';

//   const MySplashScreen({super.key});

//   @override
//   State<MySplashScreen> createState() => _MySplashScreenState();
// }

// class _MySplashScreenState extends State<MySplashScreen> {
//   late TextEditingController searchController;

//   @override
//   void initState() {
//     super.initState();

//     searchController = TextEditingController();
//   }

//   @override
//   void dispose() {
//     searchController.dispose();
//     super.dispose();
//   }

//   List<Map<String, String>> storyImages = [
//     {"image": "assets/icons/ProfilePhoto.png", "name": "Arjun"},
//     {"image": "assets/icons/arjunrampalIcon.png", "name": "Arav"},
//     {"image": "assets/icons/galleryIcon.png", "name": "Bloom Cafe"},
//     {"image": "assets/icons/girlImage.png", "name": "Bistro"},
//     {"image": "assets/icons/userprofile.png", "name": "olivia"},
//   ];

//   List chats = [
//     {
//       'id': 1,
//       'image':
//           'assets/icons/ProfilePhoto.png', // Replace with your actual image path
//       'name': 'Smith Mathew',
//       'lastMessage': 'Hi, David. Hope you\'re doing...',
//       'time': '09:18',
//     },
//     {
//       'id': 2,
//       'image': 'assets/icons/arjunrampalIcon.png',
//       'name': 'Merry An.',
//       'lastMessage': 'Are you ready for today\'s part..',
//       'time': '12:44',
//     },
//     {
//       'id': 3,
//       'image': 'assets/icons/galleryIcon.png',
//       'name': 'John Walton',
//       'lastMessage': 'I\'am sending you a parcel rece..',
//       'time': '08:06',
//     },
//     {
//       'id': 4,
//       'image': 'assets/icons/girlImage.png',
//       'name': 'Monica Randawa',
//       'lastMessage': 'Hope you\'re doing well today..',
//       'time': '09:32',
//     },
//   ];
//   int selectedId = 3;

//   List Orders = [
//     {'id': 1, 'title': 'Members'},
//     {'id': 2, 'title': 'Events'},
//     {'id': 3, 'title': 'Venues'},
//     {'id': 4, 'title': 'All'},
//   ];
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//         statusBarColor: AppColor.secondryColor,
//         statusBarIconBrightness: Brightness.dark));

//     return GestureDetector(
//       onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//       child: Scaffold(
//         backgroundColor: AppColor.secondryColor,
//         body: SafeArea(
//           child: Container(
//             height: size.height * 100 / 100,
//             width: size.width * 100 / 100,
//             child: Column(
//               children: [
//                 // SizedBox(height: size.height * 0.2 / 100),
//                 // AppHeader(text: AppLanguage.chatsText[language]),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 98 / 100,
//                   height: MediaQuery.of(context).size.height * 9 / 100,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 16 / 100,
//                             child: SizedBox(
//                               height:
//                                   MediaQuery.of(context).size.height * 15 / 100,
//                               child: Image.asset(
//                                 AppImage.hiilogo,
//                                 color: AppColor.primaryColor,
//                               ),
//                             ),
//                           ),
//                           Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               1.5 /
//                                               100,
//                                     ),
//                                     Text(
//                                       AppLanguage.welcomeText[language],
//                                       style: TextStyle(
//                                         fontFamily: AppFont.fontFamily,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w400,
//                                         color: AppColor.primaryColor,
//                                       ),
//                                     ),
//                                     Text(
//                                       AppLanguage.sanjanaText[language],
//                                       style: TextStyle(
//                                         fontFamily: AppFont.fontFamily,
//                                         fontSize: 22,
//                                         fontWeight: FontWeight.w500,
//                                         color: AppColor.primaryColor,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ]),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 PageTransition(
//                                   type: PageTransitionType.rightToLeftWithFade,
//                                   child: Notifications(),
//                                   duration: const Duration(milliseconds: 500),
//                                 ),
//                               );
//                             },
//                             child: SizedBox(
//                               height:
//                                   MediaQuery.of(context).size.height * 3 / 100,
//                               child: Image.asset(
//                                 AppImage.bellicon,
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: size.width * 2 / 100,
//                           ),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 PageTransition(
//                                   type: PageTransitionType.rightToLeftWithFade,
//                                   child: Profile(),
//                                   duration: const Duration(milliseconds: 500),
//                                 ),
//                               );
//                             },
//                             child: SizedBox(
//                               height:
//                                   MediaQuery.of(context).size.height * 5 / 100,
//                               child: Image.asset(
//                                 AppImage.userimage,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: size.width * 4 / 100),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: size.height * 2 / 100),
//                 Container(
//                   width: size.width * 90 / 100,
//                   height: size.height * 5.5 / 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(40), // pill shape
//                     border: Border.all(color: AppColor.textfieldfillColor),
//                     color: AppColor.secondryColor,
//                     boxShadow: [
//                       BoxShadow(
//                         offset: const Offset(0, 4),
//                         spreadRadius: 0,
//                         blurRadius: 4,
//                         color: AppColor.primaryColor.withOpacity(0.1),
//                       ),
//                     ],
//                   ),
//                   child: TextFormField(
//                     controller: searchController,
//                     cursorColor: AppColor.primaryColor,
//                     style: AppConstant.textFilledStyle,
//                     textAlignVertical: TextAlignVertical.center,
//                     decoration: InputDecoration(
//                       prefixIcon: Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: size.width * 4 / 100,
//                           vertical: 10,
//                         ),
//                         child: Image.asset(
//                           AppImage.searchIcon,
//                           height: size.width * 4 / 100,
//                           width: size.width * 4 / 100,
//                           color: AppColor.textcolor,
//                         ),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(40),
//                         borderSide: const BorderSide(
//                           color: AppColor.primaryColor,
//                           width: 1,
//                         ),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(40),
//                         borderSide: const BorderSide(
//                           color: AppColor.primaryColor,
//                           width: 0,
//                         ),
//                       ),
//                       border: InputBorder.none,
//                       // hintText: AppLanguage.searchText[language],
//                       hintStyle: AppConstant.textFilledStyle,
//                       contentPadding: EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: size.width * 2 / 100,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 1 / 100,
//                 ),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       Wrap(
//                         direction: Axis.horizontal,
//                         children: List.generate(
//                           Orders.length,
//                           (index) {
//                             bool isAll = Orders[index]['id'] == 4;
//                             return GestureDetector(
//                               onTap: isAll
//                                   ? null
//                                   : () {
//                                       setState(() {
//                                         selectedId = Orders[index]['id'];
//                                       });
//                                     },
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal:
//                                       MediaQuery.of(context).size.width *
//                                           4 /
//                                           100,
//                                   vertical: MediaQuery.of(context).size.height *
//                                       1 /
//                                       100,
//                                 ),
//                                 alignment: Alignment.center,
//                                 margin: EdgeInsets.symmetric(horizontal: 6),
//                                 decoration: BoxDecoration(
//                                     color: selectedId == Orders[index]['id']
//                                         ? AppColor.secondryColor
//                                         : AppColor.secondryColor,
//                                     borderRadius: BorderRadius.circular(50),
//                                     border: Border.all(
//                                         color: selectedId == Orders[index]['id']
//                                             ? AppColor.buttonColor
//                                             : AppColor.textfilledColor)),
//                                 child: Text(
//                                   Orders[index]['title'],
//                                   style: TextStyle(
//                                       fontFamily: AppFont.fontFamily,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: selectedId == Orders[index]['id']
//                                           ? AppColor.buttonColor
//                                           : AppColor.textcolor),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 3 / 100),

//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       gradient: AppColor.backgroundGradientcolor,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(45),
//                         topRight: Radius.circular(45),
//                       ),
//                     ),
//                     width: size.width * 1.0,
//                     child: Column(
//                       children: [
//                         SizedBox(height: size.height * 0.02),
//                         Container(
//                           width: size.width * 0.88,
//                           child: Column(
//                             children: [
//                               // First Image

//                               Align(
//                                 alignment: Alignment.center,
//                                 child: Image.asset(
//                                   AppImage.dashIcon,
//                                   height: size.height * 0.6 / 100,
//                                   width: size.width * 22 / 100,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 2 / 100),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * 0.93,
//                                 child: Text(
//                                   AppLanguage.myspacetext[language],
//                                   style: const TextStyle(
//                                     color: AppColor.secondryColor,
//                                     fontFamily: AppFont.fontFamily,
//                                     fontWeight: FontWeight.w600,
//                                     fontSize: 23,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * 0.88,
//                                 child: Text(
//                                   AppLanguage.eventStatementtext[language],
//                                   style: const TextStyle(
//                                     color: AppColor.secondryColor,
//                                     fontFamily: AppFont.fontFamily,
//                                     fontWeight: FontWeight.w500,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.02),

//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     PageTransition(
//                                       type: PageTransitionType
//                                           .rightToLeftWithFade,
//                                       child: splashMembers(),
//                                       duration:
//                                           const Duration(milliseconds: 500),
//                                     ),
//                                   );
//                                   ;
//                                 },
//                                 child: Container(
//                                   width: size.width * 0.92,
//                                   height: size.height * 0.17,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(20),
//                                     image: DecorationImage(
//                                       image: AssetImage(AppImage.memberBanner),
//                                       fit: BoxFit.fill,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                   height: size.height *
//                                       0.01), // spacing between images
//                               // Second Image
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     PageTransition(
//                                       type: PageTransitionType
//                                           .rightToLeftWithFade,
//                                       child: MyVenue(),
//                                       duration:
//                                           const Duration(milliseconds: 500),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   width: size.width * 0.88,
//                                   height: size.height * 0.17,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(15),
//                                     image: DecorationImage(
//                                       image: AssetImage(AppImage.venuesBanner),
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.01),
//                               // Third Image
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     PageTransition(
//                                       type: PageTransitionType
//                                           .rightToLeftWithFade,
//                                       child: MyEvents(),
//                                       duration:
//                                           const Duration(milliseconds: 500),
//                                     ),
//                                   );
//                                 },
//                                 child: Container(
//                                   width: size.width * 0.92,
//                                   height: size.height * 0.17,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(15),
//                                     image: DecorationImage(
//                                       image: AssetImage(AppImage.eventsBanner),
//                                       fit: BoxFit.fill,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // SizedBox(
//                         //     height: size.height * 0.06),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void splashMyspacebottomsheet(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     showModalBottomSheet<void>(
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(),
//       context: context,
//       builder: (BuildContext context) {
//         // String? tempSelected = selectedState;

//         return StatefulBuilder(builder: (context, setStateBottomSheet) {
//           return Container(
//             width: MediaQuery.of(context).size.width * 100 / 100,
//             height: MediaQuery.of(context).size.height * 60 / 100,
//             color: Colors.transparent,
//             child: Column(
//               children: [
//                 Container(
//                     width: MediaQuery.of(context).size.width * 100 / 100,
//                     height: MediaQuery.of(context).size.height * 60 / 100,
//                     // decoration: BoxDecoration(
//                     //     borderRadius: BorderRadius.only(
//                     //         topLeft: Radius.circular(50),
//                     //         topRight: Radius.circular(50)),
//                     //     color: Colors.transparent),

//                     child: Column(
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               gradient: AppColor.backgroundGradientcolor,
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(45),
//                                 topRight: Radius.circular(45),
//                               ),
//                             ),
//                             width: size.width * 1.0,
//                             child: Column(
//                               children: [
//                                 SizedBox(height: size.height * 0.02),
//                                 Container(
//                                   width: size.width * 0.88,
//                                   child: Column(
//                                     children: [
//                                       // First Image

//                                       Align(
//                                         alignment: Alignment.center,
//                                         child: Image.asset(
//                                           AppImage.dashIcon,
//                                           height: size.height * 0.6 / 100,
//                                           width: size.width * 22 / 100,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                       SizedBox(height: size.height * 2 / 100),
//                                       SizedBox(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.93,
//                                         child: Text(
//                                           AppLanguage.myspacetext[language],
//                                           style: const TextStyle(
//                                             color: AppColor.secondryColor,
//                                             fontFamily: AppFont.fontFamily,
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 23,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.93,
//                                         child: Text(
//                                           AppLanguage
//                                               .eventStatementtext[language],
//                                           style: const TextStyle(
//                                             color: AppColor.secondryColor,
//                                             fontFamily: AppFont.fontFamily,
//                                             fontWeight: FontWeight.w500,
//                                             fontSize: 12,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: size.height * 0.02),

//                                       GestureDetector(
//                                         onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             PageTransition(
//                                               type: PageTransitionType
//                                                   .rightToLeftWithFade,
//                                               child: splashMembers(),
//                                               duration: const Duration(
//                                                   milliseconds: 500),
//                                             ),
//                                           );
//                                         },
//                                         child: Container(
//                                           width: size.width * 0.92,
//                                           height: size.height * 0.17,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(20),
//                                             image: DecorationImage(
//                                               image: AssetImage(
//                                                   AppImage.memberBanner),
//                                               fit: BoxFit.fill,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                           height: size.height *
//                                               0.01), // spacing between images
//                                       // Second Image
//                                       GestureDetector(
//                                         onTap: () {
//                                           Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: ((context) =>
//                                                       MyVenue())));
//                                         },
//                                         child: Container(
//                                           width: size.width * 0.94,
//                                           height: size.height * 0.17,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                             image: DecorationImage(
//                                               image: AssetImage(
//                                                   AppImage.venuesBanner),
//                                               fit: BoxFit.fill,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(height: size.height * 0.01),
//                                       // Third Image
//                                       GestureDetector(
//                                         onTap: () {
//                                           Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                   builder: ((context) =>
//                                                       MyEvents())));
//                                         },
//                                         child: Container(
//                                           width: size.width * 0.99,
//                                           height: size.height * 0.17,
//                                           decoration: BoxDecoration(
//                                             borderRadius:
//                                                 BorderRadius.circular(15),
//                                             image: DecorationImage(
//                                               image: AssetImage(
//                                                   AppImage.eventsBanner),
//                                               fit: BoxFit.fill,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // SizedBox(
//                                 //     height: size.height * 0.06),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     )),
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }
// }
