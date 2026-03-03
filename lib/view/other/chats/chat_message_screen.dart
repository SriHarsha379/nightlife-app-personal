import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import '../../../../helper/ImagePreviewScreen.dart';
import '../../../../provider/user_chat_socket_provider.dart';
import '../../../../provider/user_controller.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../../../../utilities/media_picker_helper.dart';
import '../MySplashSection/MembersSection/member_liked_details.dart';

class ChatMessageScreen extends StatefulWidget {
  static String routeName = "./ChatMessageScreen";
  final String name;
  final dynamic image;
  final String? receiverId;
  final String? conversationId;

  const ChatMessageScreen({
    super.key,
    required this.name,
    required this.image,
    this.receiverId,
    this.conversationId,
  });

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen>
    with SingleTickerProviderStateMixin {
  static const String _locationPrefix = '__loc__';
  // -- UI --
  bool isBottomSheetOpen = false;
  bool isContainerVisible = false;
  bool isApproved = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  // -- Chat --
  final TextEditingController messageTextEditingController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final stt.SpeechToText _speech = stt.SpeechToText();

  UserChatSocketProvider? _socketProvider;
  UserController? _userController;

  bool _isBootstrapping = true;
  bool _joined = false;
  bool _conversationRequested = false;
  int _conversationRequestAttempt = 0;
  bool _historyRequestInFlight = false;
  int _lastVisibleMessageCount = 0;
  bool _didInitialScroll = false;
  bool _isUploadingMedia = false;
  bool _isSendingLocation = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _speechSeedText = '';
  final List<Map<String, dynamic>> _pendingMediaMessages = [];

  String _userId = '';
  String _userName = '';
  String _userImage = '';
  String _receiverId = '';
  String _receiverName = '';
  String _receiverImage = '';
  String _conversationId = '';

  @override
  void initState() {
    super.initState();
    debugPrint('[ChatMessageScreen] build version => GOOGLE_MAP_PREVIEW_V2');
    _receiverId = _raw(widget.receiverId);
    _conversationId = _raw(widget.conversationId);
    _receiverName = widget.name.trim();
    _receiverImage = _raw(widget.image);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _initSpeech();

    _scrollController.addListener(_onChatScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketProvider =
          Provider.of<UserChatSocketProvider>(context, listen: false);
      _userController = Provider.of<UserController>(context, listen: false);
      _socketProvider?.addListener(_handleSocketStateChanged);
      _bootstrapChat();
    });
  }

