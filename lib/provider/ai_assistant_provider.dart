import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utilities/app_config_provider.dart';
import '../utilities/session_manager.dart';
import 'common_api_helper.dart';

/// A tappable venue/event card the owl attaches to a reply.
class OwlCard {
  final String type; // 'venue' | 'event'
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final double? distanceKm;
  final String badge;

  const OwlCard({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle = '',
    this.image = '',
    this.distanceKm,
    this.badge = '',
  });

  bool get isEvent => type == 'event';

  static OwlCard? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = (json['id'] ?? '').toString();
    final type = (json['type'] ?? '').toString();
    if (id.isEmpty || (type != 'venue' && type != 'event')) return null;
    final dist = json['distance_km'];
    return OwlCard(
      type: type,
      id: id,
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      distanceKm: dist is num ? dist.toDouble() : double.tryParse('${dist ?? ''}'),
      badge: (json['badge'] ?? '').toString(),
    );
  }

  static List<OwlCard> listFrom(dynamic json) {
    if (json is! List) return <OwlCard>[];
    return json.map(OwlCard.fromJson).whereType<OwlCard>().toList();
  }
}

/// One turn in the Hii Owl conversation.
class AiAssistantMessage {
  final String role; // 'user' or 'assistant'
  String content;
  List<OwlCard> cards;
  bool isStreaming;
  bool isError;

  AiAssistantMessage({
    required this.role,
    required this.content,
    List<OwlCard>? cards,
    this.isStreaming = false,
    this.isError = false,
  }) : cards = cards ?? <OwlCard>[];

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Shared state for Hii Owl - the floating owl on Home and the Chats-tab
/// entry both use this one instance, so the conversation carries over.
///
/// Replies stream in word by word from `chat/stream` (Server-Sent Events).
/// If streaming isn't available (older backend, proxy buffering, network
/// hiccup) it falls back to the regular `chat/send` JSON call.
class AiAssistantProvider extends ChangeNotifier {
  static const List<String> suggestions = [
    "What's on tonight? 🎉",
    'Rooftop bars near me',
    'Best deals this weekend',
    'Clubs open right now',
    'Techno events this week',
    'Somewhere like the places I liked',
  ];

  final List<AiAssistantMessage> _messages = [];
  List<AiAssistantMessage> get messages => List.unmodifiable(_messages);

  bool _isSending = false;
  bool get isSending => _isSending;

  /// Short "what I'm doing" line, e.g. "Checking events…".
  String? _status;
  String? get status => _status;

  String? _lastError;
  String? get lastError => _lastError;

  http.Client? _activeClient;
  int _generation = 0; // bumps on "new chat" so stale replies are dropped

  Future<void> sendMessage(BuildContext context, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isSending) return;

    _lastError = null;
    _messages.add(AiAssistantMessage(role: 'user', content: trimmed));
    final history = _messages
        .where((m) => !m.isError && m.content.trim().isNotEmpty)
        .map((m) => m.toJson())
        .toList();
    final reply = AiAssistantMessage(role: 'assistant', content: '', isStreaming: true);
    _messages.add(reply);
    _isSending = true;
    _status = 'Thinking…';
    notifyListeners();

    final gen = _generation;
    var ok = await _tryStream(history, reply, gen);
    if (gen != _generation) return;
    if (!ok) {
      // The sheet may have been closed meanwhile - still finish the reply.
      ok = await _sendWithoutStream(context.mounted ? context : null, history, reply);
    }
    if (gen != _generation) return;
    if (!ok) {
      _lastError = "Couldn't reach Hii Owl. Please try again.";
      reply.content = "Sorry, I couldn't connect just now. Please try again. 🦉";
      reply.isError = true;
    }
    reply.isStreaming = false;
    _isSending = false;
    _status = null;
    notifyListeners();
  }

  Future<bool> _tryStream(
      List<Map<String, dynamic>> history, AiAssistantMessage reply, int gen) async {
    final client = http.Client();
    _activeClient = client;
    var received = false;
    try {
      final request = http.Request(
        'POST',
        Uri.parse('${AppConfigProvider.apiUrl}chat/stream'),
      );
      request.headers.addAll(SessionManager.withAuthorizationHeader({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      }));
      request.body = jsonEncode({'messages': history});

      final response = await client.send(request).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) return false;

      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(const Duration(seconds: 60));

      await for (final line in lines) {
        if (gen != _generation) return true;
        if (!line.startsWith('data:')) continue;
        dynamic event;
        try {
          event = jsonDecode(line.substring(5).trim());
        } catch (_) {
          continue;
        }
        if (event is! Map) continue;
        switch (event['type']) {
          case 'status':
            _status = (event['text'] ?? '').toString();
            break;
          case 'text':
            reply.content += (event['text'] ?? '').toString();
            _status = null;
            received = true;
            break;
          case 'done':
            final full = (event['reply'] ?? '').toString();
            if (full.isNotEmpty) reply.content = full;
            reply.cards = OwlCard.listFrom(event['cards']);
            received = true;
            break;
          case 'error':
            reply.content = (event['message'] ?? 'Sorry, something went wrong.').toString();
            reply.isError = true;
            received = true;
            break;
        }
        notifyListeners();
      }
      return received;
    } catch (_) {
      // Keep whatever already arrived; otherwise let the caller fall back.
      return received && reply.content.trim().isNotEmpty;
    } finally {
      client.close();
      if (identical(_activeClient, client)) _activeClient = null;
    }
  }

  Future<bool> _sendWithoutStream(BuildContext? context,
      List<Map<String, dynamic>> history, AiAssistantMessage reply) async {
    try {
      _status = 'Thinking…';
      notifyListeners();
      final res = await postJsonData('chat/send', {'messages': history}, context);
      if (res != null && res['success'] == true) {
        final data = res['data'];
        reply.content = (data is Map ? data['reply'] : null)?.toString() ??
            "Sorry, I couldn't find anything on that.";
        reply.cards = OwlCard.listFrom(data is Map ? data['cards'] : null);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// "New chat" - clears the conversation and ignores any reply in flight.
  void clearConversation() {
    _generation++;
    _activeClient?.close();
    _activeClient = null;
    _messages.clear();
    _isSending = false;
    _status = null;
    _lastError = null;
    notifyListeners();
  }
}
