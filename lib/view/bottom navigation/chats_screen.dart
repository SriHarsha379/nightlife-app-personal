import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../controller/home/home_controller.dart';
import '../../controller/members/conversion_list_controller.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/user_chat_socket_provider.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_config_provider.dart';
import '../../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../authentication/notification_screen.dart';
import '../authentication/profile.dart';
import '../other/chats/chat_message_screen.dart';

class ChatScreen extends StatefulWidget {
  static String routeName = './ChatScreen';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  static const String _locationPrefix = '__loc__';

  late TextEditingController searchController;
  final ScrollController _conversationScrollController = ScrollController();
  final FocusNode _chatSearchFocusNode = FocusNode();
  UserChatSocketProvider? _socketProvider;
  UserController? _userController;
  String _userId = '';
  String _bootstrappedUserId = '';
  String _headerUserName = 'User';
  String _headerUserImage = '';

  // Emit state — reset on every fresh bootstrap/login
  bool _conversationListDone = false; // true once server responded OR gave up
  int _emitAttempts = 0;
  static const int _maxEmitAttempts = 3;
  bool _emitInFlight = false;
  bool _recentFriendsRequested = false;

  Timer? _retryTimer;
  Timer? _recentFriendsRetryTimer;
  String _lastRecentFriendsLog = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    searchController = TextEditingController();
    _chatSearchFocusNode.addListener(() {
      footerVisibilityNotifier.value = !_chatSearchFocusNode.hasFocus;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _socketProvider =
          Provider.of<UserChatSocketProvider>(context, listen: false);
      _userController = Provider.of<UserController>(context, listen: false);
      _socketProvider?.addListener(_handleSocketStateChanged);
      _bootstrapChatHeaderAndEmit();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retryTimer?.cancel();
    _recentFriendsRetryTimer?.cancel();
    _socketProvider?.removeListener(_handleSocketStateChanged);
    searchController.dispose();
    _conversationScrollController.dispose();
    footerVisibilityNotifier.value = true;
    _chatSearchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Re-fetch on app resume
      _resetEmitState();
      _tryEmit();
      _tryEmitRecentFriends();
    }
  }

  // ── Reset emit tracking (call on fresh login / bootstrap) ──
  void _resetEmitState() {
    _conversationListDone = false;
    _emitAttempts = 0;
    _emitInFlight = false;
    _recentFriendsRequested = false;
    _retryTimer?.cancel();
    _recentFriendsRetryTimer?.cancel();
  }

  Future<void> _bootstrapChatHeaderAndEmit() async {
    if (_userController == null || _socketProvider == null) return;
    await _userController!.getUserDetails();
    if (!mounted) return;

    final nextUserId = _userController!.getUserId.trim();
    final didUserChange =
        _bootstrappedUserId.isNotEmpty && _bootstrappedUserId != nextUserId;
    _userId = nextUserId;
    _bootstrappedUserId = nextUserId;
    final fullName = _userController!.getUserName.trim();
    final userNameId = _userController!.getUserNameId.trim();
    _headerUserName = fullName.isNotEmpty
        ? fullName
        : (userNameId.isNotEmpty ? userNameId : 'User');
    _headerUserImage = _userController!.getUserImage.trim();

    if (mounted) setState(() {});

    // Always reset on bootstrap — new user after logout→login must re-fetch
    _resetEmitState();
    _lastRecentFriendsLog = '';
    _socketProvider!.resetConversationListState();

    final token = AppConstant.token.trim();
    final boundAuthUserId = _socketProvider!.authUserId.trim();
    if (token.isNotEmpty &&
        (didUserChange ||
            (boundAuthUserId.isNotEmpty && boundAuthUserId != _userId))) {
      await _socketProvider!.forceReconnect(
        token,
        authUserId: _userId,
      );
    } else {
      // initSocket: if already connected this is a no-op, if not it starts connecting
      await _socketProvider!.initSocket(token);
    }
    if (!mounted) return;

    // KEY FIX: don't emit immediately — wait for socket onConnect event.
    // _handleSocketStateChanged will call _tryEmit when isConnected becomes true.
    // But if socket is already connected, listener may not fire again, so check now.
    if (_socketProvider!.isConnected) {
      _tryEmit();
      _tryEmitRecentFriends();
    }
    // else: listener fires _handleSocketStateChanged → _tryEmit when connected
  }

