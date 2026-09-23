import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/ai_assistant_provider.dart';
import '../provider/user_controller.dart';
import '../utilities/app_color.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_font.dart';
import '../view/other/MySplashSection/EventSection/Liked/Liked_event_details.dart';
import '../view/other/MySplashSection/VenuesSection/venuepages.dart';
import 'owl_mascot.dart';

/// Floating owl button (Home): the DJ owl peeking into a neon ring with a
/// soft pulsing glow. Presses in on tap; shows music notes while a reply is
/// being worked on. Opens Hii Owl in a bottom sheet.
class AiAssistantLauncher extends StatefulWidget {
  const AiAssistantLauncher({super.key});

  @override
  State<AiAssistantLauncher> createState() => _AiAssistantLauncherState();
}

class _AiAssistantLauncherState extends State<AiAssistantLauncher> {
  bool _pressed = false;

  void _openAssistantSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(sheetContext).size.height * 0.86,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: OwlChatView(onClose: () => Navigator.pop(sheetContext)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.select<AiAssistantProvider, bool>((p) => p.isSending);
    return Semantics(
      button: true,
      label: 'Hii Owl assistant',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () => _openAssistantSheet(context),
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: OwlBadge(
            size: 66,
            glow: true,
            mood: busy ? OwlMood.thinking : OwlMood.idle,
          ),
        ),
      ),
    );
  }
}

/// The Hii Owl chat - used inside the bottom sheet and full-screen (Chats tab).
class OwlChatView extends StatefulWidget {
  /// Close (X) in the sheet, back arrow when full-screen.
  final VoidCallback? onClose;
  final bool fullScreen;

  const OwlChatView({super.key, this.onClose, this.fullScreen = false});

  @override
  State<OwlChatView> createState() => _OwlChatViewState();
}

