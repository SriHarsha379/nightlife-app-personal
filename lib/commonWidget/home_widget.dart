import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../utilities/app_color.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../utilities/app_language.dart';
import '../view/other/chats/chat_message_screen.dart';

class HomeWidget {
  int selectedIndex = 0;

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
  final List<String> shareIcons = [
    AppImage.shareIcon,
    AppImage.whatsappIcon,
    AppImage.instaIcon,
    AppImage.snapIcon,
  ];

  //! Members Card

  // Method to build members card
  static Widget membersCard(
    BuildContext context,
    String image,
    String name,
    VoidCallback onTap, {
    Key? key,
    required bool showHeart,
    required bool showCross,
    required String? lastSwipeType,
    required Function() onMessageTap,
    required Function() onHeartTap,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 85 / 100,
          height: MediaQuery.of(context).size.height * 57.5 / 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              //! Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      //! Image Section
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                              ),
                              child: Image.asset(
                                image,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Shadow overlay that blends into the info section
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black,
                                    ],
                                    stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //! Info Section
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Text(
                                'Weekend explorer who loves live gigs, latte art, and late-night jam sessions.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              const Text(
                                'Foodie · Explorer · Creative',
                                style: TextStyle(
                                  color: AppColor.pinkColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lane 7, Koregaon Park • 1.8 km',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //! Heart icon for left swipe (green)
              if (showHeart && lastSwipeType == 'cross')
                Positioned(
                  left: 30,
                  bottom: -50,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 10 / 100,
                      height: MediaQuery.of(context).size.width * 10 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.redColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.redColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              //! Cross icon for right swipe (red)
              if (showCross && lastSwipeType == 'heart')
                Positioned(
                  right: 30,
                  bottom: -50,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 10 / 100,
                      height: MediaQuery.of(context).size.width * 10 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.greenColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.greenColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

              //! Profile Avatars at Top Right (Overlapping)
              Positioned(
                top: 12,
                right: 0,
                child: SizedBox(
                  width: 105,
                  height: 41,
                  child: Stack(
                    children: [
                      //! First Avatar
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=1'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      //! Second Avatar
                      Positioned(
                        left: 27,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=5'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      //! +2 Badge
                      Positioned(
                        left: 56,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7B1FA2),
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                          ),
                          child: const Center(
                            child: Text(
                              '+2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //! Heart Button on Right Side
              Positioned(
                right: 0,
                top: 0,
                bottom: 100,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xff341941).withOpacity(.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onHeartTap,
                            child: Image.asset(AppImage.heart),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onMessageTap,
                            child: Image.asset(AppImage.messageIcon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build events card
  static Widget eventsCard(
    BuildContext context,
    String image,
    String name,
    VoidCallback onTap, {
    Key? key,
    required bool showHeart,
    required bool showCross,
    required String? lastSwipeType,
    required Function() onShareTap,
    required Function() onHeartTap,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 85 / 100,
          height: MediaQuery.of(context).size.height * 57.5 / 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              //! Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      //! Image Section
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                              ),
                              child: Image.asset(
                                image,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            // Shadow overlay that blends into the info section
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black,
                                    ],
                                    stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //! Info Section
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Text(
                                'Bass-heavy techno night with DJ Armin, drink specials till midnight',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Fri, 10 PM – 4 AM',
                                    style: TextStyle(
                                      color: AppColor.pinkColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Club Neon, Downtown • 2.3 km',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //! Profile Avatars at Top Right (Overlapping)
              Positioned(
                top: 12,
                right: 0,
                child: SizedBox(
                  width: 105,
                  height: 100,
                  child: Stack(
                    children: [
                      //! First Avatar
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=1'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      //! Second Avatar
                      Positioned(
                        left: 27,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=5'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      //! +2 Badge
                      Positioned(
                        left: 56,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7B1FA2),
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                          ),
                          child: const Center(
                            child: Text(
                              '+2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //! Likes Count
                      const Positioned(
                        top: 42,
                        right: 19,
                        child: SizedBox(
                          child: Text(
                            "17.6K Likes",
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textcolor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //! Beverages on Left Side
              Positioned(
                top: 10,
                left: 0,
                child: SizedBox(
                  height: 41,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 5 / 100,
                      ),
                      //! Cafe Text
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColor.themeColor.withOpacity(.7),
                          border: Border.all(
                              color: const Color(0xFF9C27B0), width: 3),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Text(
                            "Techno",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 2 / 100,
                      ),

                      //! Coffee Text
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColor.themeColor.withOpacity(.7),
                          border: Border.all(
                              color: const Color(0xFF9C27B0), width: 3),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Text(
                            "Whiskey",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //! Heart Button on Right Side
              Positioned(
                right: 0,
                top: 0,
                bottom: 100,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xff341941).withOpacity(.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onHeartTap,
                            child: Image.asset(AppImage.heart),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onShareTap,
                            child: Image.asset(AppImage.messageIcon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //! Yes - with fade animation
              if (showHeart && lastSwipeType == 'cross')
                Positioned(
                  left: 30,
                  top: 80,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 20 / 100,
                      height: MediaQuery.of(context).size.height * 6 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.greenColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.greenColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              //! Nope - with fade animation
              if (showCross && lastSwipeType == 'heart')
                Positioned(
                  right: 30,
                  top: 80,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 20 / 100,
                      height: MediaQuery.of(context).size.height * 6 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.redColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.redColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Nope",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build venues card
  static Widget venuesCard(
    BuildContext context,
    String image,
    String name,
    VoidCallback onTap, {
    Key? key,
    required bool showHeart,
    required bool showCross,
    required String? lastSwipeType,
    required Function() onShareTap,
    required Function() onHeartTap,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: GestureDetector(
        key: key,
        onTap: onTap,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 85 / 100,
          height: MediaQuery.of(context).size.height * 57.5 / 100,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              //! Main Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 0),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Column(
                    children: [
                      //! Image Section
                      Expanded(
                        flex: 7,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[200]!,
                                  ],
                                ),
                              ),
                              child: Image.asset(
                                image,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            // Shadow overlay that blends into the info section
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 150,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black.withOpacity(0.1),
                                      Colors.black,
                                    ],
                                    stops: const [0.0, 0.6, 0.7, 0.8, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //! Info Section
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Text(
                                'Cozy café with coffee, desserts, events—perfect for work, conversations, meetups.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '8 AM – 11 PM',
                                    style: TextStyle(
                                      color: AppColor.pinkColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    .5 /
                                    100,
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColor.pinkColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lane 7, Koregaon Park • 1.8 km',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              //! Profile Avatars at Top Right (Overlapping)
              Positioned(
                top: 12,
                right: 0,
                child: SizedBox(
                  width: 105,
                  height: 100,
                  child: Stack(
                    children: [
                      //! First Avatar
                      Positioned(
                        left: 0,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=1'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      //! Second Avatar
                      Positioned(
                        left: 27,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://i.pravatar.cc/150?img=5'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      //! +2 Badge
                      Positioned(
                        left: 56,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF7B1FA2),
                            border: Border.all(
                                color: const Color(0xFF9C27B0), width: 3),
                          ),
                          child: const Center(
                            child: Text(
                              '+2',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //! Likes Count
                      const Positioned(
                        top: 42,
                        right: 19,
                        child: SizedBox(
                          child: Text(
                            "17.6K Likes",
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textcolor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //! Beverages on Left Side
              Positioned(
                top: 10,
                left: 0,
                child: SizedBox(
                  height: 41,
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 5 / 100,
                      ),
                      //! Cafe Text
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColor.themeColor.withOpacity(.7),
                          border: Border.all(
                              color: const Color(0xFF9C27B0), width: 3),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Text(
                            "Cafe",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 2 / 100,
                      ),
                      //! Coffee Text
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColor.themeColor.withOpacity(.7),
                          border: Border.all(
                              color: const Color(0xFF9C27B0), width: 3),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Text(
                            "Coffee",
                            style: TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //! Heart Button on Right Side
              Positioned(
                right: 0,
                top: 0,
                bottom: 100,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xff341941).withOpacity(.6),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onHeartTap,
                            child: Image.asset(AppImage.heart),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 2 / 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: GestureDetector(
                            onTap: onShareTap,
                            child: Image.asset(AppImage.messageIcon),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              //! Yes - with fade animation
              if (showHeart && lastSwipeType == 'cross')
                Positioned(
                  left: 30,
                  top: 80,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 20 / 100,
                      height: MediaQuery.of(context).size.height * 6 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.greenColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.greenColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              //! Nope - with fade animation
              if (showCross && lastSwipeType == 'heart')
                Positioned(
                  right: 30,
                  top: 80,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 20 / 100,
                      height: MediaQuery.of(context).size.height * 6 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.redColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.redColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Nope",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
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
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * size.height * 0.3),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 60 / 100,
              color: Colors.transparent,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    height: MediaQuery.of(context).size.height * 60 / 100,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
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

                                /// -------- DRAG INDICATOR --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 0.8 + (0.2 * value),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    AppImage.dashIcon,
                                    height: size.height * 0.5 / 100,
                                    width: size.width * 28 / 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),

                                /// -------- TABS (EVENTS & VENUES) --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -20 * (1 - value)),
                                      child: Opacity(
                                        opacity: value.clamp(0.0, 1.0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: AppColor.transparentColor,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        8 /
                                        100,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 5 / 100,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// -------- EVENTS TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 0;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 0
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 0
                                                      ? AppColor.secondryColor
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 0
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .eventsText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// -------- VENUES TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 1;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 1
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 1
                                                      ? AppColor.secondryColor
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 1
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .venuesText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// -------- TAB INDICATOR (FULL WIDTH) --------
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: 2,
                                  child: Stack(
                                    children: [
                                      // Background line (full width)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 2,
                                        color: AppColor.greyLightColor
                                            .withOpacity(0.3),
                                      ),
                                      // Animated indicator
                                      AnimatedAlign(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        alignment: selectedIndex == 0
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: AppColor.secondryColor,
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColor.secondryColor
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),
                                SizedBox(height: size.height * 1 / 100),

                                /// -------- CONTACTS LIST --------
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.1, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: SingleChildScrollView(
                                      key: ValueKey<int>(selectedIndex),
                                      child: Column(
                                        children: [
                                          ...List.generate(
                                            selectedIndex == 0
                                                ? chats.length
                                                : chatsLists.length,
                                            (index) {
                                              final chat = selectedIndex == 0
                                                  ? chats[index]
                                                  : chats[index];
                                              final isSend = selectedIndex == 0
                                                  ? (chats[index]['isSend'] ==
                                                      true)
                                                  : (chatsLists[index]
                                                          ['isSend'] ==
                                                      true);

                                              return TweenAnimationBuilder<
                                                  double>(
                                                tween:
                                                    Tween(begin: 0.0, end: 1.0),
                                                duration: Duration(
                                                    milliseconds:
                                                        300 + (index * 50)),
                                                curve: Curves.easeOutBack,
                                                builder:
                                                    (context, value, child) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                        30 * (1 - value), 0),
                                                    child: Opacity(
                                                      opacity:
                                                          value.clamp(0.0, 1.0),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: Wrap(
                                                  children: [
                                                    Container(
                                                      width:
                                                          size.width * 90 / 100,
                                                      height: size.height *
                                                          8.5 /
                                                          100,
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        leading: Container(
                                                          height: size.height *
                                                              10 /
                                                              100,
                                                          width: size.width *
                                                              13 /
                                                              100,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  chat['image'] ??
                                                                      ''),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        title: Row(
                                                          children: [
                                                            Text(
                                                              chat['name'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColor
                                                                    .secondryColor,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    size.width *
                                                                        2 /
                                                                        100),
                                                            // Bordered label for Event/Venue
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    size.width *
                                                                        2 /
                                                                        100,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppColor
                                                                      .pinkColor,
                                                                  width: .3,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Text(
                                                                selectedIndex ==
                                                                        0
                                                                    ? AppLanguage
                                                                            .eventsText[
                                                                        language]
                                                                    : AppLanguage
                                                                            .venuesText[
                                                                        language],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 8,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  color: AppColor
                                                                      .secondryColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        subtitle: Text(
                                                          chat['lastMessage'] ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppColor
                                                                .secondryColor,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        trailing:
                                                            GestureDetector(
                                                          onTap: () {
                                                            setStateBottomSheet(
                                                                () {
                                                              if (selectedIndex ==
                                                                  0) {
                                                                chats[index][
                                                                        'isSend'] =
                                                                    true;
                                                              } else {
                                                                chatsLists[index]
                                                                        [
                                                                        'isSend'] =
                                                                    true;
                                                              }
                                                            });

                                                            Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                              () {
                                                                Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                    type: PageTransitionType
                                                                        .bottomToTop,
                                                                    child:
                                                                        ChatMessageScreen(
                                                                      name: chat[
                                                                              'name'] ??
                                                                          '',
                                                                      image:
                                                                          chat['image'] ??
                                                                              '',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        17,
                                                                    vertical:
                                                                        7),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSend
                                                                  ? AppColor
                                                                      .logoutContainerColor
                                                                  : AppColor
                                                                      .secondryColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
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
                                                                  ? (chat['message1']
                                                                          ?.toString() ??
                                                                      'Send')
                                                                  : (chat['message']
                                                                          ?.toString() ??
                                                                      'Send'),
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
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
                                                    if (index <
                                                        (selectedIndex == 0
                                                                ? chats.length
                                                                : chatsLists
                                                                    .length) -
                                                            1)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.1 /
                                                              100),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
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
            ),
          );
        });
      },
    );
  }

  void sharetypebottomsheet(BuildContext context) {
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
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 60 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
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

                              /// -------- DRAG INDICATOR --------
                              Image.asset(
                                AppImage.dashIcon,
                                height: size.height * 0.5 / 100,
                                width: size.width * 28 / 100,
                                fit: BoxFit.fill,
                              ),

                              SizedBox(height: size.height * 2 / 100),

                              /// -------- SOCIAL SHARE ICONS --------
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
                                        child: GestureDetector(
                                          onTap: () {
                                            // Handle share icon tap
                                          },
                                          child: Image.asset(
                                            shareIcons[index],
                                            width: size.width * 14 / 100,
                                            height: size.width * 14 / 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),

                              /// -------- DIVIDER --------
                              Divider(
                                height: 0.2,
                                thickness: 0.5,
                                color: AppColor.secondryColor,
                                indent: 28,
                                endIndent: 28,
                              ),

                              SizedBox(height: size.height * 2 / 100),
                              SizedBox(height: size.height * 1 / 100),

                              /// -------- CONTACTS LIST --------
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...List.generate(chats.length, (index) {
                                        final chat = chats[index];
                                        final isSend =
                                            chats[index]['isSend'] == true;

                                        return Wrap(
                                          children: [
                                            Container(
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
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color:
                                                        AppColor.secondryColor,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  chat['lastMessage'] ?? '',
                                                  style: TextStyle(
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
                                            if (index < chats.length - 1)
                                              SizedBox(
                                                  height:
                                                      size.height * 0.1 / 100),
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
