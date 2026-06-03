// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'package:flutter/material.dart';

//==================INF0 POP UP=============//
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

//==================INFO POP UP (Works in BottomSheets too)==============//
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class SnackBarToastMessage {
  SnackBarToastMessage._();

  static OverlayEntry? _currentOverlay;

  static void showSnackBar(BuildContext context, String message) {
    show(context, message);
  }

  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(milliseconds: 2500),
  }) {
    if (!context.mounted) return;

    final colors = _getColors(type);
    final icon = _getIcon(type);

    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Always use Overlay (works everywhere including BottomSheets)
    _showOverlayToast(context, message, icon, colors, duration);
  }

  static void dismiss(BuildContext context) {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  // Overlay-based toast for all cases
  static void _showOverlayToast(
    BuildContext context,
    String message,
    IconData icon,
    Map<String, Color> colors,
    Duration duration,
  ) {
    final overlay = Overlay.of(context);

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom + 60,
        left: 16,
        right: 16,
        child: IgnorePointer(
          ignoring: false,
          child: Material(
            color: Colors.transparent,
            child: _AnimatedSnackBarContent(
              message: message,
              icon: icon,
              backgroundColor: colors['background']!,
              iconColor: colors['icon']!,
              textColor: colors['text']!,
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto-remove after duration
    Future.delayed(duration + const Duration(milliseconds: 400), () {
      _currentOverlay?.remove();
      _currentOverlay = null;
    });
  }

  // Convenience methods
  static void success(BuildContext context, String message) {
    show(context, message, type: SnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: SnackBarType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: SnackBarType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: SnackBarType.info);
  }

  // Get colors based on type
  static Map<String, Color> _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return {
          'background': Color(0xFF10B981),
          'icon': Colors.white,
          'text': Colors.white,
        };
      case SnackBarType.error:
        return {
          'background': Color(0xFFEF4444),
          'icon': Colors.white,
          'text': Colors.white,
        };
      case SnackBarType.warning:
        return {
          'background': Color(0xFFF59E0B),
          'icon': Colors.white,
          'text': Colors.white,
        };
      case SnackBarType.info:
        return {
          'background': Color(0xFF1F2937),
          'icon': Colors.white70,
          'text': Colors.white,
        };
    }
  }

  // Get icon based on type
  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_rounded;
      case SnackBarType.error:
        return Icons.error_rounded;
      case SnackBarType.warning:
        return Icons.warning_rounded;
      case SnackBarType.info:
        return Icons.info_rounded;
    }
  }
}

// Animated SnackBar Content Widget
class _AnimatedSnackBarContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const _AnimatedSnackBarContent({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
  });

  @override
  State<_AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<_AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Animated Icon with pulse effect
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.9 + (value * 0.1),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.iconColor,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                // Message
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//================API POP UP============//

enum NotificationType { success, error }

class TopNotification {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    NotificationType type = NotificationType.success,
    Duration duration = const Duration(seconds: 2),
  }) {
    // Check if context is valid and mounted
    if (!context.mounted) {
      print('TopNotification: Context is not mounted');
      return;
    }

    try {
      // Remove existing notification if any
      _removeCurrentNotification();

      // Get the overlay with null safety check
      final overlay = Overlay.of(context, rootOverlay: true);

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: _AnimatedBanner(
            message: message,
            type: type,
            onDismiss: _removeCurrentNotification,
          ),
        ),
      );

      overlay.insert(_overlayEntry!);

      // Cancel any existing timer
      _timer?.cancel();

      // Create new timer
      _timer = Timer(duration, () {
        _removeCurrentNotification();
      });
    } catch (e) {
      print('TopNotification error: $e');
      // Fallback to SnackBar if overlay fails
      _showFallbackSnackBar(context, message, type);
    }
  }

  static void _removeCurrentNotification() {
    _timer?.cancel();
    _timer = null;

    try {
      if (_overlayEntry != null && _overlayEntry!.mounted) {
        _overlayEntry?.remove();
      }
    } catch (e) {
      print('Error removing notification: $e');
    } finally {
      _overlayEntry = null;
    }
  }

  static void _showFallbackSnackBar(
    BuildContext context,
    String message,
    NotificationType type,
  ) {
    if (!context.mounted) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                type == NotificationType.success
                    ? Icons.check_circle
                    : Icons.error,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          backgroundColor: type == NotificationType.success
              ? Colors.green.shade700
              : Colors.red.shade700,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Fallback SnackBar error: $e');
    }
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: NotificationType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: NotificationType.error);
  }

  // Optional: Call this when disposing your app or main widget
  static void dispose() {
    _removeCurrentNotification();
  }
}

class _AnimatedBanner extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _AnimatedBanner({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_AnimatedBanner> createState() => _AnimatedBannerState();
}

class _AnimatedBannerState extends State<_AnimatedBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return Colors.green.shade700;
      case NotificationType.error:
        return Colors.red.shade700;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