class _OwlChatViewState extends State<OwlChatView> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastSignature = -1;
  bool _wasSending = false;
  DateTime? _happyUntil;
  Timer? _happyTimer;

  /// Thinking while working, a short happy smile when a reply lands.
  OwlMood _moodFor(AiAssistantProvider provider) {
    if (_wasSending && !provider.isSending) {
      _happyUntil = DateTime.now().add(const Duration(milliseconds: 2200));
      _happyTimer?.cancel();
      _happyTimer = Timer(const Duration(milliseconds: 2300), () {
        if (mounted) setState(() {});
      });
    }
    _wasSending = provider.isSending;
    if (provider.isSending) return OwlMood.thinking;
    final until = _happyUntil;
    if (until != null && DateTime.now().isBefore(until)) return OwlMood.happy;
    return OwlMood.idle;
  }

  @override
  void dispose() {
    _happyTimer?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    final provider = context.read<AiAssistantProvider>();
    if (provider.isSending) return;
    _input.clear();
    provider.sendMessage(context, text);
    _scrollToBottomSoon();
  }

  String _firstName(BuildContext context) {
    // Provider.of(listen: false) is allowed during build; context.read is not.
    final user = Provider.of<UserController>(context, listen: false);
    final first = user.getFirstName.trim();
    if (first.isNotEmpty) return first;
    final full = user.getUserName.trim();
    return full.isEmpty ? '' : full.split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context) {
    final bg = AppColor.primaryColor(context);
    final fg = AppColor.secondryColor(context);
    final provider = context.watch<AiAssistantProvider>();
    final messages = provider.messages;
    final mood = _moodFor(provider);

    final signature = messages.length * 100000 +
        (messages.isEmpty ? 0 : messages.last.content.length + messages.last.cards.length) +
        (provider.status == null ? 0 : 1);
    if (signature != _lastSignature) {
      _lastSignature = signature;
      _scrollToBottomSoon();
    }

    return Material(
      color: bg,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.pinkColor.withOpacity(0.10), bg, bg],
            stops: const [0, 0.35, 1],
          ),
        ),
        child: SafeArea(
        top: widget.fullScreen,
        child: Column(
          children: [
            _header(context, fg, provider, mood),
            Divider(height: 1, color: fg.withOpacity(0.1)),
            Expanded(
              child: messages.isEmpty
                  ? _welcome(context, fg, mood)
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      itemCount: messages.length,
                      itemBuilder: (context, i) => _Appear(
                        key: ValueKey('owl-msg-$i'),
                        child: _messageItem(
                          context,
                          messages[i],
                          fg,
                          status: i == messages.length - 1 ? provider.status : null,
                          isLast: i == messages.length - 1,
                        ),
                      ),
                    ),
            ),
            _inputBar(context, fg, provider),
          ],
        ),
      ),
      ),
    );
  }

  // ------------------------------------------------------------- header
  Widget _header(BuildContext context, Color fg, AiAssistantProvider provider, OwlMood mood) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Row(
        children: [
          if (widget.fullScreen && widget.onClose != null)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: fg, size: 20),
              onPressed: widget.onClose,
            )
          else
            const SizedBox(width: 8),
          OwlBadge(size: 44, mood: mood),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hii Owl',
                    style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: fg)),
                Text(provider.isSending ? (provider.status ?? 'typing…') : 'Your nightlife guide · online',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 12,
                        color: provider.isSending
                            ? AppColor.pinkColor
                            : fg.withOpacity(0.6))),
              ],
            ),
          ),
          if (provider.messages.isNotEmpty)
            IconButton(
              tooltip: 'New chat',
              icon: Icon(Icons.refresh_rounded, color: fg.withOpacity(0.8)),
              onPressed: () => context.read<AiAssistantProvider>().clearConversation(),
            ),
          if (!widget.fullScreen && widget.onClose != null)
            IconButton(
              tooltip: 'Close',
              icon: Icon(Icons.close_rounded, color: fg.withOpacity(0.8)),
              onPressed: widget.onClose,
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ welcome
  Widget _welcome(BuildContext context, Color fg, OwlMood mood) {
    final name = _firstName(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColor.pinkColor.withOpacity(0.22),
                    AppColor.pinkColor.withOpacity(0.0),
                  ]),
                ),
              ),
              OwlMascot(size: 128, mood: mood == OwlMood.idle ? OwlMood.idle : mood),
            ],
          ),
          const SizedBox(height: 8),
          Text(name.isEmpty ? 'Hey there 👋' : 'Hey $name 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: fg)),
          const SizedBox(height: 6),
          Text(
            "I'm Hii Owl, your nightlife guide. Tell me the vibe and I'll find "
            'the spot, with distances, prices and deals.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: AppFont.fontFamily, fontSize: 14, height: 1.4, color: fg.withOpacity(0.72)),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: AiAssistantProvider.suggestions
                .map((s) => _chip(s, fg, () => _send(s)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColor.pinkColor.withOpacity(0.55)),
          gradient: LinearGradient(colors: [
            AppColor.pinkColor.withOpacity(0.14),
            const Color(0xFF7B2FF7).withOpacity(0.10),
          ]),
        ),
        child: Text(label,
            style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 13, color: fg)),
      ),
    );
  }

  // ----------------------------------------------------------- messages
  Widget _messageItem(BuildContext context, AiAssistantMessage m, Color fg, {String? status, bool isLast = false}) {
    if (m.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColor.pinkColor, Color(0xFFB02BE0)]),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(m.content,
              style: const TextStyle(
                  fontFamily: AppFont.fontFamily, fontSize: 14.5, color: Colors.white)),
        ),
      );
    }

    final waiting = m.isStreaming && m.content.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OwlBadge(
                size: 30,
                ring: false,
                animate: isLast && m.isStreaming,
                mood: isLast && m.isStreaming ? OwlMood.thinking : OwlMood.idle,
              ),
              const SizedBox(width: 8),
              Flexible(
            child: Container(
              margin: const EdgeInsets.only(right: 28),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: m.isError ? Colors.red.withOpacity(0.12) : fg.withOpacity(0.07),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: waiting
                  ? _TypingIndicator(label: status, color: fg)
                  : OwlRichText(text: m.content, color: fg),
            ),
              ),
            ],
          ),
          if (m.isStreaming && !waiting && status != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 42),
              child: _TypingIndicator(label: status, color: fg),
            ),
          if (m.cards.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 196,
              child: ListView.separated(
                padding: const EdgeInsets.only(left: 38),
                scrollDirection: Axis.horizontal,
                itemCount: m.cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _OwlResultCard(card: m.cards[i], fg: fg),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --------------------------------------------------------------- input
  Widget _inputBar(BuildContext context, Color fg, AiAssistantProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: fg.withOpacity(0.08))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: fg.withOpacity(0.07),
                borderRadius: BorderRadius.circular(26),
              ),
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 14.5, color: fg),
                cursorColor: AppColor.pinkColor,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Ask Hii Owl…',
                  hintStyle: TextStyle(fontFamily: AppFont.fontFamily, color: fg.withOpacity(0.45)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: provider.isSending ? null : () => _send(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: provider.isSending
                      ? [AppColor.pinkColor.withOpacity(0.35), const Color(0xFF7B2FF7).withOpacity(0.35)]
                      : const [AppColor.pinkColor, Color(0xFF7B2FF7)],
                ),
                boxShadow: provider.isSending
                    ? const []
                    : [BoxShadow(color: AppColor.pinkColor.withOpacity(0.45), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny formatter for the owl's replies: **bold** and "- " bullet lines.
class OwlRichText extends StatelessWidget {
  final String text;
  final Color color;
  const OwlRichText({super.key, required this.text, required this.color});

  static final RegExp _bullet = RegExp(r'^\s*(?:[-*•]|\d+[.)])\s+');

  List<TextSpan> _spans(String line, TextStyle base) {
    final spans = <TextSpan>[];
    final parts = line.split('**');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) continue;
      spans.add(TextSpan(
        text: parts[i],
        style: i.isOdd ? base.copyWith(fontWeight: FontWeight.w700) : base,
      ));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontFamily: AppFont.fontFamily, fontSize: 14.5, height: 1.4, color: color);
    final lines = text.replaceAll('\r', '').split('\n');
    final children = <Widget>[];
    var gap = false;
    for (final raw in lines) {
      final line = raw.trimRight();
      if (line.trim().isEmpty) {
        gap = true;
        continue;
      }
      if (children.isNotEmpty) children.add(SizedBox(height: gap ? 8 : 3));
      gap = false;
      final m = _bullet.firstMatch(line);
      if (m != null) {
        children.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1, right: 6),
              child: Text('•', style: base.copyWith(color: AppColor.pinkColor, fontWeight: FontWeight.w700)),
            ),
            Expanded(child: Text.rich(TextSpan(children: _spans(line.substring(m.end), base)))),
          ],
        ));
      } else {
        children.add(Text.rich(TextSpan(children: _spans(line, base))));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// Bouncing dots + optional status ("Checking events…").
class _TypingIndicator extends StatefulWidget {
  final String? label;
  final Color color;
  const _TypingIndicator({this.label, required this.color});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_c.value - i * 0.18) % 1.0;
              final lift = t < 0.5 ? t * 2 : (1 - t) * 2;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                transform: Matrix4.translationValues(0, -3 * lift, 0),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.pinkColor.withOpacity(0.5 + 0.5 * lift),
                ),
              );
            }),
          ),
        ),
        if ((widget.label ?? '').isNotEmpty) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(widget.label!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: AppFont.fontFamily,
                    fontSize: 12.5,
                    color: widget.color.withOpacity(0.65))),
          ),
        ],
      ],
    );
  }
}

