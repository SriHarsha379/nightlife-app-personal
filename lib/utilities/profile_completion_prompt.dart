import 'package:flutter/material.dart';

import '../provider/common_api_helper.dart';
import 'app_color.dart';
import 'app_constant.dart';
import 'app_font.dart';
import 'profile_completion_navigation.dart';

/// Client ask: "Completed % of profile prompt every-time app opens".
///
/// Shows a small bottom sheet with the member's profile % and a
/// "Complete now" button:
///   * once on every cold start (when Home first appears), and
///   * every time the app comes back after being in the background for
///     at least [_minBackgroundTime] (short trips - picking a photo,
///     pulling down notifications - don't count).
/// Never shows when the profile is already 100%, when logged out, or when
/// another screen is open on top of Home.
class ProfileCompletionPrompt with WidgetsBindingObserver {
  ProfileCompletionPrompt._();
  static final ProfileCompletionPrompt _instance = ProfileCompletionPrompt._();

  static const Duration _minBackgroundTime = Duration(minutes: 2);

  static BuildContext? _homeContext;
  static bool _observing = false;
  static bool _shownThisLaunch = false;
  static bool _isShowing = false;
  static DateTime? _backgroundedAt;

  /// Call from Home's initState. Safe to call repeatedly (e.g. when the
  /// member switches bottom-nav tabs and Home is rebuilt).
  static void attach(BuildContext homeContext) {
    _homeContext = homeContext;
    if (!_observing) {
      WidgetsBinding.instance.addObserver(_instance);
      _observing = true;
    }
    if (!_shownThisLaunch) {
      _shownThisLaunch = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Future.delayed(const Duration(milliseconds: 1200), _maybeShow),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (since != null && DateTime.now().difference(since) >= _minBackgroundTime) {
        Future.delayed(const Duration(milliseconds: 600), _maybeShow);
      }
    }
  }

  static Future<void> _maybeShow() async {
    final BuildContext? ctx = _homeContext;
    if (ctx == null || !ctx.mounted || _isShowing) return;
    if (AppConstant.token.isEmpty) return;
    if (ModalRoute.of(ctx)?.isCurrent == false) return; // something is open on top

    try {
      final res = await getData(
        'common/profile_complete_status',
        null,
        headers: {'authorization': 'Bearer ${AppConstant.token}'},
      );
      if (res == null || res['success'] != true || res['data'] is! Map) return;
      final Map data = res['data'];
      final dynamic pct = data['profile_completion_percentage'];
      final int percent = pct is num ? pct.toInt().clamp(0, 100) : 100;
      if (percent >= 100) return;

      final List<String> messages = (data['messages'] is List ? data['messages'] as List : const [])
          .whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final List<String> fields = (data['fields'] is List ? data['fields'] as List : const [])
          .whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      if (!ctx.mounted || ModalRoute.of(ctx)?.isCurrent == false) return;
      _isShowing = true;
      await showModalBottomSheet(
        context: ctx,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (sheetCtx) => _PromptSheet(
          percent: percent,
          hint: messages.isNotEmpty ? messages.first : null,
          onCompleteNow: () {
            Navigator.pop(sheetCtx);
            navigateToProfileCompletionField(ctx, fields.isNotEmpty ? fields.first : null);
          },
        ),
      );
    } catch (_) {
      // Best effort only - never block the app.
    } finally {
      _isShowing = false;
    }
  }
}

class _PromptSheet extends StatelessWidget {
  const _PromptSheet({required this.percent, required this.onCompleteNow, this.hint});
  final int percent;
  final String? hint;
  final VoidCallback onCompleteNow;

  @override
  Widget build(BuildContext context) {
    final Color text = AppColor.secondryColor(context);
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: AppColor.primaryColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColor.pinkColor.withOpacity(0.35)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your profile is $percent% complete',
              style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 18,
                  fontWeight: FontWeight.w700, color: text),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 8,
                backgroundColor: text.withOpacity(0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColor.pinkColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hint ?? 'Complete profiles get more matches and invites.',
              style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 14,
                  color: text.withOpacity(0.8)),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Later',
                        style: TextStyle(fontFamily: AppFont.fontFamily,
                            fontSize: 15, color: text.withOpacity(0.7))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onCompleteNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.pinkColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Complete now',
                          style: TextStyle(fontFamily: AppFont.fontFamily,
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
