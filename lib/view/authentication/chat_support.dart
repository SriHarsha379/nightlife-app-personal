import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_language.dart';

import '../../provider/socket_provider.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
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
  static const String _defaultSupportUserId = '68edf168efc853010224a2f6';

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
  bool _conversationRequested = false;
  int _conversationRequestAttempt = 0;

  SocketProvider? _socketProvider;
  UserController? _userController;

  @override
  void initState() {
    super.initState();
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

  Future<void> _bootstrapChat() async {
    await _loadUserFromController();
    debugPrint(
      'ChatSupport bootstrap => userId=$_userId userName=$_userName supportUserId=$_supportUserId conversationId=$_conversationId',
    );

    if (!mounted) return;

    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    await socketProvider.initSocket(AppConstant.token);

    if (_userId.isNotEmpty) {
      _requestConversationList();

      if (_conversationId.isNotEmpty) {
        _joinConversationIfReady();
      }

      if (_supportUserId.isNotEmpty) {
        socketProvider.emitUserStatus(
          userId: _userId,
          checkUserId: _supportUserId,
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _isBootstrapping = false;
    });
  }

  void _requestConversationList() {
    if (!mounted || _socketProvider == null || _userId.isEmpty) return;
    if (_conversationRequested) return;

    if (_socketProvider!.isConnected) {
      debugPrint(
          'ChatSupport get_conversation_list emit => userId=$_userId attempt=$_conversationRequestAttempt');
      _socketProvider!.getConversationList(userId: _userId, page: 1, limit: 50);
      _conversationRequested = true;
      return;
    }

    _conversationRequestAttempt += 1;
    if (_conversationRequestAttempt <= 12) {
      debugPrint(
          'ChatSupport waiting for socket connect, retry get_conversation_list attempt=$_conversationRequestAttempt');
      Future.delayed(
          const Duration(milliseconds: 500), _requestConversationList);
    } else {
      debugPrint(
          'ChatSupport failed to request conversation list after retries');
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

  void _handleSocketStateChanged() {
    if (!mounted || _socketProvider == null) return;
    final previousConversationId = _conversationId;

    _requestConversationList();

    if (_conversationId.isEmpty) {
      final item = _socketProvider!.conversationList.isNotEmpty
          ? _socketProvider!.conversationList.first
          : null;

      if (item != null) {
        final resolvedConversationId = _extractConversationId(item);
        final resolvedSupportUserId = _extractSupportUserId(item);
        final resolvedSupportName = _extractSupportName(item);
        final resolvedSupportImage = _extractSupportImage(item);

        if (resolvedConversationId.isNotEmpty) {
          _conversationId = resolvedConversationId;
          debugPrint('ChatSupport resolved conversationId=$_conversationId');
        }

        if (_supportUserId.isEmpty && resolvedSupportUserId.isNotEmpty) {
          _supportUserId = resolvedSupportUserId;
          debugPrint('ChatSupport resolved supportUserId=$_supportUserId');
        }

        if (_supportName == 'Support' && resolvedSupportName.isNotEmpty) {
          _supportName = resolvedSupportName;
        }

        if (_supportImage.isEmpty && resolvedSupportImage.isNotEmpty) {
          _supportImage = resolvedSupportImage;
        }
      }
    }

    if (previousConversationId != _conversationId) {
      _joined = false;
    }

    _joinConversationIfReady();

    if (_socketProvider!.isConnected &&
        _userId.isNotEmpty &&
        _supportUserId.isNotEmpty) {
      _socketProvider!.emitUserStatus(
        userId: _userId,
        checkUserId: _supportUserId,
      );
    }

    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _extractConversationId(Map<String, dynamic> item) {
    return (item['conversation_id'] ?? item['_id'] ?? '').toString().trim();
  }

  String _extractSupportUserId(Map<String, dynamic> item) {
    final candidates = [
      item['receiver_id'],
      item['user_id'],
      item['target_user_id'],
      item['other_user_id'],
      item['admin_id'],
    ];

    for (final value in candidates) {
      if (value == null) continue;
      if (value is Map) {
        final id =
            (value['_id'] ?? value['user_id'] ?? value['id'] ?? '').toString();
        if (id.isNotEmpty && id != _userId) return id;
      } else {
        final id = value.toString().trim();
        if (id.isNotEmpty && id != _userId) return id;
      }
    }

    final users = item['users'];
    if (users is List) {
      for (final user in users) {
        if (user is Map) {
          final id =
              (user['_id'] ?? user['user_id'] ?? user['id'] ?? '').toString();
          if (id.isNotEmpty && id != _userId) return id;
        }
      }
    }

    return '';
  }

  String _extractSupportName(Map<String, dynamic> item) {
    final value = item['receiver_name'] ?? item['name'] ?? item['title'];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }

    final receiverObj = item['receiver_id'];
    if (receiverObj is Map) {
      final name =
          (receiverObj['name'] ?? receiverObj['full_name'] ?? '').toString();
      if (name.trim().isNotEmpty) return name.trim();
    }

    return '';
  }

  String _extractSupportImage(Map<String, dynamic> item) {
    final value = item['receiver_image'] ?? item['image'];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }

    final receiverObj = item['receiver_id'];
    if (receiverObj is Map) {
      final image = (receiverObj['profile_image'] ?? receiverObj['image'] ?? '')
          .toString();
      if (image.trim().isNotEmpty) return image.trim();
    }

    return '';
  }

  void _joinConversationIfReady() {
    if (!mounted || _socketProvider == null) return;
    if (_joined) return;
    if (_userId.isEmpty || _conversationId.isEmpty) return;
    if (!_socketProvider!.isConnected) return;

    debugPrint(
      'ChatSupport join+fetch => userId=$_userId conversationId=$_conversationId',
    );
    _socketProvider!.joinConversationChat(
      userId: _userId,
      conversationId: _conversationId,
      firstPageLimit: 50,
    );
    _joined = true;
  }

  bool _isMineMessage(Map<String, dynamic> message) {
    final senderId = (message['sender_id'] ?? '').toString().trim();
    return senderId.isNotEmpty && senderId == _userId;
  }

  String _messageText(Map<String, dynamic> message) {
    return (message['message'] ?? '').toString();
  }

  String _messageConversationId(Map<String, dynamic> message) {
    return (message['conversation_id'] ??
            message['conversationId'] ??
            message['conversation']?['_id'] ??
            '')
        .toString()
        .trim();
  }

  void _sendMessage() {
    final text = messageTextEditingController.text.trim();
    if (text.isEmpty) return;

    final socketProvider = Provider.of<SocketProvider>(context, listen: false);
    final receiverIdToUse =
        _supportUserId.isNotEmpty ? _supportUserId : _defaultSupportUserId;

    if (_userId.isEmpty) {
      debugPrint(
        'ChatSupport not ready => userId=$_userId conversationId=$_conversationId supportUserId=$_supportUserId receiverIdToUse=$receiverIdToUse',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat is not ready yet.')),
      );
      return;
    }

    debugPrint(
      'ChatSupport send => sender=$_userId receiver=$receiverIdToUse conversation=$_conversationId',
    );

    socketProvider.sendConversationMessage(
      senderId: _userId,
      senderName: _userName,
      senderImage: _userImage,
      receiverId: receiverIdToUse,
      receiverName: _supportName,
      receiverImage: _supportImage,
      conversationId: _conversationId,
      message: text,
      senderModel: 'User',
      receiverModel: 'Admin',
      files: const [],
    );

    messageTextEditingController.clear();
    FocusScope.of(context).unfocus();
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
    _scrollController.dispose();
    super.dispose();
  }

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
            SizedBox(height: size.height * 2 / 100),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 4 / 100),
              child: Row(
                children: [
                  Text(
                    _supportName,
                    style: TextStyle(
                      color: AppColor.secondryColor(context),
                      fontSize: 13,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: size.width * 2 / 100),
                  Consumer<SocketProvider>(
                    builder: (context, socketProvider, _) {
                      final isOnline =
                          socketProvider.isCheckedUserOnline == true;
                      return Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isOnline ? Colors.greenAccent : Colors.white54,
                          fontSize: 12,
                          fontFamily: AppFont.fontFamily,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 1.5 / 100),
            Expanded(
              child: _isBootstrapping
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.buttonColor,
                      ),
                    )
                  : Consumer<SocketProvider>(
                      builder: (context, socketProvider, child) {
                        final messages = socketProvider.messages.where((m) {
                          if (_conversationId.isEmpty) return false;
                          return _messageConversationId(m) == _conversationId;
                        }).toList();

                        if (_userId.isEmpty) {
                          return const Center(
                            child: Text(
                              'Unable to load user session.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          );
                        }

                        if (_conversationId.isEmpty) {
                          return const Center(
                            child: Text(
                              'Loading support conversation...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          );
                        }

                        if (messages.isEmpty) {
                          return const Center(
                            child: Text(
                              'No previous messages. Start chatting with support.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 4 / 100,
                            vertical: size.height * 1 / 100,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final mine = _isMineMessage(message);
                            final text = _messageText(message);

                            return Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: size.height * 1.2 / 100,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? AppColor.buttonColor
                                      : const Color(0xff262626),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            SizedBox(
              width: size.width * 90 / 100,
              child: TextFormField(
                cursorColor: AppColor.secondryColor(context),
                style: TextStyle(
                  height: 1,
                  color: AppColor.secondryColor(context),
                ),
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
                maxLength: AppConstant.describeLength,
                controller: messageTextEditingController,
                onFieldSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  isDense: true,
                  suffixIconConstraints: BoxConstraints(
                    maxWidth: size.width * 30 / 100,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Image.asset(
                            AppImage.shareImg,
                            height: size.width * 7 / 100,
                            width: size.width * 7 / 100,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        SizedBox(width: size.width * 3 / 100),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Image.asset(
                            AppImage.plusIcon,
                            height: size.width * 7 / 100,
                            width: size.width * 7 / 100,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        SizedBox(width: size.width * 3 / 100),
                      ],
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.washpressColor),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.washpressColor),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColor.washpressColor),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
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
                    fontSize: 16,
                  ),
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