/// Venue/event result card - tap to open the page (Reserve / Get Tickets).
class _OwlResultCard extends StatelessWidget {
  final OwlCard card;
  final Color fg;
  const _OwlResultCard({required this.card, required this.fg});

  String get _imageUrl =>
      card.image.startsWith('http') ? card.image : '${AppConfigProvider.imageUrl}${card.image}';

  void _open(BuildContext context) {
    if (card.id.isEmpty) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => card.isEvent
          ? LikedEventDetail(eventId: card.id)
          : VenuePages(venueId: card.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColor.pinkColor.withOpacity(0.12),
      child: Center(
        child: Icon(card.isEvent ? Icons.event_rounded : Icons.local_bar_rounded,
            color: AppColor.pinkColor),
      ),
    );
    final distance = card.distanceKm == null ? '' : '${card.distanceKm!.toStringAsFixed(1)} km';
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        width: 164,
        decoration: BoxDecoration(
          color: fg.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: fg.withOpacity(0.08)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  card.image.isEmpty
                      ? placeholder
                      : CachedNetworkImage(
                          imageUrl: _imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => placeholder,
                          errorWidget: (_, __, ___) => placeholder,
                        ),
                  if (card.badge.isNotEmpty)
                    Positioned(
                      left: 8,
                      top: 8,
                      right: 8,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: card.badge == 'Sold out' ? Colors.black87 : AppColor.pinkColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(card.badge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Text(card.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: fg)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 0),
              child: Text(
                [card.subtitle, distance].where((s) => s.isNotEmpty).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 12, color: fg.withOpacity(0.6)),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(card.isEvent ? 'Get Tickets ›' : 'Reserve ›',
                  style: const TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.pinkColor)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fade + slide-up for newly added chat messages.
class _Appear extends StatelessWidget {
  final Widget child;
  const _Appear({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      ),
      child: child,
    );
  }
}
