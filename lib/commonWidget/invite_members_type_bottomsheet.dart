// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import '../controller/invite/invite_event_venue_list_controller.dart';
import '../utilities/app_color.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../utilities/app_language.dart';
import '../view/other/chats/chat_message_screen.dart';

Future<Map<String, dynamic>?> showInviteMembersTypeBottomSheet(
  BuildContext context, {
  required String receiverId,
  required String receiverName,
  required String receiverImage,
  String? conversationId,
  bool returnSelectionOnly = false,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    context: context,
    builder: (_) => _InviteMembersTypeBottomSheet(
      parentContext: context,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverImage: receiverImage,
      conversationId: conversationId,
      returnSelectionOnly: returnSelectionOnly,
    ),
  );
}

class _InviteMembersTypeBottomSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String? conversationId;
  final bool returnSelectionOnly;

  const _InviteMembersTypeBottomSheet({
    required this.parentContext,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    this.conversationId,
    this.returnSelectionOnly = false,
  });

  @override
  State<_InviteMembersTypeBottomSheet> createState() =>
      _InviteMembersTypeBottomSheetState();
}

class _InviteMembersTypeBottomSheetState
    extends State<_InviteMembersTypeBottomSheet> {
  int selectedIndex = 0;
  final Set<String> _sentIds = <String>{};
  late final ScrollController _eventScrollController;
  late final ScrollController _venueScrollController;

  @override
  void initState() {
    super.initState();
    _eventScrollController = ScrollController()..addListener(_onEventScroll);
    _venueScrollController = ScrollController()..addListener(_onVenueScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InviteEventVenueListController>().fetchInitial(context);
    });
  }

  @override
  void dispose() {
    _eventScrollController.dispose();
    _venueScrollController.dispose();
    super.dispose();
  }

  void _onEventScroll() {
    if (_eventScrollController.position.pixels >=
        _eventScrollController.position.maxScrollExtent - 120) {
      context.read<InviteEventVenueListController>().loadMoreEvents(context);
    }
  }

  void _onVenueScroll() {
    if (_venueScrollController.position.pixels >=
        _venueScrollController.position.maxScrollExtent - 120) {
      context.read<InviteEventVenueListController>().loadMoreVenues(context);
    }
  }

  String _str(dynamic value) => (value ?? '').toString().trim();

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final resolved = _str(value);
      if (resolved.isNotEmpty) return resolved;
    }
    return '';
  }

  Map<String, dynamic> _sharedItemPayload(
    Map<String, dynamic> item, {
    required bool isEvent,
  }) {
    final id = _firstNonEmpty(<dynamic>[
      item['_id'],
      item['id'],
      item[isEvent ? 'event_id' : 'venue_id'],
    ]);
    final name = _firstNonEmpty(<dynamic>[
      item['name'],
      item['title'],
      item[isEvent ? 'event_name' : 'venue_name'],
    ]);
    final image = _firstNonEmpty(<dynamic>[
      item['image'],
      item[isEvent ? 'event_image' : 'venue_image'],
    ]);
    final time = _firstNonEmpty(<dynamic>[
      item['time'],
      item['date'],
      item['timing'],
      item[isEvent ? 'date' : 'timing'],
    ]);
    final address = _firstNonEmpty(<dynamic>[
      item['address'],
      item['location'],
      item[isEvent ? 'address' : 'address'],
    ]);
    return <String, dynamic>{
      ...item,
      'type': isEvent ? 'event' : 'venue',
      'entity_type': isEvent ? 'event' : 'venue',
      '_id': id,
      'id': id,
      'name': name,
      'image': image,
      'time': time,
      'address': address,
      if (isEvent) 'event_id': id,
      if (isEvent) 'event_name': name,
      if (isEvent) 'event_image': image,
      if (isEvent) 'event_time': time,
      if (isEvent) 'event_address': address,
      if (!isEvent) 'venue_id': id,
      if (!isEvent) 'venue_name': name,
      if (!isEvent) 'venue_image': image,
      if (!isEvent) 'venue_time': time,
      if (!isEvent) 'venue_address': address,
      if (isEvent) 'date': time,
      if (!isEvent) 'timing': time,
    };
  }

  String _fullImage(String path) {
    final p = _str(path);
    if (p.isEmpty) return '';
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    return '${AppConfigProvider.imageUrl}$p';
  }

  ImageProvider _providerFor(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    return AssetImage(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, (1 - value) * size.height * 0.3),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: Container(
        width: size.width,
        height: size.height * 0.6,
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColor.backgroundGradientcolor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(46),
              topRight: Radius.circular(46),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Image.asset(
                AppImage.dashIcon,
                height: size.height * 0.005,
                width: size.width * 0.28,
                fit: BoxFit.fill,
                color: AppColor.secondryColor(context),
              ),
              SizedBox(height: size.height * 0.02),
              _tabs(context, size),
              _tabIndicator(context),
              SizedBox(height: size.height * 0.02),
              Expanded(
                child: Consumer<InviteEventVenueListController>(
                  builder: (context, controller, _) {
                    final isEvent = selectedIndex == 0;
                    final loading = isEvent
                        ? controller.isEventLoading
                        : controller.isVenueLoading;
                    final loadingMore = isEvent
                        ? controller.isEventLoadingMore
                        : controller.isVenueLoadingMore;
                    final items =
                        isEvent ? controller.eventItems : controller.venueItems;
                    if (loading && items.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColor.buttonColor,
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      controller: isEvent
                          ? _eventScrollController
                          : _venueScrollController,
                      key: ValueKey<int>(selectedIndex),
                      child: Column(
                        children: [
                          ...List.generate(items.length, (index) {
                            final item = items[index];
                            final id = _str(item['id']);
                            final key =
                                '${selectedIndex}_${id.isEmpty ? index : id}';
                            final isSend = _sentIds.contains(key);
                            final name = _str(item['name']);
                            final categories = _str(item['categories']);
                            final image = _fullImage(_str(item['image']));
                            final resolved =
                                image.isEmpty ? AppImage.dummyImageIcon : image;
                            return Column(
                              children: [
                                SizedBox(
                                  width: size.width * 0.9,
                                  height: size.height * 0.085,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      height: size.width * 0.13,
                                      width: size.width * 0.13,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image(
                                          image: _providerFor(resolved),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset(
                                            AppImage.dummyImageIcon,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Container(
                                          width: size.width * 0.35,
                                          child: Text(
                                            name,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.02),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 0.02,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: AppColor.pinkColor,
                                                width: .3),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            isEvent
                                                ? AppLanguage
                                                    .eventsText[language]
                                                : AppLanguage
                                                    .venuesText[language],
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      categories,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColor.secondryColor(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        setState(() => _sentIds.add(key));
                                        final sharedItem = _sharedItemPayload(
                                          item,
                                          isEvent: isEvent,
                                        );
                                        print(
                                          '[InviteMembersTypeBottomSheet] itemTap => '
                                          'receiverId=${widget.receiverId}, receiverName=${widget.receiverName}, '
                                          'shareItem=$sharedItem',
                                        );
                                        if (widget.returnSelectionOnly) {
                                          Navigator.of(context).pop(sharedItem);
                                          return;
                                        }
                                        Navigator.of(context).pop();
                                        Future.delayed(
                                            const Duration(milliseconds: 200),
                                            () {
                                          if (!widget.parentContext.mounted) {
                                            return;
                                          }
                                          Navigator.push(
                                            widget.parentContext,
                                            PageTransition(
                                              type: PageTransitionType
                                                  .bottomToTop,
                                              child: ChatMessageScreen(
                                                name: widget.receiverName,
                                                image: widget.receiverImage,
                                                receiverId: widget.receiverId,
                                                conversationId:
                                                    widget.conversationId,
                                                sharedEventData: sharedItem,
                                                autoSendSharedEvent: true,
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 17, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isSend
                                              ? AppColor.logoutContainerColor(
                                                  context)
                                              : AppColor.secondryColor(context),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: isSend
                                              ? Border.all(
                                                  color: AppColor.buttonColor,
                                                  width: 1)
                                              : null,
                                        ),
                                        child: Text(
                                          isSend ? 'Done' : 'Send',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppFont.fontFamily,
                                            color: isSend
                                                ? AppColor.secondryColor(
                                                    context)
                                                : AppColor.primaryColor(
                                                    context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.001),
                              ],
                            );
                          }),
                          if (loadingMore)
                            Center(
                              child: CircularProgressIndicator(
                                color: AppColor.buttonColor,
                              ),
                            )
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabs(BuildContext context, Size size) {
    Widget tab(String text, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size.width * 0.45,
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColor.secondryColor(context)
                    : AppColor.greyLightColor(context),
                fontSize: selected ? 16 : 15,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: size.height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          tab(AppLanguage.eventsText[language], selectedIndex == 0, () {
            setState(() => selectedIndex = 0);
          }),
          tab(AppLanguage.venuesText[language], selectedIndex == 1, () {
            setState(() => selectedIndex = 1);
          }),
        ],
      ),
    );
  }

  Widget _tabIndicator(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 2,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 2,
            color: AppColor.greyLightColor(context).withOpacity(0.3),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: selectedIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: MediaQuery.of(context).size.width * 0.45,
              height: 3,
              decoration: BoxDecoration(
                color: AppColor.secondryColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
