import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:night_life/view/welcomescreens/welcome_screen3.dart';
import 'package:night_life/utilities/page_transition.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class WelcomeScreen2 extends StatefulWidget {
  static String routeName = './welcomeScreen';
  const WelcomeScreen2({super.key});

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreen2State();
}

class _WelcomeScreen2State extends State<WelcomeScreen2>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _activeIndex = 2;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  void initState() {
    super.initState();

    _imageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _imageController, curve: Curves.easeOut),
    );

    _imageController.forward();
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    return Scaffold(
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            height: h,
            width: w,
            decoration: BoxDecoration(
              gradient: AppColor.welcomebackgroundGradientcolor(context),
            ),
          ),

          /// Main Carousel
          CarouselSlider(
            carouselController: _carouselController,
            items: [
              _buildScreen(
                title: "Find the hottest events near\nyou!\n.\n.\n.",
                desc:
                    "Discover the hottest\nparties, gigs, and open\nmics near you.",
                image: AppImage.micWelcomscreenIcon,
                bottom: h * 0.22,
                right: w * 0.28,
                left: 0,
              ),
            ],
            options: CarouselOptions(
              height: h,
              viewportFraction: 1,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _activeIndex = index;

                  _slideAnimation = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _imageController,
                      curve: Curves.easeOutCubic,
                    ),
                  );

                  if (index != 3) {
                    _imageController.forward(from: 0);
                  } else {
                    _imageController.reset();
                  }
                });
              },
            ),
          ),

          /// Next Button
          if (_activeIndex != 3)
            Positioned(
              bottom: h * 0.12,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: WelcomeScreen3(),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.12,
                    vertical: h * 0.015,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColor.nextButtoncolor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                  child: Text(
                    AppLanguage.nextText[language],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.045,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  /// Screen Builder
  Widget _buildScreen({
    required String title,
    required String desc,
    required String image,
    required double bottom,
    required double right,
    required double left,
  }) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        /// Card
        Positioned(
          top: h * 0.10,
          child: Container(
            width: w * 0.82,
            height: MediaQuery.of(context).size.height * 70 / 100,
            padding: EdgeInsets.symmetric(
                horizontal: w * 0.045, vertical: h * 0.045),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: AppColor.welcomefrontCardcolor2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.075,
                        height: 1.2,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: h * 0.19),
                Text("",
                    style: TextStyle(color: Colors.white, fontSize: w * 0.06)),
                SizedBox(height: h * 0.03),
                Text(desc,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.037,
                        height: 1.4,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),

        /// Animated Image
        Positioned(
          bottom: h * 0.070,
          left: w * 0.22,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                image,
                height: h * 0.75,
              ),
            ),
          ),
        ),

        /// Dot Indicator
        Positioned(
          bottom: MediaQuery.of(context).size.height * 4 / 100,
          child: Row(
            children: [
              _dot(_activeIndex == 1),
              _dot(_activeIndex == 2),
              _dot(_activeIndex == 0),
              _dot(_activeIndex == 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 5,
      height: active ? 10 : 5,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFF2CDF)
            : const Color.fromARGB(255, 251, 249, 253),
        shape: BoxShape.circle,
      ),
    );
  }
}
