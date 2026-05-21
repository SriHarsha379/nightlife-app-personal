import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:video_compress/video_compress.dart' as vc;
import '/utilities/app_constant.dart';

/// Single socket provider — handles BOTH:
///   • Admin/Support chat  (SocketProvider used by ChatSupport screen)
///   • User-to-User chat   (used by ChatMessageScreen via UserChatSocketProvider wrapper)
///
/// USAGE:
///   • On login success: call SocketProvider.setToken(token) — does NOT connect yet
///   • On chat screen open: call initSocket(token) — connects lazily
///   • On logout: call disconnect()
class SocketProvider extends ChangeNotifier with WidgetsBindingObserver {
  final bool _enableLifecycleReconnect;
  IO.Socket? socket;
  String? userId;

  // Stored token — set on login, used for lazy connect & auto-reconnect
  String _storedToken = '';
  String _activeSocketToken = '';
  String _authUserId = '';

  // ── Pagination ──
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // ── Connection ──
  @protected
  bool isConnectedValue = false;
  bool get isConnected => isConnectedValue;

  DateTime? _lastSocketErrorLogAt;
  DateTime? _lastManualConnectAttemptAt;
  Timer? _reconnectTimer;
  Timer? _conversationListLoadTimer;
  int _existingSocketReconnectAttempts = 0;
  bool _reconnectUrgent = false;
  int _connectionEpoch = 0;
  Map<String, dynamic>? _pendingConversationListRequest;
  int _conversationListRetryCount = 0;

  // Track last joined conversation to avoid unnecessary message clearing
  String _lastJoinedConversationId = '';

  // ── Pending queue (offline messages) ──
  @protected
  final List<Map<String, dynamic>> pendingConversationMessages = [];

  // ── Messages ──
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  // ── Conversation list (shared for BOTH support and user-to-user) ──
  List<Map<String, dynamic>> _conversationList = [];
  List<Map<String, dynamic>> get conversationList => _conversationList;
  bool _hasConversationListLoaded = false;
  bool get hasConversationListLoaded => _hasConversationListLoaded;

  // ── Last conversation packet ──
  @protected
  Map<String, dynamic>? lastConversationValue;
  Map<String, dynamic>? get lastConversation => lastConversationValue;
  dynamic recentFriendsListValue;
  dynamic get recentFriendsList => recentFriendsListValue;

  // ── User online status ──
  bool? _isCheckedUserOnline;
  bool? get isCheckedUserOnline => _isCheckedUserOnline;

  String _checkedUserId = '';
  String get checkedUserId => _checkedUserId;
  String get authUserId => _authUserId;

  SocketProvider({bool enableLifecycleReconnect = true})
      : _enableLifecycleReconnect = enableLifecycleReconnect {
    WidgetsBinding.instance.addObserver(this);
  }

  bool _setConnectedValue(bool value) {
    if (isConnectedValue == value) return false;
    isConnectedValue = value;
    return true;
  }

  bool _disposeAndClearBoundSocket(IO.Socket target) {
    _disposeSocketInstance(target);
    if (identical(socket, target)) {
      socket = null;
      return true;
    }
    return false;
  }

  void resetConversationListState() {
    final shouldNotify = _hasConversationListLoaded ||
        _conversationList.isNotEmpty ||
        _pendingConversationListRequest != null ||
        _conversationListRetryCount != 0;
    _hasConversationListLoaded = false;
    _conversationList = [];
    _pendingConversationListRequest = null;
    _conversationListRetryCount = 0;
    _conversationListLoadTimer?.cancel();
    if (shouldNotify) {
      notifyListeners();
    }
  }

  /// Call this on login/signup success — just saves the token, no socket yet.
  /// Socket will be created lazily when initSocket() is first called.
  void setToken(String token, {String? authUserId}) {
    final nextToken = token.trim();
    final nextUserId = (authUserId ?? '').trim();
    final didAuthChange =
        (_storedToken.isNotEmpty && _storedToken != nextToken) ||
            (_authUserId.isNotEmpty &&
                nextUserId.isNotEmpty &&
                _authUserId != nextUserId);

    if (didAuthChange) {
      _logSocket('setToken detected auth change - clearing old socket session');
      _resetSocketState();
      notifyListeners();
    }

    _storedToken = nextToken;
    _authUserId = nextUserId;
    AppConstant.token = _storedToken;
  }

  void _resetSocketState({bool clearStoredToken = false}) {
    _connectionEpoch++;
    _reconnectTimer?.cancel();
    _conversationListLoadTimer?.cancel();
    _reconnectUrgent = false;
    _lastManualConnectAttemptAt = null;
    _existingSocketReconnectAttempts = 0;
    _lastJoinedConversationId = '';
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    _messages = [];
    _conversationList = [];
    _hasConversationListLoaded = false;
    lastConversationValue = null;
    recentFriendsListValue = null;
    _isCheckedUserOnline = null;
    _checkedUserId = '';
    userId = null;
    _pendingConversationListRequest = null;
    _conversationListRetryCount = 0;
    pendingConversationMessages.clear();
    isConnectedValue = false;
    _activeSocketToken = '';

    // FIX: always clear _authUserId on reset so stale user never leaks
    // into a new login session — was previously only cleared when
    // clearStoredToken=true, causing old socket to stay "connected"
    // for the new user on logout → re-login.
    _authUserId = '';

    final existingSocket = socket;
    if (existingSocket != null) {
      try {
        existingSocket.clearListeners();
      } catch (_) {}
      try {
        existingSocket.disconnect();
      } catch (_) {}
      try {
        existingSocket.dispose();
      } catch (_) {}
    }
    socket = null;

    if (clearStoredToken) {
      _storedToken = '';
    }
  }

