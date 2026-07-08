import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utilities/app_config_provider.dart';
import '../utilities/app_constant.dart';

class AiCompanionProvider extends ChangeNotifier {
  static String get _chatEndpoint =>
      '${AppConfigProvider.apiUrl}chat/send';

  final List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;
  String? _lastError;

  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get lastError => _lastError;

  Future<void> loadHistory({required String userId}) async {}

  void clearLocalMessages() {
    _messages.clear();
    notifyListeners();
  }

  Future<void> sendMessage({
    required String userId,
    required String text,
    String personaId = 'default',
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _messages.add(<String, dynamic>{
      'id': 'local_${DateTime.now().microsecondsSinceEpoch}',
      'role': 'user',
      'message': trimmed,
      'createdAt': DateTime.now().toIso8601String(),
    });
    _isSending = true;
    _lastError = null;
    notifyListeners();

    try {
      // Backend expects: { messages: [{ role, content }] }
      final history = _messages
          .map((m) => {
        'role': m['role'],
        'content': m['message'],
      })
          .toList();

      final response = await http.post(
        Uri.parse(_chatEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'authorization': 'Bearer ${AppConstant.token}',
        },
        body: jsonEncode({'messages': history}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final innerData = data['data'] as Map<String, dynamic>?;
        final reply = (innerData?['reply'] ?? '').toString().trim();
        _messages.add(<String, dynamic>{
          'id': 'ai_${DateTime.now().microsecondsSinceEpoch}',
          'role': 'assistant',
          'message': reply.isEmpty ? "Sorry, I didn't catch that." : reply,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        _lastError = 'Server error (${response.statusCode})';
        _messages.add(_errorBubble());
      }
    } catch (e) {
      _lastError = e.toString();
      _messages.add(_errorBubble());
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _errorBubble() => <String, dynamic>{
    'id': 'err_${DateTime.now().microsecondsSinceEpoch}',
    'role': 'assistant',
    'message': "Couldn't reach the server. Please try again.",
    'createdAt': DateTime.now().toIso8601String(),
    '__error': true,
  };
}