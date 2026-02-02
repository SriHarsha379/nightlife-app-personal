import 'package:flutter/material.dart';
import 'package:night_life/view/bottom%20navigation/home_Screen.dart';
import 'package:night_life/view/bottom%20navigation/profile1.dart';
import 'package:night_life/view/bottom%20navigation/chats_screen.dart';
import 'package:night_life/view/bottom%20navigation/search_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../view/other/MySplashSection/EventSection/my_events.dart';
import '../view/other/MySplashSection/MembersSection/Members.dart';
import '../view/other/MySplashSection/VenuesSection/my_venue.dart';
import 'app_color.dart';
import 'app_constant.dart';
import 'app_font.dart';
import 'app_image.dart';
import 'app_language.dart';

class MyAppFooter extends StatefulWidget {
  final int initialIndex;

  const MyAppFooter({super.key, this.initialIndex = 4});

  @override
  State<MyAppFooter> createState() => MyAppFooterState();
}

class MyAppFooterState extends State<MyAppFooter> {
  PageController pageController = PageController(initialPage: 0);
  int selectedIndex = 0;
  int _previousIndex = 0;
  @override
  void initState() {
    pageController = PageController(initialPage: AppConstant.selectFooterIndex);
    selectedIndex = widget.initialIndex;
    _previousIndex = widget.initialIndex;

    super.initState();
  }

  final List<Map<String, dynamic>> iconList = [
    {
      "id": 1,
      "icon": AppImage.homeIcon,
    },
    {
      "id": 2,
      "icon": AppImage.searchIcon,
    },
    {
      "id": 3,
      "icon": AppImage.vectionIcon,
    },
    {
      "id": 5,
      "icon": AppImage.chatIcon,
    },
    {
      "id": 4,
      "icon": AppImage.whiteProfileicon,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          if (selectedIndex == 2) {
            return child;
          }

          return Container(
            color: AppColor.primaryColor,
            child: FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              ),
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(selectedIndex),
          child: _getCurrentPage(),
        ),
      ),
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 85 / 100,
            height: MediaQuery.of(context).size.height * 8 / 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColor.themeColor,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 4,
                  spreadRadius: 0,
                  color: AppColor.transparentColor,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 19),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(iconList.length, (index) {
                // Define icon sizes for each index
                double getIconWidth(int index) {
                  switch (index) {
                    case 0:
                      return MediaQuery.of(context).size.width * 8 / 100;
                    case 1:
                      return MediaQuery.of(context).size.width * 7 / 100;
                    case 2:
                      return MediaQuery.of(context).size.width * 7 / 100;
                    case 3:
                      return MediaQuery.of(context).size.width * 5.5 / 100;
                    default:
                      return MediaQuery.of(context).size.width * 5 / 100;
                  }
                }

                double getIconHeight(int index) {
                  switch (index) {
                    case 0:
                      return MediaQuery.of(context).size.width * 7 / 100;
                    case 1:
                      return MediaQuery.of(context).size.width * 6 / 100;
                    case 2:
                      return MediaQuery.of(context).size.width * 6 / 100;
                    case 3:
                      return MediaQuery.of(context).size.width * 6 / 100;
                    default:
                      return MediaQuery.of(context).size.width * 5 / 100;
                  }
                }

                return GestureDetector(
                  onTap: () {
                    onItemTapped(index);
                  },
                  child: Container(
                    width: selectedIndex == index
                        ? MediaQuery.of(context).size.width *
                            12.4 /
                            100 // smaller circle
                        : MediaQuery.of(context).size.width *
                            12.4 /
                            100, // normal
                    height: selectedIndex == index
                        ? MediaQuery.of(context).size.width * 10 / 100
                        : MediaQuery.of(context).size.width * 12.4 / 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedIndex == index
                          ? const Color.fromRGBO(255, 28, 192, 0.6)
                          : Colors.transparent,
                      boxShadow: selectedIndex == index
                          ? [
                              BoxShadow(
                                color: AppColor.buttonColor.withOpacity(1.0),
                                blurRadius: 20,
                                spreadRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      iconList[index]['icon'],
                      width: getIconWidth(index),
                      height: getIconHeight(index),
                      color: AppColor.secondryColor,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

// Helper method to get current page
  Widget _getCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return const Home();
      case 1:
        return const SearchScreen();
      case 2:
        return _getPreviousPage();
      case 3:
        return const ChatScreen();
      case 4:
        return const Profile1();
      default:
        return const Home();
    }
  }

// int _previousIndex = 0;

  Widget _getPreviousPage() {
    switch (_previousIndex) {
      case 0:
        return const Home();
      case 1:
        return const SearchScreen();
      case 3:
        return const ChatScreen();
      case 4:
        return const Profile1();
      default:
        return const Home();
    }
  }

  void onItemTapped(int index) {
    if (index == 2) {
      //  Don't change selectedIndex, just open bottom sheet
      documenttypebottomsheet(context);
    } else {
      setState(() {
        _previousIndex = selectedIndex;
        selectedIndex = index;
      });
    }
  }

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 78 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 78 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          width: size.width * 1.0,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Container(
                                width: size.width * 0.88,
                                child: Column(
                                  children: [
                                    // First Image

                                    Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        AppImage.dashIcon,
                                        height: size.height * 0.5 / 100,
                                        width: size.width * 22 / 100,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 4 / 100),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage.myspacetext[language],
                                        style: const TextStyle(
                                          color: AppColor.secondryColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .eventStatementtext[language],
                                        style: const TextStyle(
                                          color: AppColor.secondryColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.04),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: const splashMembers(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                AppImage.memberBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: size.height *
                                            0.02), // spacing between images
                                    // Second Image
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: const MyVenue(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                AppImage.venuesBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: const MyEvents(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                AppImage.eventsBanner),
                                            fit: BoxFit.fill,
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
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    ).then((_) {});
  }




}
