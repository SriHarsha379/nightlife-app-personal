import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/app_color.dart';
import '../utilities/app_font.dart';

/// One-time swipe gesture tutorial overlay — audit #19
/// Shows on first home screen visit, auto-dismisses after 3 seconds
/// or on tap. Never shown again after first dismiss.
class SwipeTutorialOverlay extends StatefulWidget {
  final Widget child;

  const SwipeTutorialOverlay({super.key, required this.child});

  @override
  State<SwipeTutorialOverlay> createState() => _SwipeTutorialOverlayState();
}

class _SwipeTutorialOverlayState extends State<SwipeTutorialOverlay>
    with TickerProviderStateMixin {
  bool _showTutorial = false;
  bool _dismissed = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _leftSwipeController;
  late AnimationController _rightSwipeController;
  late Animation<Offset> _leftSwipeAnimation;
  late Animation<Offset> _rightSwipeAnimation;

  static const String _prefKey = 'swipe_tutorial_shown';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Left swipe arrow animation
    _leftSwipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _leftSwipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0),
    ).animate(CurvedAnimation(
      parent: _leftSwipeController,
      curve: Curves.easeInOut,
    ));

    // Right swipe arrow animation
    _rightSwipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _rightSwipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(
      parent: _rightSwipeController,
      curve: Curves.easeInOut,
    ));

    _checkAndShow();
  }

  Future<void> _checkAndShow() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_prefKey) ?? false;
    if (!alreadyShown && mounted) {
      // Small delay so home screen loads first
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _showTutorial = true);
      _fadeController.forward();
      // Auto dismiss after 3.5 seconds
      Timer(const Duration(milliseconds: 3500), _dismiss);
    }
  }

  Future<void> _dismiss() async {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    await _fadeController.reverse();
    if (!mounted) return;
    setState(() => _showTutorial = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _leftSwipeController.dispose();
    _rightSwipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showTutorial) return widget.child;

    return Stack(
      children: [
        widget.child,
        // Overlay
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Swipe indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left arrow — Pass
                        SlideTransition(
                          position: _leftSwipeAnimation,
                          child: _buildHint(
                            icon: Icons.close_rounded,
                            label: 'Pass',
                            color: Colors.redAccent,
                            direction: 'left',
                          ),
                        ),
                        const SizedBox(width: 48),
                        // Right arrow — Like
                        SlideTransition(
                          position: _rightSwipeAnimation,
                          child: _buildHint(
                            icon: Icons.favorite_rounded,
                            label: 'Like',
                            color: AppColor.buttonColor,
                            direction: 'right',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Swipe instruction text
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'Swipe right to like · Swipe left to pass',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Tap anywhere to dismiss',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontFamily: AppFont.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHint({
    required IconData icon,
    required String label,
    required Color color,
    required String direction,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (direction == 'left')
              Icon(Icons.arrow_back_rounded,
                  color: Colors.white.withValues(alpha: 0.7), size: 16),
            if (direction == 'right')
              Icon(Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.7), size: 16),
          ],
        ),
      ],
    );
  }
}
