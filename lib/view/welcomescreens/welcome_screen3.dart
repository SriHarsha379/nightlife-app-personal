import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:night_life/view/welcomescreens/welcome_screen1.dart';
import 'package:night_life/view/authentication/signup.dart';
import 'package:night_life/view/welcomescreens/welcome_screen4.dart';
import 'package:page_transition/page_transition.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class WelcomeScreen3 extends StatefulWidget {
  static String routeName = './welcomeScreen';
  const WelcomeScreen3({super.key});

  @override
  State<WelcomeScreen3> createState() => _WelcomeScreen3State();
}

class _WelcomeScreen3State extends State<WelcomeScreen3>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  int _activeIndex = 0;

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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));

    return Scaffold(
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            decoration:  BoxDecoration(
              gradient: AppColor.backgroundGradientcolor
            ),
          ),

          /// Main Carousel
          CarouselSlider(
            carouselController: _carouselController,
            items: [
            
              _buildScreen(
                  title: "Discover spaces that define your vibe!\n.\n.",
                  desc: "From cozy cafés to high-\nenergy clubs — your \ncity’s best places await.",
                  image: AppImage.locationwelcomeScreenIcon,
                  bottom: 200,
                  right: 120,
                  left: 0),
            
              _buildLastScreen()
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
              bottom: 115,
              right: 0,
              child: GestureDetector(
                onTap: () {
 Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeftWithFade,
                                  child: WelcomeScreen4(),
                                  duration: const Duration(milliseconds: 400),
                                ),
                              );                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
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
            )
        ],
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
          top: 90,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.82,
                        height: MediaQuery.of(context).size.height * 0.65,

            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 35),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: AppColor.welcomefrontCardcolor1
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(title,
                  textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.2,
                        fontWeight: FontWeight.w700)),
                ),
                 SizedBox(height:MediaQuery.of(context).size.height * 0.23),
                 Text("",
                    style: TextStyle(color: Colors.white, fontSize: 22)),
                 SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(desc,
                  textAlign: TextAlign.right,
                      style:  TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),

        /// Animated Image
        Positioned(
          bottom: 95,
          right: 50,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Image.asset(
                image,
                height: MediaQuery.of(context).size.height * 0.68,
              ),
            ),
          ),
        ),

        /// Dots indicator
        Positioned(
          bottom: 65,
          child: Row(
            children: [
              _dot(_activeIndex == 1),
              _dot(_activeIndex == 1),
              _dot(_activeIndex == 0),
              _dot(_activeIndex == 1),
            ],
          ),
        ),
      ],
    );
  }

  /// Last Screen with button
  Widget _buildLastScreen() {
    return Stack(
      children: [
        Center(
          child: Image.asset(AppImage.signupScreen, fit: BoxFit.cover),
        ),
        Positioned(
          bottom: 25,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeftWithFade,
                    child: WelcomeScreen1())),
            child: Center(
              child: Image.asset(
                AppImage.buttonletGetsstarted,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
        )
      ],
    );
  }

 Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 12 : 5,
      height: active ? 10 : 5,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFFF2CDF) :  Color.fromARGB(255, 251, 249, 253),
        shape: BoxShape.circle,
      ),
    );
  }
}
