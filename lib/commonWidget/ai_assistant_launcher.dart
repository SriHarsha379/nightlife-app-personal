import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/ai_assistant_provider.dart';
import '../provider/darkmode_provider.dart';
import '../utilities/app_color.dart';
import '../utilities/app_font.dart';

/// Floating launcher for the AI concierge — shown on Members, Venues and
/// Events (see AiAssistantProvider doc comment). Tapping the owl button
/// opens a chat panel; the panel's header has a close (X) to dismiss it
/// back down to just the button. Uses the same backend (`chat/send`) and
/// conversation state as any other AI-assistant entry point in the app,
/// so per the client's ask this is "the same assistant, just available
/// here too" rather than a separate one.
class AiAssistantLauncher extends StatelessWidget {
  const AiAssistantLauncher({super.key});

  void _openAssistantSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const _AiAssistantPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openAssistantSheet(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.pinkColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // Placeholder owl mark — swap for the illustrated owl asset once
        // design provides one; kept as a simple glyph so the feature is
        // fully functional without waiting on final art.
        child: const Center(
          child: Text('🦉', style: TextStyle(fontSize: 28)),
        ),
      ),
    );
  }
}

class _AiAssistantPanel extends StatefulWidget {
  const _AiAssistantPanel();

  @override
  State<_AiAssistantPanel> createState() => _AiAssistantPanelState();
}

class _AiAssistantPanelState extends State<_AiAssistantPanel> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _inputController.text;
    if (text.trim().isEmpty) return;
    _inputController.clear();
    final provider = Provider.of<AiAssistantProvider>(context, listen: false);
    await provider.sendMessage(context, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: size.height * 0.65,
        decoration: BoxDecoration(
          color: AppColor.primaryColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.grayColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🦉', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        "AI Assistant",
                        style: TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.secondryColor(context),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.grayColor.withOpacity(0.15),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColor.secondryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Consumer<AiAssistantProvider>(
                builder: (context, provider, child) {
                  if (provider.messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Ask me about venues, events, or anything happening tonight.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 14,
                            color: AppColor.filledText(context),
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      final isUser = message.role == 'user';
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? AppColor.pinkColor
                                : AppColor.filledcolor(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 14,
                              color: isUser
                                  ? Colors.white
                                  : AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<AiAssistantProvider>(
              builder: (context, provider, child) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColor.filledcolor(context),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _inputController,
                            enabled: !provider.isSending,
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontFamily: AppFont.fontFamily,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Ask something...",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: provider.isSending ? null : _send,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.pinkColor,
                          ),
                          child: provider.isSending
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.arrow_upward,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}