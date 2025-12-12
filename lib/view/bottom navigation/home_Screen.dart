// import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
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
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../provider/darkmode_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';

import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../other/MySplashSection/VenuesSection/venuepages.dart';

class Home extends StatefulWidget {
  static String routeName = './Home';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var fileName;
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
  List Orders = [
    {'id': 1, 'title': 'Members'},
    {'id': 2, 'title': 'Events'},
    {'id': 3, 'title': 'Venues'},
    {'id': 4, 'title': 'All'},
  ];

  List chats = [
    {
      'id': 1,
      'image': 'assets/icons/eventstory1.jpg',
      'name': 'Brew&Bloom ',
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
      'name': 'Bloom Cafe',
      'lastMessage': '@cafebloom34',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/eventstory1.jpg',
      'name': 'SUNBURN',
      'lastMessage': '@Sunburn',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Mitro',
      'lastMessage': '@Mitro',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Razberry',
      'lastMessage': '@Razberry',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
     {
      'id': 7,
      'image': 'assets/icons/eventstory3.png',
      'name': 'CCD',
      'lastMessage': '@CCD',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
  ];

  bool isSend = true;
  final CardSwiperController membersSwiperController = CardSwiperController();
  final CardSwiperController eventsSwiperController = CardSwiperController();
  final CardSwiperController venuesSwiperController = CardSwiperController();

// Add these for tracking
  int currentMemberIndex = 0;
  int currentEventIndex = 0;
  int currentVenueIndex = 0;
  int selectedIndex = 0;
  List<Map<String, dynamic>> membersData = [
    {'_id': '1', 'image': AppImage.card1},
    {'_id': '2', 'image': AppImage.newcard2},
    {'_id': '3', 'image': AppImage.member3},
  ];
  List<Map<String, dynamic>> venuesData = [
    {'_id': '1', 'image': AppImage.newcard2},
    {'_id': '2', 'image': AppImage.newcard2},
  ];

  List<Map<String, dynamic>> eventsData = [
    {'_id': '1', 'image': AppImage.lastcard},
    {'_id': '2', 'image': AppImage.lastcard},
  ];

  bool _onSwipeMembers(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      // Handle like
      print('Liked member: ${membersData[previousIndex]['_id']}');
    } else if (direction == CardSwiperDirection.left) {
      print('Disliked member: ${membersData[previousIndex]['_id']}');
    }
    setState(() {
      currentMemberIndex = currentIndex ?? 0;
    });
    return true;
  }

  bool _onSwipeEvents(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      print('Liked event: ${eventsData[previousIndex]['_id']}');
    }
    setState(() {
      currentEventIndex = currentIndex ?? 0;
    });
    return true;
  }

  bool _onSwipeVenues(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    if (direction == CardSwiperDirection.right) {
      print('Liked venue: ${venuesData[previousIndex]['_id']}');
    }
    setState(() {
      currentVenueIndex = currentIndex ?? 0;
    });
    return true;
  }

  void _onSwipeDirectionChange(CardSwiperDirection direction) {
    // Optional: handle swipe direction changes
  }

