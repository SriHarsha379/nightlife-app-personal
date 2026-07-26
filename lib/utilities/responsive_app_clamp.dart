import 'package:flutter/material.dart';

/// Makes the app look right on phones AND tablets/iPads without touching
/// the ~500 existing `MediaQuery.of(context).size.width * X / 100` calls
/// spread across every screen in this codebase.
///
/// The problem those calls have: they were all designed against a phone
/// width. On a small phone they still look fine (everything shrinks
/// proportionally), but on a tablet the SAME percentages stretch buttons,
/// text fields, fonts, and spacing across the full tablet width, which
/// looks broken/oversized rather than "beautiful".
///
/// Rather than rewrite every call site, this widget sits directly inside
/// MaterialApp's `builder`, wrapping the whole navigator. On screens wider
/// than [tabletBreakpoint] it:
///   1. Overrides the MediaQuery `size` that every descendant widget sees,
///      clamping the width to [maxContentWidth] - so every existing
///      percentage-of-width calculation in the app automatically produces
///      the same phone-proportioned result it always has.
///   2. Visually centers that clamped-width content in the real available
///      space, with the leftover space "letterboxed" on either side.
///
/// On phones (width <= tabletBreakpoint) this is a no-op passthrough -
/// zero behavior change from what the app does today.
///
/// Usage (in main.dart's MaterialApp):
///   MaterialApp(
///     builder: (context, child) => ResponsiveAppClamp(child: child!),
///     ...
///   )
class ResponsiveAppClamp extends StatelessWidget {
  const ResponsiveAppClamp({
    super.key,
    required this.child,
    this.maxContentWidth = 480,
    this.tabletBreakpoint = 600,
    this.letterboxColor,
  });

  final Widget child;

  /// The width every screen's percentage-based sizing will behave as if
  /// the device is. 480 comfortably covers the largest phones (~430dp)
  /// with a little headroom, without still looking phone-cramped-in-a-box
  /// on a 768+ wide tablet.
  final double maxContentWidth;

  /// Below this width, behave exactly as the app does today (no clamping).
  final double tabletBreakpoint;

  /// Background shown in the letterboxed area on tablets. Defaults to
  /// the current theme's scaffold background so it blends in.
  final Color? letterboxColor;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double screenWidth = mq.size.width;

    // Also guard against extreme system font-size accessibility settings
    // blowing up the percentage-based layouts; keep it in a sane range
    // instead of disabling scaling entirely.
    final TextScaler clampedTextScaler = mq.textScaler.clamp(
      minScaleFactor: 0.9,
      maxScaleFactor: 1.2,
    );

    if (screenWidth <= tabletBreakpoint) {
      return MediaQuery(
        data: mq.copyWith(textScaler: clampedTextScaler),
        child: child,
      );
    }

    final double clampedWidth =
    screenWidth < maxContentWidth ? screenWidth : maxContentWidth;

    return Container(
      color: letterboxColor ?? Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.topCenter,
      child: MediaQuery(
        data: mq.copyWith(
          size: Size(clampedWidth, mq.size.height),
          textScaler: clampedTextScaler,
        ),
        child: SizedBox(
          width: clampedWidth,
          height: mq.size.height,
          child: child,
        ),
      ),
    );
  }
}