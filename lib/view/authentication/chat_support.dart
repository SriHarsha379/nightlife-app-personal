import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_language.dart';
import 'dart:convert';
import '../../helper/ImagePreviewScreen.dart';
import '../../provider/socket_provider.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';

class ChatSupport extends StatefulWidget {
  static String routeName = './ChatSupport';

  final String? supportUserId;
  final String? conversationId;
  final String supportName;
  final String supportImage;

  const ChatSupport({
    super.key,
    this.supportUserId,
    this.conversationId,
    this.supportName = 'Support',
    this.supportImage = '',
  });

  @override
  State<ChatSupport> createState() => _ChatSupportState();
}

class _ChatSupportState extends State<ChatSupport> {
  final TextEditingController messageTextEditingController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _userId = '';
  String _userName = '';
  String _userImage = '';

  String _supportUserId = '';
  String _supportName = '';
  String _supportImage = '';

  String _conversationId = '';
  bool _isBootstrapping = true;
  bool _joined = false;
  bool _conversationListRequested = false;
  int _lastVisibleMessageCount = 0;
  bool _didInitialScroll = false;
  bool _historyRequestInFlight = false;
  bool _isUploadingMedia = false;

  SocketProvider? _socketProvider;
  UserController? _userController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onChatScroll);
    _supportUserId = widget.supportUserId?.trim() ?? '';
    _conversationId = widget.conversationId?.trim() ?? '';
    _supportName =
        widget.supportName.trim().isEmpty ? 'Support' : widget.supportName;
    _supportImage = widget.supportImage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _userController = Provider.of<UserController>(context, listen: false);
      _socketProvider?.addListener(_handleSocketStateChanged);
      _bootstrapChat();
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Bootstrap — load user + admin details, then init socket once
  // All socket work happens in _handleSocketStateChanged
  // ─────────────────────────────────────────────────────────────────
  Future<void> _bootstrapChat() async {
    await _loadUserFromController();
    await _resolveAdminDetailsFromApi();

    if (!mounted) return;

    debugPrint(
      'ChatSupport bootstrap => userId=$_userId supportUserId=$_supportUserId conversationId=$_conversationId',
    );

    // initSocket is safe — SocketProvider skips if already connected
    await Provider.of<SocketProvider>(context, listen: false)
        .initSocket(AppConstant.token);

    if (mounted) setState(() => _isBootstrapping = false);

    // If socket already connected by the time we get here, trigger work manually
    if (mounted && _socketProvider!.isConnected) {
      _handleSocketStateChanged();
    }
  }

  Future<void> _loadUserFromController() async {
    if (_userController == null) return;
    await _userController!.getUserDetails();
    _userId = _userController!.getUserId.trim();
    _userName = _userController!.getUserName.trim().isEmpty
        ? 'User'
        : _userController!.getUserName.trim();
    _userImage = _userController!.getUserImage.trim();
  }

  Future<void> _resolveAdminDetailsFromApi() async {
    if (_userId.isEmpty || AppConstant.token.trim().isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${AppConfigProvider.apiUrl}user/admin_details'),
        headers: {'authorization': 'Bearer ${AppConstant.token}'},
      );
      if (response.statusCode != 200) return;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['success'] != true)
        return;
      final payload = decoded['message'];
      if (payload is! Map) return;

      final admin = payload['admin'];
      if (admin is Map) {
        final adminId = (admin['_id'] ?? '').toString().trim();
        final adminName =
            (admin['name'] ?? admin['user_name'] ?? '').toString().trim();
        final adminImage = (admin['profile_image'] ?? '').toString().trim();
        if (adminId.isNotEmpty && _supportUserId.isEmpty)
          _supportUserId = adminId;
        if (adminName.isNotEmpty &&
            (_supportName.isEmpty || _supportName == 'Support')) {
          _supportName = adminName;
        }
        if (adminImage.isNotEmpty && _supportImage.isEmpty)
          _supportImage = adminImage;
      }

      if (_conversationId.isEmpty) {
        final apiConvId = (payload['conversation_id'] ?? '').toString().trim();
        if (apiConvId.isNotEmpty) {
          _conversationId = apiConvId;
          _joined = false;
        }
      }
    } catch (e) {
      debugPrint('ChatSupport admin_details failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Socket state listener — called on every notifyListeners()
  // ─────────────────────────────────────────────────────────────────
  void _handleSocketStateChanged() {
    if (!mounted || _socketProvider == null) return;

    if (!_socketProvider!.isConnected) {
      _conversationListRequested = false;
      _joined = false;
      return;
    }

    // 1. Request conversation list once
    if (!_conversationListRequested && _userId.isNotEmpty) {
      final sent = _socketProvider!
          .getConversationList(userId: _userId, page: 1, limit: 50);
      if (sent) _conversationListRequested = true;
    }

    // 2. Resolve conversationId from conversation list
    if (_socketProvider!.conversationList.isNotEmpty) {
      final item =
          _resolveSupportConversationItem(_socketProvider!.conversationList);
      if (item != null) {
        final resolvedConvId = _extractConversationId(item);
        if (resolvedConvId.isNotEmpty && _conversationId.isEmpty) {
          _conversationId = resolvedConvId;
          _joined = false;
          debugPrint('ChatSupport resolved conversationId=$_conversationId');
        }
        if (_supportUserId.isEmpty) {
          final resolvedSupportId = _extractSupportUserId(item);
          if (resolvedSupportId.isNotEmpty) _supportUserId = resolvedSupportId;
        }
      }
    }

    // 3. Resolve conversationId from lastConversation (after first send)
    if (_conversationId.isEmpty && _socketProvider!.lastConversation != null) {
      final convData = _socketProvider!.lastConversation!['conversation_data'];
      if (convData is Map) {
        final convId = (convData['conversation_id'] ?? convData['_id'] ?? '')
            .toString()
            .trim();
        if (convId.isNotEmpty) {
          _conversationId = convId;
          _joined = false;
          debugPrint(
              'ChatSupport conversationId from lastConversation=$_conversationId');
        }
      }
    }

    // 4. Join conversation
    _joinConversationIfReady();
  }

  // ─────────────────────────────────────────────────────────────────
  // Conversation helpers
  // ─────────────────────────────────────────────────────────────────
  Map<String, dynamic>? _resolveSupportConversationItem(
      List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;

    // Match by conversationId first
    if (_conversationId.isNotEmpty) {
      for (final item in list) {
        if (_extractConversationId(item) == _conversationId) return item;
      }
    }

    // Match by supportUserId
    if (_supportUserId.isNotEmpty) {
      for (final item in list) {
        if (_extractSupportUserId(item) == _supportUserId) return item;
      }
    }

    return list.first;
  }

  String _extractConversationId(Map<String, dynamic> item) =>
      (item['conversation_id'] ?? item['_id'] ?? '').toString().trim();

  String _extractSupportUserId(Map<String, dynamic> item) {
    for (final key in ['receiver_id', 'user_id', 'admin_id', 'other_user_id']) {
      final value = item[key];
      if (value == null) continue;
      final id = value is Map
          ? (value['_id'] ?? value['user_id'] ?? value['id'] ?? '').toString()
          : value.toString().trim();
      if (id.isNotEmpty && id != _userId) return id;
    }
    return '';
  }

  void _joinConversationIfReady() {
    if (!mounted || _socketProvider == null) return;
    if (_joined) return;
    if (_userId.isEmpty || _conversationId.isEmpty) return;
    if (!_socketProvider!.isConnected) return;

    debugPrint(
        'ChatSupport join => userId=$_userId conversationId=$_conversationId');
    _socketProvider!.joinConversationChat(
      userId: _userId,
      conversationId: _conversationId,
      firstPageLimit: 50,
    );
    _joined = true;
  }

  // ─────────────────────────────────────────────────────────────────
  // Scroll
  // ─────────────────────────────────────────────────────────────────
  void _onChatScroll() {
    if (!mounted || _socketProvider == null) return;
    if (!_joined || _conversationId.isEmpty || _userId.isEmpty) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels > 120) return;
    if (_historyRequestInFlight || _socketProvider!.isLoadingMore) return;

    _historyRequestInFlight = true;
    _socketProvider!.loadMoreConversationMessages(
      userId: _userId,
      conversationId: _conversationId,
      limit: 50,
    );
    Future.delayed(const Duration(milliseconds: 700),
        () => _historyRequestInFlight = false);
  }

  // ─────────────────────────────────────────────────────────────────
  // Message helpers
  // ─────────────────────────────────────────────────────────────────
  bool _isMineMessage(Map<String, dynamic> message) {
    final senderId = _extractUserId(
        message['sender_id'] ?? message['senderId'] ?? message['user_id']);
    return senderId.isNotEmpty && senderId == _userId;
  }

  String _extractUserId(dynamic raw) {
    if (raw == null) return '';
    if (raw is Map) {
      return (raw['_id'] ?? raw['user_id'] ?? raw['id'] ?? '')
          .toString()
          .trim();
    }
    return raw.toString().trim();
  }

  String _messageText(Map<String, dynamic> message) =>
      (message['message'] ?? '').toString();

  List<String> _messageFiles(Map<String, dynamic> message) {
    final dynamic files = message['files'];
    if (files is! List) return const [];
    return files
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _fileUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://'))
      return value;
    return '${AppConfigProvider.imageUrl}$value';
  }

  bool _isVideoFile(String filePath) {
    final path = filePath.toLowerCase();
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.avi') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm');
  }

  bool _isImageFile(String filePath) {
    final path = filePath.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.gif') ||
        path.endsWith('.webp');
  }

  List<Map<String, String>> _previewMediaItemsForMessage(
    Map<String, dynamic> message,
  ) {
    final dynamic filesRaw = message['files'];
    if (filesRaw is! List) return const [];

    final files = filesRaw
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    if (files.isEmpty) return const [];

    final type = (message['type'] ?? message['message_type'] ?? '')
        .toString()
        .toLowerCase()
        .trim();

    if (type == 'video') {
      final videoPath =
          files.firstWhere((f) => _isVideoFile(f), orElse: () => '');
      final thumbnailPath =
          files.firstWhere((f) => _isImageFile(f), orElse: () => '');
      final source = _fileUrl(videoPath.isNotEmpty ? videoPath : files.first);
      final thumb = _fileUrl(thumbnailPath.isNotEmpty ? thumbnailPath : source);
      return <Map<String, String>>[
        <String, String>{
          'type': 'video',
          'url': thumb,
          'thumbnail': thumb,
          'source': source,
        }
      ];
    }

    return files
        .map(
          (f) => <String, String>{
            'type': _isVideoFile(f) ? 'video' : 'image',
            'url': _fileUrl(f),
            'thumbnail': _isVideoFile(f) ? _fileUrl(f) : '',
            'source': _isVideoFile(f) ? _fileUrl(f) : _fileUrl(f),
          },
        )
        .toList();
  }

  void _openMediaPreviewFromMessage(
    Map<String, dynamic> message, {
    int tappedIndex = 0,
  }) {
    final media = _previewMediaItemsForMessage(message);
    if (media.isEmpty) return;
    final safeIndex = tappedIndex < 0
        ? 0
        : (tappedIndex >= media.length ? media.length - 1 : tappedIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(
          images: media.map((e) => e['url'] ?? '').toList(),
          media: media,
          initialIndex: safeIndex,
        ),
      ),
    );
  }

  bool _belongsToCurrentConversation(Map<String, dynamic> message) {
    final msgConvId =
        (message['conversation_id'] ?? message['conversationId'] ?? '')
            .toString()
            .trim();
    if (_conversationId.isNotEmpty && msgConvId.isNotEmpty) {
      return msgConvId == _conversationId;
    }
    // Fallback for first-message (no conversationId yet)
    final sender = _extractUserId(message['sender_id'] ?? message['senderId']);
    final receiver =
        _extractUserId(message['receiver_id'] ?? message['receiverId']);
    if (_supportUserId.isEmpty || _userId.isEmpty) return false;
    return (sender == _userId && receiver == _supportUserId) ||
        (sender == _supportUserId && receiver == _userId);
  }

  void _maybeAutoScroll(int messageCount) {
    if (messageCount <= 0 || messageCount == _lastVisibleMessageCount) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (!_didInitialScroll) {
        _scrollController.jumpTo(target);
        _didInitialScroll = true;
      } else {
        _scrollController.animateTo(target,
            duration: const Duration(milliseconds: 160), curve: Curves.easeOut);
      }
      _lastVisibleMessageCount = messageCount;
    });
  }

  // ─────────────────────────────────────────────────────────────────
  // Send message
  // ─────────────────────────────────────────────────────────────────
  void _sendMessage() {
    final text = messageTextEditingController.text.trim();
    if (text.isEmpty) return;

    if (_userId.isEmpty || _supportUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support is loading. Please wait.')),
      );
      return;
    }

    Provider.of<SocketProvider>(context, listen: false).sendConversationMessage(
      senderId: _userId,
      senderName: _userName,
      senderImage: _userImage,
      receiverId: _supportUserId,
      receiverName: _supportName,
      receiverImage: _supportImage,
      conversationId: _conversationId,
      message: text,
      senderModel: 'User',
      receiverModel: 'Admin',
    );

    messageTextEditingController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _sendPickedMedia(List<Map<String, String>> picked) async {
    if (!mounted || _userId.isEmpty || _supportUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support is loading. Please wait.')),
      );
      return;
    }

    final imageOnlyPaths = picked
        .where((item) => (item['type'] ?? '').toLowerCase() == 'image')
        .map((item) => (item['file'] ?? '').trim())
        .where((p) => p.isNotEmpty)
        .toList();

    if (imageOnlyPaths.isEmpty) return;

    setState(() => _isUploadingMedia = true);

    final success = await Provider.of<SocketProvider>(context, listen: false)
        .sendConversationMediaMessage(
      senderId: _userId,
      senderName: _userName,
      senderImage: _userImage,
      receiverId: _supportUserId,
      receiverName: _supportName,
      receiverImage: _supportImage,
      conversationId: _conversationId,
      localFilePaths: imageOnlyPaths,
      senderModel: 'User',
      receiverModel: 'Admin',
    );

    if (!mounted) return;
    setState(() => _isUploadingMedia = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to upload image. Please try again.')),
      );
    }
  }

  void _openMediaPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColor.primaryColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(AppLanguage.galleryText[language]),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final List<XFile> pickedList =
                        await ImagePicker().pickMultiImage(imageQuality: 100);
                    if (!mounted || pickedList.isEmpty) return;
                    _sendPickedMedia(pickedList
                        .map((f) => <String, String>{
                              'type': 'image',
                              'file': f.path,
                              'thumbnail': '',
                            })
                        .toList());
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to pick images: $e')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(AppLanguage.cameraText[language]),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  try {
                    final XFile? picked = await ImagePicker().pickImage(
                        source: ImageSource.camera, imageQuality: 100);
                    if (!mounted || picked == null) return;
                    _sendPickedMedia([
                      <String, String>{
                        'type': 'image',
                        'file': picked.path,
                        'thumbnail': '',
                      }
                    ]);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to open camera: $e')));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Media message widget
  // ─────────────────────────────────────────────────────────────────
  Widget _buildMediaMessage(
    BuildContext context,
    Map<String, dynamic> message,
    bool mine,
    Size size,
  ) {
    final files = _messageFiles(message);
    if (files.isEmpty) return const SizedBox.shrink();

    final double boxSize = size.width * 0.62;
    final int total = files.length;
    final int visibleCount = total > 4 ? 4 : total;
    final List<String> visible = files.take(visibleCount).toList();

    Widget tile(String filePath, {int index = 0, int extraCount = 0}) {
      final url = _fileUrl(filePath);
      final isVideo = _isVideoFile(filePath);
      return GestureDetector(
        onTap: () {
          _openMediaPreviewFromMessage(message, tappedIndex: index);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                      color: Colors.black26,
                      child:
                          const Icon(Icons.broken_image, color: Colors.white70),
                    )),
            if (isVideo)
              Container(
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle),
                child:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 26),
              ),
            if (extraCount > 0)
              Container(
                color: Colors.black.withOpacity(0.45),
                alignment: Alignment.center,
                child: Text('+$extraCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      );
    }

    Widget gridBody;
    if (visibleCount == 1) {
      gridBody = tile(visible[0]);
    } else if (visibleCount == 2) {
      gridBody = Row(children: [
        Expanded(child: tile(visible[0], index: 0)),
        const SizedBox(width: 2),
        Expanded(child: tile(visible[1], index: 1)),
      ]);
    } else if (visibleCount == 3) {
      gridBody = Column(children: [
        Expanded(child: tile(visible[0], index: 0)),
        const SizedBox(height: 2),
        Expanded(
          child: Row(children: [
            Expanded(child: tile(visible[1], index: 1)),
            const SizedBox(width: 2),
            Expanded(child: tile(visible[2], index: 2)),
          ]),
        ),
      ]);
    } else {
      gridBody = Column(children: [
        Expanded(
          child: Row(children: [
            Expanded(child: tile(visible[0], index: 0)),
            const SizedBox(width: 2),
            Expanded(child: tile(visible[1], index: 1)),
          ]),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(children: [
            Expanded(child: tile(visible[2], index: 2)),
            const SizedBox(width: 2),
            Expanded(
                child: tile(visible[3],
                    index: 3, extraCount: total > 4 ? total - 4 : 0)),
          ]),
        ),
      ]);
    }

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: mine ? AppColor.buttonColor : const Color(0xff262626),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.hardEdge,
      child: gridBody,
    );
  }

  @override
  void dispose() {
    _socketProvider?.removeListener(_handleSocketStateChanged);
    if (_socketProvider != null &&
        _joined &&
        _userId.isNotEmpty &&
        _conversationId.isNotEmpty) {
      _socketProvider!.leaveConversationChat(
        userId: _userId,
        conversationId: _conversationId,
      );
    }
    messageTextEditingController.dispose();
    _scrollController.removeListener(_onChatScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: Column(
          children: [
            SizedBox(height: size.height * 5 / 100),
            AppHeader(
              text: AppLanguage.chatSupportText[language],
              onPress: () => Navigator.pop(context),
            ),
            Expanded(
              child: _isBootstrapping
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColor.buttonColor))
                  : Consumer<SocketProvider>(
                      builder: (context, socketProvider, child) {
                        final messages = socketProvider.messages
                            .where(_belongsToCurrentConversation)
                            .toList();
                        _maybeAutoScroll(messages.length);

                        if (_userId.isEmpty) {
                          return const Center(
                            child: Text('Unable to load user session.',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: AppFont.fontFamily)),
                          );
                        }

                        if (messages.isEmpty) {
                          return const Center(
                            child: Text(
                                'No previous messages. Start chatting with support.',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: AppFont.fontFamily)),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 4 / 100,
                            vertical: size.height * 1 / 100,
                          ),
                          itemCount: messages.length +
                              (socketProvider.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (socketProvider.isLoadingMore && index == 0) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text('Loading...',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 12)),
                                ),
                              );
                            }

                            final actualIndex = socketProvider.isLoadingMore
                                ? index - 1
                                : index;
                            if (actualIndex < 0 ||
                                actualIndex >= messages.length) {
                              return const SizedBox.shrink();
                            }

                            final message = messages[actualIndex];
                            final mine = _isMineMessage(message);
                            final text = _messageText(message);
                            final files = _messageFiles(message);
                            final hasMedia = files.isNotEmpty;

                            return Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: size.height * 1.2 / 100),
                                child: Column(
                                  crossAxisAlignment: mine
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    if (hasMedia)
                                      _buildMediaMessage(
                                          context, message, mine, size),
                                    if (text.trim().isNotEmpty)
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: hasMedia ? 8 : 0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: mine
                                              ? AppColor.buttonColor
                                              : const Color(0xff262626),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: Text(text,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily:
                                                    AppFont.fontFamily)),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            // ── Input bar ──
            SizedBox(
              width: size.width * 90 / 100,
              child: TextFormField(
                cursorColor: AppColor.secondryColor(context),
                style: TextStyle(
                    height: 1, color: AppColor.secondryColor(context)),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
                maxLength: AppConstant.describeLength,
                controller: messageTextEditingController,
                onFieldSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  isDense: true,
                  suffixIconConstraints:
                      BoxConstraints(maxWidth: size.width * 30 / 100),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _isUploadingMedia ? null : _openMediaPicker,
                          child: _isUploadingMedia
                              ? SizedBox(
                                  width: size.width * 7 / 100,
                                  height: size.width * 7 / 100,
                                  child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColor.buttonColor),
                                )
                              : Image.asset(AppImage.plusIcon,
                                  height: size.width * 7 / 100,
                                  width: size.width * 7 / 100,
                                  color: AppColor.secondryColor(context)),
                        ),
                        SizedBox(width: size.width * 3 / 100),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Image.asset(AppImage.shareImg,
                              height: size.width * 7 / 100,
                              width: size.width * 7 / 100,
                              color: AppColor.secondryColor(context)),
                        ),
                        SizedBox(width: size.width * 3 / 100),
                      ],
                    ),
                  ),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.washpressColor),
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.washpressColor),
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: AppColor.washpressColor),
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                  fillColor: AppColor.washpressColor,
                  filled: true,
                  counterText: '',
                  hintText: AppLanguage.messageText[language],
                  hintStyle: TextStyle(
                      color: AppColor.chatSupportcolor(context),
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: size.height * 2 / 100),
          ],
        ),
      ),
    );
  }
}
