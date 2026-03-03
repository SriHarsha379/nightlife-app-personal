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
  Timer? _reconnectTimer;

  // ── Pending queue (offline messages) ──
  @protected
  final List<Map<String, dynamic>> pendingConversationMessages = [];

  // ── Messages ──
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  // ── Conversation list (shared for BOTH support and user-to-user) ──
  List<Map<String, dynamic>> _conversationList = [];
  List<Map<String, dynamic>> get conversationList => _conversationList;

  // ── Last conversation packet ──
  @protected
  Map<String, dynamic>? lastConversationValue;
  Map<String, dynamic>? get lastConversation => lastConversationValue;

  // ── User online status ──
  bool? _isCheckedUserOnline;
  bool? get isCheckedUserOnline => _isCheckedUserOnline;

  String _checkedUserId = '';
  String get checkedUserId => _checkedUserId;

  SocketProvider({bool enableLifecycleReconnect = true})
      : _enableLifecycleReconnect = enableLifecycleReconnect {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Call this on login/signup success — just saves the token, no socket yet.
  /// Socket will be created lazily when initSocket() is first called.
  void setToken(String token) {
    _storedToken = token.trim();
    AppConstant.token = _storedToken;
  }

  void _logSocket(String text) => debugPrint('SocketProvider => $text');

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
    final packet = asMap(root['conversation_data']);
    if (packet == null) return;
    final id =
        (packet['conversation_id'] ?? packet['_id'] ?? '').toString().trim();
    if (id.isEmpty) return;
    final conversation = <String, dynamic>{
      '_id': id,
      'sender_id': packet['sender_id'],
      'receiver_id': packet['receiver_id'],
      'sender_model': packet['sender_model'],
      'receiver_model': packet['receiver_model'],
      'last_message': packet['last_message'],
      'message_type': packet['message_type'],
      'receiver_name': packet['receiver_name'],
      'receiver_image': packet['receiver_image'],
      'sender_name': packet['sender_name'],
      'sender_image': packet['sender_image'],
      'date': packet['date'],
      'time': packet['time'],
    };
    final index =
        _conversationList.indexWhere((e) => (e['_id'] ?? '').toString() == id);
    if (index == -1) {
      _conversationList.insert(0, conversation);
    } else {
      _conversationList[index] = conversation;
    }
  }

  String _messageContextKey(Map<String, dynamic> message) {
    final conversationId =
        (message['conversation_id'] ?? message['conversationId'] ?? '')
            .toString();
    return conversationId.isNotEmpty ? conversationId : '';
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

    // Always update stored token
    _storedToken = token;
    AppConstant.token = token;

    _logSocket('initSocket called, hasSocket=${socket != null}');

    // Already connected — just refresh listeners
    if (socket != null && socket!.connected) {
      _logSocket('socket already connected id=${socket?.id}');
      _setupListeners();
      return;
    }

    // Socket exists but connecting — let it finish, don't interrupt
    if (socket != null && !socket!.connected) {
      _logSocket('socket exists but not connected yet - connect() retry only');
      try {
        socket!.connect();
      } catch (_) {}
      return;
    }

    const String baseUrl = 'https://hii.life';
    const String socketPath = '/app/server/socket.io';

    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(socketPath)
          .setQuery({'token': jwtToken})
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );
    _setupListeners();
    _logSocket('new socket connect attempt baseUrl=$baseUrl path=$socketPath');
    socket!.connect();
  }

  void _setupListeners() {
    if (socket == null) return;
    socket!.clearListeners();

    socket!.onConnect((_) {
      _logSocket('onConnect id=${socket?.id}');
      isConnectedValue = true;
      _reconnectTimer?.cancel();
      _flushPendingQueue();
      notifyListeners();
    });

    socket!.onDisconnect((reason) {
      _logSocket('onDisconnect => $reason');
      isConnectedValue = false;
      _scheduleReconnect();
      notifyListeners();
    });

    socket!.onConnectError((err) {
      _logSocketErrorThrottled('Socket connect error: $err');
      isConnectedValue = false;
      _scheduleReconnect();
      notifyListeners();
    });

    socket!.onError((err) {
      _logSocketErrorThrottled('Socket error: $err');
      isConnectedValue = false;
      notifyListeners();
    });

    socket!.onReconnect((attempt) {
      _logSocket('onReconnect attempt=$attempt');
      isConnectedValue = true;
      _flushPendingQueue();
      notifyListeners();
    });

    socket!.onReconnectError((err) {
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
      final dynamic onlineRaw = root['online'] ??
          root['is_online'] ??
          root['isOnline'] ??
          root['status'] ??
          root['data']?['online'];
      if (onlineRaw is bool) {
        _isCheckedUserOnline = onlineRaw;
      } else if (onlineRaw is num) {
        _isCheckedUserOnline = onlineRaw == 1;
      } else if (onlineRaw is String) {
        final normalized = onlineRaw.toLowerCase().trim();
        _isCheckedUserOnline =
            normalized == 'online' || normalized == 'true' || normalized == '1';
      }
      _checkedUserId =
          (root['check_user_id'] ?? root['user_id'] ?? '').toString();
      notifyListeners();
    });

    // ── get_conversation_list  (both support & user-user) ──
    socket!.on('get_conversation_list', (data) {
      _logSocket('on get_conversation_list => $data');
      _conversationList = extractConversationList(data);
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
        return;
      }
      if (_currentPage == 1) {
        _messages = newMessages;
      } else {
        _messages = [...newMessages, ..._messages];
      }
      log('[get_message_list] count=${_messages.length}');
      notifyListeners();
    });

    // ── send_message  (ACK from server after we send) ──
    socket!.on('send_message', (data) {
      _logSocket('on send_message => $data');
      // upsertConversationFromPacket(data);
      // final incoming = extractIncomingMessage(data);
      // if (incoming == null) return;

      // final incomingMessage = incoming['message']?.toString() ?? '';
      // final incomingContext = _messageContextKey(incoming);
      // final incomingSenderId = (incoming['sender_id'] is Map)
      //     ? (incoming['sender_id']['_id'] ?? '').toString()
      //     : (incoming['sender_id'] ?? '').toString();
      // final incomingReceiverId = (incoming['receiver_id'] is Map)
      //     ? (incoming['receiver_id']['_id'] ?? '').toString()
      //     : (incoming['receiver_id'] ?? '').toString();

      // final index = _messages.indexWhere((m) {
      //   final id = m['_id']?.toString() ?? '';
      //   final localContext = _messageContextKey(m);
      //   final localSenderId = (m['sender_id'] ?? '').toString();
      //   final localReceiverId = (m['receiver_id'] ?? '').toString();
      //   final sameConversation = localContext == incomingContext;
      //   final contextResolvedAfterCreate = localContext.isEmpty &&
      //       incomingContext.isNotEmpty &&
      //       localSenderId == incomingSenderId &&
      //       localReceiverId == incomingReceiverId;
      //   return id.startsWith('tmp_') &&
      //       (m['message']?.toString() ?? '') == incomingMessage &&
      //       (sameConversation || contextResolvedAfterCreate);
      // });

      // if (index != -1) {
      //   _messages[index] = incoming;
      // } else {
      //   _messages.add(incoming);
      // }
      // log('[send_message] messages=${_messages.length}');
      notifyListeners();
    });

    // ── receive_message  (incoming message from other user) ──
    socket!.on('receive_message', (data) {
      _logSocket('on receive_message => $data');
      upsertConversationFromPacket(data);
      final incoming = extractIncomingMessage(data);
      if (incoming == null) return;
      _messages.add(incoming);
      log('[receive_message] messages=${_messages.length}');
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
    _reconnectTimer?.cancel();
    _storedToken = '';
    if (socket != null) {
      _logSocket('disconnect called');
      try {
        socket!.clearListeners();
      } catch (_) {}
      try {
        socket!.disconnect();
      } catch (_) {}
      try {
        socket!.dispose();
      } catch (_) {}
      socket = null;
      isConnectedValue = false;
      pendingConversationMessages.clear();
      notifyListeners();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_storedToken.isEmpty) return;
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (isConnectedValue) return; // already connected by then
      if (socket != null && socket!.connected) {
        isConnectedValue = true;
        return;
      }
      _logSocket('scheduleReconnect — retrying initSocket');
      initSocket(_storedToken);
    });
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
    if (socket == null || !socket!.connected) {
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
  }) {
    if (socket == null || !socket!.connected) {
      _logSocket('emit get_conversation_list blocked');
      return false;
    }
    final data = {'user_id': userId, 'page': page, 'limit': limit};
    log('SOCKET EMIT get_conversation_list => $data');
    socket!.emit('get_conversation_list', data);
    return true;
  }

  void getConversationMessageList({
    required String userId,
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) {
    if (socket == null || !socket!.connected) {
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
  }) {
    if (socket == null || !socket!.connected) {
      _logSocket('emit join_chat blocked');
      return;
    }
    _currentPage = 1;
    _hasMore = true;
    _messages = [];
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
    if (socket == null || !socket!.connected) return;
    socket!.emit(
        'leave_chat', {'user_id': userId, 'conversation_id': conversationId});
  }

  /// Send a text/media message (user-user OR user-admin)
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
    String receiverModel = 'User', // 'Admin' for support chat
    String type = 'message',
    List<dynamic> files = const [],
  }) {
    final now = DateTime.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tempId = 'tmp_${now.microsecondsSinceEpoch}';

    final data = <String, dynamic>{
      // '_id': tempId,
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
      // 'time': formattedTime,
      // 'createdAt': now.toIso8601String(),
    };

    if (conversationId.trim().isNotEmpty) {
      data['conversation_id'] = conversationId.trim();
    }

    // Optimistic UI — add immediately
    _messages.add(Map<String, dynamic>.from(data));
    notifyListeners();

    if (socket == null || !socket!.connected) {
      _logSocket('queue send_message, socket disconnected');
      pendingConversationMessages.add(Map<String, dynamic>.from(data));
      if (socket == null && AppConstant.token.trim().isNotEmpty) {
        initSocket(AppConstant.token);
      } else {
        socket?.connect();
      }
      return;
    }

    _logSocket('emit send_message => $data');
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
          final filename = (first['filename'] ?? first['file'] ?? first['url'] ?? '')
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
      // Keep small videos untouched for speed.
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
    String uploadEndpoint =
        'https://hii.life/app/server/api/v1/admin/user/image_uplod',
  }) async {
    final preparedPaths = await _prepareMediaPathsForUpload(localFilePaths);
    final expectsVideo =
        preparedPaths.any((p) => _isVideoPath(p)) ||
            localFilePaths.any((p) => _isVideoPath(p));
    var uploadedFiles = await uploadChatMediaFiles(
      localFilePaths: preparedPaths,
      endpoint: uploadEndpoint,
    );

    // Fallback: if compressed upload fails, retry original files once.
    if (uploadedFiles.isEmpty) {
      final normalizedPrepared =
          preparedPaths.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final normalizedOriginal =
          localFilePaths.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
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

