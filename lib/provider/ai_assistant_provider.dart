import 'package:flutter/material.dart';

import 'common_api_helper.dart';

/// One turn in the AI assistant conversation. Mirrors the shape the
/// backend's /chat/send endpoint expects and returns (see
/// Hii-Backend/src/routes/app/chatRoutes.js).
class AiAssistantMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  AiAssistantMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Shared state for the AI assistant launcher (see
/// commonWidget/ai_assistant_launcher.dart). One instance is used app-wide
/// so the conversation persists as the member navigates between the
/// screens the launcher is shown on (Members/Venues/Events), instead of
/// resetting every time the panel is reopened.
class AiAssistantProvider extends ChangeNotifier {
  final List<AiAssistantMessage> _messages = [];
  List<AiAssistantMessage> get messages => List.unmodifiable(_messages);

  bool _isSending = false;
  bool get isSending => _isSending;

  String? _lastError;
  String? get lastError => _lastError;

  Future<void> sendMessage(BuildContext context, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _lastError = null;
    _messages.add(AiAssistantMessage(role: 'user', content: trimmed));
    _isSending = true;
    notifyListeners();

    try {
      final res = await postJsonData(
        'chat/send',
        {'messages': _messages.map((m) => m.toJson()).toList()},
        context,
      );

      if (res != null && res['success'] == true) {
        final reply = res['data']?['reply']?.toString() ??
            "Sorry, I couldn't find anything on that.";
        _messages.add(AiAssistantMessage(role: 'assistant', content: reply));
      } else {
        _lastError = "Couldn't reach the assistant. Please try again.";
        _messages.add(AiAssistantMessage(
          role: 'assistant',
          content: "Sorry, something went wrong. Please try again.",
        ));
      }
    } catch (_) {
      _lastError = "Couldn't reach the assistant. Please try again.";
      _messages.add(AiAssistantMessage(
        role: 'assistant',
        content: "Sorry, something went wrong. Please try again.",
      ));
    }

    _isSending = false;
    notifyListeners();
  }

  void clearConversation() {
    _messages.clear();
    _lastError = null;
    notifyListeners();
  }
}