  void _handleSocketStateChanged() {
    if (!mounted || _socketProvider == null) return;

    if (!_socketProvider!.isConnected) {
      // Socket dropped — allow re-fetch on next connect
      _conversationListDone = false;
      _emitAttempts = 0;
      _recentFriendsRequested = false;
      _retryTimer?.cancel();
      _recentFriendsRetryTimer?.cancel();
      return;
    }

    // Socket just connected or state changed while connected
    if (!_conversationListDone) {
      _tryEmit();
    }
    if (!_recentFriendsRequested) {
      _tryEmitRecentFriends();
    }

    // Log recent friends
    final recentFriendsRaw = _socketProvider!.recentFriendsList;
    if (recentFriendsRaw != null) {
      _recentFriendsRequested = true;
      _recentFriendsRetryTimer?.cancel();
      final nextLog = recentFriendsRaw.toString();
      if (nextLog != _lastRecentFriendsLog) {
        _lastRecentFriendsLog = nextLog;
        debugPrint('[ChatScreen] recend_firends_list => $nextLog');
      }
    }

    // Detect server response: socket_provider sets hasConversationListLoaded=true
    // when server responds OR when its own 3s timeout fallback fires.
    // Either way — we are done.
    if (_socketProvider!.hasConversationListLoaded && !_conversationListDone) {
      _conversationListDone = true;
      _emitInFlight = false;
      _retryTimer?.cancel();
      debugPrint('[ChatScreen] conversation list loaded — done');
    }
  }

  /// Core emit logic — guarded by attempt counter and done flag.
  void _tryEmit() {
    if (!mounted || _socketProvider == null) return;
    if (_conversationListDone) return;
    if (_emitInFlight) return;
    if (_emitAttempts >= _maxEmitAttempts) {
      // Gave up — mark done so loader disappears
      debugPrint('[ChatScreen] max emit attempts reached — marking done');
      _conversationListDone = true;
      _emitInFlight = false;
      // Force hasConversationListLoaded so UI stops showing spinner
      // socket_provider's timeout fallback will already have fired by now,
      // but just in case, notify directly via provider reset is NOT safe here.
      // Instead just rebuild — provider's timeout fallback handles the rest.
      return;
    }
    if (_userId.isEmpty) {
      debugPrint('[ChatScreen] tryEmit: userId empty, skip');
      return;
    }
    if (!_socketProvider!.isConnected) {
      debugPrint('[ChatScreen] tryEmit: not connected — waiting for onConnect');
      return;
    }

    _emitAttempts++;
    _emitInFlight = true;
    debugPrint(
        '[ChatScreen] getConversationList emit #$_emitAttempts userId=$_userId');

    final sent = _socketProvider!
        .getConversationList(userId: _userId, page: 1, limit: 50);
    debugPrint('[ChatScreen] getConversationList sent=$sent');

    if (!sent) {
      _emitInFlight = false;
      // Emit failed even though isConnected was true — retry shortly
      if (_emitAttempts < _maxEmitAttempts) {
        _retryTimer?.cancel();
        _retryTimer = Timer(const Duration(milliseconds: 800), () {
          if (mounted) _tryEmit();
        });
      }
    }
    // If sent=true: socket_provider's _armConversationListLoadTimeout (3s)
    // will fire hasConversationListLoaded=true which _handleSocketStateChanged
    // picks up. No extra timer needed here.
  }

