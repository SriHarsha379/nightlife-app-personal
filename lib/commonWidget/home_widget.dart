import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../utilities/app_color.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../view/other/MySplashSection/MembersSection/member_liked_details.dart';

class HomeWidget {
  int selectedIndex = 0;

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
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;

          if (velocity < -300) {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.bottomToTop,
                child: const LikedMemberDetail(),
                duration: const Duration(milliseconds: 400),
              ),
            );
          }
        },
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
              // Positioned(
              //   top: 12,
              //   right: 0,
              //   child: SizedBox(
              //     width: 105,
              //     height: 41,
              //     child: Stack(
              //       children: [
              //         //! First Avatar
              //         Positioned(
              //           left: 0,
              //           child: Container(
              //             width: 38,
              //             height: 38,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               border: Border.all(
              //                   color: const Color(0xFF9C27B0), width: 3),
              //               image: const DecorationImage(
              //                 image: NetworkImage(
              //                     'https://i.pravatar.cc/150?img=1'),
              //                 fit: BoxFit.cover,
              //               ),
              //             ),
              //           ),
              //         ),

              //         //! Second Avatar
              //         // Positioned(
              //         //   left: 27,
              //         //   child: Container(
              //         //     width: 38,
              //         //     height: 38,
              //         //     decoration: BoxDecoration(
              //         //       shape: BoxShape.circle,
              //         //       border: Border.all(
              //         //           color: const Color(0xFF9C27B0), width: 3),
              //         //       image: const DecorationImage(
              //         //         image: NetworkImage(
              //         //             'https://i.pravatar.cc/150?img=5'),
              //         //         fit: BoxFit.cover,
              //         //       ),
              //         //     ),
              //         //   ),
              //         // ),

              //         //! +2 Badge
              //         // Positioned(
              //         //   left: 56,
              //         //   child: Container(
              //         //     width: 38,
              //         //     height: 38,
              //         //     decoration: BoxDecoration(
              //         //       shape: BoxShape.circle,
              //         //       color: const Color(0xFF7B1FA2),
              //         //       border: Border.all(
              //         //           color: const Color(0xFF9C27B0), width: 3),
              //         //     ),
              //         //     child: const Center(
              //         //       child: Text(
              //         //         '+2',
              //         //         style: TextStyle(
              //         //           color: Colors.white,
              //         //           fontSize: 16,
              //         //           fontWeight: FontWeight.bold,
              //         //         ),
              //         //       ),
              //         //     ),
              //         //   ),
              //         // ),
              //       ],
              //     ),
              //   ),
              // ),

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
              // Positioned(
              //   top: 12,
              //   right: 0,
              //   child: SizedBox(
              //     width: 105,
              //     height: 100,
              //     child: Stack(
              //       children: [
              //         //! First Avatar
              //         Positioned(
              //           left: 0,
              //           child: Container(
              //             width: 38,
              //             height: 38,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               border: Border.all(
              //                   color: const Color(0xFF9C27B0), width: 3),
              //               image: const DecorationImage(
              //                 image: NetworkImage(
              //                     'https://i.pravatar.cc/150?img=1'),
              //                 fit: BoxFit.cover,
              //               ),
              //             ),
              //           ),
              //         ),

              //         //! Second Avatar
              //         Positioned(
              //           left: 27,
              //           child: Container(
              //             width: 38,
              //             height: 38,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               border: Border.all(
              //                   color: const Color(0xFF9C27B0), width: 3),
              //               image: const DecorationImage(
              //                 image: NetworkImage(
              //                     'https://i.pravatar.cc/150?img=5'),
              //                 fit: BoxFit.cover,
              //               ),
              //             ),
              //           ),
              //         ),

              //         //! +2 Badge
              //         Positioned(
              //           left: 56,
              //           child: Container(
              //             width: 38,
              //             height: 38,
              //             decoration: BoxDecoration(
              //               shape: BoxShape.circle,
              //               color: const Color(0xFF7B1FA2),
              //               border: Border.all(
              //                   color: const Color(0xFF9C27B0), width: 3),
              //             ),
              //             child: const Center(
              //               child: Text(
              //                 '+2',
              //                 style: TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 16,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),
              //             ),
              //           ),
              //         ),

              //         //! Likes Count
              //         const Positioned(
              //           top: 42,
              //           right: 19,
              //           child: SizedBox(
              //             child: Text(
              //               "17.6K Likes",
              //               style: TextStyle(
              //                 fontFamily: AppFont.fontFamily,
              //                 fontSize: 12,
              //                 fontWeight: FontWeight.w600,
              //                 color: AppColor.textcolor,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

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
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Text(
                            "Techno",
                            style: TextStyle(
                              color: Colors.white,
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 10),
                          child: Text(
                            "Whiskey",
                            style: TextStyle(
                              color: Colors.white,
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
                      child: Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
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
                      child: Center(
                        child: Text(
                          "Nope",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
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
                              color: Colors.white,
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
                              color: Colors.white,
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
                      child: Center(
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
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
                      child: Center(
                        child: Text(
                          "Nope",
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
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
}
