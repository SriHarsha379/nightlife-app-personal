import 'package:flutter/material.dart';

import '../../utilities/app_color.dart';

/// A modal popup showing a single admin-created contest, with an Enter
/// action. Built to match poll_popup.dart's visual language.
///
/// This is the first app-side UI for Contests at all — the admin
/// dashboard's Polls & Contests page and the backend entry-tracking model
/// already existed, but nothing let a real user see or enter a contest.
class ContestPopup extends StatefulWidget {
  final String title;
  final String rules;
  final String reward;
  final DateTime? deadline;
  final int participants;
  final bool alreadyEntered;

  /// Called when the user taps Enter. Should submit the entry and return
  /// true on success (including "already entered", which the caller
  /// treats as a soft success), or false on genuine failure.
  final Future<bool> Function() onEnter;

  const ContestPopup({
    super.key,
    required this.title,
    required this.rules,
    required this.reward,
    required this.deadline,
    required this.participants,
    required this.alreadyEntered,
    required this.onEnter,
  });

  static Future<void> show(
      BuildContext context, {
        required String title,
        required String rules,
        required String reward,
        required DateTime? deadline,
        required int participants,
        required bool alreadyEntered,
        required Future<bool> Function() onEnter,
      }) {
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
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slideAnimation, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => ContestPopup(
        title: title,
        rules: rules,
        reward: reward,
        deadline: deadline,
        participants: participants,
        alreadyEntered: alreadyEntered,
        onEnter: onEnter,
      ),
    );
  }

  @override
  State<ContestPopup> createState() => _ContestPopupState();
}

class _ContestPopupState extends State<ContestPopup> {
  late bool _entered;
  late int _participants;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _entered = widget.alreadyEntered;
    _participants = widget.participants;
  }

  Future<void> _handleEnter() async {
    if (_isSubmitting || _entered) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final success = await widget.onEnter();

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (success) {
        _entered = true;
        _participants += 1;
      } else {
        _errorText = "Couldn't enter this contest. Please try again.";
      }
    });
  }

  void _dismiss() => Navigator.of(context).pop();

  String get _deadlineLabel {
    final deadline = widget.deadline;
    if (deadline == null) return 'No deadline set';
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) return 'Closed';
    if (diff.inDays >= 1) return '${diff.inDays}d left to enter';
    if (diff.inHours >= 1) return '${diff.inHours}h left to enter';
    return '${diff.inMinutes}m left to enter';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420, maxHeight: size.height * 0.88),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.emoji_events, size: 14, color: AppColor.buttonColor),
                            const SizedBox(width: 6),
                            Text(
                              'CONTEST',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: AppColor.buttonColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Icon(Icons.close, size: 20, color: isDark ? Colors.white54 : Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  if (widget.rules.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.rules,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (widget.reward.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColor.buttonColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColor.buttonColor.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_giftcard, size: 18, color: AppColor.buttonColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.reward,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.people_alt_outlined, size: 15, color: isDark ? Colors.white54 : Colors.black45),
                      const SizedBox(width: 6),
                      Text(
                        '$_participants entered',
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.schedule, size: 15, color: isDark ? Colors.white54 : Colors.black45),
                      const SizedBox(width: 6),
                      Text(
                        _deadlineLabel,
                        style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black45),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_errorText != null) ...[
                    Text(
                      _errorText!,
                      style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _entered || _isSubmitting ? null : _handleEnter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.buttonColor,
                        disabledBackgroundColor: _entered
                            ? AppColor.buttonColor.withOpacity(0.5)
                            : AppColor.buttonColor.withOpacity(0.35),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : Text(
                        _entered ? "You're In! 🎉" : 'Enter Contest',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (!_entered) ...[
                    const SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: _dismiss,
                        child: Text(
                          'Maybe later',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}