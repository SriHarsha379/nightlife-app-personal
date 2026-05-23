import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_language.dart';
import 'dart:convert';
import '../../helper/ImagePreviewScreen.dart';
import '../../provider/darkmode_provider.dart';
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

  // conversationId ONLY set from admin_details API or from a conversation
  // item whose sender/receiver is the known admin. Never from list.first.
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

  String _raw(dynamic value) => (value ?? '').toString().trim();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onChatScroll);

    // Only accept a pre-supplied conversationId if it was explicitly passed in.
    // Never inherit one from widget defaults.
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
  // Bootstrap
  // ─────────────────────────────────────────────────────────────────
  Future<void> _bootstrapChat() async {
    await _loadUserFromController();
    await _resolveAdminDetailsFromApi();

    if (!mounted) return;

    debugPrint(
      'ChatSupport bootstrap => userId=$_userId '
      'supportUserId=$_supportUserId conversationId=$_conversationId',
    );

    await Provider.of<SocketProvider>(context, listen: false)
        .initSocket(AppConstant.token);

    if (mounted) setState(() => _isBootstrapping = false);

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

  /// Fetches admin details and sets _supportUserId / _conversationId.
  /// _conversationId is ONLY set here if the API returns a non-null value.
  /// It is NEVER resolved from the conversation list fallback.
  Future<void> _resolveAdminDetailsFromApi() async {
    if (_userId.isEmpty || AppConstant.token.trim().isEmpty) return;
    try {
      final response = await http.get(
        Uri.parse('${AppConfigProvider.apiUrl}user/admin_details'),
        headers: {
          'authorization': 'Bearer ${AppConstant.token}',
          'User-Agent': 'NightLifeApp/1.0 (Flutter; iOS)',
          'Accept': 'application/json',
          'X-Requested-With': 'com.example.nightLife',
        },
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

        if (adminId.isNotEmpty && _supportUserId.isEmpty) {
          _supportUserId = adminId;
        }
        if (adminName.isNotEmpty &&
            (_supportName.isEmpty || _supportName == 'Support')) {
          _supportName = adminName;
        }
        if (adminImage.isNotEmpty && _supportImage.isEmpty) {
          _supportImage = adminImage;
        }
      }

      // ONLY set conversationId from API if it is truly non-null & non-empty.
      // If API returns null, we leave _conversationId empty intentionally.
      final apiConvId = payload['conversation_id'];
      if (apiConvId != null) {
        final convIdStr = apiConvId.toString().trim();
        if (convIdStr.isNotEmpty &&
            convIdStr.toLowerCase() != 'null' &&
            _conversationId.isEmpty) {
          _conversationId = convIdStr;
          _joined = false;
        }
      }
    } catch (e) {
      debugPrint('ChatSupport admin_details failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // Socket state handler
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

    // 2. Resolve conversationId from conversation list — ONLY match by admin ID.
    //    Never fall back to list.first or any unrelated conversation.
    if (_conversationId.isEmpty &&
        _socketProvider!.conversationList.isNotEmpty) {
      final item =
          _resolveSupportConversationItem(_socketProvider!.conversationList);
      if (item != null) {
        final resolvedConvId = _extractConversationId(item);
        if (resolvedConvId.isNotEmpty) {
          _conversationId = resolvedConvId;
          _joined = false;
          debugPrint(
              'ChatSupport resolved conversationId from list=$_conversationId');
        }
      }
    }

    // 3. Resolve conversationId from lastConversation ONLY if it involves admin.
    if (_conversationId.isEmpty && _socketProvider!.lastConversation != null) {
      final convData = _socketProvider!.lastConversation!['conversation_data'];
      if (convData is Map) {
        final convId = (convData['conversation_id'] ?? convData['_id'] ?? '')
            .toString()
            .trim();

        // Extract sender/receiver IDs robustly (may be Map or String)
        final senderRaw = convData['sender_id'];
        final receiverRaw = convData['receiver_id'];
        final senderId = senderRaw is Map
            ? (senderRaw['_id'] ?? senderRaw['id'] ?? '').toString().trim()
            : senderRaw?.toString().trim() ?? '';
        final receiverId = receiverRaw is Map
            ? (receiverRaw['_id'] ?? receiverRaw['id'] ?? '').toString().trim()
            : receiverRaw?.toString().trim() ?? '';

        final involvesAdmin = _supportUserId.isNotEmpty &&
            (senderId == _supportUserId || receiverId == _supportUserId);

        if (convId.isNotEmpty && involvesAdmin) {
          _conversationId = convId;
          _joined = false;
          debugPrint(
              'ChatSupport conversationId from lastConversation=$_conversationId');
        }
      }
    }

    // 4. Join only if we have a valid admin conversationId
    _joinConversationIfReady();
  }

  // ─────────────────────────────────────────────────────────────────
  // Conversation helpers
  // ─────────────────────────────────────────────────────────────────

  /// Returns the conversation item that belongs to the admin/support user.
  /// Returns null if no matching item is found — never falls back to list.first.
  Map<String, dynamic>? _resolveSupportConversationItem(
      List<Map<String, dynamic>> list) {
    if (list.isEmpty || _supportUserId.isEmpty) return null;

    // Match by exact conversationId first (fastest path)
    if (_conversationId.isNotEmpty) {
      for (final item in list) {
        if (_extractConversationId(item) == _conversationId) return item;
      }
    }

    // Match by admin userId — check both sender_id and receiver_id
    for (final item in list) {
      if (_isAdminConversationItem(item)) return item;
    }

    // No admin conversation found — return null, do NOT fall back
    return null;
  }

  /// Returns true only if this conversation item has the admin as a participant.
  bool _isAdminConversationItem(Map<String, dynamic> item) {
    if (_supportUserId.isEmpty) return false;

    for (final key in ['sender_id', 'receiver_id']) {
      final value = item[key];
      if (value == null) continue;
      final id = value is Map
          ? (value['_id'] ?? value['user_id'] ?? value['id'] ?? '')
              .toString()
              .trim()
          : value.toString().trim();
      if (id == _supportUserId) return true;
    }
    return false;
  }

  String _extractConversationId(Map<String, dynamic> item) =>
      (item['conversation_id'] ?? item['_id'] ?? '').toString().trim();

  void _joinConversationIfReady() {
    if (!mounted || _socketProvider == null) return;
    if (_joined) return;
    if (_userId.isEmpty || _conversationId.isEmpty) return;
    if (!_socketProvider!.isConnected) return;

    // Extra safety: don't join if we still don't know the admin
    if (_supportUserId.isEmpty) return;

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

  String _supportMessageRenderKey(Map<String, dynamic> message) {
    final signature = [
      _extractUserId(message['sender_id'] ?? message['senderId']),
      _extractUserId(message['receiver_id'] ?? message['receiverId']),
      _raw(message['conversation_id'] ?? message['conversationId']),
      _messageText(message),
      _raw(message['type']),
      _messageFiles(message).join(','),
      _raw(message['date']),
      _raw(message['time']),
    ].join('|');
    if (signature.replaceAll('|', '').isNotEmpty) return 'sig:$signature';
    final id = _raw(message['_id']);
    if (id.isNotEmpty) return 'id:$id';
    return 'fallback:${message.hashCode}';
  }

  List<Map<String, dynamic>> _dedupeVisibleMessages(
      List<Map<String, dynamic>> messages) {
    final byKey = <String, Map<String, dynamic>>{};
    for (final message in messages) {
      final key = _supportMessageRenderKey(message);
      final existing = byKey[key];
      if (existing == null) {
        byKey[key] = message;
        continue;
      }

      final existingId = _raw(existing['_id']);
      final nextId = _raw(message['_id']);
      if (existingId.isEmpty && nextId.isNotEmpty) {
        byKey[key] = message;
      }
    }
    return byKey.values.toList();
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
            'source': _fileUrl(f),
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

  /// Filters messages so only those belonging to the current admin
  /// conversation are shown. If conversationId is empty, shows nothing.
  bool _belongsToCurrentConversation(Map<String, dynamic> message) {
    // If we don't have a conversationId yet, show nothing
    if (_conversationId.isEmpty) return false;

    final msgConvId =
        (message['conversation_id'] ?? message['conversationId'] ?? '')
            .toString()
            .trim();

    // Must match our conversationId exactly
    if (msgConvId.isNotEmpty) {
      return msgConvId == _conversationId;
    }

    // Fallback for first optimistic message (no conversationId assigned yet)
    // Only valid if we know both user and admin IDs
    if (_supportUserId.isEmpty || _userId.isEmpty) return false;
    final sender = _extractUserId(message['sender_id'] ?? message['senderId']);
    final receiver =
        _extractUserId(message['receiver_id'] ?? message['receiverId']);
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
      isuser: false,
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
      isuser: false,
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
    final messageKey = [
      _raw(message['_id']),
      _raw(message['conversation_id']),
      _raw(message['date']),
      _raw(message['time']),
      files.join(','),
    ].join('|');

    Widget tile(String filePath, {int index = 0, int extraCount = 0}) {
      final url = _fileUrl(filePath);
      final isVideo = _isVideoFile(filePath);
      return GestureDetector(
        key: ValueKey('support-media-tile-$messageKey-$index-$filePath'),
        onTap: () => _openMediaPreviewFromMessage(message, tappedIndex: index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(url,
                key: ValueKey('support-media-image-$messageKey-$index-$url'),
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
      key: ValueKey('support-media-box-$messageKey'),
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

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
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
                        // Only show messages that belong to the admin conversation.
                        // If _conversationId is empty, messages list will be empty.
                        final messages = socketProvider.messages
                            .where(_belongsToCurrentConversation)
                            .map((m) => Map<String, dynamic>.from(m))
                            .toList();
                        final visibleMessages =
                            _dedupeVisibleMessages(messages).toList();

                        _maybeAutoScroll(visibleMessages.length);

                        if (_userId.isEmpty) {
                          return const Center(
                            child: Text('Unable to load user session.',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: AppFont.fontFamily)),
                          );
                        }

                        if (visibleMessages.isEmpty) {
                          return const Center(
                            child: Text(
                              'No previous messages. Start chatting with support.',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: AppFont.fontFamily),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 4 / 100,
                            vertical: size.height * 1 / 100,
                          ),
                          itemCount: visibleMessages.length +
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
                                actualIndex >= visibleMessages.length) {
                              return const SizedBox.shrink();
                            }

                            final message = visibleMessages[actualIndex];
                            final mine = _isMineMessage(message);
                            final text = _messageText(message);
                            final files = _messageFiles(message);
                            final hasMedia = files.isNotEmpty;

                            return Align(
                              key: ValueKey(
                                  'support-msg-${_raw(message['_id']).isNotEmpty ? _raw(message['_id']) : '${_raw(message['conversation_id'])}-$actualIndex-${files.join(',')}'}'),
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
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              isDark ? AppColor.washpressColor : Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              isDark ? AppColor.washpressColor : Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              isDark ? AppColor.washpressColor : Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
                  fillColor: isDark ? AppColor.washpressColor : Colors.white,
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
            SizedBox(height: size.height * 3 / 100),
          ],
        ),
      ),
    );
  }
}
