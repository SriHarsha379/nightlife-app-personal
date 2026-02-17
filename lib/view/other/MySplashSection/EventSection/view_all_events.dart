import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/my_events.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_header.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class ViewAllEventsScreen extends StatefulWidget {
  static String routeName = './ViewAllEventsScreen';
  const ViewAllEventsScreen({super.key});
  @override
  State<ViewAllEventsScreen> createState() => _ViewAllEventsScreenState();
}

class _ViewAllEventsScreenState extends State<ViewAllEventsScreen> {
  List Likedlist = [
    {
      'image': AppImage.roofimg,
      'title': 'Rustic Rooftop Lounge',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.brewandbloomIcon,
      'title': 'The Brew Corner',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
    {
      'image': AppImage.img3,
      'title': 'Summer Music Festival 2025',
      'date': 'Fri, 10 PM - 4 AM',
      'address': 'Club Neon, Downtown',
      'text': 'Mark',
    },
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            width: size.width * 100 / 100,
            height: size.height * 100 / 100,
            color: AppColor.primaryColor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
                AppHeader(
                  onPress: () => Navigator.pop(context),
                  text: AppLanguage.likedEvents[language],
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
                            Wrap(
                              runSpacing: 10,
                              children: List.generate(
                                Likedlist.length,
                                (index) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: MyEvents(),
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: size.width * 90 / 100,
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor(context),
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
                                                Likedlist[index]['image'],
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
                                                    Likedlist[index]['title'],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
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
                                                          .secondryColor(
                                                              context),
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
                                                    Likedlist[index]['date'],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
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
                                                  Text(
                                                    Likedlist[index]['address'],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
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
                                                        AppColor.secondryColor(
                                                            context),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Center(
                                                  child: Text(
                                                    AppLanguage
                                                            .ReservedtableText[
                                                        language],
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
}
