// // import 'dart:html';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_html/flutter_html.dart';

// import 'package:image_picker/image_picker.dart';
// import 'package:night_life/view/authentication/notification_screen.dart';
// import 'package:night_life/view/authentication/profile.dart';
// import 'package:night_life/view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
// import 'package:night_life/view/other/MySplashSection/MembersSection/member_liked_details.dart';
// import 'package:night_life/view/other/MySplashSection/VenuesSection/my_venue.dart';
// import 'package:night_life/view/other/MySplashSection/VenuesSection/venue_liked_details.dart';
// import 'package:night_life/view/other/chats/chat_message_screen.dart';
// import 'package:night_life/view/bottom%20navigation/chats_screen.dart';
// import 'package:night_life/view/other/city_Preference/badge_screen.dart';
// import 'package:night_life/view/other/upload_id_screen.dart';
// import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';

// import '../../../utilities/app_button.dart';
// import '../../../utilities/app_color.dart';
// import '../../../utilities/app_constant.dart';
// import '../../../utilities/app_font.dart';
// import '../../../utilities/app_image.dart';
// import '../../../utilities/app_language.dart';

// class PartyPreference extends StatefulWidget {
//   static String routeName = './PartyPreference';

//   const PartyPreference({super.key});

//   @override
//   State<PartyPreference> createState() => _PartyPreferenceState();
// }

// class _PartyPreferenceState extends State<PartyPreference> {
//   // File? _imageSelect;
//   // ignore: prefer_typing_uninitialized_variables
//   var fileName;

//   @override
//   void initState() {
//     super.initState();
//   }

//   int reportId = 0;

//   int selectedId = 2;
//   List Orders = [
//     {'id': 1, 'title': 'Hip Hop',"music":"Electronic"},
//     {'id': 2, 'title': 'House',"music":"Techno"},
//     {'id': 3, 'title': 'R&B',"music":"Pop"},
//     {'id': 4, 'title': 'Latin',"music":"Reggeston"},
//     {'id': 5, 'title': 'Indie',"music":"Rock"},
//     {'id': 6, 'title': 'Disco',"music":"Funk"},
   
//   ];
//   List<Map<String, dynamic>> imageList = [
//     {
//       "image": AppImage.div3,
//     },
//     {
//       "image": AppImage.div,
//     },
//     {
//       "image": AppImage.div2,
//     },
//   ];
//   TextEditingController searchController = TextEditingController();

//  List Events = [
//     {'id': 1, 'title': 'Techno'},
//     {'id': 2, 'title': 'Concerts'},
//     {'id': 3, 'title': 'Banglore'},
//     {'id': 4, 'title': 'Clubs'},
//     {'id': 5, 'title': 'DJ Sets'},
//     {'id': 6, 'title': 'Live Band'},
//   ];

//    List Vibe = [
//     {'id': 1, 'title': 'Energetic 💥'},
//     {'id': 2, 'title': 'Chill 😎'},
//     {'id': 3, 'title': 'Romantic 😍'},
//     {'id': 4, 'title': 'Intimate 🤗'},
//     {'id': 5, 'title': 'Wild 😈'},
//   ];
//   List chats = [
//     {
//       'id': 1,
//       'image':
//           'assets/icons/ProfilePhoto.png', // Replace with your actual image path
//       'name': 'Gaurav Kapoor',
//       'lastMessage': '@gkapoor02',
//       'message': 'send',
//     },
//     {
//       'id': 2,
//       'image': 'assets/icons/riya.png',
//       'name': 'Riya',
//       'lastMessage': '@riya00',
//       'message': 'send',
//     },
//     {
//       'id': 3,
//       'image': 'assets/icons/galleryIcon.png',
//       'name': 'Bloom Cafe',
//       'lastMessage': '@cafebloom34',
//       'message': 'send',
//     },
//     {
//       'id': 4,
//       'image': 'assets/icons/aadityaIcon.png',
//       'name': 'Aaditya',
//       'lastMessage': '@aadi54',
//       'message': 'send',
//     },
//     {
//       'id': 5,
//       'image': 'assets/icons/rushi.png',
//       'name': 'Rushi',
//       'lastMessage': '@rushi87',
//       'message': 'send',
//     },
//     {
//       'id': 6,
//       'image': 'assets/icons/soham.png',
//       'name': 'Soham',
//       'lastMessage': '@soham23',
//       'message': 'send',
//     },
//   ];
//   // final ImagePicker imagePicker = ImagePicker();
//   // List<XFile>? imageFileList = [];

//   // void selectImages() async {
//   //   final List<XFile>? selectedImages = await imagePicker.pickMultiImage();

