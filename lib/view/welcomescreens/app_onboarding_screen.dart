import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'welcome_screen4.dart';

/// Unified onboarding flow (screens 1-3). Replaces the three separate
/// WelcomeScreen widgets with a single PageView so that:
///   • Page transitions are smooth with shared animation state.
///   • Dot indicators correctly reflect the active page index.
///   • Back-navigation is disabled throughout the onboarding flow.
class AppOnboardingScreen extends StatefulWidget {
  static String routeName = './AppOnboarding';

  const AppOnboardingScreen({super.key});

  @override
  State<AppOnboardingScreen> createState() => _AppOnboardingScreenState();
}

class _AppOnboardingScreenState extends State<AppOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  late AnimationController _animController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  int _currentPage = 0;

  /// 3 onboarding slides + WelcomeScreen4 = 4 total steps → 4 dots
  static const int _slidesCount = 3;
  static const int _totalDots = 4;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _createAnimations();
    _animController.forward();
  }

  void _createAnimations() {
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animController.forward(from: 0);
  }

  void _onNext() {
    if (_currentPage < _slidesCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to the final "All in One Place" CTA screen
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const WelcomeScreen4(),
          duration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: Scaffold(
        body: Stack(
          children: [
            // ── Background gradient ──────────────────────────────────────
            Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                gradient: AppColor.welcomebackgroundGradientcolor(context),
              ),
            ),

            // ── Slide pages ──────────────────────────────────────────────
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: const ClampingScrollPhysics(),
              children: [
                _Slide1(h: h, w: w, slideAnim: _slideAnim, fadeAnim: _fadeAnim),
                _Slide2(h: h, w: w, slideAnim: _slideAnim, fadeAnim: _fadeAnim),
                _Slide3(h: h, w: w, slideAnim: _slideAnim, fadeAnim: _fadeAnim),
              ],
            ),

            // ── Dot page indicator ───────────────────────────────────────
            Positioned(
              bottom: h * 0.04,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalDots,
                  (i) => _Dot(active: i == _currentPage),
                ),
              ),
            ),

            // ── Next button ──────────────────────────────────────────────
            Positioned(
              bottom: h * 0.11,
              right: 0,
              child: GestureDetector(
                onTap: _onNext,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: w * 0.12,
                    vertical: h * 0.016,
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
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFont.fontFamily,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Individual slide widgets (stateless – animation objects are passed in)
// ──────────────────────────────────────────────────────────────────────────────

/// Slide 1 – "Connect with people who vibe like you"
class _Slide1 extends StatelessWidget {
  final double h, w;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;

  const _Slide1({
    required this.h,
    required this.w,
    required this.slideAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Content card
        Positioned(
          top: h * 0.10,
          left: w * 0.09,
          child: Container(
            width: w * 0.82,
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.065,
              vertical: h * 0.045,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: AppColor.welcomefrontCardcolor(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Connect with people who\nvibe like you\n.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.075,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
                SizedBox(height: h * 0.30),
                SizedBox(height: h * 0.03),
                Text(
                  "Chat, connect, and meet\npeople at the clubs and\nevents you love.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.035,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated hero image
        Positioned(
          bottom: h * 0.19,
          left: w * 0.19,
          child: FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Image.asset(
                AppImage.chatWelcomescreenIcon,
                height: h * 0.60,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Slide 2 – "Find the hottest events near you!"
class _Slide2 extends StatelessWidget {
  final double h, w;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;

  const _Slide2({
    required this.h,
    required this.w,
    required this.slideAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Content card
        Positioned(
          top: h * 0.10,
          left: w * 0.09,
          child: Container(
            width: w * 0.82,
            height: h * 0.70,
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.045,
              vertical: h * 0.045,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: AppColor.welcomefrontCardcolor2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Find the hottest events near\nyou!\n.\n.\n.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.075,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
                SizedBox(height: h * 0.19),
                SizedBox(height: h * 0.03),
                Text(
                  "Discover the hottest\nparties, gigs, and open\nmics near you.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.037,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated hero image
        Positioned(
          bottom: h * 0.07,
          left: w * 0.22,
          child: FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Image.asset(
                AppImage.micWelcomscreenIcon,
                height: h * 0.75,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Slide 3 – "Discover spaces that define your vibe!" (right-aligned)
class _Slide3 extends StatelessWidget {
  final double h, w;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;

  const _Slide3({
    required this.h,
    required this.w,
    required this.slideAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Content card
        Positioned(
          top: h * 0.10,
          left: w * 0.09,
          child: Container(
            width: w * 0.82,
            height: h * 0.70,
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.065,
              vertical: h * 0.045,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: AppColor.welcomefrontCardcolor1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Discover spaces that\ndefine your vibe!\n.\n.",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.075,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
                SizedBox(height: h * 0.22),
                SizedBox(height: h * 0.03),
                Text(
                  "From cozy cafés to high-\nenergy clubs — your\ncity's best places await.",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w * 0.028,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFont.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Animated hero image (placed on the right)
        Positioned(
          bottom: h * 0.11,
          right: w * 0.13,
          child: FadeTransition(
            opacity: fadeAnim,
            child: SlideTransition(
              position: slideAnim,
              child: Image.asset(
                AppImage.locationwelcomeScreenIcon,
                height: h * 0.68,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Animated dot indicator
// ──────────────────────────────────────────────────────────────────────────────

class _Dot extends StatelessWidget {
  final bool active;

  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
