import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class ConversionListController with ChangeNotifier {
  bool _isFetchingConversation = false;
  String _lastConversationId = '';
  final Map<String, String> _conversationIdByUserId = <String, String>{};

  bool get isFetchingConversation => _isFetchingConversation;
  String get lastConversationId => _lastConversationId;

  String conversationIdForUser(String userId) {
    final key = userId.trim();
    if (key.isEmpty) return '';
    return _conversationIdByUserId[key] ?? '';
  }

  Future<String> fetchConversationIdByUserId({
    required String otherUserId,
  }) async {
    final userId = otherUserId.trim();
    if (userId.isEmpty) {
      _lastConversationId = '';
      return '';
    }

    if (_conversationIdByUserId.containsKey(userId)) {
      _lastConversationId = _conversationIdByUserId[userId] ?? '';
      return _lastConversationId;
    }

    final token = AppConstant.token;
    if (token.isEmpty) {
      _lastConversationId = '';
      return '';
    }

    _isFetchingConversation = true;
    notifyListeners();

    String resolvedConversationId = '';
    try {
      final response = await postJsonData(
        'user/user_convertion_details',
        <String, dynamic>{
          'user_id': userId,
        },
        null,
        headers: <String, String>{
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final message = response['message'];
        if (message is Map) {
          final dynamic conversation = message['conversation'];
          resolvedConversationId =
              (message['conversation_id'] ?? '').toString().trim();

          if (resolvedConversationId.isEmpty && conversation is Map) {
            resolvedConversationId =
                (conversation['_id'] ?? conversation['conversation_id'] ?? '')
                    .toString()
                    .trim();
          }
        }
      }
    } catch (_) {
      resolvedConversationId = '';
    } finally {
      _lastConversationId = resolvedConversationId;
      _conversationIdByUserId[userId] = resolvedConversationId;
      _isFetchingConversation = false;
      notifyListeners();
    }

    return resolvedConversationId;
  }

  void clearCache() {
    _lastConversationId = '';
    _conversationIdByUserId.clear();
    notifyListeners();
  }
}