  void _disposeSocketInstance(IO.Socket? target) {
    if (target == null) return;
    try {
      target.clearListeners();
    } catch (_) {}
    try {
      target.disconnect();
    } catch (_) {}
    try {
      target.dispose();
    } catch (_) {}
  }

  void forceDisconnect({bool clearStoredToken = false}) {
    _logSocket(
        'forceDisconnect called clearStoredToken=$clearStoredToken authUserId=$_authUserId');
    _resetSocketState(clearStoredToken: clearStoredToken);
    notifyListeners();
  }

  Future<void> forceReconnect(
    String token, {
    String? authUserId,
  }) async {
    final nextToken = token.trim();
    if (nextToken.isEmpty) {
      _logSocket('forceReconnect skipped: token empty');
      return;
    }
    final nextUserId = (authUserId ?? '').trim();
    _logSocket('forceReconnect called authUserId=$nextUserId');
    forceDisconnect(clearStoredToken: false);
    _storedToken = nextToken;
    _authUserId = nextUserId;
    AppConstant.token = nextToken;
    await initSocket(nextToken);
  }

  void _logSocket(String text) => log('SocketProvider => $text');

  bool _rawBool(dynamic value) {
    if (value is bool) return value;
    final raw = (value ?? '').toString().trim().toLowerCase();
    return raw == 'true' || raw == '1';
  }

  void _logSocketErrorThrottled(String message) {
    final now = DateTime.now();
    if (_lastSocketErrorLogAt != null &&
        now.difference(_lastSocketErrorLogAt!).inSeconds < 5) return;
    _lastSocketErrorLogAt = now;
    print(message);
  }

