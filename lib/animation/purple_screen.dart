import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../utilities/app_color.dart';

class PurpleScreen extends StatefulWidget {
  static String routeName = './PurpleScreen';
  final Widget nextScreen;
  const PurpleScreen({super.key, required this.nextScreen});

  @override
  State<PurpleScreen> createState() => _PurpleScreenState();
}

class _PurpleScreenState extends State<PurpleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create slide animation (down to up, then up to down)
    _slideAnimation = TweenSequence<Offset>([
      // Phase 1: Slide down from top to center (0.0 to 0.4)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -1), // Start from top (hidden)
          end: Offset.zero, // End at center (visible)
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 40,
      ),
      // Phase 2: Hold at center (0.4 to 0.6)
      TweenSequenceItem(
        tween: ConstantTween<Offset>(Offset.zero),
        weight: 20,
      ),
      // Phase 3: Slide up to bottom (0.6 to 1.0)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero, 
          end: const Offset(0, 1), 
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 20,
      ),
    ]).animate(_controller);

    // Create fade animation for smoother appearance
    _fadeAnimation = TweenSequence<double>([
      // Fade in (0.0 to 0.4)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      // Stay visible (0.4 to 0.6)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 20,
      ),
      // Fade out (0.6 to 1.0)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    // Start the animation
    _controller.forward();

    // Navigate to next screen after animation completes
    Timer(const Duration(milliseconds: 1100), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextScreen),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: const BoxDecoration(
                    color: AppColor.purpleScreenColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
