import 'package:flutter/material.dart';
import 'socket_provider.dart';

class UserChatSocketProvider extends ChangeNotifier {
  SocketProvider _socket;

  UserChatSocketProvider(this._socket) {
    _socket.addListener(_onSocketChanged);
  }

  /// Called by ProxyProvider when SocketProvider changes
  void update(SocketProvider socket) {
    if (_socket == socket) return;
    _socket.removeListener(_onSocketChanged);
    _socket = socket;
    _socket.addListener(_onSocketChanged);
    notifyListeners();
  }

  void _onSocketChanged() => notifyListeners();

  // ── Delegates ──

  bool get isConnected => _socket.isConnected;

  bool get isLoadingMore => _socket.isLoadingMore;

  List<Map<String, dynamic>> get messages => _socket.messages;

  List<Map<String, dynamic>> get conversationList => _socket.conversationList;

  Map<String, dynamic>? get lastConversation => _socket.lastConversation;

  bool? get isCheckedUserOnline => _socket.isCheckedUserOnline;

  String get checkedUserId => _socket.checkedUserId;

  Future<void> initSocket(String jwtToken) => _socket.initSocket(jwtToken);

  bool emitUserStatus({required String userId, required String checkUserId}) =>
      _socket.emitUserStatus(userId: userId, checkUserId: checkUserId);

  bool getConversationList({
    required String userId,
    int page = 1,
    int limit = 50,
  }) =>
      _socket.getConversationList(userId: userId, page: page, limit: limit);

  void joinConversationChat({
    required String userId,
    required String conversationId,
    int firstPageLimit = 50,
  }) =>
      _socket.joinConversationChat(
        userId: userId,
        conversationId: conversationId,
        firstPageLimit: firstPageLimit,
      );

  void leaveConversationChat({
    required String userId,
    required String conversationId,
  }) =>
      _socket.leaveConversationChat(
          userId: userId, conversationId: conversationId);

  void loadMoreConversationMessages({
    required String userId,
    required String conversationId,
    int limit = 50,
  }) =>
      _socket.loadMoreConversationMessages(
        userId: userId,
        conversationId: conversationId,
        limit: limit,
      );

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
  }) =>
      _socket.sendConversationMessage(
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        conversationId: conversationId,
        message: message,
        senderModel: senderModel,
        receiverModel: receiverModel,
        type: type,
        files: files,
      );

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
    String receiverModel = 'User',
    String uploadEndpoint =
        'https://hii.life/app/server/api/v1/admin/user/image_uplod',
  }) =>
      _socket.sendConversationMediaMessage(
        senderId: senderId,
        senderName: senderName,
        senderImage: senderImage,
        receiverId: receiverId,
        receiverName: receiverName,
        receiverImage: receiverImage,
        conversationId: conversationId,
        localFilePaths: localFilePaths,
        senderModel: senderModel,
        receiverModel: receiverModel,
        uploadEndpoint: uploadEndpoint,
      );

  /// disconnect() is intentionally a no-op here.
  /// SocketProvider manages its own lifecycle.
  /// ChatMessageScreen should NOT disconnect the shared socket on dispose.
  void disconnect() {
    debugPrint(
        'UserChatSocketProvider.disconnect() — no-op (managed by SocketProvider)');
  }

  @override
  void dispose() {
    _socket.removeListener(_onSocketChanged);
    super.dispose();
  }
}