  @override
  void dispose() {
    _socketProvider?.removeListener(_handleSocketStateChanged);

    // Leave room if joined ? do NOT disconnect socket (it's shared)
    if (_socketProvider != null &&
        _joined &&
        _userId.isNotEmpty &&
        _conversationId.isNotEmpty) {
      _socketProvider!.leaveConversationChat(
        userId: _userId,
        conversationId: _conversationId,
      );
    }

    _scrollController.removeListener(_onChatScroll);
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _speech.stop();
    messageTextEditingController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------------
  // Bootstrap
  // -----------------------------------------------------------------
  Future<void> _bootstrapChat() async {
    await _loadUserFromController();
    if (!mounted) return;

    // initSocket is safe to call ? SocketProvider will skip if already connected
    await _socketProvider?.initSocket(AppConstant.token);
    if (!mounted) return;

    if (_userId.isNotEmpty) {
      _requestConversationList();
    }

    if (mounted) setState(() => _isBootstrapping = false);
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

  // -----------------------------------------------------------------
  // Request conversation list
  // -----------------------------------------------------------------
  void _requestConversationList() {
    if (!mounted || _socketProvider == null || _userId.isEmpty) return;
    if (_conversationRequested) return;

    if (_socketProvider!.isConnected) {
      final sent = _socketProvider!
          .getConversationList(userId: _userId, page: 1, limit: 50);
      if (sent) {
        _conversationRequested = true;
      } else {
        _conversationRequestAttempt++;
        if (_conversationRequestAttempt <= 60) {
          Future.delayed(
              const Duration(milliseconds: 500), _requestConversationList);
        }
      }
      return;
    }

    _conversationRequestAttempt++;
    if (_conversationRequestAttempt <= 60) {
      Future.delayed(
          const Duration(milliseconds: 500), _requestConversationList);
    }
  }

  // -----------------------------------------------------------------
  // Socket state listener
  // -----------------------------------------------------------------
  void _handleSocketStateChanged() {
    if (!mounted || _socketProvider == null) return;

    if (!_socketProvider!.isConnected) {
      _conversationRequested = false;
      _joined = false;
      return;
    }

    final previousConversationId = _conversationId;

    // 1. Request conversation list
    _requestConversationList();

    // 2. Resolve conversationId from conversation list
    final item = _resolveUserConversation(_socketProvider!.conversationList);
    if (item != null) {
      final resolvedConvId = _extractConversationId(item);
      if (resolvedConvId.isNotEmpty &&
          (_conversationId.isEmpty ||
              !_conversationExistsInList(_conversationId))) {
        _conversationId = resolvedConvId;
      }
      final resolvedUserId = _extractOtherUserId(item);
      if (_receiverId.isEmpty && resolvedUserId.isNotEmpty) {
        _receiverId = resolvedUserId;
      }
    }

    // 3. Resolve conversationId from messages (first-send scenario)
    if (_conversationId.isEmpty && _socketProvider!.messages.isNotEmpty) {
      for (final msg in _socketProvider!.messages.reversed) {
        final msgConvId =
            (msg['conversation_id'] ?? msg['conversationId'] ?? '')
                .toString()
                .trim();
        if (msgConvId.isNotEmpty) {
          final msgSender = _extractId(msg['sender_id'] ?? msg['senderId']);
          final msgReceiver =
              _extractId(msg['receiver_id'] ?? msg['receiverId']);
          if ((_receiverId.isNotEmpty &&
                  (msgSender == _receiverId || msgReceiver == _receiverId)) ||
              msgSender == _userId ||
              msgReceiver == _userId) {
            _conversationId = msgConvId;
            debugPrint(
                '[Chat] conversationId resolved from message: $_conversationId');
            break;
          }
        }
      }
    }

    // 4. Resolve from lastConversation packet (after first message)
    if (_conversationId.isEmpty && _socketProvider!.lastConversation != null) {
      final lastConv = _socketProvider!.lastConversation!;
      final convData = lastConv['conversation_data'];
      if (convData is Map) {
        final convId = (convData['conversation_id'] ?? convData['_id'] ?? '')
            .toString()
            .trim();
        if (convId.isNotEmpty) {
          final sender = _extractId(convData['sender_id']);
          final receiver = _extractId(convData['receiver_id']);
          if ((sender == _userId && receiver == _receiverId) ||
              (sender == _receiverId && receiver == _userId)) {
            _conversationId = convId;
            debugPrint(
                '[Chat] conversationId resolved from lastConversation: $_conversationId');
          }
        }
      }
    }

    if (previousConversationId != _conversationId) {
      _joined = false;
    }

    // 5. Join conversation room
    _joinConversationIfReady();
  }

  // -----------------------------------------------------------------
  // Conversation helpers
  // -----------------------------------------------------------------
  Map<String, dynamic>? _resolveUserConversation(
      List<Map<String, dynamic>> list) {
    if (list.isEmpty) return null;

    // Match by conversationId first
    if (_conversationId.isNotEmpty) {
      for (final item in list) {
        if (_extractConversationId(item) == _conversationId) return item;
      }
    }

    // Match by receiverId
    if (_receiverId.isNotEmpty) {
      for (final item in list) {
        if (_extractOtherUserId(item) == _receiverId) return item;
      }
    }

    // Match by name
    final targetName = _receiverName.toLowerCase().trim();
    if (targetName.isNotEmpty) {
      for (final item in list) {
        if (_extractOtherUserName(item).toLowerCase().trim() == targetName) {
          return item;
        }
      }
    }

    return null;
  }

  bool _conversationExistsInList(String conversationId) {
    if (_socketProvider == null || conversationId.trim().isEmpty) return false;
    for (final item in _socketProvider!.conversationList) {
      if (_extractConversationId(item) == conversationId) return true;
    }
    return false;
  }

  String _extractConversationId(Map<String, dynamic> item) =>
      (item['_id'] ?? item['conversation_id'] ?? '').toString().trim();

  String _extractId(dynamic raw) {
    if (raw == null) return '';
    if (raw is Map) {
      return (raw['_id'] ?? raw['user_id'] ?? raw['id'] ?? '')
          .toString()
          .trim();
    }
    return raw.toString().trim();
  }

  String _extractOtherUserId(Map<String, dynamic> item) {
    final senderId = _extractId(item['sender_id']);
    final receiverId = _extractId(item['receiver_id']);
    if (senderId == _userId) return receiverId;
    if (receiverId == _userId) return senderId;
    if (_receiverId.isNotEmpty && senderId == _receiverId) return senderId;
    if (_receiverId.isNotEmpty && receiverId == _receiverId) return receiverId;
    return receiverId;
  }

  String _extractOtherUserName(Map<String, dynamic> item) {
    final sender = item['sender_id'];
    final receiver = item['receiver_id'];
    final senderId = _extractId(sender);
    final receiverId = _extractId(receiver);
    if (sender is Map && senderId != _userId) {
      return (sender['name'] ?? sender['full_name'] ?? '').toString().trim();
    }
    if (receiver is Map && receiverId != _userId) {
      return (receiver['name'] ?? receiver['full_name'] ?? '')
          .toString()
          .trim();
    }
    return '';
  }

  void _joinConversationIfReady() {
    if (!mounted || _socketProvider == null) return;
    if (_joined) return;
    if (_userId.isEmpty || _conversationId.isEmpty) return;
    if (!_socketProvider!.isConnected) return;

    _socketProvider!.joinConversationChat(
      userId: _userId,
      conversationId: _conversationId,
      firstPageLimit: 50,
    );
    _joined = true;
    debugPrint('[Chat] Joined conversation: $_conversationId');
  }

  // -----------------------------------------------------------------
  // Message helpers
  // -----------------------------------------------------------------
  bool _belongsToCurrentConversation(Map<String, dynamic> message) {
    final msgConversationId =
        (message['conversation_id'] ?? message['conversationId'] ?? '')
            .toString()
            .trim();

    if (_conversationId.isNotEmpty && msgConversationId.isNotEmpty) {
      return msgConversationId == _conversationId;
    }

    // Fallback for first-send (no conversationId yet)
    final sender = _extractId(message['sender_id'] ?? message['senderId']);
    final receiver =
        _extractId(message['receiver_id'] ?? message['receiverId']);
    if (_receiverId.isEmpty || _userId.isEmpty) return false;
    return (sender == _userId && receiver == _receiverId) ||
        (sender == _receiverId && receiver == _userId);
  }

  bool _isMine(Map<String, dynamic> message) =>
      _extractId(message['sender_id'] ?? message['senderId']) == _userId;

  // -----------------------------------------------------------------
  // Scroll
  // -----------------------------------------------------------------
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

  void _maybeAutoScroll(int messageCount) {
    if (messageCount <= 0 || messageCount == _lastVisibleMessageCount) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final target = _scrollController.position.minScrollExtent;
      if (!_didInitialScroll) {
        _scrollController.jumpTo(target);
        _didInitialScroll = true;
      } else {
        _scrollController.animateTo(target,
            duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
      }
      _lastVisibleMessageCount = messageCount;
    });
  }

  // -----------------------------------------------------------------
  // Send message
  // -----------------------------------------------------------------
  void _sendMessage() {
    final text = messageTextEditingController.text.trim();
    if (text.isEmpty) return;

    if (_userId.isEmpty || _receiverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat is loading. Please wait.')),
      );
      return;
    }

    Provider.of<UserChatSocketProvider>(context, listen: false)
        .sendConversationMessage(
      senderId: _userId,
      senderName: _userName,
      senderImage: _userImage,
      receiverId: _receiverId,
      receiverName: _receiverName,
      receiverImage: (_receiverImage.startsWith('assets/') ||
              _receiverImage.startsWith('./assets/'))
          ? ''
          : _receiverImage,
      conversationId: _conversationId,
      message: text,
      senderModel: 'User',
      receiverModel: 'User', // user-to-user
    );

    messageTextEditingController.clear();
    if (!_messageFocusNode.hasFocus) {
      _messageFocusNode.requestFocus();
    }
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (_) {
          if (!mounted) return;
          setState(() => _isListening = false);
        },
      );
      if (mounted) {
        setState(() => _speechEnabled = available);
      }
    } catch (_) {
      if (mounted) setState(() => _speechEnabled = false);
    }
  }

  Future<void> _toggleSpeechToText() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission required.')),
        );
        return;
      }
    }

    _speechSeedText = messageTextEditingController.text.trim();

    await _speech.listen(
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        if (!mounted) return;
        final spokenText = result.recognizedWords.trim();
        final merged = [
          _speechSeedText,
          spokenText,
        ].where((e) => e.isNotEmpty).join(' ');
        messageTextEditingController.text = merged;
        messageTextEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageTextEditingController.text.length),
        );
        if (!_messageFocusNode.hasFocus) {
          _messageFocusNode.requestFocus();
        }
      },
    );
    if (mounted) setState(() => _isListening = true);
  }

  Future<bool> _shareCurrentLocation() async {
    if (_isSendingLocation) return false;
    if (_userId.isEmpty || _receiverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat is loading. Please wait.')),
      );
      return false;
    }
    if (mounted) setState(() => _isSendingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude.toStringAsFixed(6);
      final lng = position.longitude.toStringAsFixed(6);
      final address =
          await _resolveAddress(position.latitude, position.longitude);
      final locationPayload = '$_locationPrefix$lat,$lng|$address';

      if (!mounted) return false;
      Provider.of<UserChatSocketProvider>(context, listen: false)
          .sendConversationMessage(
        senderId: _userId,
        senderName: _userName,
        senderImage: _userImage,
        receiverId: _receiverId,
        receiverName: _receiverName,
        receiverImage: (_receiverImage.startsWith('assets/') ||
                _receiverImage.startsWith('./assets/'))
            ? ''
            : _receiverImage,
        conversationId: _conversationId,
        message: locationPayload,
        senderModel: 'User',
        receiverModel: 'User',
        // Keep as normal message so backend persists it reliably.
        type: 'message',
      );
      debugPrint('[LocationSend] type=message payload=$locationPayload');
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share location: $e')),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSendingLocation = false);
    }
  }

  Future<String> _resolveAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return '$lat, $lng';
      final p = placemarks.first;
      final parts = <String>[
        p.name ?? '',
        p.subLocality ?? '',
        p.locality ?? '',
        p.administrativeArea ?? '',
        p.country ?? '',
      ].where((e) => e.trim().isNotEmpty).toList();
      final text = parts.join(', ').trim();
      return text.isEmpty ? '$lat, $lng' : text;
    } catch (_) {
      return '$lat, $lng';
    }
  }

  Future<void> _sendPickedMedia(List<Map<String, String>> picked) async {
    if (!mounted || _userId.isEmpty || _receiverId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat is loading. Please wait.')),
      );
      return;
    }

    final uploadPaths = <String>[];
    for (final item in picked) {
      final filePath = (item['file'] ?? '').trim();
      if (filePath.isNotEmpty) uploadPaths.add(filePath);

      final isVideo = (item['type'] ?? '').toLowerCase() == 'video';
      if (isVideo) {
        final thumbnailPath = (item['thumbnail'] ?? '').trim();
        if (thumbnailPath.isNotEmpty) {
          uploadPaths.add(thumbnailPath);
        }
      }
    }

    if (uploadPaths.isEmpty) return;

    final bool containsVideo = picked.any(
      (item) => (item['type'] ?? '').toLowerCase().trim() == 'video',
    );
    final String pendingId = 'pending_${DateTime.now().microsecondsSinceEpoch}';
    final Map<String, dynamic> pendingMessage = <String, dynamic>{
      '_id': pendingId,
      'sender_id': _userId,
      'receiver_id': _receiverId,
      'conversation_id': _conversationId,
      'type': containsVideo ? 'video' : 'image',
      'message': '',
      'files': uploadPaths,
      '__pending': true,
      '__failed': false,
    };

    setState(() {
      _isUploadingMedia = true;
      _pendingMediaMessages.add(pendingMessage);
    });

    await _uploadPendingMediaById(pendingId);
  }

  Future<void> _uploadPendingMediaById(String pendingId) async {
    if (!mounted) return;
    final idx = _pendingMediaMessages.indexWhere((m) => m['_id'] == pendingId);
    if (idx == -1) return;

    final pending = _pendingMediaMessages[idx];
    final paths = (pending['files'] is List)
        ? List<String>.from(
            (pending['files'] as List).map((e) => e?.toString() ?? ''))
        : <String>[];

    if (paths.isEmpty) return;

    setState(() {
      _isUploadingMedia = true;
      _pendingMediaMessages[idx]['__pending'] = true;
      _pendingMediaMessages[idx]['__failed'] = false;
    });

    final success = await Provider.of<UserChatSocketProvider>(
      context,
      listen: false,
    ).sendConversationMediaMessage(
      senderId: _userId,
      senderName: _userName,
      senderImage: _userImage,
      receiverId: _receiverId,
      receiverName: _receiverName,
      receiverImage: (_receiverImage.startsWith('assets/') ||
              _receiverImage.startsWith('./assets/'))
          ? ''
          : _receiverImage,
      conversationId: _conversationId,
      localFilePaths: paths,
      senderModel: 'User',
      receiverModel: 'User',
    );

    if (!mounted) return;

    final currentIdx =
        _pendingMediaMessages.indexWhere((m) => m['_id'] == pendingId);
    if (currentIdx == -1) {
      _isUploadingMedia = false;
      return;
    }

    setState(() {
      _isUploadingMedia = false;
      if (success) {
        _pendingMediaMessages.removeAt(currentIdx);
      } else {
        _pendingMediaMessages[currentIdx]['__pending'] = false;
        _pendingMediaMessages[currentIdx]['__failed'] = true;
      }
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload failed. Tap retry on media preview.'),
        ),
      );
    }
  }

  Future<void> _pickFromCameraAndSend() async {
    if (_isUploadingMedia) return;
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (!mounted || picked == null) return;
      await _sendPickedMedia([
        <String, String>{
          'type': 'image',
          'file': picked.path,
          'thumbnail': '',
        }
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open camera: $e')),
      );
    }
  }

  Future<void> _pickGalleryImagesAndSend() async {
    if (_isUploadingMedia) return;
    try {
      final List<XFile> pickedList =
          await ImagePicker().pickMultiImage(imageQuality: 100);
      if (!mounted || pickedList.isEmpty) return;

      await _sendPickedMedia(
        pickedList
            .map((f) => <String, String>{
                  'type': 'image',
                  'file': f.path,
                  'thumbnail': '',
                })
            .toList(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images: $e')),
      );
    }
  }

  Future<void> _pickGalleryVideoAndSend() async {
    if (_isUploadingMedia) return;
    try {
      final XFile? pickedVideo = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 30),
      );
      if (!mounted || pickedVideo == null) return;

      final thumbnailPath =
          await MediaPickerHelper.generateThumbnail(pickedVideo.path);

      await _sendPickedMedia([
        <String, String>{
          'type': 'video',
          'file': pickedVideo.path,
          'thumbnail': thumbnailPath ?? '',
        }
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick video: $e')),
      );
    }
  }

  // -----------------------------------------------------------------
  // Image helper
  // -----------------------------------------------------------------
  String _raw(dynamic value) => (value ?? '').toString().trim();

  ImageProvider _chatAvatar(dynamic value) {
    final raw = _raw(value);
    if (raw.isEmpty || raw == 'null') {
      return const AssetImage(AppImage.placeHolder2Icon);
    }
    final normalized = raw.replaceFirst(RegExp(r'^\./'), '');
    if (normalized.startsWith('assets/')) return AssetImage(normalized);
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return NetworkImage(normalized);
    }
    return NetworkImage('${AppConfigProvider.imageUrl}$normalized');
  }

  String _messageText(Map<String, dynamic> message) =>
      (message['message'] ?? '').toString();

  List<String> _messageFiles(Map<String, dynamic> message) {
    final dynamic files = message['files'];
    if (files is! List) return const [];

    final values = files
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    if (values.isEmpty) return const [];

    final type = (message['type'] ?? message['message_type'] ?? '')
        .toString()
        .toLowerCase()
        .trim();
    if (type == 'video') {
      final imageLike = values.where(_isImageFile).toList();
      if (imageLike.isNotEmpty) return imageLike;
    }

    return values;
  }

  String _fileUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (File(value).existsSync()) {
      return value;
    }
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

  Map<String, double>? _extractLocation(Map<String, dynamic> message) {
    final type = (message['type'] ?? message['message_type'] ?? '')
        .toString()
        .toLowerCase()
        .trim();
    final payload = (message['message'] ?? '').toString().trim();
    if (payload.isEmpty) return null;
    final looksLikeCoordinates =
        RegExp(r'^\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?').hasMatch(payload);
    final looksLikeLocationMessage = type == 'location' ||
        payload.startsWith(_locationPrefix) ||
        looksLikeCoordinates;
    if (!looksLikeLocationMessage) return null;
    final normalizedPayload = payload.startsWith(_locationPrefix)
        ? payload.substring(_locationPrefix.length).trim()
        : payload;
    final locationPart = normalizedPayload.split('|').first.trim();
    final parts = locationPart.split(',');
    if (parts.length < 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return <String, double>{'lat': lat, 'lng': lng};
  }

  String _extractLocationAddress(Map<String, dynamic> message) {
    final payload = (message['message'] ?? '').toString().trim();
    if (payload.isEmpty) return '';
    final normalizedPayload = payload.startsWith(_locationPrefix)
        ? payload.substring(_locationPrefix.length).trim()
        : payload;
    final parts = normalizedPayload.split('|');
    if (parts.length < 2) return '';
    return parts.sublist(1).join('|').trim();
  }

  Widget _buildMapPreview(double lat, double lng) {
    final target = LatLng(lat, lng);
    return GoogleMap(
      key: ValueKey('mini_map_${lat}_$lng'),
      initialCameraPosition: CameraPosition(target: target, zoom: 15.5),
      markers: <Marker>{
        Marker(markerId: const MarkerId('loc_pin'), position: target),
      },
      mapType: MapType.normal,
      liteModeEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      zoomGesturesEnabled: false,
    );
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open Google Maps.')),
      );
    }
  }

  Widget _buildLocationMessage(
    BuildContext context,
    bool mine,
    Size size, {
    required double lat,
    required double lng,
    required String address,
  }) {
    return GestureDetector(
      onTap: () => _openInGoogleMaps(lat, lng),
      child: Container(
        width: size.width * 65 / 100,
        margin: EdgeInsets.only(bottom: size.height * 0.8 / 100),
        decoration: BoxDecoration(
          color: mine ? AppColor.buttonColor : AppColor.washpressColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 16 / 100,
              width: double.infinity,
              child: _buildMapPreview(lat, lng),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.isNotEmpty ? address : '$lat, $lng',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.secondryColor(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFont.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Open in Google Maps',
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    final bool isVideoMessage =
        ((message['type'] ?? message['message_type'] ?? '')
                .toString()
                .toLowerCase()
                .trim() ==
            'video');

    Widget tile(String filePath, {int index = 0, int extraCount = 0}) {
      final url = _fileUrl(filePath);
      final isVideo = isVideoMessage || _isVideoFile(filePath);
      final isPending = message['__pending'] == true;
      final isFailed = message['__failed'] == true;
      final pendingId = (message['_id'] ?? '').toString();
      return GestureDetector(
        onTap: isFailed
            ? () => _uploadPendingMediaById(pendingId)
            : () => _openMediaPreviewFromMessage(message, tappedIndex: index),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url.startsWith('http://') || url.startsWith('https://'))
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black26,
                  child: const Icon(Icons.broken_image, color: Colors.white70),
                ),
              )
            else if (File(url).existsSync())
              Image.file(
                File(url),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black26,
                  child: const Icon(Icons.broken_image, color: Colors.white70),
                ),
              )
            else
              Container(
                color: Colors.black26,
                child: const Icon(Icons.broken_image, color: Colors.white70),
              ),
            if (isVideo)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 26),
                ),
              ),
            if (extraCount > 0)
              Container(
                color: Colors.black.withOpacity(0.45),
                alignment: Alignment.center,
                child: Text(
                  '+$extraCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (isPending)
              Container(
                color: Colors.black.withOpacity(0.38),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Uploading...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (isFailed)
              Container(
                color: Colors.black.withOpacity(0.45),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 26),
                    const SizedBox(height: 8),
                    const Text(
                      'Failed',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    Widget gridBody;
    if (visibleCount == 1) {
      gridBody = tile(visible[0], index: 0);
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
              child: tile(
                visible[3],
                index: 3,
                extraCount: total > 4 ? total - 4 : 0,
              ),
            ),
          ]),
        ),
      ]);
    }

    return Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.only(bottom: size.height * 0.8 / 100),
      decoration: BoxDecoration(
        color: mine ? AppColor.buttonColor : const Color(0xff262626),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.hardEdge,
      child: gridBody,
    );
  }

  // ------------------------------------------------------------------
  //                            BUILD
  // ------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor(context),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => true,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() => isContainerVisible = false);
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                systemNavigationBarColor: Color(0xff000000),
                systemNavigationBarIconBrightness: Brightness.light,
                statusBarColor: Color(0xff000000),
                statusBarIconBrightness: Brightness.light,
              ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  width: size.width,
                  height: size.height,
                  color: AppColor.primaryColor(context),
                  child: Column(
                    children: [
                      // -- Top bar --
                      Container(
                        width: size.width,
                        height: size.height * 9 / 100,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: size.width * 10 / 100,
                                width: size.width * 12 / 100,
                                color: AppColor.transparentColor,
                                alignment: Alignment.center,
                                child: Image.asset(AppImage.backArrowIcon,
                                    fit: BoxFit.cover,
                                    height: size.width * 5 / 100,
                                    width: size.width * 5 / 100,
                                    color: AppColor.secondryColor(context)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: const LikedMemberDetail(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: size.width * 60 / 100,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: size.width * 10 / 100,
                                      height: size.width * 10 / 100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        image: DecorationImage(
                                          image: _chatAvatar(widget.image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: size.width * 2 / 100),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: size.width * 45 / 100,
                                          child: Text(widget.name,
                                              style: TextStyle(
                                                  color: AppColor.secondryColor(
                                                      context),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      AppFont.fontFamily)),
                                        ),
                                        Text(
                                            AppLanguage.activeTwominuteAgotext[
                                                language],
                                            style: TextStyle(
                                                height: 1,
                                                color: AppColor.textcolor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    AppFont.fontFamily)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 15 / 100),
                            GestureDetector(
                              onTap: () => reportBottomSheet(context),
                              child: Image.asset(AppImage.threedotIcon,
                                  color: AppColor.secondryColor(context)),
                            ),
                            SizedBox(width: size.width * 0.5 / 100),
                          ],
                        ),
                      ),

                      // -- Message list --
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          reverse: true,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 1 / 100),
                              _isBootstrapping
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: CircularProgressIndicator(
                                          color: AppColor.buttonColor),
                                    )
                                  : Consumer<UserChatSocketProvider>(
                                      builder: (context, socketProvider, _) {
                                        final visibleMessages = socketProvider
                                            .messages
                                            .where(
                                                _belongsToCurrentConversation)
                                            .toList();
                                        final allVisibleMessages =
                                            <Map<String, dynamic>>[
                                          ...visibleMessages,
                                          ..._pendingMediaMessages,
                                        ];
                                        _maybeAutoScroll(
                                            allVisibleMessages.length);

                                        if (allVisibleMessages.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return Wrap(
                                          runSpacing: 2.0,
                                          children: List.generate(
                                              allVisibleMessages.length,
                                              (index) {
                                            final message =
                                                allVisibleMessages[index];
                                            final mine = _isMine(message);
                                            final text = _messageText(message);
                                            final hasMedia =
                                                _messageFiles(message)
                                                    .isNotEmpty;
                                            final location =
                                                _extractLocation(message);
                                            final locationAddress =
                                                _extractLocationAddress(
                                                    message);
                                            final hasLocation =
                                                location != null;
                                            final showText =
                                                text.trim().isNotEmpty &&
                                                    !hasLocation;
                                            if (!showText &&
                                                !hasMedia &&
                                                !hasLocation) {
                                              return const SizedBox.shrink();
                                            }

                                            return SizedBox(
                                              width: size.width * 92 / 100,
                                              child: Column(
                                                crossAxisAlignment: mine
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: mine
                                                        ? MainAxisAlignment.end
                                                        : MainAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (!mine)
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                type: PageTransitionType
                                                                    .rightToLeftWithFade,
                                                                child:
                                                                    const LikedMemberDetail(),
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: size.width *
                                                                10 /
                                                                100,
                                                            height: size.width *
                                                                10 /
                                                                100,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              image:
                                                                  DecorationImage(
                                                                image: _chatAvatar(
                                                                    widget
                                                                        .image),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      if (!mine)
                                                        SizedBox(
                                                            width: size.width *
                                                                2 /
                                                                100),
                                                      Column(
                                                        crossAxisAlignment: mine
                                                            ? CrossAxisAlignment
                                                                .end
                                                            : CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          if (hasLocation)
                                                            _buildLocationMessage(
                                                              context,
                                                              mine,
                                                              size,
                                                              lat: location[
                                                                  'lat']!,
                                                              lng: location[
                                                                  'lng']!,
                                                              address:
                                                                  locationAddress,
                                                            ),
                                                          if (hasMedia)
                                                            _buildMediaMessage(
                                                              context,
                                                              message,
                                                              mine,
                                                              size,
                                                            ),
                                                          if (showText)
                                                            Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxWidth:
                                                                    size.width *
                                                                        65 /
                                                                        100,
                                                              ),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                vertical:
                                                                    size.height *
                                                                        1.5 /
                                                                        100,
                                                                horizontal:
                                                                    size.width *
                                                                        3 /
                                                                        100,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: !mine
                                                                    ? AppColor
                                                                        .washpressColor
                                                                    : AppColor
                                                                        .buttonColor,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.2),
                                                                    blurRadius:
                                                                        10,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: mine
                                                                      ? const Radius
                                                                          .circular(
                                                                          25)
                                                                      : const Radius
                                                                          .circular(
                                                                          0),
                                                                  topRight: mine
                                                                      ? const Radius
                                                                          .circular(
                                                                          0)
                                                                      : const Radius
                                                                          .circular(
                                                                          25),
                                                                  bottomLeft:
                                                                      const Radius
                                                                          .circular(
                                                                          25),
                                                                  bottomRight:
                                                                      const Radius
                                                                          .circular(
                                                                          25),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                text,
                                                                style: TextStyle(
                                                                    color: AppColor
                                                                        .secondryColor(
                                                                            context),
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                    ),
                              SizedBox(height: size.height * 4 / 100),

                              // -- Event card --
                              SlideTransition(
                                position: _offsetAnimation,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: size.width * 90 / 100,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.asset(
                                              AppImage.msgCardicon,
                                              fit: BoxFit.cover,
                                              width: size.width * 0.70,
                                              height: size.height * 0.40),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: size.width * 24 / 100,
                                      right: 0,
                                      bottom: size.height * 2 / 100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Bass Drop Fridays',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 18)),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            Icon(Icons.schedule,
                                                color: AppColor.buttonColor,
                                                size: 16),
                                            const SizedBox(width: 6),
                                            Text('Fri, 10 PM ? 4 AM',
                                                style: TextStyle(
                                                    color: AppColor.buttonColor,
                                                    fontSize: 14)),
                                          ]),
                                          const SizedBox(height: 4),
                                          const Row(children: [
                                            Icon(Icons.location_on,
                                                color: Colors.white, size: 16),
                                            SizedBox(width: 6),
                                            Text('Club Neon, Downtown ? 2.3 km',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14)),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 1 / 100),

                              // -- Accept / Reject --
                              SlideTransition(
                                position: _offsetAnimation,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: size.width * 90 / 100,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => isApproved = true),
                                          child: Container(
                                            width: size.width * 0.70,
                                            height: size.height * 0.06,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: isApproved
                                                  ? AppColor.greenColor1
                                                  : AppColor.statusbar,
                                            ),
                                            child: Center(
                                              child: Text(
                                                  isApproved
                                                      ? 'Approved'
                                                      : 'Accept',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      width: size.width * 90 / 100,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: size.width * 0.70,
                                          height: size.height * 0.06,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.grey.shade900,
                                          ),
                                          child: const Center(
                                            child: Text('Reject',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // -- Input bar --
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 2 / 100),
                            SizedBox(
                              width: size.width * 90 / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4))
                                  ],
                                ),
                                child: SizedBox(
                                  width: size.width * 90 / 100,
                                  height: size.height * 7 / 100,
                                  child: TextFormField(
                                    cursorColor:
                                        AppColor.secondryColor(context),
                                    style: TextStyle(
                                        height: 1,
                                        color: AppColor.secondryColor(context)),
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.send,
                                    maxLength: AppConstant.describeLength,
                                    focusNode: _messageFocusNode,
                                    controller: messageTextEditingController,
                                    onFieldSubmitted: (_) => _sendMessage(),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      suffixIconConstraints: BoxConstraints(
                                          maxWidth: size.width * 30 / 100),
                                      prefixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 9.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: GestureDetector(
                                                onTap: _pickFromCameraAndSend,
                                                child: Container(
                                                  height: size.height * 0.04,
                                                  width: size.height * 0.04,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColor
                                                              .buttonColor,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: Center(
                                                    child: _isUploadingMedia
                                                        ? SizedBox(
                                                            width: size.height *
                                                                0.018,
                                                            height:
                                                                size.height *
                                                                    0.018,
                                                            child:
                                                                const CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        : Image.asset(
                                                            AppImage.cameraIcon,
                                                            fit: BoxFit.contain,
                                                            height:
                                                                size.height *
                                                                    0.026),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: _sendMessage,
                                              child: Image.asset(
                                                  AppImage.shareImg,
                                                  height: size.width * 6 / 100,
                                                  width: size.width * 6 / 100,
                                                  color: AppColor.secondryColor(
                                                          context)
                                                      .withOpacity(0.5)),
                                            ),
                                            SizedBox(
                                                width: size.width * 1 / 100),
                                            GestureDetector(
                                              onTap: _toggleSpeechToText,
                                              child: Image.asset(
                                                AppImage.microphone,
                                                height: size.width * 6 / 100,
                                                width: size.width * 6 / 100,
                                                color: _isListening
                                                    ? AppColor.buttonColor
                                                    : AppColor.secondryColor(
                                                            context)
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                            SizedBox(
                                                width: size.width * 2 / 100),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isBottomSheetOpen =
                                                      !isBottomSheetOpen;
                                                });
                                                if (isBottomSheetOpen) {
                                                  plusiconsBottomSheet(context)
                                                      .whenComplete(() {
                                                    setState(() =>
                                                        isBottomSheetOpen =
                                                            false);
                                                  });
                                                }
                                              },
                                              child: Image.asset(
                                                  AppImage.plusIcon,
                                                  height: size.width * 6 / 100,
                                                  width: size.width * 6 / 100,
                                                  color: AppColor.secondryColor(
                                                          context)
                                                      .withOpacity(0.5)),
                                            ),
                                            SizedBox(
                                                width: size.width * 3 / 100),
                                          ],
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.washpressColor),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40))),
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.washpressColor),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40))),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColor.washpressColor),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40))),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 16, horizontal: 15),
                                      fillColor: AppColor.washpressColor,
                                      filled: true,
                                      counterText: '',
                                      hintText:
                                          AppLanguage.messageText[language],
                                      hintStyle: const TextStyle(
                                          color: AppColor.textcolor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 1 / 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Bottom sheets --
  Future<void> plusiconsBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            height: MediaQuery.of(context).size.height * 28 / 100,
            width: MediaQuery.of(context).size.width * 90 / 100,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 32 / 100,
                  height: MediaQuery.of(context).size.height * 18 / 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColor.washpressColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickGalleryVideoAndSend();
                        },
                        child: Row(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 10 / 100,
                            child: Image.asset(AppImage.vedioIcon,
                                width:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                color: AppColor.secondryColor(context)),
                          ),
                          Text(AppLanguage.videoText[language],
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: AppColor.secondryColor(context),
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400)),
                        ]),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          await _pickGalleryImagesAndSend();
                        },
                        child: Row(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 10 / 100,
                            child: Image.asset(AppImage.galleryIcon,
                                width:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                color: AppColor.secondryColor(context)),
                          ),
                          Text(AppLanguage.galleryText[language],
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: AppColor.secondryColor(context),
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400)),
                        ]),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      Row(children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 10 / 100,
                          child: Image.asset(AppImage.eventIcon,
                              width:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              color: AppColor.secondryColor(context)),
                        ),
                        Text(AppLanguage.eventsText[language],
                            style: TextStyle(
                                fontSize: 15,
                                decoration: TextDecoration.none,
                                color: AppColor.secondryColor(context),
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w400)),
                      ]),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      InkWell(
                        onTap: () async {
                          final sent = await _shareCurrentLocation();
                          if (sent && mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Row(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 10 / 100,
                            child: _isSendingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColor.buttonColor,
                                    ),
                                  )
                                : Image.asset(AppImage.locationBlackicon,
                                    width: MediaQuery.of(context).size.width *
                                        5 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        5 /
                                        100,
                                    color: AppColor.secondryColor(context)),
                          ),
                          Text(
                              _isSendingLocation
                                  ? 'Sharing location...'
                                  : AppLanguage.locationText[language],
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: AppColor.secondryColor(context),
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> reportBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 10 / 100,
                    right: MediaQuery.of(context).size.width * 5 / 100,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width * 40 / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColor.washpressColor,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text('Block User',
                                    style: TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.none,
                                        color: AppColor.secondryColor(context),
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text('Unmatch',
                                    style: TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.none,
                                        color: AppColor.secondryColor(context),
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text('Report',
                                    style: TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.none,
                                        color: AppColor.secondryColor(context),
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
