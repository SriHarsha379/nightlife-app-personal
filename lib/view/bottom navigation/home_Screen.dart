import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:night_life/view/authentication/notification_screen.dart';
import 'package:night_life/view/authentication/profile.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/liked_event_details.dart';
import 'package:night_life/view/other/chats/chat_message_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../commonWidget/home_widget.dart';
import '../../provider/darkmode_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../other/MySplashSection/MembersSection/member_liked_details.dart';
import '../other/MySplashSection/VenuesSection/venuepages.dart';

class Home extends StatefulWidget {
  static String routeName = './Home';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CardSwiperController cardController = CardSwiperController();
  final CardSwiperController swipeControllerfollowGuardians =
      CardSwiperController();
  @override
  void initState() {
    super.initState();
  }

  int reportId = 0;

  DateTime? lastPressed;
  int selectedId = 1;

  List orders = [
    {'id': 1, 'title': 'Members'},
    {'id': 2, 'title': 'Events'},
    {'id': 3, 'title': 'Venues'},
  ];

  List chats = [
    {
      'id': 1,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Brew&Bloom',
      'lastMessage': '@Brew&BloomCafé',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Techno',
      'lastMessage': '@Techno',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/eventstory3.png',
      'name': 'SUNBURN',
      'lastMessage': '@Sunburn',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/eventstory1.jpg',
      'name': 'Mitro',
      'lastMessage': '@Mitro',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Razberry',
      'lastMessage': '@Razberry',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/eventstory3.png',
      'name': 'CCD',
      'lastMessage': '@CCD',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
  ];

  List chatsLists = [
    {
      'id': 1,
      'image': 'assets/icons/ProfilePhoto.png',
      'name': 'Gaurav Kapoor',
      'lastMessage': '@gkapoor02',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/riya.png',
      'name': 'Riya',
      'lastMessage': '@riya00',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Café',
      'lastMessage': '@cafebloom34',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/aadityaIcon.png',
      'name': 'Aaditya',
      'lastMessage': '@aadi54',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/rushi.png',
      'name': 'Rushi',
      'lastMessage': '@rushi87',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/Soham.png',
      'name': 'soham',
      'lastMessage': '@soham23',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
  ];

  bool showHeart = false;
  bool showCross = false;
  String? lastSwipeType; // 'heart' or 'cross'
  bool isSend = true;
  final CardSwiperController membersSwiperController = CardSwiperController();
  final CardSwiperController eventsSwiperController = CardSwiperController();
  final CardSwiperController venuesSwiperController = CardSwiperController();

  //! Add these for tracking
  int currentMemberIndex = 0;
  int currentEventIndex = 0;
  int currentVenueIndex = 0;
  int selectedIndex = 0;

  bool isYes = false;
  bool isNope = false;
  double swipeProgress = 0.0;

  List<dynamic> membersData = [
    {'_id': '1', 'image': AppImage.userImage1, 'name': "Gourav Kapoor"},
    {'_id': '2', 'image': AppImage.userImage2, 'name': "Jack Danials"},
    {'_id': '3', 'image': AppImage.userImage3, 'name': "Tony Stark"},
  ];

  List<dynamic> venuesData = [
    {'_id': '1', 'image': AppImage.venu1},
    {'_id': '2', 'image': AppImage.venu2},
  ];

  List<dynamic> eventsData = [
    {'_id': '1', 'image': AppImage.eventimg},
    {'_id': '2', 'image': AppImage.eventImg2},
  ];

  bool _onSwipeMembers(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      // Swipe right to left (cross)
      setState(() {
        showCross = true;
        showHeart = false;
        lastSwipeType = 'heart';
      });

      // Reset after animation duration
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showCross = false;
            lastSwipeType = null;
          });
        }
      });
    } else if (direction == CardSwiperDirection.left) {
      // Swipe left to right (heart)
      setState(() {
        showHeart = true;
        showCross = false;
        lastSwipeType = 'cross';
      });

      // Reset after animation duration
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showHeart = false;
            lastSwipeType = null;
          });
        }
      });
    }

    setState(() {
      currentMemberIndex = currentIndex ?? 0;
    });
    return true;
  }

  bool _onSwipeEvents(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      // Swipe right to left (cross)
      print('Liked event: ${eventsData[previousIndex]['_id']}');
      setState(() {
        showCross = true;
        showHeart = false;
        lastSwipeType = 'heart';
      });

      // Reset after animation duration
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showCross = false;
            lastSwipeType = null;
          });
        }
      });
    } else if (direction == CardSwiperDirection.left) {
      // Swipe left to right (heart)
      setState(() {
        showHeart = true;
        showCross = false;
        lastSwipeType = 'cross';
      });

      // Reset after animation duration
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showHeart = false;
            lastSwipeType = null;
          });
        }
      });
    }

    setState(() {
      log("currentIndex$currentIndex");
      currentEventIndex = currentIndex ?? 0;
    });

    return true;
  }

  bool _onSwipeVenues(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      // Swipe right to left (cross)
      print('Liked venue: ${venuesData[previousIndex]['_id']}');
      setState(() {
        showCross = true;
        showHeart = false;
        lastSwipeType = 'heart';
      });

      // Reset after animation duration
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showCross = false;
            lastSwipeType = null;
          });
        }
      });
    } else if (direction == CardSwiperDirection.left) {
      // Swipe left to right (heart)
      setState(() {
        showHeart = true;
        showCross = false;
        lastSwipeType = 'cross';
      });

      // Reset after animation duration
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showHeart = false;
            lastSwipeType = null;
          });
        }
      });
    }
    setState(() {
      currentVenueIndex = currentIndex ?? 0;
    });
    return true;
  }

  @override
  void dispose() {
    membersSwiperController.dispose();
    eventsSwiperController.dispose();
    venuesSwiperController.dispose();
    super.dispose();
  }

  int membersTabVersion = 0;
  int eventTabVersion = 0;
  int venusTabVersion = 0;

  final List<String> shareIcons = [
    AppImage.shareIcon,
    AppImage.whatsappIcon,
    AppImage.instaIcon,
    AppImage.snapIcon,
  ];

  int selectedTab = 0; // 0=Members, 1=Events, 2=Venues

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          final now = DateTime.now();
          const maxDuration = Duration(seconds: 2);
          final isWarning =
              lastPressed == null || now.difference(lastPressed!) > maxDuration;
          if (isWarning) {
            lastPressed = now;
            SnackBarToastMessage.showSnackBar(
                context, AppLanguage.pressAgainExitText[language]);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.primaryColor,
          body: SafeArea(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 100 / 100,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 95 / 100,
                    height: MediaQuery.of(context).size.height * 9 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 14 / 100,
                              child: Image.asset(
                                AppImage.hiilogo,
                                color: isDark
                                    ? AppColor.darkTextColor
                                    : AppColor.richBlackColor,
                                width: MediaQuery.of(context).size.width *
                                    10 /
                                    100,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                                Text(
                                  AppLanguage.welcomeText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? AppColor.darkTextColor
                                        : AppColor.richBlackColor,
                                  ),
                                ),
                                Text(
                                  AppLanguage.sanjanaText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColor.secondryColor
                                        : AppColor.richBlackColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.topToBottom,
                                    child: const Notifications(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100,
                                child: Image.asset(
                                  AppImage.bellicon,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 2 / 100,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: const Profile(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                child: Image.asset(
                                  AppImage.userimage,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 4 / 100),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Wrap(
                          direction: Axis.horizontal,
                          children: List.generate(
                            orders.length,
                            (index) {
                              bool isAll = orders[index]['id'] == 4;
                              return GestureDetector(
                                onTap: isAll
                                    ? null
                                    : () {
                                        setState(() {
                                          if (orders[index]['id'] == 1) {
                                            membersTabVersion++;
                                            eventTabVersion++;
                                          }
                                          selectedId = orders[index]['id'];
                                        });
                                      },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            4 /
                                            100,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            1 /
                                            100,
                                  ),
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                      color: selectedId == orders[index]['id']
                                          ? isDark
                                              ? AppColor.primaryColor
                                              : AppColor.secondryColor
                                          : isDark
                                              ? AppColor.primaryColor
                                              : AppColor.secondryColor,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color:
                                              selectedId == orders[index]['id']
                                                  ? AppColor.buttonColor
                                                  : AppColor.textfilledColor)),
                                  child: Text(
                                    orders[index]['title'],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selectedId == orders[index]['id']
                                            ? AppColor.buttonColor
                                            : AppColor.textcolor),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),

                  //! Members Card
                  if (selectedId == 1)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(
                              "members_tab_${membersTabVersion}_$selectedId"),
                          child: CardSwiper(
                            controller: membersSwiperController,
                            padding: EdgeInsets.zero,
                            onSwipe: _onSwipeMembers,
                            cardsCount: membersData.length,
                            allowedSwipeDirection:
                                const AllowedSwipeDirection.only(
                              left: true,
                              right: true,
                              down: false,
                              up: false,
                            ),
                            numberOfCardsDisplayed: 1,
                            cardBuilder: (context, index, _, __) {
                              return Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              100,
                                    ),
                                    HomeWidget.membersCard(
                                      context,
                                      membersData[index]['image'],
                                      membersData[index]['name'],
                                      () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: const LikedMemberDetail(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      key: ValueKey(
                                          "member_image_${eventTabVersion}_$index"),
                                      showHeart: showHeart,
                                      showCross: showCross,
                                      lastSwipeType: lastSwipeType,
                                      onMessageTap: () {
                                        eventstypebottomsheet(context);
                                      },
                                      onHeartTap: () {
                                        // Handle heart tap for members
                                      },
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015),

                                    //! Undo Button
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                0.008,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.themeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          membersSwiperController.undo();
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              AppLanguage.undoText[language],
                                              style: const TextStyle(
                                                color: AppColor.secondryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01),
                                            Image.asset(
                                              AppImage.arrow,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              color: AppColor.secondryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  //! Events Card
                  if (selectedId == 2)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(
                              "events_tab_${eventTabVersion}_$selectedId"),
                          child: CardSwiper(
                            controller: eventsSwiperController,
                            padding: EdgeInsets.zero,
                            onSwipe: _onSwipeEvents,
                            cardsCount: eventsData.length,
                            allowedSwipeDirection:
                                const AllowedSwipeDirection.only(
                              left: true,
                              right: true,
                              down: false,
                              up: false,
                            ),
                            numberOfCardsDisplayed: 1,
                            cardBuilder: (context, index, _, __) {
                              return Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              100,
                                    ),
                                    HomeWidget.eventsCard(
                                      context,
                                      eventsData[index]['image'],
                                      "Bass Drop Fridays",
                                      () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: const LikedEventDetail(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      key: ValueKey(
                                          "events_tab_${eventTabVersion}_$index"),
                                      showHeart: showHeart,
                                      showCross: showCross,
                                      lastSwipeType: lastSwipeType,
                                      onShareTap: () {
                                        eventstypebottomsheet(context);
                                      },
                                      onHeartTap: () {
                                        // Handle heart tap for events
                                      },
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015),

                                    //! Undo Button
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                0.008,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.themeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          eventsSwiperController.undo();
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              AppLanguage.undoText[language],
                                              style: const TextStyle(
                                                color: AppColor.secondryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01),
                                            Image.asset(
                                              AppImage.arrow,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              color: AppColor.secondryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                  //! Venues Card
                  if (selectedId == 3)
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(
                              "venues_tab_${venusTabVersion}_$selectedId"),
                          child: CardSwiper(
                            controller: eventsSwiperController,
                            padding: EdgeInsets.zero,
                            onSwipe: _onSwipeVenues,
                            cardsCount: venuesData.length,
                            allowedSwipeDirection:
                                const AllowedSwipeDirection.only(
                              left: true,
                              right: true,
                              down: false,
                              up: false,
                            ),
                            numberOfCardsDisplayed: 1,
                            cardBuilder: (context, index, _, __) {
                              return Center(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              100,
                                    ),
                                    HomeWidget.venuesCard(
                                      context,
                                      venuesData[index]['image'],
                                      "Brew & Bloom Café",
                                      () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: const VenuePages(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      key: ValueKey(
                                          "venues_tab_${venusTabVersion}_$index"),
                                      showHeart: showHeart,
                                      showCross: showCross,
                                      lastSwipeType: lastSwipeType,
                                      onShareTap: () {
                                        eventstypebottomsheet(context);
                                      },
                                      onHeartTap: () {
                                        // Handle heart tap for venues
                                      },
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015),

                                    //! Undo Button
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                0.008,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.themeColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          venuesSwiperController.undo();
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              AppLanguage.undoText[language],
                                              style: const TextStyle(
                                                color: AppColor.secondryColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01),
                                            Image.asset(
                                              AppImage.arrow,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                              color: AppColor.secondryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
    );
  }

  void eventstypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 60 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 60 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(46),
                              topRight: Radius.circular(46),
                            ),
                          ),
                          width: size.width * 100 / 100,
                          height: size.height * 80 / 100,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 2 / 100),
                              Image.asset(
                                AppImage.dashIcon,
                                height: size.height * 0.5 / 100,
                                width: size.width * 28 / 100,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(height: size.height * 2 / 100),
                              Center(
                                child: SizedBox(
                                  width: size.width * 90 / 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: List.generate(shareIcons.length,
                                        (index) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 3 / 100,
                                            vertical: size.height * 2 / 100),
                                        child: Image.asset(
                                          shareIcons[index],
                                          width: size.width * 14 / 100,
                                          height: size.width * 14 / 100,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0.2,
                                thickness: 0.5,
                                color: AppColor.secondryColor,
                                indent: 28,
                                endIndent: 28,
                              ),
                              SizedBox(height: size.height * 3 / 100),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...List.generate(chats.length, (index) {
                                        final chat = chatsLists[index];
                                        final isSend =
                                            chats[index]['isSend'] == true;

                                        return Wrap(
                                          children: [
                                            SizedBox(
                                              width: size.width * 90 / 100,
                                              height: size.height * 8.5 / 100,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Container(
                                                  height:
                                                      size.height * 10 / 100,
                                                  width: size.width * 13 / 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          chat['image'] ?? ''),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  chat['name'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color:
                                                        AppColor.secondryColor,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  chat['lastMessage'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColor.secondryColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: () {
                                                    setStateBottomSheet(() {
                                                      chats[index]['isSend'] =
                                                          true;
                                                    });

                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 200),
                                                        () {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .bottomToTop,
                                                          child:
                                                              ChatMessageScreen(
                                                            name: chats[index]
                                                                    ['name'] ??
                                                                '',
                                                            image: chats[index]
                                                                    ['image'] ??
                                                                '',
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: isSend
                                                          ? AppColor
                                                              .logoutContainerColor
                                                          : AppColor
                                                              .secondryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: isSend
                                                          ? Border.all(
                                                              color: AppColor
                                                                  .buttonColor,
                                                              width: 1)
                                                          : null,
                                                    ),
                                                    child: Text(
                                                      isSend
                                                          ? (chats[index][
                                                                      'message1']
                                                                  ?.toString() ??
                                                              'Send')
                                                          : (chats[index][
                                                                      'message']
                                                                  ?.toString() ??
                                                              'Send'),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        color: isSend
                                                            ? AppColor
                                                                .secondryColor
                                                            : AppColor
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (index < chats.length - 0)
                                              if (index < chats.length - 0)
                                                SizedBox(
                                                    height: size.height *
                                                        0.1 /
                                                        100),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
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
    );
  }
}