//   //   if (selectedImages!.isNotEmpty) {
//   //     imageFileList!.addAll(selectedImages);
//   //   }
//   //   print("Image List Length:" + imageFileList!.length.toString());
//   //   setState(() {});
//   // }
//   // Future<void> _imgFromGallery() async {
//   //   // ignore: deprecated_member_use
//   //   dynamic image = await ImagePicker().pickImage(
//   //       source: ImageSource.gallery,
//   //       maxHeight: 450.0,
//   //       maxWidth: 450.0,
//   //       imageQuality: 50);
//   //   if (image != null) {
//   //     Future.delayed(const Duration(seconds: 2), () {
//   //       setState(() {
//   //         imageFileList!.add(image);
//   //         _imageSelect = File(image!.path);
//   //         fileName = image.path.split('/').last;

//   //         var _btnActive = true;
//   //         print(imageFileList);
//   //       });
//   //     });
//   //   } else {
//   //     setState(() {
//   //       var _btnActive = false;
//   //     });
//   //   }

//   //   // Navigator.of(context).pop();
//   // }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//         statusBarColor: AppColor.secondryColor,
//         statusBarIconBrightness: Brightness.dark));

//     // ignore: deprecated_member_use
//     return Scaffold(
//       backgroundColor: Colors.white,

//       body: SafeArea(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 100 / 100,
//           height: MediaQuery.of(context).size.height * 100 / 100,
//           decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 90 / 100,
//                   height: MediaQuery.of(context).size.height * 8 / 100,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: SizedBox(
//                               width: MediaQuery.of(context).size.width * 4 / 100,
//                               child: SizedBox(
//                                 height:
//                                     MediaQuery.of(context).size.height * 5 / 100,
//                                 child: Image.asset(
//                                   AppImage.backArrowIcon,
//                                   color: AppColor.secondryColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 80 / 100,
//                             child: Center(
//                               child: Text(
//                                 textAlign: TextAlign.center,
//                                 AppLanguage.partyPreferenceText[language],
//                                 style: TextStyle(
//                                   fontFamily: AppFont.fontFamily,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w700,
//                                   color: AppColor.secondryColor,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
            
//                       // Row(
//                       //   children: [
//                       //     GestureDetector(
//                       //       onTap: () {
//                       //         Navigator.push(
//                       //           context,
//                       //           MaterialPageRoute(
//                       //               builder: (context) => const Notifications()),
//                       //         );
//                       //       },
//                       //       child: SizedBox(
//                       //         height:
//                       //             MediaQuery.of(context).size.height * 3 / 100,
//                       //         child: Image.asset(
//                       //           AppImage.bellicon,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //     SizedBox(
//                       //       width: size.width * 2 / 100,
//                       //     ),
//                       //     GestureDetector(
//                       //       onTap: () {
//                       //         Navigator.push(
//                       //           context,
//                       //           MaterialPageRoute(
//                       //               builder: (context) => const Profile()),
//                       //         );
//                       //       },
//                       //       child: SizedBox(
//                       //         height:
//                       //             MediaQuery.of(context).size.height * 5 / 100,
//                       //         child: Image.asset(
//                       //           AppImage.userimage,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // )
//                     ],
//                   ),
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 90 / 100,
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       textAlign: TextAlign.center,
//                       AppLanguage.musicGenres[language],
//                       style: TextStyle(
//                         fontFamily: AppFont.fontFamily,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.secondryColor,
//                       ),
//                     ),
//                   ),
//                 ),
            
               
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 1 / 100,
//                 ),
//                     SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: List.generate(
//                   Orders.length, // generate for all items
//                   (index) {
//                     return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedId = Orders[index]['id'];
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 9),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: MediaQuery.of(context).size.width * 0.04,
//                         vertical: MediaQuery.of(context).size.height * 0.018,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColor.filledcolor,
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: AppColor.buttonColor),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.music_note,
//                               size: 16, color: Colors.white),
//                            SizedBox(width:MediaQuery.of(context).size.width*2/100),
//                           Text(
//                             Orders[index]['title'],
//                             style: TextStyle(
//                               fontFamily: AppFont.fontFamily,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: AppColor.secondryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
            
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 9),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: MediaQuery.of(context).size.width * 0.04,
//                       vertical: MediaQuery.of(context).size.height * 0.018,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColor.filledcolor,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: AppColor.buttonColor),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.music_note,
//                             size: 16, color: Colors.white),
//              SizedBox(width:MediaQuery.of(context).size.width*2/100),                      Text(
//                           Orders[index]['music'],
//                           style: TextStyle(
//                             fontFamily: AppFont.fontFamily,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w600,
//                             color: AppColor.secondryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(
//                   height: MediaQuery.of(context).size.height * 1 / 100,
//                 ),
//              SizedBox(
//                   width: MediaQuery.of(context).size.width * 90 / 100,
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       textAlign: TextAlign.center,
//                       AppLanguage.eventTypetext[language],
//                       style: TextStyle(
//                         fontFamily: AppFont.fontFamily,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.secondryColor,
//                       ),
//                     ),
//                   ),
//                 ),
//             SizedBox(
//                   height: MediaQuery.of(context).size.height * 1 / 100,
//                 ),
//                Wrap(
//                       spacing: 16, // horizontal space between items
//                       runSpacing: 10, // vertical space between rows
//                       children: List.generate(
//                         Events.length,
//                         (index) {
//                           bool isAll = Events[index]['id'] == 1;
            