  void _tryEmitRecentFriends() {
    if (!mounted || _socketProvider == null) return;
    if (_recentFriendsRequested) return;
    if (_userId.isEmpty) {
      debugPrint('[ChatScreen] recent friends: userId empty, skip');
      return;
    }
    if (!_socketProvider!.isConnected) {
      debugPrint(
          '[ChatScreen] recent friends: not connected - waiting for onConnect');
      return;
    }

    final sent = _socketProvider!.emitRecendFirendsList(userId: _userId);
    debugPrint('[ChatScreen] recend_firends_list sent=$sent');
    if (sent) {
      _recentFriendsRequested = true;
      _recentFriendsRetryTimer?.cancel();
      _recentFriendsRetryTimer = Timer(const Duration(seconds: 3), () {
        if (!mounted || _socketProvider == null) return;
        if (_socketProvider!.recentFriendsList != null) return;
        _recentFriendsRequested = false;
        _tryEmitRecentFriends();
      });
      return;
    }

    _recentFriendsRetryTimer?.cancel();
    _recentFriendsRetryTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) _tryEmitRecentFriends();
    });
  }

  // ── Helpers ──
  String _raw(dynamic value) => (value ?? '').toString().trim();

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _extractId(dynamic value) {
    if (value is Map) {
      return _raw(value['_id'] ?? value['id'] ?? value['user_id']);
    }
    return _raw(value);
  }

  Map<String, dynamic> _otherUserMap(Map<String, dynamic> conversation) {
    final sender = _asMap(conversation['sender_id']);
    final receiver = _asMap(conversation['receiver_id']);
    final senderId = _extractId(sender);
    final receiverId = _extractId(receiver);
    if (_userId.isEmpty) return sender.isNotEmpty ? sender : receiver;
    if (senderId == _userId) return receiver;
    if (receiverId == _userId) return sender;
    return receiver.isNotEmpty ? receiver : sender;
  }

  String _conversationName(Map<String, dynamic> conversation) {
    final other = _otherUserMap(conversation);
    final name = _raw(other['name']);
    if (name.isNotEmpty) return name;
    final username = _raw(other['username']);
    if (username.isNotEmpty) return username;
    final senderId = _extractId(conversation['sender_id']);
    final receiverId = _extractId(conversation['receiver_id']);
    if (_userId.isNotEmpty) {
      if (senderId == _userId) {
        final n =
            _raw(conversation['receiver_name'] ?? conversation['receiverName']);
        if (n.isNotEmpty) return n;
      } else if (receiverId == _userId) {
        final n =
            _raw(conversation['sender_name'] ?? conversation['senderName']);
        if (n.isNotEmpty) return n;
      }
    }
    final receiverName =
        _raw(conversation['receiver_name'] ?? conversation['receiverName']);
    if (receiverName.isNotEmpty) return receiverName;
    final senderName =
        _raw(conversation['sender_name'] ?? conversation['senderName']);
    if (senderName.isNotEmpty) return senderName;
    return 'User';
  }

  String _conversationReceiverId(Map<String, dynamic> conversation) {
    final senderId = _extractId(conversation['sender_id']);
    final receiverId = _extractId(conversation['receiver_id']);
    if (_userId.isNotEmpty) {
      if (senderId == _userId && receiverId.isNotEmpty) return receiverId;
      if (receiverId == _userId && senderId.isNotEmpty) return senderId;
    }
    if (receiverId.isNotEmpty) return receiverId;
    if (senderId.isNotEmpty) return senderId;
    return _extractId(_otherUserMap(conversation));
  }

  String _conversationId(Map<String, dynamic> conversation) =>
      _raw(conversation['_id'] ?? conversation['conversation_id']);

  ImageProvider<Object> _headerAvatar() {
    final rawImage = _headerUserImage.trim();
    if (rawImage.isEmpty || rawImage == 'null') {
      return const AssetImage(AppImage.placeHolder2Icon)
          as ImageProvider<Object>;
    }
    try {
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        return NetworkImage(rawImage) as ImageProvider<Object>;
      }
      if (rawImage.startsWith('file://')) {
        return FileImage(File(Uri.parse(rawImage).toFilePath()))
            as ImageProvider<Object>;
      }
      if (rawImage.startsWith('/') || rawImage.contains(r':\')) {
        return FileImage(File(rawImage)) as ImageProvider<Object>;
      }
      return NetworkImage('${AppConfigProvider.imageUrl}$rawImage')
          as ImageProvider<Object>;
    } catch (_) {
      return const AssetImage(AppImage.placeHolder2Icon)
          as ImageProvider<Object>;
    }
  }

  ImageProvider<Object> _conversationAvatar(Map<String, dynamic> conversation) {
    final other = _otherUserMap(conversation);
    String rawImage = _raw(other['profile_image'] ?? other['image']);
    if (rawImage.isEmpty) {
      final senderId = _extractId(conversation['sender_id']);
      final receiverId = _extractId(conversation['receiver_id']);
      if (_userId.isNotEmpty) {
        if (senderId == _userId) {
          rawImage = _raw(
              conversation['receiver_image'] ?? conversation['receiverImage']);
        } else if (receiverId == _userId) {
          rawImage =
              _raw(conversation['sender_image'] ?? conversation['senderImage']);
        }
      }
      if (rawImage.isEmpty) {
        rawImage = _raw(
            conversation['receiver_image'] ?? conversation['sender_image']);
      }
    }
    if (rawImage.isEmpty || rawImage == 'null') {
      return const AssetImage(AppImage.placeHolder2Icon)
          as ImageProvider<Object>;
    }
    final normalized = rawImage.replaceFirst(RegExp(r'^\./'), '');
    if (normalized.startsWith('assets/')) {
      return AssetImage(normalized) as ImageProvider<Object>;
    }
    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return NetworkImage(normalized) as ImageProvider<Object>;
    }
    return NetworkImage('${AppConfigProvider.imageUrl}$normalized')
        as ImageProvider<Object>;
  }

  int _conversationUnreadCount(Map<String, dynamic> conversation) {
    final rawUnread = conversation['unreadCount'] ??
        conversation['unread_count'] ??
        conversation['unread'];
    final conversationId = _conversationId(conversation);
    if (rawUnread is num) return rawUnread.toInt();
    if (rawUnread is String) return int.tryParse(rawUnread) ?? 0;
    if (rawUnread is List) {
      int total = 0;
      for (final item in rawUnread) {
        if (item is Map) {
          if (conversationId.isNotEmpty) {
            final unreadForId = _raw(item['_id'] ?? item['conversation_id']);
            if (unreadForId.isNotEmpty && unreadForId != conversationId) {
              continue;
            }
          }
          final count = item['count'];
          if (count is num) total += count.toInt();
          if (count is String) total += int.tryParse(count) ?? 0;
        } else if (item is num) {
          total += item.toInt();
        }
      }
      return total;
    }
    return 0;
  }

  bool _parseSeen(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    final raw = _raw(value).toLowerCase();
    if (raw == 'true' || raw == '1' || raw == 'yes') return true;
    if (raw == 'false' || raw == '0' || raw == 'no') return false;
    return true;
  }

  bool _isConversationUnread(Map<String, dynamic> conversation) {
    if (_conversationUnreadCount(conversation) > 0) return true;
    final seenRaw = conversation['is_seen'] ??
        conversation['isSeen'] ??
        conversation['isseen'] ??
        conversation['seen'];
    if (seenRaw == null) return false;
    final senderId = _extractId(conversation['sender_id']);
    if (_userId.isNotEmpty && senderId == _userId) return false;
    return !_parseSeen(seenRaw);
  }

  String _messagePreview(Map<String, dynamic> conversation) {
    final type = _raw(conversation['message_type'] ?? conversation['type'])
        .toLowerCase();
    final message =
        _raw(conversation['last_message'] ?? conversation['message']);
    if (message.isNotEmpty) {
      if (message.startsWith(_locationPrefix)) return 'Shared a location';
      return message;
    }
    if (type == 'image') return 'Sent an image';
    if (type == 'video') return 'Sent a video';
    if (type == 'location') return 'Shared a location';
    if (type == 'audio') return 'Sent an audio';
    if (type == 'file') return 'Sent an attachment';
    return 'Sent an attachment';
  }

  bool _matchesConversationSearch(
      Map<String, dynamic> conversation, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;
    return _conversationName(conversation)
            .toLowerCase()
            .contains(normalizedQuery) ||
        _messagePreview(conversation).toLowerCase().contains(normalizedQuery);
  }

  String _conversationTime(Map<String, dynamic> conversation) {
    final rawDate = _raw(conversation['updatedAt'] ??
        conversation['createdAt'] ??
        conversation['time']);
    if (rawDate.isEmpty) return '';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    final local = parsed.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  List<Map<String, dynamic>> _recentFriendsList(dynamic raw) {
    final List<dynamic> items;
    if (raw is List) {
      items = raw;
    } else if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw['friends'] ?? raw['list'];
      items = data is List ? data : const [];
    } else {
      items = const [];
    }
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final item in items) {
      final map = _asMap(item);
      if (map.isEmpty) continue;
      final friendId =
          _raw(map['friend_id'] ?? map['receiver_id'] ?? map['user_id']);
      if (friendId.isEmpty || seen.contains(friendId)) continue;
      seen.add(friendId);
      result.add(map);
    }
    return result;
  }

  String _recentFriendId(Map<String, dynamic> item) =>
      _raw(item['friend_id'] ?? item['receiver_id'] ?? item['user_id']);

  String _recentFriendName(Map<String, dynamic> item) =>
      _raw(item['name'] ?? item['friend_name'] ?? item['receiver_name']);

  String _recentFriendImage(Map<String, dynamic> item) =>
      _raw(item['image'] ?? item['friend_image'] ?? item['receiver_image']);

  ImageProvider<Object> _recentFriendAvatar(Map<String, dynamic> item) {
    final rawImage = _recentFriendImage(item);
    if (rawImage.isEmpty || rawImage == 'null') {
      return const AssetImage(AppImage.placeHolder2Icon)
          as ImageProvider<Object>;
    }
    if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
      return NetworkImage(rawImage) as ImageProvider<Object>;
    }
    return NetworkImage('${AppConfigProvider.imageUrl}$rawImage')
        as ImageProvider<Object>;
  }

  Widget _avatarLoader(double size) => Center(
        child: LoadingAnimationWidget.dotsTriangle(
          color: AppColor.buttonColor,
          size: size,
        ),
      );

  Widget _animatedChatAvatar(
      {required String imageUrl, required double size, double radius = 35}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? Image.asset(AppImage.placeHolder2Icon, fit: BoxFit.cover)
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                      color: Colors.transparent,
                      child: _avatarLoader(size > 40 ? 28 : 22));
                },
                errorBuilder: (_, __, ___) =>
                    Image.asset(AppImage.placeHolder2Icon, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Future<void> _openRecentFriendChat(Map<String, dynamic> friend) async {
    final receiverId = _recentFriendId(friend);
    if (receiverId.isEmpty) return;
    String conversationId = _raw(friend['conversation_id']);
    if (conversationId.isEmpty) {
      final conversationController =
          Provider.of<ConversionListController>(context, listen: false);
      conversationId = await conversationController.fetchConversationIdByUserId(
        otherUserId: receiverId,
      );
    }
    if (!mounted) return;
    final name = _recentFriendName(friend);
    final image = _recentFriendImage(friend);
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: ChatMessageScreen(
          name: name.isEmpty ? 'User' : name,
          image: image,
          receiverId: receiverId,
          conversationId: conversationId.isEmpty ? null : conversationId,
          autoSendSharedEvent: false,
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  int selectedId = 2;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final displayHeaderName = _headerUserName.trim().isNotEmpty
        ? _headerUserName.trim()
        : AppLanguage.sanjanaText[language];
    final ImageProvider<Object> headerUserImageProvider = _headerAvatar();

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          AppConstant.selectFooterIndex = 0;
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: Column(
                  children: [
                    // ── Header ──
                    SizedBox(
                      width: size.width * 95 / 100,
                      height: size.height * 9 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: size.height * 14 / 100,
                                child: Image.asset(
                                  AppImage.hiilogo,
                                  color: AppColor.secondryColor(context),
                                  width: size.width * 10 / 100,
                                ),
                              ),
                              SizedBox(width: size.width * 1 / 100),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 2 / 100),
                                  Text(
                                    AppLanguage.welcomeText[language],
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 58 / 100,
                                    child: Text(
                                      displayHeaderName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Consumer<HomeController>(
                                builder: (context, homeController, _) {
                                  return GestureDetector(
                                    onTap: () async {
                                      homeController.clearNotificationStatus();
                                      await Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.topToBottom,
                                          child: const Notifications(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        SizedBox(
                                          height: size.height * 3 / 100,
                                          child: Image.asset(AppImage.bellicon),
                                        ),
                                        if (homeController
                                            .getNotificationStatus)
                                          Positioned(
                                            right: 2,
                                            top: 2,
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 163, 86, 199),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white,
                                                    width: 2),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: size.width * 2 / 100),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType
                                          .rightToLeftWithFade,
                                      child: Profile(),
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 38,
                                  height: 38,
                                  child: CircleAvatar(
                                    backgroundImage: headerUserImageProvider,
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                              ),
                              SizedBox(width: size.width * 4 / 100),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    // ── Search bar ──
                    Container(
                      width: size.width * 90 / 100,
                      height: size.height * 5.5 / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: AppColor.textfieldfillColor),
                        color: AppColor.secondryColor(context),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                            blurRadius: 4,
                            color:
                                AppColor.primaryColor(context).withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        focusNode: _chatSearchFocusNode,
                        cursorColor: AppColor.secondryColor(context),
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFont.fontFamily,
                          fontSize: 14,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 4 / 100,
                              vertical: 10,
                            ),
                            child: Image.asset(
                              AppImage.searchIcon,
                              height: size.width * 4 / 100,
                              width: size.width * 4 / 100,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(
                              color: AppColor.primaryColor(context),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(
                              color: AppColor.primaryColor(context),
                              width: 0,
                            ),
                          ),
                          border: InputBorder.none,
                          hintStyle: AppConstant.textFilledStyle(context),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: size.width * 2 / 100,
                          ),
                        ),
                      ),
                    ),

                    // ── Recent friends ──
                    Consumer<UserChatSocketProvider>(
                      builder: (context, socketProvider, _) {
                        final recentFriends = _recentFriendsList(
                            socketProvider.recentFriendsList);
                        return Column(
                          children: [
                            SizedBox(height: size.height * 0.02),
                            SizedBox(
                              width: size.width * 0.90,
                              child: Text(
                                AppLanguage.recentFriends[language],
                                style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),
                            SizedBox(
                              width: size.width * 91 / 100,
                              child: recentFriends.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Text(
                                        'No recent friends',
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(
                                            recentFriends.length, (index) {
                                          final friend = recentFriends[index];
                                          final name =
                                              _recentFriendName(friend);
                                          final avatar =
                                              _recentFriendAvatar(friend);
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 5.0),
                                            child: Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () =>
                                                      _openRecentFriendChat(
                                                          friend),
                                                  child: Container(
                                                    width:
                                                        size.width * 15 / 100,
                                                    height:
                                                        size.width * 15 / 100,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColor
                                                                  .primaryColor(
                                                                      context)
                                                              .withOpacity(
                                                                  0.25),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              35),
                                                      child: Image(
                                                          image: avatar,
                                                          fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.height *
                                                        0.8 /
                                                        100),
                                                SizedBox(
                                                  width: size.width * 16 / 100,
                                                  child: Text(
                                                    name.isEmpty
                                                        ? 'User'
                                                        : name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: AppColor
                                                          .secondryColor(
                                                              context),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: size.height * 2 / 100),
                    SizedBox(
                      width: size.width * 0.90,
                      child: Text(
                        AppLanguage.messageText[language],
                        style: const TextStyle(
                          color: AppColor.buttonColor,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 1 / 100),

                    // ── Conversation list ──
                    Expanded(
                      child: Consumer<UserChatSocketProvider>(
                        builder: (context, socketProvider, _) {
                          // Detect server response in build phase
                          if (!_conversationListDone &&
                              socketProvider.hasConversationListLoaded) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted && !_conversationListDone) {
                                _conversationListDone = true;
                                _retryTimer?.cancel();
                              }
                            });
                          }

                          final filteredConversations =
                              socketProvider.conversationList
                                  .where((item) => _matchesConversationSearch(
                                        Map<String, dynamic>.from(item),
                                        searchController.text,
                                      ))
                                  .toList();

                          return Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              gradient:
                                  AppColor.backgroundGradientcolor(context),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(32),
                                topRight: Radius.circular(32),
                              ),
                            ),
                            child: !socketProvider.hasConversationListLoaded &&
                                    socketProvider.conversationList.isEmpty
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.buttonColor,
                                    ),
                                  )
                                : filteredConversations.isEmpty
                                    ? Center(
                                        child: Text(
                                          searchController.text.trim().isEmpty
                                              ? 'No conversations found'
                                              : 'No results found',
                                          style: TextStyle(
                                            color:
                                                AppColor.secondryColor(context),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        key: const PageStorageKey<String>(
                                          'chat_conversation_list',
                                        ),
                                        controller:
                                            _conversationScrollController,
                                        padding: EdgeInsets.only(
                                          top: size.height * 0.03,
                                          bottom: size.height * 0.05,
                                        ),
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        itemCount: filteredConversations.length,
                                        itemBuilder: (context, index) {
                                          final chat =
                                              Map<String, dynamic>.from(
                                                  filteredConversations[index]);
                                          final title = _conversationName(chat);
                                          final subtitle =
                                              _messagePreview(chat);
                                          final time = _conversationTime(chat);
                                          final unreadCount =
                                              _conversationUnreadCount(chat);
                                          final isUnread = unreadCount > 0 ||
                                              _isConversationUnread(chat);
                                          final receiverId =
                                              _conversationReceiverId(chat);
                                          final conversationId =
                                              _conversationId(chat);
                                          final avatar =
                                              _conversationAvatar(chat);

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: size.width * 0.92,
                                                height: size.height * 0.095,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  horizontalTitleGap: 9,
                                                  leading: Container(
                                                    margin: EdgeInsets.only(
                                                        left:
                                                            size.width * 0.036),
                                                    height: size.width * 0.18,
                                                    width: size.width * 0.18,
                                                    child: CircleAvatar(
                                                      backgroundImage: avatar,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context),
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    subtitle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isUnread
                                                          ? AppColor
                                                              .secondryColor(
                                                                  context)
                                                          : AppColor
                                                              .greyLightColor(
                                                                  context),
                                                    ),
                                                  ),
                                                  trailing: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      if (isUnread)
                                                        Container(
                                                          width: size.width *
                                                              0.025,
                                                          height: size.height *
                                                              0.02,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppColor
                                                                .pinkColor,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                        )
                                                      else
                                                        SizedBox(
                                                          width: size.width *
                                                              0.025,
                                                          height: size.height *
                                                              0.02,
                                                        ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                      Text(
                                                        time,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .greyLightColor(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeftWithFade,
                                                        child:
                                                            ChatMessageScreen(
                                                          name: title,
                                                          image: _raw(_otherUserMap(chat)['profile_image']) ==
                                                                  ''
                                                              ? (_raw(_otherUserMap(chat)['image'])
                                                                      .isNotEmpty
                                                                  ? _raw(_otherUserMap(
                                                                          chat)[
                                                                      'image'])
                                                                  : (_extractId(chat['sender_id']) ==
                                                                          _userId
                                                                      ? _raw(
                                                                          chat['receiver_image'] ??
                                                                              '')
                                                                      : _raw(chat['sender_image'] ??
                                                                          '')))
                                                              : _raw(_otherUserMap(
                                                                      chat)[
                                                                  'profile_image']),
                                                          autoSendSharedEvent:
                                                              false,
                                                          receiverId:
                                                              receiverId,
                                                          conversationId:
                                                              conversationId,
                                                        ),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              Divider(
                                                height: 0.2,
                                                thickness: 0.5,
                                                color: AppColor.greyLightColor(
                                                    context),
                                                indent: 30,
                                                endIndent: 30,
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.025),
                                              if (index ==
                                                  filteredConversations.length -
                                                      1)
                                                SizedBox(
                                                    height:
                                                        size.height * 0.046),
                                            ],
                                          );
                                        },
                                      ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
