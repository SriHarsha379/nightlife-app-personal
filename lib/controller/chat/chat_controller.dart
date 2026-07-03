import 'package:flutter/material.dart';

/// A single chat message exchanged between the user and the AI assistant.
class ChatMessageModel {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessageModel({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, String> toApiJson() => {'role': role, 'content': content};
}

/// Holds the in-memory conversation history for the Nightlife Assistant chat.
/// Registered as a ChangeNotifierProvider alongside HomeController/UserController.
class ChatController with ChangeNotifier {
  final List<ChatMessageModel> _messages = [];
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);

  bool get isEmpty => _messages.isEmpty;

  void addUserMessage(String text) {
    _messages.add(ChatMessageModel(role: 'user', content: text));
    notifyListeners();
  }

  void addAssistantMessage(String text) {
    _messages.add(ChatMessageModel(role: 'assistant', content: text));
    notifyListeners();
  }

  /// Converts the stored history into the {role, content} shape expected
  /// by the backend /chat/send endpoint.
  List<Map<String, String>> historyForApi() =>
      _messages.map((m) => m.toApiJson()).toList();

  void clear() {
    _messages.clear();
    notifyListeners();
  }
}