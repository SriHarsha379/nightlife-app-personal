import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '/utilities/app_constant.dart';

class SocketProvider extends ChangeNotifier with WidgetsBindingObserver {
  IO.Socket? socket;
  String? userId;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  List<dynamic> _bookingList = [];
  List<dynamic> get bookingList => _bookingList;

  bool? _isDriverAccepted;
  bool? get isDriverAccepted => _isDriverAccepted;

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  List<Map<String, dynamic>> _conversationList = [];
  List<Map<String, dynamic>> get conversationList => _conversationList;

  Map<String, dynamic>? _lastConversation;
  Map<String, dynamic>? get lastConversation => _lastConversation;

  bool? _isCheckedUserOnline;
  bool? get isCheckedUserOnline => _isCheckedUserOnline;

  String _checkedUserId = '';
  String get checkedUserId => _checkedUserId;

  Map<String, double>? _lastDriverLocation;
  Map<String, double>? get lastDriverLocation => _lastDriverLocation;

  SocketProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final raw = value.trim();
      if (raw.isEmpty) return null;

      final normalized = raw.replaceAll(',', '.');
      final direct = double.tryParse(normalized);
      if (direct != null) return direct;

      final match = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(raw);
      if (match != null) {
        return double.tryParse(match.group(0)!);
      }
      return null;
    }
    return double.tryParse(value.toString());
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  List<Map<String, dynamic>> _extractMessageList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final root = _asMap(data);
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
      final nested = _asMap(candidate);
      if (nested != null && nested['list'] is List) {
        final list = nested['list'] as List;
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    return [];
  }

  List<Map<String, dynamic>> _extractConversationList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final root = _asMap(data);
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

      final nested = _asMap(candidate);
      if (nested != null) {
        final nestedList =
            nested['list'] ?? nested['conversation_list'] ?? nested['data'];
        if (nestedList is List) {
          return nestedList
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }

    return [];
  }

  Map<String, dynamic>? _extractIncomingMessage(dynamic data) {
    final root = _asMap(data);
    if (root == null) return null;

    if (root['newObj'] != null) {
      return _asMap(root['newObj']);
    }

    if (root['data'] != null) {
      final dataMap = _asMap(root['data']);
      if (dataMap != null && dataMap['message'] != null) {
        return dataMap;
      }
    }

    return root;
  }

  String _messageContextKey(Map<String, dynamic> message) {
    final conversationId = message['conversation_id']?.toString() ?? '';
    if (conversationId.isNotEmpty) return conversationId;
    return message['booking_id']?.toString() ?? '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _reconnectIfLoggedIn();
    }
  }

  Future<void> _reconnectIfLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDetails = prefs.getString('user_details');

      if (userDetails != null && userDetails.isNotEmpty) {
        final data = json.decode(userDetails);
        final String? newUserId = data['user_id']?.toString();

        if (newUserId != null && newUserId.isNotEmpty) {
          userId = newUserId;
          await initSocket(AppConstant.token);
        }
      }
    } catch (e) {
      print('Reconnect check error: $e');
    }
  }

  Future<void> initSocket(String jwtToken) async {
    if (socket != null && socket!.connected) {
      _setupListeners();
      return;
    }

    if (jwtToken.isEmpty) {
      print('Token empty, socket not connecting');
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
    socket!.connect();
  }

  void _setupListeners() {
    if (socket == null) return;

    socket!.clearListeners();

    socket!.onConnect((_) {
      _isConnected = true;
      notifyListeners();
    });

    socket!.onDisconnect((reason) {
      _isConnected = false;
      notifyListeners();
    });

    socket!.on('booking_status', (data) {
      final root = _asMap(data);
      _isDriverAccepted = root?['is_driver_accepted'] == true;
      notifyListeners();
    });

    socket!.onConnectError((err) {
      print('Socket connect error: $err');
      _isConnected = false;
      notifyListeners();
    });

    socket!.onError((err) {
      print('Socket error: $err');
      _isConnected = false;
      notifyListeners();
    });

    socket!.onReconnect((attempt) {
      _isConnected = true;
      notifyListeners();
    });

    socket!.on('user_status', (data) {
      final root = _asMap(data);
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

    socket!.on('get_conversation_list', (data) {
      _conversationList = _extractConversationList(data);
      print(
          'get_conversation_list parsed count=${_conversationList.length} raw=$data');
      notifyListeners();
    });

    socket!.on('last_conversation', (data) {
      final root = _asMap(data);
      if (root == null) return;

      _lastConversation = root;

      final candidate = _extractIncomingMessage(data);
      if (candidate != null) {
        _messages.add(candidate);
      }

      notifyListeners();
    });

    socket!.on('get_message_list', (data) {
      final newMessages = _extractMessageList(data).reversed.toList();

      if (newMessages.isEmpty) {
        _hasMore = false;
        return;
      }

      if (_currentPage == 1) {
        _messages = newMessages;
      } else {
        _messages = [...newMessages, ..._messages];
      }

      notifyListeners();
    });

    socket!.on('send_message', (data) {
      final incoming = _extractIncomingMessage(data);
      if (incoming == null) return;

      final incomingMessage = incoming['message']?.toString() ?? '';
      final incomingContext = _messageContextKey(incoming);

      final index = _messages.indexWhere((m) {
        final id = m['_id']?.toString() ?? '';
        return id.startsWith('tmp_') &&
            (m['message']?.toString() ?? '') == incomingMessage &&
            _messageContextKey(m) == incomingContext;
      });

      if (index != -1) {
        _messages[index] = incoming;
      } else {
        _messages.add(incoming);
      }

      notifyListeners();
    });

    socket!.on('receive_message', (data) {
      final incoming = _extractIncomingMessage(data);
      if (incoming == null) return;

      _messages.add(incoming);
      notifyListeners();
    });

    socket!.on('driver_live_location', (data) {
      if (data == null) return;

      try {
        final root = _asMap(data);
        final nestedData = _asMap(root?['data']);
        final driverObj = _asMap(nestedData?['driver_id']);

        final lat = _toDouble(root?['latitude']) ??
            _toDouble(nestedData?['latitude']) ??
            _toDouble(driverObj?['latitude']);
        final lng = _toDouble(root?['longitude']) ??
            _toDouble(nestedData?['longitude']) ??
            _toDouble(driverObj?['longitude']);

        if (lat == null || lng == null) {
          return;
        }

        _lastDriverLocation = {'lat': lat, 'lng': lng};
        notifyListeners();
      } catch (e) {
        print('Error parsing driver location: $e');
      }
    });
  }

  void disconnect() {
    if (socket != null) {
      socket!.clearListeners();
      socket!.disconnect();
      socket!.dispose();
      socket = null;
      _isConnected = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnect();
    super.dispose();
  }

  void emitBookingStatus({
    required String userId,
    required String bookingId,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot emit booking_status');
      return;
    }

    socket!.emit('check_booking');
  }

  void emitUserStatus({
    required String userId,
    required String checkUserId,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot emit user_status');
      return;
    }

    final data = {
      'user_id': userId,
      'check_user_id': checkUserId,
    };

    _checkedUserId = checkUserId;
    socket!.emit('user_status', data);
  }

  void getConversationList({
    required String userId,
    int page = 1,
    int limit = 50,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot get conversation list');
      return;
    }

    final data = {
      'user_id': userId,
      'page': page,
      'limit': limit,
    };

    print('SOCKET EMIT get_conversation_list => $data');
    socket!.emit('get_conversation_list', data);
  }

  void getMessageList({
    required String userId,
    required String bookingId,
    int page = 1,
    int limit = 30,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot get message list');
      return;
    }

    final data = {
      'user_id': userId,
      'booking_id': bookingId,
      'page': page,
      'limit': limit,
    };

    socket!.emit('get_message_list', data);
  }

  void getConversationMessageList({
    required String userId,
    required String conversationId,
    int page = 1,
    int limit = 50,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot get conversation messages');
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

  void joinChat({
    required String userId,
    required String bookingId,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot join chat');
      return;
    }

    _currentPage = 1;
    _hasMore = true;
    _messages = [];

    final data = {
      'user_id': userId,
      'booking_id': bookingId,
    };

    socket!.emit('join_chat', data);

    getMessageList(
      userId: userId,
      bookingId: bookingId,
      page: 1,
      limit: 30,
    );
  }

  void joinConversationChat({
    required String userId,
    required String conversationId,
    int firstPageLimit = 50,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot join conversation chat');
      return;
    }

    _currentPage = 1;
    _hasMore = true;
    _messages = [];

    final data = {
      'user_id': userId,
      'conversation_id': conversationId,
    };

    socket!.emit('join_chat', data);

    getConversationMessageList(
      userId: userId,
      conversationId: conversationId,
      page: 1,
      limit: firstPageLimit,
    );
  }

  void leaveChat({
    required String userId,
    required String bookingId,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot leave chat');
      return;
    }

    final data = {
      'user_id': userId,
      'booking_id': bookingId,
    };

    socket!.emit('leave_chat', data);
  }

  void leaveConversationChat({
    required String userId,
    required String conversationId,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot leave conversation chat');
      return;
    }

    final data = {
      'user_id': userId,
      'conversation_id': conversationId,
    };

    socket!.emit('leave_chat', data);
  }

  void sendMessage({
    required String senderId,
    required String receiverId,
    required String bookingId,
    required String message,
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot send message');
      return;
    }

    final now = DateTime.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final tempId = 'tmp_${now.microsecondsSinceEpoch}';

    final data = {
      '_id': tempId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'booking_id': bookingId,
      'message': message,
      'type': 'message',
      'files': [],
      'time': formattedTime,
      'createdAt': now.toIso8601String(),
    };

    _messages.add(Map<String, dynamic>.from(data));
    notifyListeners();

    socket!.emit('send_message', data);
  }

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
    String receiverModel = 'Admin',
    String type = 'message',
    List<dynamic> files = const [],
  }) {
    if (socket == null || !socket!.connected) {
      print('Socket not connected, cannot send conversation message');
      return;
    }

    final now = DateTime.now();
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final tempId = 'tmp_${now.microsecondsSinceEpoch}';

    final data = {
      '_id': tempId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_image': senderImage,
      'receiver_id': receiverId,
      'receiver_name': receiverName,
      'receiver_image': receiverImage,
      'conversation_id': conversationId,
      'receiver_model': receiverModel,
      'sender_model': senderModel,
      'message': message,
      'type': type,
      'files': files,
      'time': formattedTime,
      'createdAt': now.toIso8601String(),
    };

    _messages.add(Map<String, dynamic>.from(data));
    notifyListeners();

    socket!.emit('send_message', data);

    log("send dataaa to socket=======>>>>>>$data");
  }

  void loadMoreMessages({
    required String userId,
    required String bookingId,
    int limit = 30,
  }) {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    _currentPage += 1;

    getMessageList(
      userId: userId,
      bookingId: bookingId,
      page: _currentPage,
      limit: limit,
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoadingMore = false;
    });
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