//                           return GestureDetector(
//                             onTap: isAll
//                                 ? null
//                                 : () {
//                                     setState(() {
//                                       selectedId = Events[index]['id'];
//                                     });
//                                   },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 24, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: selectedId == Events[index]['id']
//                                     ? AppColor.filledcolor
//                                     : AppColor.filledcolor,
//                                 borderRadius: BorderRadius.circular(50),
//                                 border: Border.all(
//                                   color: selectedId == Events[index]['id']
//                                       ? AppColor.buttonColor
//                                       : AppColor.buttonColor,
//                                 ),
//                               ),
//                               child: Text(
//                                 Events[index]['title'],
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   fontFamily: AppFont.fontFamily,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500,
//                                   color: selectedId == Events[index]['id']
//                                       ? AppColor.secondryColor
//                                       : AppColor.secondryColor,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
            
//             SizedBox(
//                   height: MediaQuery.of(context).size.height * 2 / 100,
//                 ),
//                  SizedBox(
//                   width: MediaQuery.of(context).size.width * 90 / 100,
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       textAlign: TextAlign.center,
//                       AppLanguage.vibe[language],
//                       style: TextStyle(
//                         fontFamily: AppFont.fontFamily,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: AppColor.secondryColor,
//                       ),
//                     ),
//                   ),
//                 ),

// SizedBox(
//                   height: MediaQuery.of(context).size.height * 2 / 100,
//                 ),
//                   Wrap(
//                     spacing: 10, // horizontal space between items
//                     runSpacing: 10, // vertical space between rows
//                     children: List.generate(
//                       Vibe.length,
//                       (index) {
//                         bool isAll = Vibe[index]['id'] == 1;

//                         return GestureDetector(
//                           onTap: isAll
//                               ? null
//                               : () {
//                                   setState(() {
//                                     selectedId = Vibe[index]['id'];
//                                   });
//                                 },
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 18, vertical: 8),
//                             decoration: BoxDecoration(
//                               color: selectedId == Vibe[index]['id']
//                                   ? AppColor.filledcolor
//                                   : AppColor.filledcolor,
//                               borderRadius: BorderRadius.circular(50),
//                               border: Border.all(
//                                 color: selectedId == Vibe[index]['id']
//                                     ? AppColor.buttonColor
//                                     : AppColor.buttonColor,
//                               ),
//                             ),
//                             child: Text(
//                               Vibe[index]['title'],
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontFamily: AppFont.fontFamily,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: selectedId == Vibe[index]['id']
//                                     ? AppColor.secondryColor
//                                     : AppColor.secondryColor,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
            
                
//                  SizedBox(
//                       height: MediaQuery.of(context).size.height * 4 / 100,
//                     ),
//                     AppButton(
//                         text: AppLanguage.continueText[language],
                        
//                         onPress: () {
//                           Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadIDScreen()));
//                         }
//                         ),
            
//               SizedBox(
//                       height: MediaQuery.of(context).size.height * 4 / 100,
//                     ),
            
//                 // ),
            
//                 // Container(
            
//                 //   margin: EdgeInsets.symmetric(horizontal: 90, vertical: 1),
//                 //   width: MediaQuery.of(context).size.width * 100 / 100,
//                 //   height: MediaQuery.of(context).size.width *20 / 100,
//                 //   child: Image.asset(
//                 //     AppImage.undo,
//                 //     fit: BoxFit.contain,
//                 //   ),
//                 // ),
            
//                 // SizedBox(
//                 //   height: MediaQuery.of(context).size.height * 2 / 100,
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       // bottomNavigationBar: const AppFooter(
//       //     selectedMenu: BottomMenus.home, notificationCount: 0),
//     );
//   }

//   // void documenttypebottomsheet(BuildContext context) {
//   //   final size = MediaQuery.of(context).size;

//   //   showModalBottomSheet<void>(
//   //     backgroundColor: Colors.transparent,
//   //     isScrollControlled: true,
//   //     shape: const RoundedRectangleBorder(),
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       // String? tempSelected = selectedState;

