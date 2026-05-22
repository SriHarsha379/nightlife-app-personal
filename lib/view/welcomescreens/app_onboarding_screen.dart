import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/animation/purple_screen.dart';
import 'package:night_life/provider/common_sharedpreferences.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/authentication/signup.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';

class AppOnboardingScreen extends StatefulWidget {
  static String routeName = './AppOnboarding';
  static const String completionStorageKey = 'onboarding_completed_v1';

  const AppOnboardingScreen({super.key});

  @override
  State<AppOnboardingScreen> createState() => _AppOnboardingScreenState();
}

class _AppOnboardingScreenState extends State<AppOnboardingScreen> {
  static const int _lastPageIndex = 3;

  final PageController _pageController = PageController();

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      title: 'Connect with people who vibe like you',
      description:
          'Chat, connect, and meet people at the clubs and events you love.',
      imageAsset: AppImage.chatWelcomescreenIcon,
      accentIcon: Icons.people_alt_rounded,
      highlights: [
        'Match with like-minded people',
        'Start chats instantly',
        'Build your nightlife circle',
      ],
    ),
    _OnboardingSlideData(
      title: 'Find the hottest events near you',
      description:
          'Discover trending parties, gigs, and open mics happening around your city.',
      imageAsset: AppImage.micWelcomscreenIcon,
      accentIcon: Icons.celebration_rounded,
      highlights: [
        'Explore curated event picks',
        'See what is trending nearby',
        'Plan your next night out quickly',
      ],
    ),
    _OnboardingSlideData(
      title: 'Discover spaces that define your vibe',
      description:
          'From cozy lounges to high-energy clubs, explore the best places in one app.',
      imageAsset: AppImage.locationwelcomeScreenIcon,
      accentIcon: Icons.location_city_rounded,
      highlights: [
        'Browse venues by mood',
        'Check details before you go',
        'Find the right spot faster',
      ],
    ),
  ];

  int _currentPage = 0;

  bool get _isLastPage => _currentPage == _lastPageIndex;

  Future<void> _markOnboardingCompleted() {
    return CacheHelper.save(AppOnboardingScreen.completionStorageKey, 'true');
  }

  Future<void> _goToLogin() async {
    await _markOnboardingCompleted();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: const LoginScreen(),
        duration: const Duration(milliseconds: 350),
      ),
    );
  }

  Future<void> _goToSignup() async {
    await _markOnboardingCompleted();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        child: const PurpleScreen(
          nextScreen: SignUp(),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _lastPageIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextPage() {
    if (_isLastPage) {
      _goToSignup();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousPage() {
    if (_currentPage == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (_) {},
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColor.backgroundGradientcolor1,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.05,
                      safeTop > 0 ? size.height * 0.006 : size.height * 0.02,
                      size.width * 0.05,
                      size.height * 0.012,
                    ),
                    child: _buildTopBar(context),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _slides.length + 1,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        if (index == _lastPageIndex) {
                          return _buildFinalPage(context);
                        }
                        return _buildIntroPage(context, _slides[index]);
                      },
                    ),
                  ),
                  _buildBottomBar(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.035,
            vertical: size.height * 0.008,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Text(
            'Hii',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFont.fontFamily,
              fontWeight: FontWeight.w700,
              fontSize: size.width * 0.042,
            ),
          ),
        ),
        const Spacer(),
        Text(
          '${_currentPage + 1}/4',
          style: TextStyle(
            color: Colors.white70,
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: size.width * 0.035,
          ),
        ),
        SizedBox(width: size.width * 0.03),
        if (!_isLastPage)
          GestureDetector(
            onTap: _skipToLastPage,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.008,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: size.width * 0.034,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIntroPage(
    BuildContext context,
    _OnboardingSlideData slide,
  ) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heroHeight = constraints.maxHeight * 0.44;
          final cardHeight = constraints.maxHeight * 0.68;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: constraints.maxHeight * 0.02),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: cardHeight),
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.06,
                      size.height * 0.03,
                      size.width * 0.06,
                      size.height * 0.025,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: AppColor.welcomefrontCardcolor(context),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.24),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: size.width * 0.12,
                          height: size.width * 0.12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.12),
                          ),
                          child: Icon(
                            slide.accentIcon,
                            color: Colors.white,
                            size: size.width * 0.06,
                          ),
                        ),
                        SizedBox(height: size.height * 0.024),
                        Text(
                          slide.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.085,
                            height: 1.12,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                        SizedBox(height: size.height * 0.016),
                        Text(
                          slide.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: size.width * 0.038,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                        SizedBox(height: size.height * 0.026),
                        ...slide.highlights.map(
                          (highlight) => Padding(
                            padding: EdgeInsets.only(
                              bottom: size.height * 0.012,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    top: size.height * 0.004,
                                  ),
                                  width: size.width * 0.018,
                                  height: size.width * 0.018,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF2CDF),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: Text(
                                    highlight,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.94),
                                      fontSize: size.width * 0.035,
                                      height: 1.4,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            child: Image.asset(
                              slide.imageAsset,
                              key: ValueKey(slide.imageAsset),
                              height: heroHeight,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.03),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFinalPage(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.07,
                      size.height * 0.04,
                      size.width * 0.07,
                      size.height * 0.035,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: AppColor.welcomefrontCardcolor(context),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: size.width * 0.18,
                          height: size.width * 0.18,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: size.width * 0.09,
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Text(
                          'All in One Place',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.09,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                        SizedBox(height: size.height * 0.018),
                        Text(
                          'Discover the best venues, explore events, and connect with people who share your vibe before you enter the app.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: size.width * 0.039,
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        _buildCtaRow(
                          icon: Icons.people_alt_rounded,
                          text: 'Meet people with your vibe',
                        ),
                        _buildCtaRow(
                          icon: Icons.celebration_rounded,
                          text: 'Explore the best events nearby',
                        ),
                        _buildCtaRow(
                          icon: Icons.location_city_rounded,
                          text: 'Find venues that match your mood',
                        ),
                        SizedBox(height: size.height * 0.04),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _goToSignup,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColor.buttonColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Create Account',
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: size.width * 0.04,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.014),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _goToLogin,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.24),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: size.height * 0.018,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                                fontSize: size.width * 0.04,
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
          );
        },
      ),
    );
  }

  Widget _buildCtaRow({
    required IconData icon,
    required String text,
  }) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.014),
      child: Row(
        children: [
          Container(
            width: size.width * 0.1,
            height: size.width * 0.1,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size.width * 0.05,
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: size.width * 0.036,
                fontWeight: FontWeight.w500,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = (_currentPage + 1) / (_slides.length + 1);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        size.width * 0.06,
        size.height * 0.018,
        size.width * 0.06,
        size.height * 0.032,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFFF2CDF),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.014),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _slides.length + 1,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentPage ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? const Color(0xFFFF2CDF)
                      : Colors.white.withOpacity(0.28),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          if (!_isLastPage)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _currentPage == 0 ? null : _goToPreviousPage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white38,
                      side: BorderSide(color: Colors.white.withOpacity(0.18)),
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.018,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: size.width * 0.038,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _goToNextPage,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColor.buttonColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.018,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'Choose how you want to continue',
              style: TextStyle(
                color: Colors.white70,
                fontFamily: AppFont.fontFamily,
                fontSize: size.width * 0.035,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingSlideData {
  final String title;
  final String description;
  final String imageAsset;
  final IconData accentIcon;
  final List<String> highlights;

  const _OnboardingSlideData({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.accentIcon,
    required this.highlights,
  });
}
