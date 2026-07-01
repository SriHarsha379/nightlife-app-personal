import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../provider/ai_companion_provider.dart';
import '../../../provider/user_controller.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';

class AiCompanionChatScreen extends StatefulWidget {
  static String routeName = './AiCompanionChatScreen';

  final String personaName;
  final String personaImage;
  final String personaId;

  const AiCompanionChatScreen({
    super.key,
    this.personaName = 'Aria',
    this.personaImage = AppImage.placeHolder2Icon,
    this.personaId = 'default',
  });

  @override
  State<AiCompanionChatScreen> createState() => _AiCompanionChatScreenState();
}

class _AiCompanionChatScreenState extends State<AiCompanionChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _userId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userController =
          Provider.of<UserController>(context, listen: false);
      await userController.getUserDetails();
      _userId = userController.getUserId.trim();

      final aiProvider = Provider.of<AiCompanionProvider>(context, listen: false);
      await aiProvider.loadHistory(userId: _userId);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (text.trim().isEmpty || _userId.isEmpty) return;
    Provider.of<AiCompanionProvider>(context, listen: false).sendMessage(
      userId: _userId,
      text: text,
      personaId: widget.personaId,
    );
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  ImageProvider _avatar() {
    final img = widget.personaImage;
    if (img.startsWith('http')) return NetworkImage(img);
    return AssetImage(img);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: size.height * 0.09,
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: AppColor.secondryColor(context)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CircleAvatar(backgroundImage: _avatar(), radius: 20),
                  SizedBox(width: size.width * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.personaName,
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'AI Companion',
                        style: TextStyle(
                          color: AppColor.buttonColor,
                          fontFamily: AppFont.fontFamily,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AiCompanionProvider>(
                builder: (context, aiProvider, _) {
                  final messages = aiProvider.messages;
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());

                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Say hi to ${widget.personaName} 👋',
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.04,
                      vertical: 10,
                    ),
                    itemCount:
                        messages.length + (aiProvider.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && aiProvider.isSending) {
                        return _typingBubble(context);
                      }
                      final message = messages[index];
                      final mine = message['role'] == 'user';
                      final isError = message['__error'] == true;
                      return Align(
                        alignment: mine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints:
                              BoxConstraints(maxWidth: size.width * 0.7),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isError
                                ? Colors.red.withOpacity(0.15)
                                : mine
                                    ? AppColor.buttonColor
                                    : AppColor.washpressColor,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft:
                                  Radius.circular(mine ? 18 : 4),
                              bottomRight:
                                  Radius.circular(mine ? 4 : 18),
                            ),
                          ),
                          child: Text(
                            (message['message'] ?? '').toString(),
                            style: TextStyle(
                              color: mine
                                  ? Colors.white
                                  : AppColor.secondryColor(context),
                              fontFamily: AppFont.fontFamily,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.04,
                right: size.width * 0.04,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                top: 6,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(color: AppColor.secondryColor(context)),
                      decoration: InputDecoration(
                        hintText: 'Message ${widget.personaName}',
                        filled: true,
                        fillColor: AppColor.washpressColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Consumer<AiCompanionProvider>(
                    builder: (context, aiProvider, _) => IconButton(
                      icon: const Icon(Icons.send, color: AppColor.buttonColor),
                      onPressed: aiProvider.isSending ? null : _send,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typingBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColor.washpressColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: SizedBox(
          width: 30,
          height: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (i) => CircleAvatar(
                radius: 2.5,
                backgroundColor: AppColor.secondryColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
