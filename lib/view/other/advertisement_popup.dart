import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';
import '../../utilities/url_utils.dart';

/// Data model for an advertisement popup.
class AdvertisementData {
  final String imageUrl;
  final String? title;
  final String? description;
  final String? ctaText;
  final String? ctaUrl;

  const AdvertisementData({
    required this.imageUrl,
    this.title,
    this.description,
    this.ctaText,
    this.ctaUrl,
  });
}

/// A set of sample advertisements used only as a fallback, for the rare
/// case the popup triggers before any real ad items have loaded from the
/// backend (see _collectRealAdImages() in home_Screen.dart, which is now
/// the primary source). These point at real network images rather than
/// local assets, since the local asset files these used to reference
/// ('assets/icons/eventimg.png' / 'eventstory1.jpg') were never actually
/// bundled with the app and always rendered as a broken-image icon.
const List<AdvertisementData> sampleAds = [
  AdvertisementData(
    imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=1200&fit=crop',
    title: 'Hot Events Near You 🔥',
    description:
    'Discover the hottest parties and nightlife events happening around you tonight.',
  ),
  AdvertisementData(
    imageUrl: 'https://images.unsplash.com/photo-1514933651103-005eec06c04b?w=800&h=1200&fit=crop',
    title: 'VIP Access — Limited Seats',
    description:
    'Book your VIP table before they run out. Exclusive deals for Hii members.',
  ),
];

/// Modal advertisement popup overlay.
///
/// Features:
/// - Smooth fade + scale entry animation
/// - Forced 3-second view period before the close button is enabled
/// - Countdown indicator that transitions to a close (✕) icon
/// - Optional call-to-action button that opens a URL
/// - Fully theme-aware (dark / light mode)
/// - Responsive layout that adapts to all screen sizes
class AdvertisementPopup extends StatefulWidget {
  final AdvertisementData data;

  const AdvertisementPopup({super.key, required this.data});

  /// Shows [data] as a modal advertisement overlay.
  ///
  /// Returns after the user closes or the dialog is dismissed.
  static Future<void> show(BuildContext context, AdvertisementData data) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Advertisement',
      barrierColor: Colors.black.withOpacity(0.75),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, _, __) => AdvertisementPopup(data: data),
    );
  }

  @override
  State<AdvertisementPopup> createState() => _AdvertisementPopupState();
}

class _AdvertisementPopupState extends State<AdvertisementPopup> {
  static const int _forceViewSeconds = 3;

  int _secondsLeft = _forceViewSeconds;
  bool _canClose = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsLeft--;
        if (_secondsLeft <= 0) {
          _canClose = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _close() {
    if (!_canClose) return;
    Navigator.of(context).pop();
  }

  Future<void> _onCtaTap() async {
    final url = widget.data.ctaUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasTitle = widget.data.title?.isNotEmpty ?? false;
    final bool hasDescription = widget.data.description?.isNotEmpty ?? false;
    final bool hasCta = (widget.data.ctaText?.isNotEmpty ?? false) &&
        (widget.data.ctaUrl?.isNotEmpty ?? false);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: size.height * 0.82,
          ),
          child: Container(
            width: size.width * 0.88,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E0E2A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColor.themeColor.withOpacity(0.45),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Image section ─────────────────────────────────────────
                    _buildImageSection(size, isDark),

                    // ── Body section ──────────────────────────────────────────
                    if (hasTitle || hasDescription || hasCta)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasTitle) ...[
                              Text(
                                widget.data.title!,
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color:
                                  isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                            if (hasDescription) ...[
                              Text(
                                widget.data.description!,
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade600,
                                  height: 1.55,
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],
                            if (hasCta)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _onCtaTap,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.buttonColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    widget.data.ctaText!,
                                    style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(Size size, bool isDark) {
    final imageH = size.height * 0.36;
    return Stack(
      children: [
        _AdImageWidget(
          imageUrl: widget.data.imageUrl,
          height: imageH,
          width: double.infinity,
          isDark: isDark,
        ),
        // Top overlay: "AD" badge + countdown/close button
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColor.themeColor.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.fontFamily,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              // Countdown / close button
              GestureDetector(
                onTap: _canClose ? _close : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _canClose
                        ? Colors.black.withOpacity(0.60)
                        : Colors.black.withOpacity(0.30),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _canClose
                        ? const Icon(Icons.close,
                        color: Colors.white, size: 18)
                        : Text(
                      '$_secondsLeft',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Internal helper widget that renders the ad image with a purple gradient
/// fallback when the image cannot be loaded.
class _AdImageWidget extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final bool isDark;

  const _AdImageWidget({
    required this.imageUrl,
    required this.height,
    required this.width,
    required this.isDark,
  });

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF472657), Color(0xFF1A0F1F)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white54,
          size: 48,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isNetworkUrl(imageUrl)) {
      return Image.network(
        imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return _placeholder();
        },
      );
    }

    return Image.asset(
      imageUrl,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }
}