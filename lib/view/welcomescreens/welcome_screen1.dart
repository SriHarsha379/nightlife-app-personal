import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:night_life/view/welcomescreens/welcome_Screen2.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class WelcomeScreen1 extends StatefulWidget {
  static String routeName = './welcomeScreen';
  const WelcomeScreen1({super.key});

  @override
  State<WelcomeScreen1> createState() => _WelcomeScreen1State();
}

class _WelcomeScreen1State extends State<WelcomeScreen1>
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
      duration: const Duration(milliseconds: 1200),
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        body: Stack(
          children: [
            /// Background Gradient
            Container(
              decoration: BoxDecoration(
                gradient: AppColor.welcomebackgroundGradientcolor(context),
              ),
            ),

            /// Main Carousel
            CarouselSlider(
              carouselController: _carouselController,
              items: [
                _buildScreen(
                    title: "Connect with people who\nvibe like you\n.",
                    desc:
                        "Chat, connect, and meet\npeople at the clubs and \nevents you love.",
                    image: AppImage.chatWelcomescreenIcon,
                    bottom: 200,
                    right: 120,
                    left: 0),
              ],
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height,
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
                bottom: 85,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    _carouselController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut);
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WelcomeScreen2()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColor.nextButtoncolor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25),
                        ),
                      ),
                      child: Text(
                        AppLanguage.nextText[language],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  /// Common Animated UI Card
  Widget _buildScreen({
    required String title,
    required String desc,
    required String image,
    required double bottom,
    required double right,
    required double left,
  }) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        /// Card
        Positioned(
          top: MediaQuery.of(context).size.height * 0.10,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: AppColor.welcomefrontCardcolor(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.2,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.30),
                Text("", style: TextStyle(color: Colors.white, fontSize: 22)),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Text(desc,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),

        /// Animated Image
        Positioned(
          bottom: 200,
          left: 80,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                image,
                height: MediaQuery.of(context).size.height * 0.60,
              ),
            ),
          ),
        ),

        /// Dots indicator
        Positioned(
          bottom: MediaQuery.of(context).size.height * 4 / 100,
          child: Row(
            children: [
              _dot(_activeIndex == 2),
              _dot(_activeIndex == 0),
              _dot(_activeIndex == 0),
              _dot(_activeIndex == 3),
            ],
          ),
        ),
      ],
    );
  }

  /// Last Screen with button

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 5,
      height: active ? 10 : 5,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFF2CDF)
            : Color.fromARGB(255, 251, 249, 253),
        shape: BoxShape.circle,
      ),
    );
  }
}