  @override
  void dispose() {
    membersSwiperController.dispose();
    eventsSwiperController.dispose();
    venuesSwiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isDark = themeProvider.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));

    // ignore: deprecated_member_use
    return PopScope(
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
                              width:
                                  MediaQuery.of(context).size.width * 10 / 100,
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
                                  child: Notifications(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 100,
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
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: Profile(),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            },
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
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
                          Orders.length,
                          (index) {
                            bool isAll = Orders[index]['id'] == 4;
                            return GestureDetector(
                              onTap: isAll
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedId = Orders[index]['id'];
                                      });
                                    },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width *
                                          4 /
                                          100,
                                  vertical: MediaQuery.of(context).size.height *
                                      1 /
                                      100,
                                ),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                    color: selectedId == Orders[index]['id']
                                        ? isDark
                                            ? AppColor.primaryColor
                                            : AppColor.secondryColor
                                        : isDark
                                            ? AppColor.primaryColor
                                            : AppColor.secondryColor,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: selectedId == Orders[index]['id']
                                            ? AppColor.buttonColor
                                            : AppColor.textfilledColor)),
                                child: Text(
                                  Orders[index]['title'],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selectedId == Orders[index]['id']
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
                if (selectedId == 1)
                  Expanded(
                    child: CardSwiper(
                      controller: membersSwiperController,
                      padding: EdgeInsets.zero,
                      onSwipe: _onSwipeMembers,
                      // onSwipeDirectionChange: _onSwipeDirectionChange
                      cardsCount: membersData.length,
                      allowedSwipeDirection: const AllowedSwipeDirection.only(
                        left: true,
                        right: true,
                        down: false,
                        up: false,
                      ),
                      numberOfCardsDisplayed: 1,
                      backCardOffset:
                          Offset(0, -MediaQuery.of(context).size.height * 0.00),
                      cardBuilder: (context, index, _, __) {
                        if (index >= membersData.length) {
                          return const SizedBox.shrink();
                        }
                        // YOUR EXISTING DESIGN - Just wrap it:
                        return Center(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: LikedMemberDetail(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      key: ValueKey(index),
                                      width: MediaQuery.of(context).size.width *
                                          0.88,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.62,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              membersData[index]['image']),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: MediaQuery.of(context).size.height *
                                        0.30,
                                    right: MediaQuery.of(context).size.width *
                                        0.004,
                                    child: GestureDetector(
                                      onTap: () {
                                        documenttypebottomsheet(context);
                                      },
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            AppImage.heart,
                                            fit: BoxFit.contain,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.12,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.03,
                                          ),
                                          Image.asset(
                                            AppImage.messageIcon,
                                            fit: BoxFit.contain,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.09,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1.5 /
                                    100,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.04,
                                  vertical: MediaQuery.of(context).size.height *
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
                                        style: TextStyle(
                                          color: AppColor.secondryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppFont.fontFamily,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                      ),
                                      Image.asset(
                                        AppImage.arrow,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                        height:
                                            MediaQuery.of(context).size.height *
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

                if (selectedId == 3)
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: VenuePages(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey(selectedId),
                                width: MediaQuery.of(context).size.width * 0.88,
                                height:
                                    MediaQuery.of(context).size.height * 0.62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  image: DecorationImage(
                                    image: AssetImage(AppImage.newcard2),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: MediaQuery.of(context).size.height * 0.29,
                              right: MediaQuery.of(context).size.width *
                                  0.004, // Changed from 0.01 to 0.005
                              child: GestureDetector(
                                onTap: () {
                                  documenttypebottomsheet(context);
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      AppImage.heart,
                                      fit: BoxFit.contain,
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              3.4 /
                                              100,
                                    ),
                                    Image.asset(
                                      AppImage.messageIcon,
                                      fit: BoxFit.contain,
                                      width: MediaQuery.of(context).size.width *
                                          0.09,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 1.5 / 100,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.04,
                            vertical:
                                MediaQuery.of(context).size.height * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.themeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedId = 2;
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLanguage.undoText[language],
                                  style: TextStyle(
                                    color: AppColor.secondryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.01),
                                Image.asset(
                                  AppImage.arrow,
                                  width:
                                      MediaQuery.of(context).size.width * 0.04,
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                  color: AppColor.secondryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (selectedId == 2)
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            // Main card
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: LikedEventDetail(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: Container(
                                key: ValueKey(selectedId),
                                width: MediaQuery.of(context).size.width * 0.88,
                                height:
                                    MediaQuery.of(context).size.height * 0.63,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.secondryColor
                                          .withOpacity(0.5),
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(24),
                                  image: DecorationImage(
                                    image: AssetImage(AppImage.Eventcard3),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            // Top left - Techno and Whiskey tags
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.02,
                              left: MediaQuery.of(context).size.width * 0.04,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.002,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF9D4EDD),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      'Techno',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppFont.fontFamily,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.01),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.002,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFF9D4EDD),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Text(
                                      'Whiskey',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppFont.fontFamily,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Top right - Profile images with +2
                            Positioned(
                              top: MediaQuery.of(context).size.height * 0.018,
                              right: MediaQuery.of(context).size.width * 0.02,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 40.0),
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.20,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.11,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(AppImage
                                                  .likeImg), // Replace with profile image
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.005),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.17,
                                    child: Text(
                                      textAlign: TextAlign.left,
                                      '17.6K Likes',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: AppFont.fontFamily,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Heart and message icons on the right
                            Positioned(
                              bottom: MediaQuery.of(context).size.height * 0.30,
                              right: MediaQuery.of(context).size.width * 0.00,
                              child: GestureDetector(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      AppImage.heart,
                                      fit: BoxFit.contain,
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              2.5 /
                                              100,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        documenttypebottomsheet(context);
                                      },
                                      child: Image.asset(
                                        AppImage.messageIcon,
                                        fit: BoxFit.contain,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.09,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.04,
                            vertical:
                                MediaQuery.of(context).size.height * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.themeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedId == 3) {
                                  selectedId = 2;
                                } else if (selectedId == 3) {
                                  selectedId = 2;
                                }
                              });
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLanguage.undoText[language],
                                  style: TextStyle(
                                    color: AppColor.secondryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                                Image.asset(
                                  AppImage.arrow,
                                  width:
                                      MediaQuery.of(context).size.width * 0.04,
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                  color: AppColor.secondryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        // String? tempSelected = selectedState;

        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 60 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    height: MediaQuery.of(context).size.height * 60 / 100,
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.only(
                    //         topLeft: Radius.circular(50),
                    //         topRight: Radius.circular(50)),
                    //     color: Colors.transparent),

                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColor.backgroundGradientcolor,
                              // gradient: AppColor.chatContainerColor,
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
                                Container(
                                  color: AppColor.transparentColor,
                                  width: MediaQuery.of(context).size.width *
                                      100 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      8 /
                                      100,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedIndex = 0;
                                            });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                50 /
                                                100,
                                            // height:
                                            //     MediaQuery.of(context).size.height * 6 / 100,
                                            child: Center(
                                              child: Text(
                                                AppLanguage
                                                    .eventsText[language],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: selectedIndex == 0
                                                      ? AppColor.secondryColor
                                                      : AppColor.greyLightColor,
                                                  fontSize: 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedIndex = 1;
                                            });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                50 /
                                                100,
                                            // height:
                                            //     MediaQuery.of(context).size.height * 6 / 100,
                                            child: Center(
                                              child: Text(
                                                AppLanguage
                                                    .venuesText[language],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: selectedIndex == 1
                                                      ? AppColor.greyLightColor
                                                      : AppColor.greyLightColor,
                                                  fontSize: 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex = 0;
                                          });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.40,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.003,
                                          color: selectedIndex == 0
                                              ? AppColor.secondryColor
                                              : AppColor.secondryColor,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedIndex =
                                                1; // fixed selection
                                          });
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.40,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.003,
                                          color: selectedIndex == 1
                                              ? AppColor.greyLightColor
                                              : AppColor.greyLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: size.height * 2 / 100),
                                SizedBox(height: size.height * 1 / 100),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ...List.generate(chats.length, (index) {
                                          final chat = chats[index];
                                          return Wrap(
                                            children: [
                                              Container(
                                                width: size.width * 90 / 100,
                                                height: size.height * 8.5 / 100,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  leading: Container(
                                                    height:
                                                        size.height * 10 / 100,
                                                    width:
                                                        size.width * 13 / 100,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                            chat['image']),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    chat['name'],
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: AppColor
                                                          .secondryColor,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    chat['lastMessage'],
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppColor
                                                          .secondryColor,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  trailing: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        chats[index]['isSend'] =
                                                            true;
                                                      });

                                                      Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  200), () {
                                                        Navigator.push(
                                                          context,
                                                          PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .bottomToTop,
                                                            child:
                                                                ChatMessageScreen(
                                                              name: chats[index]
                                                                  ['name'],
                                                              image:
                                                                  chats[index]
                                                                      ['image'],
                                                            ),
                                                            duration: const Duration(milliseconds: 500),
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
                                                        color: (chats[index]
                                                                    ['isSend']
                                                                as bool)
                                                            ? AppColor
                                                                .logoutContainerColor
                                                            : AppColor
                                                                .secondryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        border: (chats[index]
                                                                    ['isSend']
                                                                as bool)
                                                            ? Border.all(
                                                                color: AppColor
                                                                    .buttonColor,
                                                                width: 1)
                                                            : null,
                                                      ),
                                                      child: Text(
                                                        (chats[index]['isSend']
                                                                as bool)
                                                            ? chats[index]
                                                                ['message1']
                                                            : chats[index]
                                                                ['message'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          color: (chats[index]
                                                                      ['isSend']
                                                                  as bool)
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
                                                // Divider(
                                                //   height: 0.2,
                                                //   // thickness: 0.5,
                                                //   // color: Colors.grey[300],
                                                //   indent: 30,
                                                // ),
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
                    )),
              ],
            ),
          );
        });
      },
    );
  }



}
