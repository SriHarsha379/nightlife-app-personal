import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
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

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController searchController;
  UserChatSocketProvider? _socketProvider;
  UserController? _userController;
  String _userId = '';
  String _headerUserName = 'User';
  String _headerUserImage = '';
  bool _conversationEmitLogged = false;
  int _emitRetryCount = 0;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
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
    _socketProvider?.removeListener(_handleSocketStateChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapChatHeaderAndEmit() async {
    if (_userController == null || _socketProvider == null) return;
    await _userController!.getUserDetails();
    if (!mounted) return;

    _userId = _userController!.getUserId.trim();
    final fullName = _userController!.getUserName.trim();
    final userNameId = _userController!.getUserNameId.trim();
    _headerUserName = fullName.isNotEmpty
        ? fullName
        : (userNameId.isNotEmpty ? userNameId : 'User');
    _headerUserImage = _userController!.getUserImage.trim();

    if (mounted) {
      setState(() {});
    }

    await _socketProvider!.initSocket(AppConstant.token);
    if (!mounted) return;
    _tryGetConversationListEmit();
  }

  void _handleSocketStateChanged() {
    if (!mounted || _socketProvider == null) return;
    if (_socketProvider!.isConnected && !_conversationEmitLogged) {
      _tryGetConversationListEmit();
    }
  }

  void _tryGetConversationListEmit() {
    if (!mounted || _socketProvider == null || _conversationEmitLogged) return;
    if (_userId.isEmpty) {
      debugPrint('[ChatScreen] getConversationList skipped: user_id is empty');
      return;
    }

    final payload = {'user_id': _userId, 'page': 1, 'limit': 50};
    debugPrint(
        '[ChatScreen] getConversationList payload keys => ${payload.keys.toList()}');
    debugPrint('[ChatScreen] getConversationList payload => $payload');

    final sent = _socketProvider!
        .getConversationList(userId: _userId, page: 1, limit: 50);
    debugPrint('[ChatScreen] getConversationList emit sent => $sent');

    if (sent) {
      _conversationEmitLogged = true;
      return;
    }

    _emitRetryCount++;
    if (_emitRetryCount <= 20) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _tryGetConversationListEmit();
      });
    }
  }

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
    return 'User';
  }

  String _conversationReceiverId(Map<String, dynamic> conversation) {
    final other = _otherUserMap(conversation);
    return _extractId(other);
  }

  String _conversationId(Map<String, dynamic> conversation) {
    return _raw(conversation['_id'] ?? conversation['conversation_id']);
  }

  ImageProvider<Object> _conversationAvatar(Map<String, dynamic> conversation) {
    final other = _otherUserMap(conversation);
    final rawImage = _raw(other['profile_image'] ?? other['image']);
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
    final rawUnread = conversation['unreadCount'];
    if (rawUnread is num) return rawUnread.toInt();
    if (rawUnread is String) return int.tryParse(rawUnread) ?? 0;
    if (rawUnread is List) {
      int total = 0;
      for (final item in rawUnread) {
        if (item is Map) {
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

  String _messagePreview(Map<String, dynamic> conversation) {
    final type = _raw(conversation['message_type'] ?? conversation['type'])
        .toLowerCase();
    final message =
        _raw(conversation['last_message'] ?? conversation['message']);
    if (message.isNotEmpty) return message;

    if (type == 'image') return 'Sent an image';
    if (type == 'video') return 'Sent a video';
    if (type == 'location') return 'Shared a location';
    if (type == 'audio') return 'Sent an audio';
    if (type == 'file') return 'Sent an attachment';
    return 'Start chatting';
  }

  String _conversationTime(Map<String, dynamic> conversation) {
    final rawDate = _raw(
      conversation['updatedAt'] ??
          conversation['createdAt'] ??
          conversation['time'],
    );
    if (rawDate.isEmpty) return '';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return '';
    final local = parsed.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  List<Map<String, String>> storyImages = [
    {"image": "assets/icons/aadityaIcon.png", "name": "Arjun"},
    {"image": "assets/icons/arjunrampalIcon.png", "name": "Arav"},
    {"image": "assets/icons/galleryIcon.png", "name": "Bloom Cafe"},
    {"image": "assets/icons/girlImage.png", "name": "Bistro"},
    {"image": "assets/icons/userprofile.png", "name": "olivia"},
  ];

  List chats = [
    {
      'id': 1,
      'image':
          'assets/icons/aadityaIcon.png', // Replace with your actual image path
      'name': 'Gaurav Kapoor',
      'lastMessage': 'What about that new jacket if..',
      'time': '09:18',
    },
    {
      'id': 2,
      'image': 'assets/icons/arjunRoyicon.png',
      'name': 'Clara Hazel',
      'lastMessage': 'Are you ready for today\'s part..',
      'time': '12:44',
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Cafe',
      'lastMessage': 'I\'am sending you a parcel rece..',
      'time': '08:06',
    },
    {
      'id': 4,
      'image': 'assets/icons/girlImage.png',
      'name': 'Monica Randawa',
      'lastMessage': 'Hope you\'re doing well today..',
      'time': '09:32',
    },
  ];
  int selectedId = 2;

  List orders = [
    {'id': 1, 'title': 'Members'},
    {'id': 2, 'title': 'Events'},
    {'id': 3, 'title': 'Venues'},
    {'id': 4, 'title': 'All'},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final displayHeaderName = _headerUserName.trim().isNotEmpty
        ? _headerUserName.trim()
        : AppLanguage.sanjanaText[language];
    final ImageProvider<Object> headerUserImageProvider = _headerUserImage
                .startsWith('http://') ||
            _headerUserImage.startsWith('https://')
        ? NetworkImage(_headerUserImage) as ImageProvider<Object>
        : const AssetImage(AppImage.placeHolder2Icon) as ImageProvider<Object>;

    // final themeProvider = Provider.of<ThemeProvider>(context);

    // bool isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          setState(() {
            AppConstant.selectFooterIndex = 0; // Footer first index par jao
          });
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            // backgroundColor:
            //     isDark ? AppColor.primaryColor : AppColor.secondryColor(context),
            body: SafeArea(
              child: Container(
                height: size.height * 100 / 100,
                width: size.width * 100 / 100,
                child: Column(
                  children: [
                    // SizedBox(height: size.height * 0.2 / 100),
                    // AppHeader(text: AppLanguage.chatsText[language]),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 95 / 100,
                      height: MediaQuery.of(context).size.height * 9 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    14 /
                                    100,
                                child: Image.asset(
                                  AppImage.hiilogo,
                                  color: AppColor.secondryColor(context),
                                  width: MediaQuery.of(context).size.width *
                                      10 /
                                      100,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        2 /
                                        100,
                                  ),
                                  Text(
                                    AppLanguage.welcomeText[language],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                  Text(
                                    displayHeaderName,
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType.topToBottom,
                                      child: Notifications(),
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      3 /
                                      100,
                                  child: Image.asset(
                                    AppImage.bellicon,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 2 / 100,
                              ),
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
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),
                    Container(
                      width: size.width * 90 / 100,
                      height: size.height * 5.5 / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40), // pill shape
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
                        cursorColor: AppColor.secondryColor(context),
                        style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                            fontSize: 14),
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
                          // hintText: AppLanguage.searchText[language],
                          hintStyle: AppConstant.textFilledStyle(context),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: size.width * 2 / 100,
                          ),
                        ),
                      ),
                    ),

                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.90,
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
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 91 / 100,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  List.generate(storyImages.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 5.0),
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: size.width * 15 / 100,
                                              height: size.width * 15 / 100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        AppColor.primaryColor(
                                                                context)
                                                            .withOpacity(0.25),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                                child: Image.asset(
                                                  storyImages[index]["image"] ??
                                                      "no image",
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            if (index == 0)
                                              Positioned(
                                                right: -8,
                                                top: -2,
                                                child: Container(
                                                  width: size.width * 5.2 / 100,
                                                  height:
                                                      size.width * 5.2 / 100,
                                                  decoration: BoxDecoration(
                                                    color: AppColor
                                                        .darkPurpleColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Image.asset(
                                                    AppImage.storySendiconn,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .height,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.8 / 100),
                                      Text(
                                        storyImages[index]["name"] ?? "No Name",
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          ),
                        )
                      ],
                    ),

                    SizedBox(
                        height: MediaQuery.of(context).size.height * 2 / 100),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.90,
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
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    Expanded(
                      flex: 1,
                      child: Consumer<UserChatSocketProvider>(
                        builder: (context, socketProvider, _) {
                          final conversations = socketProvider.conversationList;
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
                            child: ListView.builder(
                              padding: EdgeInsets.only(
                                  top: size.height * 0.03,
                                  bottom: size.height * 0.05),
                              physics: const AlwaysScrollableScrollPhysics(),
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: conversations.length,
                              itemBuilder: (context, index) {
                                final chat = Map<String, dynamic>.from(
                                    conversations[index]);
                                final title = _conversationName(chat);
                                final subtitle = _messagePreview(chat);
                                final time = _conversationTime(chat);
                                final unreadCount =
                                    _conversationUnreadCount(chat);
                                final receiverId =
                                    _conversationReceiverId(chat);
                                final conversationId = _conversationId(chat);
                                final avatar = _conversationAvatar(chat);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: size.width * 0.92,
                                      height: size.height * 0.095,
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        horizontalTitleGap: 9,
                                        leading: Container(
                                          margin: EdgeInsets.only(
                                              left: size.width * 0.036),
                                          height: size.width * 0.18,
                                          width: size.width * 0.18,
                                          child: CircleAvatar(
                                            backgroundImage: avatar,
                                            backgroundColor: Colors.transparent,
                                          ),
                                        ),
                                        title: Text(
                                          title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                        subtitle: Text(
                                          subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                        trailing: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            if (unreadCount > 0)
                                              Container(
                                                width: size.width * 0.025,
                                                height: size.height * 0.02,
                                                decoration: const BoxDecoration(
                                                  color: AppColor.pinkColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            else
                                              SizedBox(
                                                width: size.width * 0.025,
                                                height: size.height * 0.02,
                                              ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Text(
                                              time,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColor.greyLightColor,
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
                                              child: ChatMessageScreen(
                                                name: title,
                                                image: _raw(_otherUserMap(chat)[
                                                            'profile_image']) ==
                                                        ''
                                                    ? _raw(_otherUserMap(
                                                        chat)['image'])
                                                    : _raw(_otherUserMap(
                                                        chat)['profile_image']),
                                                receiverId: receiverId,
                                                conversationId: conversationId,
                                              ),
                                              duration: const Duration(
                                                  milliseconds: 500),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const Divider(
                                      height: 0.2,
                                      thickness: 0.5,
                                      color: AppColor.greyLightColor,
                                      indent: 30,
                                      endIndent: 30,
                                    ),
                                    SizedBox(height: size.height * 0.025),
                                    if (index == conversations.length - 1)
                                      SizedBox(height: size.height * 0.046),
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
