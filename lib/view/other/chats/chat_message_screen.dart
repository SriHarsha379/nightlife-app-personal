import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import '../../../commonWidget/invite_members_type_bottomsheet.dart';
import '../../../../controller/members/conversion_list_controller.dart';
import '../../../../helper/ImagePreviewScreen.dart';
import '../../../../provider/common_api_helper.dart';
import '../../../../provider/post_api_provider.dart';
import '../../../../provider/user_chat_socket_provider.dart';
import '../../../../provider/user_controller.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_footer.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../../../../utilities/media_picker_helper.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_snack_bar_toast_message.dart';
import '../MySplashSection/EventSection/Liked/Liked_event_details.dart';
import '../MySplashSection/MembersSection/member_liked_details.dart';
import '../MySplashSection/VenuesSection/venuepages.dart';

class ChatMessageScreen extends StatefulWidget {
  static String routeName = "./ChatMessageScreen";
  final String name;
  final dynamic image;
  final String? receiverId;
  final String? conversationId;
  final String userType;
  final Map<String, dynamic>? sharedEventData;
  final bool autoSendSharedEvent;

  const ChatMessageScreen({
    super.key,
    required this.name,
    required this.image,
    this.receiverId,
    this.conversationId,
    this.userType = 'User',
    this.sharedEventData,
    this.autoSendSharedEvent = false,
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
  bool _showSpeechOverlay = false;
  String _speechSeedText = '';
  String _speechLiveText = '';
  final List<Map<String, dynamic>> _pendingMediaMessages = [];

  String _userId = '';
  String _userName = '';
  String _userImage = '';
  String _receiverId = '';
  String _receiverName = '';
  String _receiverImage = '';
  String _conversationId = '';
  Timer? _userStatusPollTimer;
  Timer? _conversationRefreshTimer;
  DateTime? _lastUserStatusEmitAt;
  bool _blockedByMe = false;
  bool _unfriendByMe = false;
  bool _reportStatus = false;
  bool _isMyFirendStatus = false;

  String _relationStatusLoadedForUserId = '';
  bool _relationStatusLoading = false;
  Map<String, dynamic>? _pendingSharedEvent;
  bool _sharedEventAutoSent = false;
  bool _shareConversationLookupInFlight = false;
  bool _autoShareInProgress = false;
  bool _lastSocketConnected = false;
  bool _conversationUnlocked = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[ChatMessageScreen] build version => GOOGLE_MAP_PREVIEW_V2');
    _receiverId = _raw(widget.receiverId);
    _conversationId = _raw(widget.conversationId);
    _receiverName = widget.name.trim();
    _receiverImage = _raw(widget.image);
    _pendingSharedEvent = _normalizeSharedEventData(widget.sharedEventData);

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
    _userStatusPollTimer?.cancel();
    _conversationRefreshTimer?.cancel();
    _markConversationAsReadOnExit();
    _clearLocalChatCache();

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

  void _markConversationAsReadOnExit() {
    if (_socketProvider == null) return;
    if (_conversationId.trim().isEmpty) return;
    _socketProvider!.markConversationSeenLocal(conversationId: _conversationId);
    if (_userId.trim().isEmpty) return;
    _socketProvider!.getConversationList(userId: _userId, page: 1, limit: 50);
  }

  void _clearLocalChatCache() {
    _pendingMediaMessages.clear();
    _socketProvider?.clearLocalMessages();
  }

  // -----------------------------------------------------------------
  // Bootstrap
  // -----------------------------------------------------------------
  Future<void> _bootstrapChat() async {
    _clearLocalChatCache();
    await _loadUserFromController();
    if (!mounted) return;

    await _socketProvider?.initSocket(AppConstant.token);
    if (!mounted) return;

    if (_userId.isNotEmpty) {
      final hasDirectContext =
          _conversationId.isNotEmpty && _receiverId.isNotEmpty;
      if (!hasDirectContext && _receiverId.isEmpty) {
        _requestConversationList();
      } else {
        _joinConversationIfReady();
      }
      _loadRelationStatusIfNeeded();
      _emitUserStatusIfNeeded(force: true);
      _startUserStatusPolling();
    }

    if (mounted) setState(() => _isBootstrapping = false);
    _tryAutoSendSharedEvent();
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

    final isConnected = _socketProvider!.isConnected;
    final didReconnect = !_lastSocketConnected && isConnected;
    _lastSocketConnected = isConnected;

    if (!isConnected) {
      _conversationRequested = false;
      _joined = false;
      _userStatusPollTimer?.cancel();
      _userStatusPollTimer = null;
      return;
    }

    final previousConversationId = _conversationId;
    final hasDirectContext =
        _conversationId.isNotEmpty && _receiverId.isNotEmpty;

    if (!hasDirectContext && _receiverId.isEmpty) {
      _requestConversationList();
    }

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
    _loadRelationStatusIfNeeded();
    _emitUserStatusIfNeeded();
    _startUserStatusPolling();
    if (_hasApprovedRequest(
      _socketProvider!.messages.where(_belongsToCurrentConversation).toList(),
    )) {
      _conversationUnlocked = true;
    }

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

    _syncConversationCache();
    _joinConversationIfReady();
    if (didReconnect) {
      _tryAutoSendSharedEvent();
    }
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

  Future<void> _tryAutoSendSharedEvent({bool force = false}) async {
    if (!mounted) return;
    if (_socketProvider == null || !_socketProvider!.isConnected) return;
    if (!widget.autoSendSharedEvent && !force) return;
    if (_sharedEventAutoSent) return;
    if (_autoShareInProgress) return;
    if (_pendingSharedEvent == null) return;
    if (_userId.isEmpty || _receiverId.isEmpty) return;
    if (_shareConversationLookupInFlight) return;

    _autoShareInProgress = true;
    try {
      final pendingEvent = _pendingSharedEvent;
      if (pendingEvent == null) return;

      _sharedEventAutoSent = true;
      if (mounted) {
        setState(() {
          _pendingSharedEvent = null;
          isApproved = false;
        });
      }

      bool requiresApproval = _conversationId.isEmpty;
      if (_conversationId.isEmpty) {
        _shareConversationLookupInFlight = true;
        try {
          final conversionController =
              Provider.of<ConversionListController>(context, listen: false);
          final resolvedConversationId =
              await conversionController.fetchConversationIdByUserId(
            otherUserId: _receiverId,
          );
          if (!mounted) return;
          if (resolvedConversationId.isNotEmpty) {
            _conversationId = resolvedConversationId;
            requiresApproval = false;
            _joined = false;
            _joinConversationIfReady();
          }
        } finally {
          _shareConversationLookupInFlight = false;
        }
      }

      final eventObject = Map<String, dynamic>.from(pendingEvent);
      eventObject['requires_approval'] = requiresApproval;
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
        message: '',
        senderModel: 'User',
        receiverModel: 'User',
        isEvent: true,
        approveEvent: false,
        rejectEvent: false,
        requiresApproval: requiresApproval,
        eventObject: eventObject,
      );
      _refreshConversationListAfterSend();
    } catch (_) {
      _sharedEventAutoSent = false;
      if (mounted && _pendingSharedEvent == null) {
        setState(() {
          _pendingSharedEvent = widget.sharedEventData == null
              ? null
              : _normalizeSharedEventData(widget.sharedEventData);
        });
      }
      rethrow;
    } finally {
      _autoShareInProgress = false;
    }
  }

  Future<void> _shareSelectedChatEntity() async {
    final sharedItem = await showInviteMembersTypeBottomSheet(
      context,
      receiverId: _receiverId,
      receiverName: _receiverName,
      receiverImage: _receiverImage,
      conversationId: _conversationId.isEmpty ? null : _conversationId,
      returnSelectionOnly: true,
    );
    if (!mounted || sharedItem == null || sharedItem.isEmpty) return;

    final normalized = _normalizeSharedEventData(sharedItem);
    if (normalized == null) return;

    setState(() {
      _pendingSharedEvent = normalized;
      _sharedEventAutoSent = false;
      isApproved = false;
    });
    await _tryAutoSendSharedEvent(force: true);
  }

  void _startUserStatusPolling() {
    if (_userStatusPollTimer != null) return;
    if (_userId.isEmpty || _receiverId.isEmpty) return;
    _userStatusPollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _emitUserStatusIfNeeded();
    });
  }

