import 'package:flutter/material.dart';
import '/utilities/app_color.dart';

class ProgressHUD extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? loaderColor;
  final Color? backgroundColor;
  final double loaderSize;
  final Duration animationDuration;
  final Duration exitDelay;
  final bool showDots;
  final bool showBackground;

  const ProgressHUD({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.loaderColor = AppColor.themeColor,
    this.backgroundColor = Colors.white,
    this.loaderSize = 60.0,
    this.animationDuration = const Duration(milliseconds: 800),
    this.exitDelay = const Duration(milliseconds: 500),
    this.showDots = true,
    this.showBackground = true,
  });

  @override
  _ProgressHUDState createState() => _ProgressHUDState();
}

class _ProgressHUDState extends State<ProgressHUD>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late AnimationController _exitController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _exitAnimation;

  bool _showLoader = false;
  bool _previousLoadingState = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _showLoader = widget.isLoading;
    _previousLoadingState = widget.isLoading;

    if (widget.isLoading) {
      _startLoadingAnimation();
    }
  }

  void _initializeAnimations() {
    // Fade animation for entrance
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Continuous rotation for loader
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Exit animation for smooth disappearance
    _exitController = AnimationController(
      duration: widget.exitDelay,
      vsync: this,
    );

    // Create smooth animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _exitAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );
  }

  @override
  void didUpdateWidget(ProgressHUD oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle loading state changes smoothly
    if (widget.isLoading != _previousLoadingState) {
      if (widget.isLoading) {
        _startLoadingAnimation();
      } else {
        _stopLoadingAnimation();
      }
      _previousLoadingState = widget.isLoading;
    }
  }

  void _startLoadingAnimation() {
    setState(() => _showLoader = true);
    _fadeController.forward();
    _rotationController.repeat();
  }

  Future<void> _stopLoadingAnimation() async {
    // Start exit animation
    await _exitController.forward();

    // Stop rotation and fade out
    _rotationController.stop();
    _fadeController.reverse();

    // Hide loader
    setState(() => _showLoader = false);
    _exitController.reset();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loaderColor = widget.loaderColor ?? theme.primaryColor;
    final backgroundColor = widget.backgroundColor ??
        (widget.showBackground
            ? Colors.white.withOpacity(0.9)
            : Colors.transparent);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Main content with simple fade transition
          AnimatedOpacity(
            opacity: _showLoader ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: widget.child,
          ),

          // Smooth loader overlay - FIXED: Background maintains 0.4 opacity
          if (_showLoader)
            AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _exitAnimation]),
              builder: (context, child) {
                final contentOpacity =
                    _fadeAnimation.value * _exitAnimation.value;
                final backgroundOpacity = 0.4 * _fadeAnimation.value;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: contentOpacity > 0
                      ? Container(
                          key: const ValueKey("smooth_loader"),
                          color: backgroundColor.withOpacity(backgroundOpacity),
                          child: Center(
                            child: Opacity(
                              opacity: contentOpacity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Custom rotating loader
                                  _buildRotatingLoader(loaderColor),

                                  const SizedBox(height: 24),
                                  _buildLoadingText(loaderColor),

                                  if (widget.showDots) ...[
                                    const SizedBox(height: 16),
                                    _buildAnimatedDots(loaderColor),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRotatingLoader(Color color) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: SizedBox(
            width: widget.loaderSize,
            height: widget.loaderSize,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: color.withOpacity(0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingText(Color color) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: 1,
          child: Text(
            widget.loadingText ?? "Loading...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedDots(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            double delay = index * 0.3;
            double animValue = (_rotationAnimation.value + delay) % 1.0;
            double scale = 0.5 + (animValue * 0.5);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.4 + (animValue * 0.6)),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
