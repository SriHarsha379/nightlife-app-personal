import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/chat/chat_controller.dart';
import '../../utilities/post_api_provider.dart';

/// Chat UI for the AI-powered nightlife recommendations assistant.
/// Push with: Navigator.push(context, PageTransition(
///   type: PageTransitionType.rightToLeftWithFade,
///   child: const NightlifeChatScreen(),
///   duration: const Duration(milliseconds: 400),
/// ));
class NightlifeChatScreen extends StatefulWidget {
  const NightlifeChatScreen({super.key});

  @override
  State<NightlifeChatScreen> createState() => _NightlifeChatScreenState();
}

class _NightlifeChatScreenState extends State<NightlifeChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final chatController = Provider.of<ChatController>(context, listen: false);
    final postApiProvider = Provider.of<PostApiProvider>(context, listen: false);

    chatController.addUserMessage(text);
    _inputController.clear();
    _scrollToBottom();

    final res = await postApiProvider.sendChatMessageApi(
      context,
      chatController.historyForApi(),
    );

    if (!mounted) return;

    if (res != null && res['data'] != null && res['data']['reply'] != null) {
      chatController.addAssistantMessage(res['data']['reply'].toString());
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildSuggestionChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: const Color(0xFF1E1E1E),
      side: const BorderSide(color: Color(0xFF7B2FF7), width: 0.6),
      onPressed: () {
        _inputController.text = label;
        _handleSend();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatController = context.watch<ChatController>();
    final postApiProvider = context.watch<PostApiProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Nightlife Assistant'),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.refresh),
            onPressed: chatController.isEmpty
                ? null
                : () => Provider.of<ChatController>(context, listen: false).clear(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatController.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Ask me about clubs, bars, or events near you 🎶",
                        style: TextStyle(color: Colors.white54, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSuggestionChip("Best rooftop bars in Bangalore"),
                          _buildSuggestionChip("Techno clubs open tonight"),
                          _buildSuggestionChip("Chill lounges for a date"),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: chatController.messages.length,
                itemBuilder: (_, i) {
                  final m = chatController.messages[i];
                  final isUser = m.role == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF7B2FF7) : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        m.content,
                        style: const TextStyle(color: Colors.white, height: 1.35),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (postApiProvider.secondaryLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: "e.g. Best rooftop bar in Bangalore tonight",
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF7B2FF7),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: postApiProvider.secondaryLoading ? null : _handleSend,
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
}