  void _emitUserStatusIfNeeded({bool force = false}) {
    if (!mounted || _socketProvider == null) return;
    if (_userId.isEmpty || _receiverId.isEmpty) return;
    if (_blockedByMe) return;
    if (!_socketProvider!.isConnected) return;
    final now = DateTime.now();
    if (!force &&
        _lastUserStatusEmitAt != null &&
        now.difference(_lastUserStatusEmitAt!).inSeconds < 4) {
      return;
    }
    final sent = _socketProvider!
        .emitUserStatus(userId: _userId, checkUserId: _receiverId);
    if (sent) {
      _lastUserStatusEmitAt = now;
    }
  }

  DateTime? _messageDateTime(Map<String, dynamic> message) {
    final updated = _raw(message['updatedAt']);
    final created = _raw(message['createdAt']);
    if (updated.isNotEmpty) return DateTime.tryParse(updated)?.toLocal();
    if (created.isNotEmpty) return DateTime.tryParse(created)?.toLocal();
    return null;
  }

  String _presenceSubtitle(UserChatSocketProvider socketProvider) {
    final isOnline = socketProvider.checkedUserId == _receiverId &&
        socketProvider.isCheckedUserOnline == true;
    if (isOnline) return 'Online';

    final messages = socketProvider.messages
        .where(_belongsToCurrentConversation)
        .toList(growable: false);
    DateTime? lastAt;
    for (final msg in messages) {
      final dt = _messageDateTime(msg);
      if (dt == null) continue;
      if (lastAt == null || dt.isAfter(lastAt)) {
        lastAt = dt;
      }
    }
    if (lastAt == null) {
      final item = _resolveUserConversation(socketProvider.conversationList);
      if (item != null) {
        final updated = _raw(item['updatedAt']);
        final created = _raw(item['createdAt']);
        lastAt = DateTime.tryParse(updated)?.toLocal() ??
            DateTime.tryParse(created)?.toLocal();
      }
    }
    if (lastAt == null) return 'Offline';

    final diff = DateTime.now().difference(lastAt);
    if (diff.inMinutes < 1) return 'Active now';
    if (diff.inMinutes < 60) return 'Active ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Active ${diff.inHours} hr ago';
    return 'Active ${diff.inDays} day ago';
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

  bool _flagBool(dynamic value) {
    if (value is bool) return value;
    final raw = _raw(value).toLowerCase();
    return raw == 'true' || raw == '1';
  }

  bool _requiresApproval(Map<String, dynamic> message) {
    if (_flagBool(message['requires_approval'])) return true;
    final eventObject = message['event_object'];
    if (eventObject is Map) {
      return _flagBool(eventObject['requires_approval']);
    }
    return false;
  }

  bool _isApprovedEvent(Map<String, dynamic> message) =>
      _flagBool(message['approve_event']);

  bool _isRejectedEvent(Map<String, dynamic> message) =>
      _flagBool(message['reject_event']);

  bool _hasEstablishedChatHistory(List<Map<String, dynamic>> messages) {
    return messages.any((message) {
      if (_eventObjectForMessage(message) != null) return false;
      if (_messageText(message).trim().isNotEmpty) return true;
      if (_messageFiles(message).isNotEmpty) return true;
      return _extractLocation(message) != null;
    });
  }

  bool _hasApprovedRequest(List<Map<String, dynamic>> messages) {
    if (_conversationUnlocked || _isMyFirendStatus) return true;
    if (_hasEstablishedChatHistory(messages)) return true;
    return messages.any((message) {
      final eventObject = _eventObjectForMessage(message);
      return eventObject != null && _isApprovedEvent(message);
    });
  }

  bool _isApprovalFlowActive(List<Map<String, dynamic>> messages) {
    if (_hasApprovedRequest(messages)) return false;
    return messages.any((message) {
      final eventObject = _eventObjectForMessage(message);
      return eventObject != null && _requiresApproval(message);
    });
  }

  String _firstNonEmptyRaw(List<dynamic> values) {
    for (final value in values) {
      final resolved = _raw(value);
      if (resolved.isNotEmpty) return resolved;
    }
    return '';
  }

  Map<String, dynamic>? _normalizeSharedEventData(
    Map<String, dynamic>? source,
  ) {
    if (source == null || source.isEmpty) return null;

    final normalizedType = _firstNonEmptyRaw(<dynamic>[
      source['type'],
      source['entity_type'],
    ]).toLowerCase();
    final bool isVenue;
    if (normalizedType == 'venue') {
      isVenue = true;
    } else if (normalizedType == 'event') {
      isVenue = false;
    } else {
      isVenue = _raw(source['venue_name']).isNotEmpty ||
          _raw(source['timing']).isNotEmpty ||
          _raw(source['venue_time']).isNotEmpty;
    }
    final type = isVenue ? 'venue' : 'event';

    final resolvedId = _firstNonEmptyRaw(<dynamic>[
      source['_id'],
      source['id'],
      source[type == 'venue' ? 'venue_id' : 'event_id'],
    ]);
    final name = _firstNonEmptyRaw(<dynamic>[
      source[type == 'venue' ? 'venue_name' : 'event_name'],
      source['name'],
      source['title'],
    ]);
    final image = _firstNonEmptyRaw(<dynamic>[
      source[type == 'venue' ? 'venue_image' : 'event_image'],
      source['image'],
      source['profile_image'],
    ]);
    final time = _firstNonEmptyRaw(<dynamic>[
      source['time'],
      source[type == 'venue' ? 'venue_time' : 'event_time'],
      source[type == 'venue' ? 'timing' : 'date'],
      source['event_date'],
    ]);
    final address = _firstNonEmptyRaw(<dynamic>[
      source['address'],
      source[type == 'venue' ? 'venue_address' : 'event_address'],
      source['location'],
      source['venue_location'],
    ]);
    final about = _firstNonEmptyRaw(<dynamic>[
      source['about'],
      source['description'],
    ]);
    final categories = source['categories'];

    if (resolvedId.isEmpty &&
        name.isEmpty &&
        image.isEmpty &&
        time.isEmpty &&
        address.isEmpty) {
      return null;
    }

    return <String, dynamic>{
      'type': type,
      'id': resolvedId,
      'name': name,
      'image': image,
      'time': time,
      'address': address,
      'entity_type': type,
      if (about.isNotEmpty) 'about': about,
      if (categories != null) 'categories': categories,
      if (type == 'venue') 'venue_id': resolvedId,
      if (type == 'venue') 'venue_name': name,
      if (type == 'venue') 'venue_image': image,
      if (type == 'venue') 'venue_time': time,
      if (type == 'venue') 'timing': time,
      if (type == 'venue') 'venue_address': address,
      if (type == 'event') 'event_id': resolvedId,
      if (type == 'event') 'event_name': name,
      if (type == 'event') 'event_image': image,
      if (type == 'event') 'event_time': time,
      if (type == 'event') 'date': time,
      if (type == 'event') 'event_address': address,
    };
  }

  Map<String, dynamic>? _eventObjectForMessage(Map<String, dynamic> message) {
    final rawObject = message['event_object'];
    if (rawObject is Map && rawObject.isNotEmpty) {
      return _normalizeSharedEventData(Map<String, dynamic>.from(rawObject));
    }
    if (_raw(rawObject).isEmpty) return null;
    final isEvent = message['is_event'] == true ||
        _raw(message['is_event']).toLowerCase() == 'true';
    if (!isEvent) return null;
    if (rawObject is Map) {
      return _normalizeSharedEventData(Map<String, dynamic>.from(rawObject));
    }
    return null;
  }

  String _messageRenderKey(Map<String, dynamic> message) {
    final eventObject = _eventObjectForMessage(message);
    final eventId = _firstNonEmptyRaw(<dynamic>[
      eventObject?['id'],
      eventObject?['event_id'],
      eventObject?['venue_id'],
    ]);

    final files = _messageFiles(message)
        .map((e) => _raw(e))
        .where((e) => e.isNotEmpty)
        .join(',');
    final normalizedConversationId = eventId.isNotEmpty
        ? ''
        : _raw(message['conversation_id'] ?? message['conversationId']);

    if (eventId.isNotEmpty) {
      return [
        'share',
        _extractId(message['sender_id'] ?? message['senderId']),
        _extractId(message['receiver_id'] ?? message['receiverId']),
        _raw(message['type']),
        files,
        eventId,
        _raw(message['date']),
        _raw(message['time']),
      ].join('|');
    }

    final id = _raw(message['_id']);
    if (id.isNotEmpty && !id.startsWith('tmp_')) {
      return 'id:$id';
    }

    return [
      _extractId(message['sender_id'] ?? message['senderId']),
      _extractId(message['receiver_id'] ?? message['receiverId']),
      normalizedConversationId,
      _raw(message['message']),
      _raw(message['type']),
      files,
      eventId,
    ].join('|');
  }

  List<Map<String, dynamic>> _dedupeVisibleMessages(
    List<Map<String, dynamic>> messages,
  ) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final message in messages) {
      final key = _messageRenderKey(message);
      if (key.isEmpty || seen.add(key)) {
        result.add(message);
      }
    }
    return result;
  }

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

  Map<String, dynamic>? _latestApprovalGateMessage(
    List<Map<String, dynamic>> messages,
  ) {
    final hasApprovedRequest = messages.any((message) {
      final eventObject = _eventObjectForMessage(message);
      return eventObject != null && _isApprovedEvent(message);
    });
    if (hasApprovedRequest) return null;

    for (final message in messages.reversed) {
      final eventObject = _eventObjectForMessage(message);
      if (eventObject != null && _requiresApproval(message)) return message;
    }
    return null;
  }

  // -----------------------------------------------------------------
  // Send message
  // -----------------------------------------------------------------
  void _sendMessage() {
    if (_blockedByMe) return;
    final text = messageTextEditingController.text.trim();
    final eventObject = _pendingSharedEvent != null
        ? Map<String, dynamic>.from(_pendingSharedEvent!)
        : null;
    if (text.isEmpty && eventObject == null) return;

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
      receiverModel: 'User',
      isEvent: eventObject != null,
      approveEvent: false,
      rejectEvent: false,
      requiresApproval: false,
      eventObject: eventObject,
    );
    _refreshConversationListAfterSend();

    messageTextEditingController.clear();
    if (_pendingSharedEvent != null) {
      setState(() {
        _pendingSharedEvent = null;
        isApproved = false;
      });
    }
    if (!_messageFocusNode.hasFocus) {
      _messageFocusNode.requestFocus();
    }
  }

  Future<void> _emitEventApprovalUpdate(
    Map<String, dynamic> message, {
    required bool isApprove,
  }) async {
    final messageId = _raw(message['_id']);
    if (messageId.isEmpty || _userId.isEmpty) return;
    final sent = Provider.of<UserChatSocketProvider>(context, listen: false)
        .emitEventUpdate(
      userId: _userId,
      messageId: messageId,
      isApprove: isApprove,
    );
    if (!sent) return;

    final socketProvider =
        Provider.of<UserChatSocketProvider>(context, listen: false);
    final index =
        socketProvider.messages.indexWhere((m) => _raw(m['_id']) == messageId);
    if (index != -1) {
      socketProvider.messages[index]['approve_event'] = isApprove;
      socketProvider.messages[index]['reject_event'] = !isApprove;
    }
    setState(() {
      if (isApprove) {
        _conversationUnlocked = true;
      }
    });
  }

  void _refreshConversationListAfterSend() {
    if (!mounted || _socketProvider == null || _userId.isEmpty) return;
    _conversationRefreshTimer?.cancel();
    _conversationRefreshTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || _socketProvider == null || _userId.isEmpty) return;
      if (!_socketProvider!.isConnected) return;
      _socketProvider!.getConversationList(userId: _userId, page: 1, limit: 50);
      if (_conversationId.isEmpty && _receiverId.isNotEmpty) {
        _resolveConversationAfterFirstSend();
      }
    });
  }

  Future<void> _resolveConversationAfterFirstSend() async {
    if (!mounted || _receiverId.isEmpty) return;
    final conversionController =
        Provider.of<ConversionListController>(context, listen: false);
    final resolvedConversationId =
        await conversionController.fetchConversationIdByUserId(
      otherUserId: _receiverId,
    );
    if (!mounted || resolvedConversationId.isEmpty) return;
    if (_conversationId == resolvedConversationId) return;
    setState(() {
      _conversationId = resolvedConversationId;
      _joined = false;
    });
    _syncConversationCache();
    _joinConversationIfReady();
    if (_socketProvider != null && _socketProvider!.isConnected) {
      _socketProvider!.getConversationList(userId: _userId, page: 1, limit: 50);
    }
  }

  void _openOtherUserProfile() {
    final memberId = _receiverId.trim().isNotEmpty
        ? _receiverId.trim()
        : _raw(widget.receiverId);
    if (memberId.isEmpty) return;
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: LikedMemberDetail(memberId: memberId),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _openSharedEntityDetail(Map<String, dynamic> eventObject) {
    final entityType = _raw(eventObject['type']).isNotEmpty
        ? _raw(eventObject['type']).toLowerCase()
        : _raw(eventObject['entity_type']).toLowerCase();
    final entityId = _raw(eventObject['id']).isNotEmpty
        ? _raw(eventObject['id'])
        : entityType == 'venue'
            ? _raw(eventObject['venue_id'])
            : _raw(eventObject['event_id']);

    if (entityId.isEmpty) return;

    final Widget destination = entityType == 'venue'
        ? VenuePages(venueId: entityId)
        : LikedEventDetail(eventId: entityId);

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: destination,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _syncConversationCache() {
    if (!mounted || _receiverId.isEmpty || _conversationId.isEmpty) return;
    Provider.of<ConversionListController>(context, listen: false)
        .cacheConversationId(
      otherUserId: _receiverId,
      conversationId: _conversationId,
    );
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
              _showSpeechOverlay = false;
            });
          }
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _isListening = false;
            _showSpeechOverlay = false;
          });
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
      await _stopSpeechToText();
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
    _speechLiveText = '';
    FocusScope.of(context).unfocus();

    await _speech.listen(
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (result) {
        if (!mounted) return;
        final spokenText = result.recognizedWords.trim();
        _speechLiveText = spokenText;
        final merged = [
          _speechSeedText,
          spokenText,
        ].where((e) => e.isNotEmpty).join(' ');
        messageTextEditingController.text = merged;
        messageTextEditingController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageTextEditingController.text.length),
        );
        setState(() {});
      },
    );
    if (mounted) {
      setState(() {
        _isListening = true;
        _showSpeechOverlay = true;
      });
    }
  }

  Future<void> _stopSpeechToText() async {
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _showSpeechOverlay = false;
    });
  }

  Widget _buildSpeechOverlay(Size size) {
    final spoken = _speechLiveText.trim();
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.45),
        child: InkWell(
          onTap: _stopSpeechToText,
          child: Center(
            child: Container(
              width: size.width * 0.78,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: AppColor.primaryColor(context),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: AppColor.buttonColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImage.microphone,
                        width: 26,
                        height: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    spoken.isEmpty ? 'Listening...' : spoken,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.secondryColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFont.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap to close',
                    style: TextStyle(
                      color: AppColor.textcolor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
      _refreshConversationListAfterSend();
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
        _refreshConversationListAfterSend();
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

  Widget _chatMediaLoader() {
    return Center(
      child: LoadingAnimationWidget.dotsTriangle(
        color: AppColor.buttonColor,
        size: 35,
      ),
    );
  }

  Widget _buildNetworkImageWithLoader(
    String url, {
    required BoxFit fit,
    required Widget fallback,
  }) {
    return Image.network(
      url,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.black12,
          child: _chatMediaLoader(),
        );
      },
      errorBuilder: (_, __, ___) => fallback,
    );
  }

  Widget _buildFileImageWithLoader(
    String path, {
    required BoxFit fit,
    required Widget fallback,
  }) {
    return Image.file(
      File(path),
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame == null) {
          return Container(
            color: Colors.black12,
            child: _chatMediaLoader(),
          );
        }
        return AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (_, __, ___) => fallback,
    );
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
              _buildNetworkImageWithLoader(
                url,
                fit: BoxFit.cover,
                fallback: Container(
                  color: Colors.black26,
                  child: const Icon(Icons.broken_image, color: Colors.white70),
                ),
              )
            else if (File(url).existsSync())
              _buildFileImageWithLoader(
                url,
                fit: BoxFit.cover,
                fallback: Container(
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

  Widget _buildEventCard(
    BuildContext context,
    Size size, {
    required Map<String, dynamic> eventObject,
    required bool mine,
    bool approved = false,
    bool showActions = false,
    VoidCallback? onApprove,
    VoidCallback? onReject,
  }) {
    final entityType = _raw(eventObject['type']).isNotEmpty
        ? _raw(eventObject['type']).toLowerCase()
        : _raw(eventObject['entity_type']).toLowerCase();
    final entityId = _raw(eventObject['id']).isNotEmpty
        ? _raw(eventObject['id'])
        : entityType == 'venue'
            ? _raw(eventObject['venue_id'])
            : _raw(eventObject['event_id']);
    final title = _raw(eventObject['name']).isNotEmpty
        ? _raw(eventObject['name'])
        : _raw(eventObject['venue_name']).isNotEmpty
            ? _raw(eventObject['venue_name'])
            : _raw(eventObject['event_name']);
    final time = _raw(eventObject['time']).isNotEmpty
        ? _raw(eventObject['time'])
        : _raw(eventObject['venue_time']).isNotEmpty
            ? _raw(eventObject['venue_time'])
            : _raw(eventObject['event_time']);
    final address = _raw(eventObject['address']).isNotEmpty
        ? _raw(eventObject['address'])
        : _raw(eventObject['venue_address']).isNotEmpty
            ? _raw(eventObject['venue_address'])
            : _raw(eventObject['event_address']);
    final image = _raw(eventObject['image']).isNotEmpty
        ? _raw(eventObject['image'])
        : _raw(eventObject['venue_image']).isNotEmpty
            ? _raw(eventObject['venue_image'])
            : _raw(eventObject['event_image']);
    final imageUrl = image.isEmpty ? '' : _fileUrl(image);
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 1 / 100),
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 90 / 100,
            child: Align(
              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: entityId.isEmpty
                        ? null
                        : () => _openSharedEntityDetail(eventObject),
                    child: SizedBox(
                      width: size.width * 0.70,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: size.width * 0.70,
                              height: size.height * 0.40,
                              child: imageUrl.isNotEmpty
                                  ? _buildNetworkImageWithLoader(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      fallback: Image.asset(
                                        AppImage.msgCardicon,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      AppImage.msgCardicon,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.12),
                                      Colors.black.withOpacity(0.28),
                                      Colors.black.withOpacity(0.72),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: size.width * 0.04,
                    right: size.width * 0.04,
                    bottom: size.height * 2 / 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (time.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: AppColor.buttonColor,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  time,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColor.buttonColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (address.isNotEmpty) const SizedBox(height: 4),
                        if (address.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
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
          ),
          if (showActions) SizedBox(height: size.height * 1 / 100),
          if (showActions)
            SizedBox(
              width: size.width * 90 / 100,
              child: Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onApprove,
                  child: Container(
                    width: size.width * 0.70,
                    height: size.height * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color:
                          approved ? AppColor.greenColor1 : AppColor.statusbar,
                    ),
                    child: Center(
                      child: Text(
                        approved ? 'Approved' : 'Accept',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (showActions) const SizedBox(height: 15),
          if (showActions)
            SizedBox(
              width: size.width * 90 / 100,
              child: Align(
                alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onReject,
                  child: Container(
                    width: size.width * 0.70,
                    height: size.height * 0.06,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey.shade900,
                    ),
                    child: const Center(
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));
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
                              onTap: _openOtherUserProfile,
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
                                          image: _chatAvatar(_receiverImage),
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
                                          child: Text(_receiverName,
                                              style: TextStyle(
                                                  color: AppColor.secondryColor(
                                                      context),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      AppFont.fontFamily)),
                                        ),
                                        if (!_blockedByMe)
                                          Consumer<UserChatSocketProvider>(
                                            builder:
                                                (context, socketProvider, _) =>
                                                    Text(
                                              _presenceSubtitle(socketProvider),
                                              style: TextStyle(
                                                  height: 1,
                                                  color: AppColor.textcolor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily:
                                                      AppFont.fontFamily),
                                            ),
                                          ),
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
                                            .map((e) =>
                                                Map<String, dynamic>.from(e))
                                            .toList();
                                        final allVisibleMessages =
                                            _dedupeVisibleMessages(<Map<String,
                                                dynamic>>[
                                          ...visibleMessages,
                                          ..._pendingMediaMessages,
                                        ]);
                                        final approvalFlowActive =
                                            _isApprovalFlowActive(
                                          visibleMessages,
                                        );
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
                                            final eventObject =
                                                _eventObjectForMessage(message);
                                            final hasEventCard =
                                                eventObject != null;
                                            final approvedEvent =
                                                _isApprovedEvent(message);
                                            final rejectedEvent =
                                                _isRejectedEvent(message);
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
                                                !hasLocation &&
                                                !hasEventCard) {
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
                                                          onTap:
                                                              _openOtherUserProfile,
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
                                                                image:
                                                                    _chatAvatar(
                                                                  _receiverImage,
                                                                ),
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
                                                          if (hasEventCard)
                                                            _buildEventCard(
                                                              context,
                                                              size,
                                                              eventObject:
                                                                  eventObject,
                                                              mine: mine,
                                                              approved:
                                                                  approvedEvent,
                                                              showActions: !mine &&
                                                                  approvalFlowActive &&
                                                                  !approvedEvent &&
                                                                  !rejectedEvent,
                                                              onApprove: () =>
                                                                  _emitEventApprovalUpdate(
                                                                message,
                                                                isApprove: true,
                                                              ),
                                                              onReject: () =>
                                                                  _emitEventApprovalUpdate(
                                                                message,
                                                                isApprove:
                                                                    false,
                                                              ),
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
                                                                    color: Colors
                                                                        .white,
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
                              if (_pendingSharedEvent != null &&
                                  !widget.autoSendSharedEvent)
                                SlideTransition(
                                  position: _offsetAnimation,
                                  child: _buildEventCard(
                                    context,
                                    size,
                                    eventObject: _pendingSharedEvent!,
                                    mine: true,
                                    approved: isApproved,
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
                            SizedBox(height: size.height * 1 / 100),
                            if (_blockedByMe)
                              _buildBlockedComposerPlaceholder(size)
                            else
                              Consumer<UserChatSocketProvider>(
                                builder: (context, socketProvider, _) {
                                  final visibleMessages = socketProvider
                                      .messages
                                      .where(_belongsToCurrentConversation)
                                      .toList();
                                  final conversationHasApprovedRequest =
                                      _hasApprovedRequest(visibleMessages);
                                  final gateMessage =
                                      _latestApprovalGateMessage(
                                    visibleMessages,
                                  );
                                  final gatePending = gateMessage != null &&
                                      !_isApprovedEvent(gateMessage) &&
                                      !_isRejectedEvent(gateMessage);
                                  final gateRejected = gateMessage != null &&
                                      _isRejectedEvent(gateMessage);

                                  if (!conversationHasApprovedRequest &&
                                      (gatePending || gateRejected)) {
                                    return _buildApprovalComposerPlaceholder(
                                      size,
                                      rejected: gateRejected,
                                    );
                                  }

                                  return SizedBox(
                                    width: size.width * 90 / 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 2))
                                        ],
                                      ),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: size.height * 7 / 100,
                                          maxHeight: size.height * 16 / 100,
                                        ),
                                        child: TextFormField(
                                          cursorColor:
                                              AppColor.secondryColor(context),
                                          style: TextStyle(
                                              height: 1.25,
                                              color: AppColor.secondryColor(
                                                  context)),
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          keyboardType: TextInputType.multiline,
                                          textInputAction:
                                              TextInputAction.newline,
                                          maxLength: AppConstant.describeLength,
                                          minLines: 1,
                                          maxLines: 3,
                                          focusNode: _messageFocusNode,
                                          controller:
                                              messageTextEditingController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            suffixIconConstraints:
                                                BoxConstraints(
                                                    maxWidth:
                                                        size.width * 30 / 100),
                                            counterText: '',
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 9.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: GestureDetector(
                                                      onTap:
                                                          _pickFromCameraAndSend,
                                                      child: Container(
                                                        height:
                                                            size.height * 0.04,
                                                        width:
                                                            size.height * 0.04,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: AppColor
                                                                    .buttonColor,
                                                                shape: BoxShape
                                                                    .circle),
                                                        child: Center(
                                                          child:
                                                              _isUploadingMedia
                                                                  ? SizedBox(
                                                                      width: size
                                                                              .height *
                                                                          0.018,
                                                                      height: size
                                                                              .height *
                                                                          0.018,
                                                                      child:
                                                                          const CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )
                                                                  : Image.asset(
                                                                      AppImage
                                                                          .cameraIcon,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      height: size
                                                                              .height *
                                                                          0.026),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            suffixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: _sendMessage,
                                                    child: Image.asset(
                                                        AppImage.shareImg,
                                                        height: size.width *
                                                            6 /
                                                            100,
                                                        width: size.width *
                                                            6 /
                                                            100,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 1 / 100),
                                                  GestureDetector(
                                                    onTap: _toggleSpeechToText,
                                                    child: Image.asset(
                                                        AppImage.microphone,
                                                        height: size.width *
                                                            6 /
                                                            100,
                                                        width: size.width *
                                                            6 /
                                                            100,
                                                        color: _isListening
                                                            ? AppColor
                                                                .buttonColor
                                                            : AppColor
                                                                .secondryColor(
                                                                    context)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 2 / 100),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        isBottomSheetOpen =
                                                            !isBottomSheetOpen;
                                                      });
                                                      if (isBottomSheetOpen) {
                                                        plusiconsBottomSheet(
                                                                context)
                                                            .whenComplete(() {
                                                          setState(() =>
                                                              isBottomSheetOpen =
                                                                  false);
                                                        });
                                                      }
                                                    },
                                                    child: Image.asset(
                                                        AppImage.plusIcon,
                                                        height: size.width *
                                                            6 /
                                                            100,
                                                        width: size.width *
                                                            6 /
                                                            100,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 3 / 100),
                                                ],
                                              ),
                                            ),
                                            border: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppColor
                                                        .washpressColor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(40))),
                                            enabledBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppColor
                                                        .washpressColor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(40))),
                                            focusedBorder: const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: AppColor
                                                        .washpressColor),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(40))),
                                            fillColor: isDark
                                                ? AppColor.washpressColor
                                                : Colors.white,
                                            filled: true,
                                            hintText: AppLanguage
                                                .messageText[language],
                                            hintStyle: const TextStyle(
                                                color: AppColor.textcolor,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            SizedBox(height: size.height * 1 / 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_showSpeechOverlay) _buildSpeechOverlay(size),
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
            height: MediaQuery.of(context).size.height * 100 / 100,
            width: MediaQuery.of(context).size.width * 100 / 100,
            padding: EdgeInsets.only(
              right: 10,
              top: MediaQuery.of(context).size.height * 72 / 100,
            ),
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
                            child: Image.asset(
                              AppImage.vedioIcon,
                              width:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              color: Colors.white,
                            ),
                          ),
                          Text(AppLanguage.videoText[language],
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
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
                              width:
                                  MediaQuery.of(context).size.width * 10 / 100,
                              child: Icon(
                                Icons.photo_library,
                                size:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                color: Colors.white,
                              )),
                          Text(AppLanguage.galleryText[language],
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400)),
                        ]),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 1 / 100),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          await _shareSelectedChatEntity();
                        },
                        child: Row(children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 10 / 100,
                            child: Image.asset(
                              AppImage.eventIcon,
                              width:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              height:
                                  MediaQuery.of(context).size.width * 5 / 100,
                              color: Colors.white,
                            ),
                          ),
                          Text(AppLanguage.eventsText[language],
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400)),
                        ]),
                      ),
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
                                : Image.asset(
                                    AppImage.locationBlackicon,
                                    width: MediaQuery.of(context).size.width *
                                        5 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        5 /
                                        100,
                                    color: Colors.white,
                                  ),
                          ),
                          Text(
                              _isSendingLocation
                                  ? 'Sharing location...'
                                  : AppLanguage.locationText[language],
                              style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
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
                              onTap: () async {
                                Navigator.pop(context);
                                if (_blockedByMe) {
                                  final shouldUnblock =
                                      await _showConfirmActionDialog(
                                    title: 'Unblock User',
                                    message:
                                        'Are you sure you want to unblock this user?',
                                    confirmText: 'Unblock',
                                  );
                                  if (shouldUnblock != true) return;
                                  await _handleUnblockUser();
                                } else {
                                  final shouldBlock =
                                      await _showConfirmActionDialog(
                                    title: 'Block User',
                                    message:
                                        'Are you sure you want to block this user?',
                                    confirmText: 'Block',
                                  );
                                  if (shouldBlock != true) return;
                                  await _handleBlockUser();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text(
                                    _blockedByMe
                                        ? 'Unblock User'
                                        : 'Block User',
                                    style: TextStyle(
                                        fontSize: 15,
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                            if (!_unfriendByMe)
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  final shouldUnmatch =
                                      await _showConfirmActionDialog(
                                    title: 'Unmatch',
                                    message:
                                        'Are you sure you want to unmatch this user?',
                                    confirmText: 'Unmatch',
                                  );
                                  if (shouldUnmatch != true) return;
                                  await _handleUnmatchUser();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  child: Text('Unmatch',
                                      style: TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400)),
                                ),
                              ),
                            if (!_reportStatus)
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context);
                                  final shouldReport =
                                      await _showConfirmActionDialog(
                                    title: 'Report User',
                                    message:
                                        'Are you sure you want to report this user?',
                                    confirmText: 'Report',
                                  );
                                  if (shouldReport != true) return;
                                  await _handleReportUser();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  child: Text('Report',
                                      style: TextStyle(
                                          fontSize: 15,
                                          decoration: TextDecoration.none,
                                          color: Colors.white,
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

  Future<void> _loadRelationStatusIfNeeded({bool force = false}) async {
    if (!mounted) return;
    final token = AppConstant.token;
    final otherUserId = _receiverId.trim();
    if (token.isEmpty || otherUserId.isEmpty) return;
    if (!force && _relationStatusLoadedForUserId == otherUserId) return;
    if (_relationStatusLoading) return;
    _relationStatusLoading = true;

    try {
      final response = await postJsonData(
        'feed/get_user_relation_status',
        <String, dynamic>{
          'other_user_id': otherUserId,
        },
        context,
        headers: <String, String>{
          'authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map) {
          setState(() {
            _blockedByMe = data['blocked_by_me'] == true;
            _unfriendByMe = data['unfriend_by_me'] == true;
            _reportStatus = data['report_status'] == true;
            _isMyFirendStatus = data['is_friend'] == true;
            if (_isMyFirendStatus) {
              _conversationUnlocked = true;
            }

            _relationStatusLoadedForUserId = otherUserId;
          });
        }
      }
    } finally {
      _relationStatusLoading = false;
    }
  }

  Future<bool?> _showConfirmActionDialog({
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColor.washpressColor,
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFont.fontFamily,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFont.fontFamily,
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColor.textcolor,
                  fontFamily: AppFont.fontFamily,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                confirmText,
                style: const TextStyle(
                  color: AppColor.buttonColor,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUnmatchUser() async {
    final targetUserId = _receiverId.trim();
    final token = AppConstant.token;
    if (targetUserId.isEmpty || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to unmatch right now.')),
      );
      return;
    }

    final response = await postJsonData(
      'feed/unfriend_user',
      <String, dynamic>{
        'target_user_id': targetUserId,
        'action': 'left',
      },
      context,
      headers: <String, String>{
        'authorization': 'Bearer $token',
      },
    );

    if (!mounted) return;
    if (response != null && response['success'] == true) {
      TopNotification.success(context, response['message'][language]);
      await _loadRelationStatusIfNeeded(force: true);
      return;
    }

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Failed to unmatch user.')),
    // );
  }

  Future<void> _handleBlockUser() async {
    final targetUserId = _receiverId.trim();
    final token = AppConstant.token;
    if (targetUserId.isEmpty || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to block right now.')),
      );
      return;
    }

    final response = await postJsonData(
      'common/block_unblock',
      <String, dynamic>{
        'target_user_id': targetUserId,
        'action': 'block',
      },
      context,
      headers: <String, String>{
        'authorization': 'Bearer $token',
      },
    );

    if (!mounted) return;
    if (response != null && response['success'] == true) {
      await _loadRelationStatusIfNeeded(force: true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to block user.')),
    );
  }

  Future<void> _handleUnblockUser() async {
    final targetUserId = _receiverId.trim();
    final token = AppConstant.token;
    if (targetUserId.isEmpty || token.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to unblock right now.')),
      );
      return;
    }

    final response = await postJsonData(
      'common/block_unblock',
      <String, dynamic>{
        'target_user_id': targetUserId,
        'action': 'unblock',
      },
      context,
      headers: <String, String>{
        'authorization': 'Bearer $token',
      },
    );

    if (!mounted) return;
    if (response != null && response['success'] == true) {
      await _loadRelationStatusIfNeeded(force: true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to unblock user.')),
    );
  }

  Future<void> _handleReportUser() async {
    final otherUserId = _receiverId.trim();
    if (otherUserId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to report right now.')),
      );
      return;
    }

    final response = await Provider.of<PostApiProvider>(context, listen: false)
        .reportUserApi(
      context,
      otherUserId: otherUserId,
    );

    if (!mounted) return;
    if (response != null && response['success'] == true) {
      setState(() {
        _reportStatus = true;
      });
      await _loadRelationStatusIfNeeded(force: true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to report user.')),
    );
  }

  Widget _buildBlockedComposerPlaceholder(Size size) {
    return Container(
      width: size.width * 90 / 100,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.washpressColor,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'You blocked this contact',
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final shouldUnblock = await _showConfirmActionDialog(
                title: 'Unblock User',
                message: 'Are you sure you want to unblock this user?',
                confirmText: 'Unblock',
              );
              if (shouldUnblock != true) return;
              await _handleUnblockUser();
            },
            child: const Text(
              'Unblock',
              style: TextStyle(
                color: AppColor.buttonColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalComposerPlaceholder(
    Size size, {
    required bool rejected,
  }) {
    final text =
        rejected ? 'Chat request rejected' : 'Chat request pending approval';
    return Container(
      width: size.width * 90 / 100,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColor.washpressColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColor.secondryColor(context),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: AppFont.fontFamily,
        ),
      ),
    );
  }

  void _goToFooterHome() {
    if (!mounted) return;
    AppConstant.selectFooterIndex = 0;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MyAppFooter(initialIndex: 0),
      ),
      (route) => false,
    );
  }
}
