import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_font.dart';

/// Vibe Check answer rules (client): an answer counts only when it has at
/// least [kVibeMinWords] real words - and isn't one word repeated
/// ("later later later ..."). Used by signup Vibe Check and Edit Vibe Check.
const int kVibeMinWords = 6;

List<String> _vibeWords(String text) => text
    .trim()
    .split(RegExp(r'\s+'))
    .where((w) => RegExp(r'[A-Za-z0-9]').hasMatch(w))
    .toList();

int vibeWordCount(String text) => _vibeWords(text).length;

bool isValidVibeAnswer(String text) {
  final words = _vibeWords(text);
  return words.length >= kVibeMinWords &&
      words.map((w) => w.toLowerCase()).toSet().length >= 3;
}

/// Something typed, but not a valid answer yet (too short / repetitive).
bool isUnfinishedVibeAnswer(String text) =>
    text.trim().isNotEmpty && !isValidVibeAnswer(text);

/// Live "3/6 words" -> "✓ 7 words" hint shown under each answer box.
class VibeWordCounter extends StatelessWidget {
  final TextEditingController controller;
  const VibeWordCounter({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text;
        final n = vibeWordCount(text);
        String label;
        Color color;
        if (text.trim().isEmpty) {
          label = 'Minimum $kVibeMinWords words';
          color = AppColor.secondryColor(context).withOpacity(0.5);
        } else if (isValidVibeAnswer(text)) {
          label = '\u2713 $n words';
          color = const Color(0xFF34C759);
        } else if (n >= kVibeMinWords) {
          label = 'Write a real answer, not the same word repeated';
          color = AppColor.pinkColor;
        } else {
          label = '$n/$kVibeMinWords words';
          color = AppColor.pinkColor;
        }
        return Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFont.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