  // ── Helpers ──
  @protected
  Map<String, dynamic>? asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  @protected
  List<Map<String, dynamic>> extractMessageList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    final root = asMap(data);
    if (root == null) return [];
    final candidates = [
      root['data'],
      root['list'],
      root['messages'],
      root['conversation_messages'],
      root['message_list'],
    ];
    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      final nested = asMap(candidate);
      if (nested != null && nested['list'] is List) {
        return (nested['list'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return [];
  }

  @protected
  List<Map<String, dynamic>> extractConversationList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    final root = asMap(data);
    if (root == null) return [];
    final candidates = [
      root['data'],
      root['list'],
      root['conversation_list'],
      root['conversations'],
    ];
    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      final nested = asMap(candidate);
      if (nested != null) {
        final nestedList =
            nested['list'] ?? nested['conversation_list'] ?? nested['data'];
        if (nestedList is List) {
          return (nestedList as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return [];
  }

  @protected
  Map<String, dynamic>? extractIncomingMessage(dynamic data) {
    final root = asMap(data);
    if (root == null) return null;
    if (root['conversation_data'] is Map && root['message'] == null)
      return null;
    if (root['newObj'] != null) return asMap(root['newObj']);
    if (root['data'] != null) {
      final dataMap = asMap(root['data']);
      if (dataMap != null && dataMap['message'] != null) return dataMap;
    }
    return root;
  }

  @protected
  void upsertConversationFromPacket(dynamic data) {
    final root = asMap(data);
    if (root == null) return;
    final packet = asMap(root['conversation_data']) ??
        asMap(root['newObj']) ??
        asMap(root['data']) ??
        root;
    final id =
        (packet['conversation_id'] ?? packet['_id'] ?? '').toString().trim();
    if (id.isEmpty) return;
    final index =
        _conversationList.indexWhere((e) => (e['_id'] ?? '').toString() == id);
    final existing =
        index == -1 ? <String, dynamic>{} : _conversationList[index];

    final incomingSender = packet['sender_id'];
    final incomingReceiver = packet['receiver_id'];
    final senderValue = incomingSender ?? existing['sender_id'];
    final receiverValue = incomingReceiver ?? existing['receiver_id'];

    final conversation = <String, dynamic>{
      '_id': id,
      'sender_id': senderValue,
      'receiver_id': receiverValue,
      'sender_model': packet['sender_model'] ?? existing['sender_model'],
      'receiver_model': packet['receiver_model'] ?? existing['receiver_model'],
      'last_message': packet['last_message'] ??
          packet['message'] ??
          existing['last_message'],
      'message_type':
          packet['message_type'] ?? packet['type'] ?? existing['message_type'],
      'receiver_name': packet['receiver_name'] ?? existing['receiver_name'],
      'receiver_image': packet['receiver_image'] ?? existing['receiver_image'],
      'sender_name': packet['sender_name'] ?? existing['sender_name'],
      'sender_image': packet['sender_image'] ?? existing['sender_image'],
      'date': packet['date'] ?? existing['date'],
      'time': packet['time'] ?? existing['time'],
      'createdAt': packet['createdAt'] ?? existing['createdAt'],
      'updatedAt': packet['updatedAt'] ?? existing['updatedAt'],
      'is_seen': packet['is_seen'] ??
          packet['isSeen'] ??
          packet['isseen'] ??
          existing['is_seen'] ??
          existing['isSeen'] ??
          existing['isseen'],
      'unreadCount': packet['unreadCount'] ??
          packet['unread_count'] ??
          existing['unreadCount'],
    };

    final merged = <String, dynamic>{...existing, ...conversation};
    if (index == -1) {
      _conversationList.insert(0, merged);
    } else {
      _conversationList.removeAt(index);
      _conversationList.insert(0, merged);
    }
    _hasConversationListLoaded = true;
  }

  String _eventKey(Map<String, dynamic> message) {
    final eventObject = asMap(message['event_object']);
    if (eventObject == null) return '';
    return (eventObject['id'] ??
            eventObject['event_id'] ??
            eventObject['venue_id'] ??
            '')
        .toString()
        .trim();
  }

  String _participantKey(dynamic value) {
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? value['user_id'] ?? '')
          .toString()
          .trim();
    }
    return (value ?? '').toString().trim();
  }

  String _messageKey(Map<String, dynamic> message) {
    final id = (message['_id'] ?? '').toString().trim();
    final signature = _messageSignature(message);
    if (id.isNotEmpty && !id.startsWith('tmp_')) {
      return _isSharedEventMessage(message) && signature.isNotEmpty
          ? 'sig:$signature'
          : 'id:$id';
    }

    if (_isSharedEventMessage(message) && signature.isNotEmpty) {
      return 'sig:$signature';
    }

    final files = (message['files'] is List)
        ? (message['files'] as List)
            .map((e) => (e ?? '').toString().trim())
            .where((e) => e.isNotEmpty)
            .join(',')
        : '';

    return [
      _participantKey(message['sender_id']),
      _participantKey(message['receiver_id']),
      (message['conversation_id'] ?? '').toString().trim(),
      (message['message'] ?? '').toString().trim(),
      (message['type'] ?? '').toString().trim(),
      files,
      _eventKey(message),
    ].join('|');
  }

  String _messageSignature(Map<String, dynamic> message) {
    final files = (message['files'] is List)
        ? (message['files'] as List)
            .map((e) => (e ?? '').toString().trim())
            .where((e) => e.isNotEmpty)
            .join(',')
        : '';
    return [
      _participantKey(message['sender_id']),
      _participantKey(message['receiver_id']),
      (message['conversation_id'] ?? '').toString().trim(),
      (message['message'] ?? '').toString().trim(),
      (message['type'] ?? '').toString().trim(),
      files,
      _eventKey(message),
      (message['date'] ?? '').toString().trim(),
      (message['time'] ?? '').toString().trim(),
    ].join('|');
  }

  bool _isSharedEventMessage(Map<String, dynamic> message) {
    final isEvent = message['is_event'] == true ||
        (message['is_event'] ?? '').toString().trim().toLowerCase() == 'true';
    return isEvent && _eventKey(message).isNotEmpty;
  }

  Map<String, dynamic> _normalizeIncomingMessage(
      Map<String, dynamic> incoming) {
    final normalized = Map<String, dynamic>.from(incoming);
    normalized['conversation_id'] =
        (normalized['conversation_id'] ?? '').toString().trim();
    normalized['message'] = (normalized['message'] ?? '').toString();
    normalized['type'] = (normalized['type'] ?? 'message').toString().trim();
    normalized['sender_id'] = normalized['sender_id'];
    normalized['receiver_id'] = normalized['receiver_id'];
    normalized['files'] =
        normalized['files'] is List ? normalized['files'] : [];
    return normalized;
  }

  void _upsertMessage(Map<String, dynamic> incoming) {
    final normalizedIncoming = _normalizeIncomingMessage(incoming);
    _logSocket('upsert message => $normalizedIncoming');

    final incomingId = (normalizedIncoming['_id'] ?? '').toString().trim();
    if (incomingId.isNotEmpty) {
      final idIndex = _messages
          .indexWhere((m) => (m['_id'] ?? '').toString() == incomingId);
      if (idIndex != -1) {
        _messages[idIndex] = normalizedIncoming;
        return;
      }
    }

    final incomingSender = _participantKey(normalizedIncoming['sender_id']);
    final incomingReceiver = _participantKey(normalizedIncoming['receiver_id']);
    final incomingMessage =
        (normalizedIncoming['message'] ?? '').toString().trim();
    final incomingType = (normalizedIncoming['type'] ?? '').toString().trim();
    final incomingEventKey = _eventKey(normalizedIncoming);
    final incomingConversationId =
        (normalizedIncoming['conversation_id'] ?? '').toString().trim();
    final incomingSignature = _messageSignature(normalizedIncoming);
    final incomingFiles = (normalizedIncoming['files'] is List)
        ? (normalizedIncoming['files'] as List)
            .map((e) => (e ?? '').toString().trim())
            .where((e) => e.isNotEmpty)
            .join(',')
        : '';

    final optimisticIndex = _messages.indexWhere((m) {
      final localId = (m['_id'] ?? '').toString();
      final localSender = _participantKey(m['sender_id']);
      final localReceiver = _participantKey(m['receiver_id']);
      final localMessage = (m['message'] ?? '').toString().trim();
      final localType = (m['type'] ?? '').toString().trim();
      final localEventKey = _eventKey(m);
      final localFiles = (m['files'] is List)
          ? (m['files'] as List)
              .map((e) => (e ?? '').toString().trim())
              .where((e) => e.isNotEmpty)
              .join(',')
          : '';
      final localConversationId =
          (m['conversation_id'] ?? '').toString().trim();
      return (localId.isEmpty || localId.startsWith('tmp_')) &&
          localSender == incomingSender &&
          localReceiver == incomingReceiver &&
          (localConversationId.isEmpty ||
              incomingConversationId.isEmpty ||
              localConversationId == incomingConversationId) &&
          localMessage == incomingMessage &&
          localType == incomingType &&
          localFiles == incomingFiles &&
          localEventKey == incomingEventKey;
    });

    if (optimisticIndex != -1) {
      _messages[optimisticIndex] = normalizedIncoming;
      return;
    }

    if (incomingId.isNotEmpty && incomingSignature.isNotEmpty) {
      final signatureIndex = _messages.indexWhere((m) {
        final localId = (m['_id'] ?? '').toString().trim();
        if (localId.isNotEmpty && !localId.startsWith('tmp_')) return false;
        return _messageSignature(m) == incomingSignature;
      });
      if (signatureIndex != -1) {
        _messages[signatureIndex] = normalizedIncoming;
        return;
      }
    }

    if (incomingId.isEmpty && incomingSignature.isNotEmpty) {
      final noIdSignatureIndex = _messages.indexWhere((m) {
        final localId = (m['_id'] ?? '').toString().trim();
        if (localId.isNotEmpty && !localId.startsWith('tmp_')) return false;
        return _messageSignature(m) == incomingSignature;
      });
      if (noIdSignatureIndex != -1) {
        _messages[noIdSignatureIndex] = normalizedIncoming;
        return;
      }
    }

    _messages.add(normalizedIncoming);
  }

  List<Map<String, dynamic>> _dedupeMessages(List<Map<String, dynamic>> items) {
    final ordered = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final item in items) {
      final key = _messageKey(item);
      if (seen.add(key)) {
        ordered.add(item);
      }
    }
    return ordered;
  }

  // ── App lifecycle ──
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_enableLifecycleReconnect) return;
    if (state == AppLifecycleState.resumed) {
      _reconnectIfLoggedIn();
    }
  }

  Future<void> _reconnectIfLoggedIn() async {
    // Use stored token first (fastest path)
    if (_storedToken.isNotEmpty) {
      await initSocket(_storedToken);
      return;
    }
    // Fallback: read from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDetails = prefs.getString('user_details');
      if (userDetails != null && userDetails.isNotEmpty) {
        final data = json.decode(userDetails);
        final String? token = data['token']?.toString();
        if (token != null && token.isNotEmpty) {
          _storedToken = token;
          AppConstant.token = token;
          await initSocket(token);
        }
      }
    } catch (e) {
      print('Reconnect check error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // initSocket — SINGLE connection point
  // Safe to call multiple times — skips if already connected
  // ─────────────────────────────────────────────────────────────────
  Future<void> initSocket(String jwtToken) async {
    final token = jwtToken.trim();
    if (token.isEmpty) {
      _logSocket('Token empty, socket not connecting');
      return;
    }

    if (_storedToken.isNotEmpty && _storedToken != token) {
      _logSocket('stale initSocket call ignored for previous auth token');
      return;
    }

    if (_storedToken.isEmpty) {
      _storedToken = token;
    }
    AppConstant.token = token;

    _logSocket('initSocket called, hasSocket=${socket != null}');

    if (_activeSocketToken.isNotEmpty && _activeSocketToken != token) {
      _logSocket('auth token changed - recreating socket for fresh session');
      _resetSocketState();
      notifyListeners();
    }

    // Already connected — keep current socket/listeners intact.
    if (socket != null && socket!.connected) {
      _logSocket('socket already connected id=${socket?.id}');
      _existingSocketReconnectAttempts = 0;
      return;
    }

    // Socket exists but not connected — prefer recreating a fresh instance
    // instead of keeping a half-open socket around.
    if (socket != null && !socket!.connected) {
      final now = DateTime.now();
      final isTooSoon = _lastManualConnectAttemptAt != null &&
          now.difference(_lastManualConnectAttemptAt!).inMilliseconds < 4000;
      if (isTooSoon) {
        _logSocket('socket exists but not connected yet - connect() throttled');
        _scheduleReconnect();
        return;
      }
      _lastManualConnectAttemptAt = now;
      _existingSocketReconnectAttempts++;
      _logSocket(
          'socket exists but not connected yet - recreating socket instance');
      _disposeSocketInstance(socket);
      socket = null;
    }

    const String baseUrl = 'https://hii.life';
    const String socketPath = '/app/server/socket.io';
    final query = <String, dynamic>{
      'token': token,
      if (_authUserId.trim().isNotEmpty) 'user_id': _authUserId.trim(),
    };

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .enableForceNew()
          .setTransports(['websocket'])
          .setPath(socketPath)
          .setQuery(query)
          .enableReconnection()
          .setReconnectionAttempts(20)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(4000)
          .setTimeout(10000)
          .build(),
    );
    _lastManualConnectAttemptAt = DateTime.now();
    _activeSocketToken = token;
    _setupListeners();
    _logSocket(
        'new socket connect attempt baseUrl=$baseUrl path=$socketPath authUserId=${_authUserId.trim()}');
    socket!.connect();
  }

  void _setupListeners() {
    if (socket == null) return;
    final boundSocket = socket!;
    boundSocket.clearListeners();

    boundSocket.onConnect((_) {
      if (!identical(socket, boundSocket)) return;
      _logSocket('onConnect id=${boundSocket.id}');
      final didChange = _setConnectedValue(true);
      _existingSocketReconnectAttempts = 0;
      _lastManualConnectAttemptAt = null;
      _reconnectTimer?.cancel();
      _flushPendingQueue();
      if (didChange) {
        notifyListeners();
      }
    });

    boundSocket.onDisconnect((reason) {
      if (!identical(socket, boundSocket)) return;
      _logSocket('onDisconnect => $reason');
      var didChange = _setConnectedValue(false);
      final reasonText = (reason ?? '').toString().toLowerCase();
      if (reasonText.contains('transport close') ||
          reasonText.contains('ping timeout')) {
        _reconnectUrgent = true;
        _lastManualConnectAttemptAt = null;
        didChange = _disposeAndClearBoundSocket(boundSocket) || didChange;
      }
      _scheduleReconnect();
      if (didChange) {
        notifyListeners();
      }

      // socket.io built-in reconnection handles transport close automatically.
    });

    boundSocket.onConnectError((err) {
      if (!identical(socket, boundSocket)) return;
      _logSocketErrorThrottled('Socket connect error: $err');
      var didChange = _setConnectedValue(false);
      final errorText = (err ?? '').toString().toLowerCase();
      if (errorText.contains('timeout')) {
        didChange = _disposeAndClearBoundSocket(boundSocket) || didChange;
      }
      _scheduleReconnect();
      if (didChange) {
        notifyListeners();
      }
    });

    boundSocket.onError((err) {
      if (!identical(socket, boundSocket)) return;
      _logSocketErrorThrottled('Socket error: $err');
      var didChange = _setConnectedValue(false);
      final errorText = (err ?? '').toString().toLowerCase();
      if (errorText.contains('timeout') || errorText.contains('transport')) {
        didChange = _disposeAndClearBoundSocket(boundSocket) || didChange;
      }
      _scheduleReconnect();
      if (didChange) {
        notifyListeners();
      }
    });

    boundSocket.onReconnect((attempt) {
      if (!identical(socket, boundSocket)) return;
      _logSocket('onReconnect attempt=$attempt');
      final didChange = _setConnectedValue(true);
      _existingSocketReconnectAttempts = 0;
      _lastManualConnectAttemptAt = null;
      _reconnectTimer?.cancel();
      _flushPendingQueue();
      if (didChange) {
        notifyListeners();
      }
    });

    boundSocket.onReconnectError((err) {
      if (!identical(socket, boundSocket)) return;
      _logSocketErrorThrottled('Socket reconnect error: $err');
    });

    socket!.onReconnectFailed((_) {
      _logSocket('onReconnectFailed — will retry in 5s');
      _scheduleReconnect();
    });

    // ── user_status ──
    socket!.on('user_status', (data) {
      _logSocket('on user_status => $data');
      final root = asMap(data);
      if (root == null) return;
      final previousOnline = _isCheckedUserOnline;
      final previousCheckedUserId = _checkedUserId;
      final dynamic onlineRaw = root['online'] ??
          root['is_online'] ??
          root['isOnline'] ??
          root['status'] ??
          root['data']?['online'];
      if (onlineRaw is bool) {
        if (_isCheckedUserOnline != onlineRaw) {
          _isCheckedUserOnline = onlineRaw;
        }
      } else if (onlineRaw is num) {
        final nextOnline = onlineRaw == 1;
        if (_isCheckedUserOnline != nextOnline) {
          _isCheckedUserOnline = nextOnline;
        }
      } else if (onlineRaw is String) {
        final normalized = onlineRaw.toLowerCase().trim();
        final nextOnline =
            normalized == 'online' || normalized == 'true' || normalized == '1';
        if (_isCheckedUserOnline != nextOnline) {
          _isCheckedUserOnline = nextOnline;
        }
      }
      final resolvedCheckedUserId = (root['check_user_id'] ??
              root['checkUserId'] ??
              root['user_id'] ??
              root['userId'] ??
              '')
          .toString()
          .trim();
      if (resolvedCheckedUserId.isNotEmpty &&
          resolvedCheckedUserId != _checkedUserId) {
        _checkedUserId = resolvedCheckedUserId;
      }
      final didChange = previousOnline != _isCheckedUserOnline ||
          previousCheckedUserId != _checkedUserId;
      if (didChange) {
        notifyListeners();
      }
    });

    // ── get_conversation_list  (both support & user-user) ──
    socket!.on('get_conversation_list', (data) {
      _logSocket('on get_conversation_list => $data');
      _conversationListLoadTimer?.cancel();
      _pendingConversationListRequest = null;
      _conversationListRetryCount = 0;
      _conversationList = extractConversationList(data);
      _hasConversationListLoaded = true;
      log('get_conversation_list parsed count=${_conversationList.length}');
      notifyListeners();
    });

    // ── last_conversation  (new conversation created after first message) ──
    socket!.on('last_conversation', (data) {
      _logSocket('on last_conversation => $data');
      final root = asMap(data);
      if (root == null) return;
      lastConversationValue = root;
      upsertConversationFromPacket(data);
      notifyListeners();
    });

    // ── get_message_list ──
    socket!.on('get_message_list', (data) {
      _logSocket('on get_message_list => $data');
      final newMessages = extractMessageList(data).reversed.toList();
      if (newMessages.isEmpty) {
        _hasMore = false;
        notifyListeners();
        return;
      }
      if (_currentPage == 1) {
        // FIX: preserve any optimistic (pending) messages so they don't
        // disappear when the server returns the first page after reconnect.
        final pendingOptimistic = _messages
            .where((m) =>
                (m['_id'] ?? '').toString().startsWith('tmp_') ||
                (m['_id'] ?? '').toString().isEmpty)
            .toList();
        final merged = [...newMessages, ...pendingOptimistic];
        _messages = _dedupeMessages(merged);
      } else {
        _messages = _dedupeMessages([...newMessages, ..._messages]);
      }
      log('[get_message_list] count=${_messages.length}');
      notifyListeners();
    });

    // ── send_message  (ACK from server after we send) ──
    socket!.on('send_message', (data) {
      _logSocket('on send_message => $data');
      _logSocket('on send_message =>1111 $data');
      final incoming = extractIncomingMessage(data);
      if (incoming != null) {
        _upsertMessage(incoming);
      }
      notifyListeners();
    });

    // ── receive_message  (incoming message from other user) ──
    socket!.on('receive_message', (data) {
      _logSocket('on receive_message => $data');
      upsertConversationFromPacket(data);
      final incoming = extractIncomingMessage(data);
      if (incoming == null) return;
      _upsertMessage(incoming);
      log('[receive_message] messages=${_messages.length}');
      notifyListeners();
    });

    socket!.on('event_update', (data) {
      _logSocket('on event_update => $data');
      final root = asMap(data);
      if (root == null) return;
      final messageId =
          (root['message_id'] ?? root['messageId'] ?? root['_id'] ?? '')
              .toString()
              .trim();
      if (messageId.isEmpty) return;
      final isApprove = root['is_approve'] == true ||
          root['isApprove'] == true ||
          _rawBool(root['is_approve']) ||
          _rawBool(root['isApprove']);
      final index =
          _messages.indexWhere((m) => (m['_id'] ?? '').toString() == messageId);
      if (index == -1) return;
      final updated = Map<String, dynamic>.from(_messages[index]);
      updated['approve_event'] = isApprove;
      updated['reject_event'] = !isApprove;
      _messages[index] = updated;
      notifyListeners();
    });

    socket!.on('recend_firends_list', (data) {
      _logSocket('on recend_firends_list => $data');
      recentFriendsListValue = data;
      notifyListeners();
    });
  }

  void _flushPendingQueue() {
    if (pendingConversationMessages.isEmpty) return;
    if (socket == null || !socket!.connected) return;
    final pending =
        List<Map<String, dynamic>>.from(pendingConversationMessages);
    pendingConversationMessages.clear();
    for (final item in pending) {
      _logSocket('flush queued send_message => $item');
      socket!.emit('send_message', item);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Disconnect — call on logout only
  // ─────────────────────────────────────────────────────────────────
  void disconnect() {
    _logSocket('disconnect called');
    // FIX: explicitly zero out auth identifiers before reset so that
    // a subsequent login with ANY token always creates a brand-new
    // socket session — prevents old user's socket staying alive.
    _activeSocketToken = '';
    _authUserId = '';
    forceDisconnect(clearStoredToken: true);
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;
    _reconnectTimer?.cancel();
    if (_storedToken.isEmpty) return;
    final int scheduledEpoch = _connectionEpoch;
    final String scheduledToken = _storedToken;
    final delay = _reconnectUrgent
        ? const Duration(milliseconds: 900)
        : const Duration(seconds: 2);
    _reconnectTimer = Timer(delay, () {
      if (scheduledEpoch != _connectionEpoch) return;
      if (scheduledToken.isEmpty || scheduledToken != _storedToken) return;
      if (isConnectedValue) return;
      if (socket != null && socket!.connected) {
        final didChange = _setConnectedValue(true);
        _reconnectUrgent = false;
        if (didChange) {
          notifyListeners();
        }
        return;
      }
      _logSocket('scheduleReconnect — retrying initSocket');
      _reconnectUrgent = false;
      initSocket(scheduledToken);
    });
  }

  bool _canEmit() => socket != null && isConnectedValue && socket!.connected;

  void clearLocalMessages({bool notify = true}) {
    _messages = [];
    _currentPage = 1;
    _hasMore = true;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────
  // Emit helpers
  // ─────────────────────────────────────────────────────────────────

  bool emitUserStatus({required String userId, required String checkUserId}) {
    if (!_canEmit()) {
      _logSocket('emit user_status blocked');
      return false;
    }
    final data = {'user_id': userId, 'check_user_id': checkUserId};
    _checkedUserId = checkUserId;
    socket!.emit('user_status', data);
    return true;
  }

  bool getConversationList({
    required String userId,
    int page = 1,
    int limit = 50,
    String userType = 'User',
  }) {
    if (!_canEmit()) {
      _logSocket('emit get_conversation_list blocked');
      return false;
    }
    final data = {
      'user_id': userId,
      'page': page,
      'limit': limit,
      'user_type': userType,
    };
    _pendingConversationListRequest = Map<String, dynamic>.from(data);
    _conversationListRetryCount = 0;
    _hasConversationListLoaded = false;
    log('SOCKET EMIT get_conversation_list => $data');
    _armConversationListLoadTimeout();
    socket!.emit('get_conversation_list', data);
    return true;
  }

  void _armConversationListLoadTimeout() {
    _conversationListLoadTimer?.cancel();
    _conversationListLoadTimer = Timer(const Duration(seconds: 3), () {
      if (_hasConversationListLoaded) return;
      if (_conversationListRetryCount < 2 &&
          _pendingConversationListRequest != null &&
          _canEmit()) {
        _conversationListRetryCount++;
        _logSocket(
            'get_conversation_list timeout => retry ${_conversationListRetryCount}');
        socket!.emit('get_conversation_list', _pendingConversationListRequest);
        _armConversationListLoadTimeout();
        return;
      }
      _logSocket('get_conversation_list timeout fallback => mark loaded');
      _hasConversationListLoaded = true;
      notifyListeners();
    });
  }

  bool emitRecendFirendsList({
    required String userId,
  }) {
    if (!_canEmit()) {
      _logSocket('emit recend_firends_list blocked');
      return false;
    }
    final data = {'user_id': userId};
    log('SOCKET EMIT recend_firends_list => $data');
    socket!.emit('recend_firends_list', data);
    return true;
  }

  bool emitEventUpdate({
    required String userId,
    required String messageId,
    required bool isApprove,
  }) {
    if (!_canEmit()) {
      _logSocket('emit event_update blocked');
      return false;
    }
    final data = {
      'user_id': userId,
      'message_id': messageId,
      'is_approve': isApprove,
    };
    _logSocket('emit event_update => $data');
    socket!.emit('event_update', data);
    return true;
  }

  void markConversationSeenLocal({
    required String conversationId,
  }) {
    final id = conversationId.trim();
    if (id.isEmpty) return;
    final index =
        _conversationList.indexWhere((e) => (e['_id'] ?? '').toString() == id);
    if (index == -1) return;

    final item = Map<String, dynamic>.from(_conversationList[index]);
    item['is_seen'] = true;
    item['isSeen'] = true;
    item['isseen'] = true;

    final rawUnread =
        item['unreadCount'] ?? item['unread_count'] ?? item['unread'];
    if (rawUnread is num || rawUnread is String) {
      item['unreadCount'] = 0;
    } else if (rawUnread is List) {
      final updated = <dynamic>[];
      for (final entry in rawUnread) {
        if (entry is Map) {
          final map = Map<String, dynamic>.from(entry);
          final entryId =
              (map['_id'] ?? map['conversation_id'] ?? '').toString().trim();
          if (entryId == id) {
            map['count'] = 0;
          }
          updated.add(map);
        } else {
          updated.add(entry);
        }
      }
      item['unreadCount'] = updated;
    }

    _conversationList[index] = item;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  void getConversationMessageList({
    required String userId,
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) {
    if (!_canEmit()) {
      _logSocket('emit get_message_list blocked');
      return;
    }
    final data = {
      'user_id': userId,
      'conversation_id': conversationId,
      'page': page,
      'limit': limit,
    };
    socket!.emit('get_message_list', data);
  }

  void joinConversationChat({
    required String userId,
    required String conversationId,
    int firstPageLimit = 50,
    bool forceReset = false,
  }) {
    if (!_canEmit()) {
      _logSocket('emit join_chat blocked');
      return;
    }

    final isSameConversation =
        _lastJoinedConversationId == conversationId && !forceReset;

    if (!isSameConversation) {
      // Different conversation — full reset
      _currentPage = 1;
      _hasMore = true;
      _messages = [];
    } else {
      // Same conversation rejoining (reconnect scenario) — keep messages,
      // just reset page counter so page-1 fetch merges without clearing.
      _currentPage = 1;
      _hasMore = true;
      // DO NOT clear _messages — existing messages stay visible
    }

    _lastJoinedConversationId = conversationId;
    socket!.emit(
        'join_chat', {'user_id': userId, 'conversation_id': conversationId});
    getConversationMessageList(
      userId: userId,
      conversationId: conversationId,
      page: 1,
      limit: firstPageLimit,
    );
  }

  void leaveConversationChat({
    required String userId,
    required String conversationId,
  }) {
    if (!_canEmit()) return;
    // FIX: clear last joined so next joinConversationChat does a full reset
    if (_lastJoinedConversationId == conversationId) {
      _lastJoinedConversationId = '';
    }
    socket!.emit(
        'leave_chat', {'user_id': userId, 'conversation_id': conversationId});
  }

  /// Send a text/event message (user-user OR user-admin)
  void sendConversationMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String conversationId,
    required String message,
    String senderModel = 'User',
    String receiverModel = 'User',
    String type = 'message',
    List<dynamic> files = const [],
    bool isEvent = false,
    bool approveEvent = false,
    bool rejectEvent = false,
    bool requiresApproval = false,
    Map<String, dynamic>? eventObject,
    bool isuser = true,
  }) {
    final now = DateTime.now();
    final tempId = 'tmp_${now.microsecondsSinceEpoch}';

    final data = <String, dynamic>{
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'receiver_image': receiverImage,
      'receiver_model': receiverModel,
      'sender_model': senderModel,
      'message': message,
      'type': type,
      'files': files,
      'is_event': isEvent,
      'approve_event': approveEvent,
      'reject_event': rejectEvent,
      'requires_approval': requiresApproval,
      'is_user': isuser,
    };

    if (eventObject != null && eventObject.isNotEmpty) {
      data['event_object'] = Map<String, dynamic>.from(eventObject);
    }

    if (conversationId.trim().isNotEmpty) {
      data['conversation_id'] = conversationId.trim();
    }

    // Optimistic UI — add immediately with a temp id so it's visible instantly
    if (!isEvent) {
      final optimisticEntry = Map<String, dynamic>.from(data);
      optimisticEntry['_id'] = tempId;
      _messages.add(optimisticEntry);
      notifyListeners();
    }

    if (!_canEmit()) {
      _logSocket('queue send_message, socket disconnected');
      // Queue without the temp _id so server assigns real id
      pendingConversationMessages.add(Map<String, dynamic>.from(data));
      if (socket == null && AppConstant.token.trim().isNotEmpty) {
        initSocket(AppConstant.token);
      } else {
        _scheduleReconnect();
      }
      return;
    }

    _logSocket('emit send_message => $data');
    _logSocket(
      'emit send_message details => '
      'receiver_id=${data['receiver_id']}, receiver_name=${data['receiver_name']}, '
      'is_event=${data['is_event']}, event_object=${data['event_object']}',
    );
    socket!.emit('send_message', data);
    log('send_message emitted =======>>>>>>$data');
  }

  // ── Media upload ──
  Future<String?> _uploadSingleMediaFile({
    required String endpoint,
    required String path,
    String fieldName = 'image',
  }) async {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;

      Future<String?> doUpload(String key) async {
        final uri = Uri.parse(endpoint);
        final request = http.MultipartRequest('POST', uri);
        if (AppConstant.token.trim().isNotEmpty) {
          request.headers['Authorization'] = 'Bearer ${AppConstant.token}';
        }
        request.files.add(await http.MultipartFile.fromPath(key, path));
        final streamed = await request.send();
        final response = await http.Response.fromStream(streamed);
        if (response.statusCode != 200) {
          log('upload single failed status=${response.statusCode} key=$key');
          return null;
        }
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is! Map || decoded['success'] != true) return null;
        final dynamic dataList = decoded['data'];
        if (dataList is! List || dataList.isEmpty) return null;
        final first = dataList.first;
        if (first is String && first.trim().isNotEmpty) return first.trim();
        if (first is Map) {
          final filename =
              (first['filename'] ?? first['file'] ?? first['url'] ?? '')
                  .toString()
                  .trim();
          if (filename.isNotEmpty) return filename;
        }
        return null;
      }

      String? uploaded = await doUpload(fieldName);
      if (uploaded != null) return uploaded;

      // Some backends accept `file` key instead of `image`.
      if (fieldName != 'file') {
        uploaded = await doUpload('file');
        if (uploaded != null) return uploaded;
      }
    } catch (e) {
      log('uploadSingleMediaFile error=$e');
    }
    return null;
  }

  Future<List<String>> uploadChatMediaFiles({
    required List<String> localFilePaths,
    String endpoint =
        'https://hii.life/app/server/api/v1/admin/user/image_uplod',
    String fieldName = 'image',
  }) async {
    final paths =
        localFilePaths.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (paths.isEmpty) return [];
    try {
      final uploaded = <String>[];
      for (final path in paths) {
        final uploadedName = await _uploadSingleMediaFile(
          endpoint: endpoint,
          path: path,
          fieldName: fieldName,
        );
        if (uploadedName != null && uploadedName.trim().isNotEmpty) {
          uploaded.add(uploadedName.trim());
        } else {
          log('upload skipped/failed path=$path');
        }
      }
      return uploaded;
    } catch (e) {
      log('uploadChatMediaFiles error=$e');
      return [];
    }
  }

  String _resolveMediaType(List<String> fileNames) {
    if (fileNames.isEmpty) return 'message';
    for (final raw in fileNames) {
      final file = raw.toLowerCase().trim();
      if (file.endsWith('.mp4') ||
          file.endsWith('.mov') ||
          file.endsWith('.avi') ||
          file.endsWith('.mkv') ||
          file.endsWith('.webm')) return 'video';
    }
    for (final raw in fileNames) {
      final file = raw.toLowerCase().trim();
      if (file.endsWith('.pdf') ||
          file.endsWith('.doc') ||
          file.endsWith('.docx') ||
          file.endsWith('.xls') ||
          file.endsWith('.xlsx') ||
          file.endsWith('.txt')) return 'pdf';
    }
    return 'image';
  }

  bool _isVideoPath(String path) {
    final file = path.toLowerCase().trim();
    return file.endsWith('.mp4') ||
        file.endsWith('.mov') ||
        file.endsWith('.avi') ||
        file.endsWith('.mkv') ||
        file.endsWith('.webm');
  }

  Future<String> _compressVideoIfNeeded(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!file.existsSync()) return videoPath;

      final sizeInBytes = await file.length();
      if (sizeInBytes <= 10 * 1024 * 1024) return videoPath;

      Future<String?> tryCompress(vc.VideoQuality quality) async {
        final result = await vc.VideoCompress.compressVideo(
          videoPath,
          quality: quality,
          includeAudio: true,
          deleteOrigin: false,
        );
        final path = result?.file?.path ?? '';
        if (path.trim().isNotEmpty && File(path).existsSync()) {
          return path;
        }
        return null;
      }

      final medium = await tryCompress(vc.VideoQuality.MediumQuality);
      if (medium != null) return medium;

      final low = await tryCompress(vc.VideoQuality.LowQuality);
      if (low != null) return low;
    } catch (e) {
      log('compressVideoIfNeeded error=$e');
    }
    return videoPath;
  }

  Future<List<String>> _prepareMediaPathsForUpload(
      List<String> localFilePaths) async {
    final prepared = <String>[];
    for (final raw in localFilePaths) {
      final path = raw.trim();
      if (path.isEmpty) continue;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        prepared.add(path);
        continue;
      }
      if (_isVideoPath(path)) {
        prepared.add(await _compressVideoIfNeeded(path));
      } else {
        prepared.add(path);
      }
    }
    return prepared;
  }

  Future<bool> sendConversationMediaMessage({
    required String senderId,
    required String senderName,
    required String senderImage,
    required String receiverId,
    required String receiverName,
    required String receiverImage,
    required String conversationId,
    required List<String> localFilePaths,
    String senderModel = 'User',
    String receiverModel = 'Admin',
    bool isuser = true,
    String uploadEndpoint =
        'https://hii.life/app/server/api/v1/admin/user/image_uplod',
  }) async {
    final preparedPaths = await _prepareMediaPathsForUpload(localFilePaths);
    final expectsVideo = preparedPaths.any((p) => _isVideoPath(p)) ||
        localFilePaths.any((p) => _isVideoPath(p));
    var uploadedFiles = await uploadChatMediaFiles(
      localFilePaths: preparedPaths,
      endpoint: uploadEndpoint,
    );

    // Fallback: if compressed upload fails, retry original files once.
    if (uploadedFiles.isEmpty) {
      final normalizedPrepared = preparedPaths
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final normalizedOriginal = localFilePaths
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final changed = normalizedPrepared.length == normalizedOriginal.length &&
          List.generate(normalizedPrepared.length, (i) => i).any(
            (i) => normalizedPrepared[i] != normalizedOriginal[i],
          );
      if (changed) {
        log('compressed upload failed, retrying original media paths');
        uploadedFiles = await uploadChatMediaFiles(
          localFilePaths: normalizedOriginal,
          endpoint: uploadEndpoint,
        );
      }
    }
    if (expectsVideo) {
      final hasVideoUploaded = uploadedFiles.any((f) => _isVideoPath(f));
      if (!hasVideoUploaded) {
        log('video expected but uploaded files contain no video');
        return false;
      }
    }
    if (uploadedFiles.isEmpty) return false;
    final type = _resolveMediaType(uploadedFiles);
    sendConversationMessage(
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverImage: receiverImage,
      conversationId: conversationId,
      message: '',
      senderModel: senderModel,
      receiverModel: receiverModel,
      isuser: isuser,
      type: type,
      files: uploadedFiles,
    );
    return true;
  }

  void loadMoreConversationMessages({
    required String userId,
    required String conversationId,
    int limit = 50,
  }) {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _currentPage += 1;
    getConversationMessageList(
      userId: userId,
      conversationId: conversationId,
      page: _currentPage,
      limit: limit,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoadingMore = false;
    });
  }
}