//   //       return StatefulBuilder(builder: (context, setStateBottomSheet) {
//   //         return Container(
//   //           width: MediaQuery.of(context).size.width * 100 / 100,
//   //           height: MediaQuery.of(context).size.height * 60 / 100,
//   //           color: Colors.transparent,
//   //           child: Column(
//   //             children: [
//   //               Container(
//   //                   width: MediaQuery.of(context).size.width * 100 / 100,
//   //                   height: MediaQuery.of(context).size.height * 60 / 100,
//   //                   // decoration: BoxDecoration(
//   //                   //     borderRadius: BorderRadius.only(
//   //                   //         topLeft: Radius.circular(50),
//   //                   //         topRight: Radius.circular(50)),
//   //                   //     color: Colors.transparent),
//   //                   child: Column(
//   //                     children: [
//   //                       Expanded(
//   //                         flex: 1,
//   //                         child: SingleChildScrollView(
//   //                           child: Container(
//   //                             decoration: BoxDecoration(
//   //                               gradient: AppColor.backgroundGradient,
//   //                               // gradient: AppColor.chatContainerColor,
//   //                               borderRadius: BorderRadius.only(
//   //                                 topLeft: Radius.circular(46),
//   //                                 topRight: Radius.circular(46),
//   //                               ),
//   //                             ),
//   //                             width: size.width * 100 / 100,
//   //                             height: size.height * 80 / 100,
//   //                             child: Column(
//   //                               children: [
//   //                                 SizedBox(height: size.height * 2 / 100),
//   //                                 ...List.generate(chats.length, (index) {
//   //                                   final chat = chats[index];
//   //                                   return Wrap(
//   //                                     children: [
//   //                                       Container(
//   //                                         width: size.width * 90 / 100,
//   //                                         height: size.height * 8.5 / 100,
//   //                                         child: ListTile(
//   //                                           contentPadding: EdgeInsets.zero,
//   //                                           leading: Container(
//   //                                             height: size.height * 10 / 100,
//   //                                             width: size.width * 13 / 100,
//   //                                             decoration: BoxDecoration(
//   //                                               shape: BoxShape
//   //                                                   .circle, // makes it circular
//   //                                               image: DecorationImage(
//   //                                                 image:
//   //                                                     AssetImage(chat['image']),
//   //                                                 fit: BoxFit.cover,
//   //                                               ),
//   //                                             ),
//   //                                           ),
//   //                                           title: Text(
//   //                                             chat['name'],
//   //                                             style: TextStyle(
//   //                                               fontWeight: FontWeight.w600,
//   //                                               fontSize: 16,
//   //                                               color: AppColor.secondryColor,
//   //                                             ),
//   //                                           ),
//   //                                           subtitle: Text(
//   //                                             chat['lastMessage'],
//   //                                             style: TextStyle(
//   //                                               fontSize: 14,
//   //                                               color: AppColor.secondryColor,
//   //                                             ),
//   //                                             maxLines: 1,
//   //                                             overflow: TextOverflow.ellipsis,
//   //                                           ),
//   //                                           trailing: Container(
//   //                                             padding:
//   //                                                 const EdgeInsets.symmetric(
//   //                                                     horizontal: 20,
//   //                                                     vertical: 8),
//   //                                             decoration: BoxDecoration(
//   //                                               color: AppColor.secondryColor,
//   //                                               borderRadius:
//   //                                                   BorderRadius.circular(10),
//   //                                               // border: Border.all(

//   //                                               //      color : AppColor.primaryColor,
//   //                                               // ),
//   //                                             ),
//   //                                             child: Text(
//   //                                               chat['message'],
//   //                                               style: TextStyle(
//   //                                                 fontSize: 14,
//   //                                                 fontWeight: FontWeight.w500,
//   //                                                 fontFamily:
//   //                                                     AppFont.fontFamily,
//   //                                                 color: AppColor.primaryColor,
//   //                                               ),
//   //                                             ),
//   //                                           ),
//   //                                           onTap: () {
//   //                                             // Handle chat item tap
//   //                                             print(
//   //                                                 'Tapped on ${chat['name']}');
//   //                                             Navigator.push(
//   //                                               context,
//   //                                               MaterialPageRoute(
//   //                                                 builder: (context) =>
//   //                                                     ChatMessageScreen(
//   //                                                   name: chat['name'],
//   //                                                   image: chat['image'],
//   //                                                 ),
//   //                                               ),
//   //                                             );
//   //                                           },
//   //                                         ),
//   //                                       ),
//   //                                       if (index < chats.length - 0)
//   //                                         // Divider(
//   //                                         //   height: 0.2,
//   //                                         //   // thickness: 0.5,
//   //                                         //   // color: Colors.grey[300],
//   //                                         //   indent: 30,
//   //                                         // ),
//   //                                         if (index < chats.length - 0)
//   //                                           SizedBox(
//   //                                               height:
//   //                                                   size.height * 0.1 / 100),
//   //                                     ],
//   //                                   );
//   //                                 }),
//   //                               ],
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   )),
//   //             ],
//   //           ),
//   //         );
//   //       });
//   //     },
//   //   );
//   // }
// //
// }
