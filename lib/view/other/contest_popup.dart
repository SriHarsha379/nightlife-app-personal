import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/contest/contest_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';

// ── Data model ───────────────────────────────────────────────────────────────

/// Data model that describes a contest.
class ContestData {
  final String id;
  final String title;
  final String rules;
  final String reward;
  final DateTime? deadline;
  final int participants;

  /// True if this user has already entered — set from the real API so
  /// the popup opens straight into the "you're in" state instead of
  /// letting them enter twice (the backend also enforces one entry per
  /// user per contest, but the UI shouldn't even offer a second try).
  final bool alreadyEntered;

  const ContestData({
    required this.id,
    required this.title,
    required this.rules,
    required this.reward,
    required this.deadline,
    required this.participants,
    this.alreadyEntered = false,
  });

  factory ContestData.fromJson(Map<String, dynamic> json) {
    DateTime? deadline;
    final rawDeadline = json['deadline'];
    if (rawDeadline is String && rawDeadline.isNotEmpty) {
      deadline = DateTime.tryParse(rawDeadline);
    }
    return ContestData(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      rules: (json['rules'] ?? '').toString(),
      reward: (json['reward'] ?? '').toString(),
      deadline: deadline,
      participants:
      (json['participants'] is num) ? (json['participants'] as num).toInt() : 0,
      alreadyEntered: json['already_entered'] == true,
    );
  }

  ContestData copyWith({int? participants, bool? alreadyEntered}) {
    return ContestData(
      id: id,
      title: title,
      rules: rules,
      reward: reward,
      deadline: deadline,
      participants: participants ?? this.participants,
      alreadyEntered: alreadyEntered ?? this.alreadyEntered,
    );
  }
}

// ── Widget ───────────────────────────────────────────────────────────────────

/// An animated, interactive contest popup displayed as a centered modal
/// dialog. Mirrors PollPopup's structure and visual language.
class ContestPopup extends StatefulWidget {
  final ContestData data;

  const ContestPopup({super.key, required this.data});

  static Future<void> show(BuildContext context, ContestData data) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Contest',
      barrierColor: Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (ctx, animation, _, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => ContestPopup(data: data),
    );
  }

  @override
  State<ContestPopup> createState() => _ContestPopupState();
}

class _ContestPopupState extends State<ContestPopup> {
  late bool _hasEntered;
  late int _participants;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _hasEntered = widget.data.alreadyEntered;
    _participants = widget.data.participants;
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _enter() async {
    if (_hasEntered || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final contestController =
    Provider.of<ContestController>(context, listen: false);
    final result = await contestController.enterContest(context, widget.data.id);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _hasEntered = true;
      // Real count from the server when available; otherwise an
      // optimistic local +1 so the entry still visually registers.
      _participants = result?.participants ?? (_participants + 1);
    });
  }

  void _dismiss() => Navigator.of(context).pop();

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String get _deadlineLabel {
    final deadline = widget.data.deadline;
    if (deadline == null) return '';
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return 'Closed';
    if (diff.inDays >= 1) return 'Ends in ${diff.inDays}d';
    if (diff.inHours >= 1) return 'Ends in ${diff.inHours}h';
    return 'Ends in ${diff.inMinutes}m';
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: size.height * 0.88,
          ),
          child: Container(
            width: size.width * 0.88,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E0E2A) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isDark),
                  const SizedBox(height: 16),
                  _buildTitle(isDark),
                  const SizedBox(height: 6),
                  _buildSubtitle(isDark),
                  const SizedBox(height: 20),
                  if (widget.data.rules.isNotEmpty) _buildRules(isDark),
                  if (widget.data.reward.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildReward(isDark),
                  ],
                  const SizedBox(height: 20),
                  _buildActionButton(isDark),
                  if (!_hasEntered) ...[
                    const SizedBox(height: 10),
                    _buildSkipButton(isDark),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFB800), Color(0xFFFF3BC1)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: const Text(
            '🏆  CONTEST',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: AppFont.fontFamily,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Spacer(),
        if (_deadlineLabel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _deadlineLabel,
              style: TextStyle(
                fontFamily: AppFont.fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _dismiss,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              size: 16,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      widget.data.title,
      style: TextStyle(
        fontFamily: AppFont.fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildSubtitle(bool isDark) {
    final label = _hasEntered
        ? '$_participants entered · You\'re in! 🎉'
        : '$_participants have entered so far';
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppFont.fontFamily,
        fontSize: 12,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildRules(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.10) : Colors.grey.shade200,
        ),
      ),
      child: Text(
        widget.data.rules,
        style: TextStyle(
          fontFamily: AppFont.fontFamily,
          fontSize: 13,
          height: 1.5,
          color: isDark ? Colors.white.withOpacity(0.75) : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildReward(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColor.buttonColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.buttonColor.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.data.reward,
              style: TextStyle(
                fontFamily: AppFont.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColor.buttonColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark) {
    if (_hasEntered) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _dismiss,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.buttonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Done',
            style: TextStyle(
              fontFamily: AppFont.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _enter,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.buttonColor,
          disabledBackgroundColor: AppColor.buttonColor.withOpacity(0.35),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Text(
          'Join Contest',
          style: TextStyle(
            fontFamily: AppFont.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(bool isDark) {
    return Center(
      child: TextButton(
        onPressed: _dismiss,
        style: TextButton.styleFrom(
          foregroundColor:
          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
        child: Text(
          'Skip',
          style: TextStyle(
            fontFamily: AppFont.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}