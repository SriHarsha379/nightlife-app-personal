import 'package:flutter/material.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';

// ── Data models ──────────────────────────────────────────────────────────────

/// A single option within a poll.
class PollOption {
  final String id;
  final String text;

  /// Seed vote count used to make results look realistic before any user votes.
  final int votes;

  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
  });

  PollOption copyWith({String? id, String? text, int? votes}) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      votes: votes ?? this.votes,
    );
  }
}

/// Data model that describes a poll.
class PollData {
  final String id;
  final String question;
  final List<PollOption> options;

  const PollData({
    required this.id,
    required this.question,
    required this.options,
  });

  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);
}

// ── Sample poll data ─────────────────────────────────────────────────────────

/// Sample polls shown when no backend data is available.
///
/// Replace or augment this list with real API-sourced data as needed.
const List<PollData> samplePolls = [
  PollData(
    id: 'poll_vibe_1',
    question: 'What\'s your go-to nightlife vibe? 🎶',
    options: [
      PollOption(id: 'a', text: '🍸  Cocktail bar with friends', votes: 42),
      PollOption(id: 'b', text: '🎵  Live music venue', votes: 37),
      PollOption(id: 'c', text: '🪩  Dance club', votes: 61),
      PollOption(id: 'd', text: '🌆  Rooftop lounge', votes: 29),
    ],
  ),
  PollData(
    id: 'poll_time_1',
    question: 'When do you usually head out? ⏰',
    options: [
      PollOption(id: 'a', text: '🌅  Before midnight', votes: 34),
      PollOption(id: 'b', text: '🌙  Around midnight', votes: 55),
      PollOption(id: 'c', text: '🦉  After midnight', votes: 28),
    ],
  ),
  PollData(
    id: 'poll_feature_1',
    question: 'Which app feature do you use most? 🔥',
    options: [
      PollOption(id: 'a', text: '👥  Finding members', votes: 48),
      PollOption(id: 'b', text: '🎉  Discovering events', votes: 53),
      PollOption(id: 'c', text: '🏛️  Browsing venues', votes: 31),
      PollOption(id: 'd', text: '💬  Chatting', votes: 22),
    ],
  ),
];

// ── Widget ───────────────────────────────────────────────────────────────────

/// An animated, interactive poll popup displayed as a centered modal dialog.
///
/// Features:
/// - Smooth slide-up + fade entry animation
/// - Single-select voting with animated radio indicators
/// - Animated result progress bars revealed after submission
/// - "Skip" link to dismiss without voting
/// - Theme-aware (dark / light mode)
/// - Fully responsive layout
class PollPopup extends StatefulWidget {
  final PollData data;

  const PollPopup({super.key, required this.data});

  /// Shows [data] as a modal poll overlay.
  ///
  /// Returns after the user submits a vote or dismisses the popup.
  static Future<void> show(BuildContext context, PollData data) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Poll',
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
      pageBuilder: (ctx, _, __) => PollPopup(data: data),
    );
  }

  @override
  State<PollPopup> createState() => _PollPopupState();
}

class _PollPopupState extends State<PollPopup>
    with SingleTickerProviderStateMixin {
  String? _selectedOptionId;
  bool _hasVoted = false;

  /// Live copy of options – updated when the user votes.
  late List<PollOption> _options;

  late AnimationController _barAnimController;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _options = List<PollOption>.from(widget.data.options);
    _barAnimController = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );
    _barAnimation = CurvedAnimation(
      parent: _barAnimController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  void _selectOption(String id) {
    if (_hasVoted) return;
    setState(() => _selectedOptionId = id);
  }

  void _submitVote() {
    final id = _selectedOptionId;
    if (id == null) return;

    setState(() {
      _options = _options.map((opt) {
        return opt.id == id ? opt.copyWith(votes: opt.votes + 1) : opt;
      }).toList();
      _hasVoted = true;
    });
    _barAnimController.forward();
  }

  void _dismiss() => Navigator.of(context).pop();

  // ── Computed helpers ─────────────────────────────────────────────────────────

  int get _totalDisplayVotes =>
      _options.fold(0, (sum, o) => sum + o.votes);

  double _votePercent(PollOption option) {
    final total = _totalDisplayVotes;
    if (total == 0) return 0.0;
    return option.votes / total;
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
                  _buildQuestion(isDark),
                  const SizedBox(height: 6),
                  _buildSubtitle(isDark),
                  const SizedBox(height: 20),
                  ..._options.map((opt) => _buildOption(opt, isDark)),
                  const SizedBox(height: 20),
                  _buildActionButton(isDark),
                  if (!_hasVoted) ...[
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
              colors: [Color(0xFFFF3BC1), Color(0xFFB131FA)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: const Text(
            '📊  POLL',
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

  Widget _buildQuestion(bool isDark) {
    return Text(
      widget.data.question,
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
    final label = _hasVoted
        ? '$_totalDisplayVotes votes · Thanks for voting! 🎉'
        : 'Tap an option, then submit';
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppFont.fontFamily,
        fontSize: 12,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      ),
    );
  }

  Widget _buildOption(PollOption option, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _hasVoted
          ? _buildResultBar(option, isDark)
          : _buildSelectableOption(option, isDark),
    );
  }

  Widget _buildSelectableOption(PollOption option, bool isDark) {
    final bool isSelected = _selectedOptionId == option.id;
    return GestureDetector(
      onTap: () => _selectOption(option.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.buttonColor.withOpacity(0.10)
              : isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColor.buttonColor
                : isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? AppColor.buttonColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColor.buttonColor
                      : isDark
                          ? Colors.white38
                          : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColor.buttonColor
                      : isDark
                          ? Colors.white87
                          : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar(PollOption option, bool isDark) {
    final bool isVoted = option.id == _selectedOptionId;
    final double percent = _votePercent(option);
    final int percentInt = (percent * 100).round();

    return AnimatedBuilder(
      animation: _barAnimation,
      builder: (context, _) {
        final animatedFraction = percent * _barAnimation.value;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: isVoted
                ? AppColor.buttonColor.withOpacity(0.08)
                : isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isVoted
                  ? AppColor.buttonColor.withOpacity(0.50)
                  : isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade200,
              width: isVoted ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isVoted) ...[
                    Icon(Icons.check_circle,
                        color: AppColor.buttonColor, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      option.text,
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 14,
                        fontWeight:
                            isVoted ? FontWeight.w600 : FontWeight.w400,
                        color: isVoted
                            ? AppColor.buttonColor
                            : isDark
                                ? Colors.white87
                                : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    '$percentInt%',
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isVoted
                          ? AppColor.buttonColor
                          : isDark
                              ? Colors.white54
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          width: constraints.maxWidth,
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.grey.shade200,
                        ),
                        Container(
                          height: 6,
                          width: constraints.maxWidth * animatedFraction,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isVoted
                                  ? [
                                      AppColor.buttonColor,
                                      AppColor.darkPurpleColor,
                                    ]
                                  : [
                                      const Color(0xFF5B308D),
                                      const Color(0xFF331F53),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(bool isDark) {
    if (_hasVoted) {
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
        onPressed: _selectedOptionId != null ? _submitVote : null,
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
        child: const Text(
          'Submit Vote',
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
