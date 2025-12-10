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
import 'package:night_life/view/other/city_Preference/vibe_check_screen.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuepages.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class BadgeScreen extends StatefulWidget {
  static String routeName = './BadgeScreen';

  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;

  @override
  void initState() {
    super.initState();
  }

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

  List chats = [
    {
      'id': 1,
      'image':
          'assets/icons/ProfilePhoto.png', // Replace with your actual image path
      'name': 'Gaurav Kapoor',
      'lastMessage': '@gkapoor02',
      'message': 'send',
    },
    {
      'id': 2,
      'image': 'assets/icons/riya.png',
      'name': 'Riya',
      'lastMessage': '@riya00',
      'message': 'send',
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Cafe',
      'lastMessage': '@cafebloom34',
      'message': 'send',
    },
    {
      'id': 4,
      'image': 'assets/icons/aadityaIcon.png',
      'name': 'Aaditya',
      'lastMessage': '@aadi54',
      'message': 'send',
    },
    {
      'id': 5,
      'image': 'assets/icons/rushi.png',
      'name': 'Rushi',
      'lastMessage': '@rushi87',
      'message': 'send',
    },
    {
      'id': 6,
      'image': 'assets/icons/soham.png',
      'name': 'Soham',
      'lastMessage': '@soham23',
      'message': 'send',
    },
  ];
  // final ImagePicker imagePicker = ImagePicker();
  // List<XFile>? imageFileList = [];

  // void selectImages() async {
  //   final List<XFile>? selectedImages = await imagePicker.pickMultiImage();

  //   if (selectedImages!.isNotEmpty) {
  //     imageFileList!.addAll(selectedImages);
  //   }
  //   print("Image List Length:" + imageFileList!.length.toString());
  //   setState(() {});
  // }
  // Future<void> _imgFromGallery() async {
  //   // ignore: deprecated_member_use
  //   dynamic image = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //       maxHeight: 450.0,
  //       maxWidth: 450.0,
  //       imageQuality: 50);
  //   if (image != null) {
  //     Future.delayed(const Duration(seconds: 2), () {
  //       setState(() {
  //         imageFileList!.add(image);
  //         _imageSelect = File(image!.path);
  //         fileName = image.path.split('/').last;

  //         var _btnActive = true;
  //         print(imageFileList);
  //       });
  //     });
  //   } else {
  //     setState(() {
  //       var _btnActive = false;
  //     });
  //   }

  //   // Navigator.of(context).pop();
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.secondryColor,
        statusBarIconBrightness: Brightness.dark));

    // ignore: deprecated_member_use
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
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
                          width: MediaQuery.of(context).size.width * 80 / 100,
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.partyPreferenceText[language],
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 20,
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
                width: MediaQuery.of(context).size.width * 90 / 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    AppLanguage.selectBadgeSentence[language],
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
                width: MediaQuery.of(context).size.width * 95 / 100,
                child: Image.asset(
                  AppImage.badgeIcon,
                  height: size.height * 66 / 100, // smaller, looks balanced
                  width: size.width * 15 / 100,
                ),
              ),

           

              SizedBox(
                height: MediaQuery.of(context).size.height * 5 / 100,
              ),
              AppButton(
                  text: AppLanguage.saveandContinue[language],
                  onPress: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VibeCheckScreen()));
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
    );
  }


}
