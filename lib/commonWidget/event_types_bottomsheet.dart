// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/members/conversion_list_controller.dart';
import '../controller/invite/invite_event_venue_list_controller.dart';
import '../utilities/app_color.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../view/other/chats/chat_message_screen.dart';

void showEventTypesBottomSheet(
  BuildContext context, {
  required String type,
  required String id,
  Map<String, dynamic>? sharedEventData,
}) {
  showModalBottomSheet<void>(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    context: context,
    builder: (_) => _InviteMembersBottomSheet(
      parentContext: context,
      type: type,
      id: id,
      sharedEventData: sharedEventData,
    ),
  );
}

class _InviteMembersBottomSheet extends StatefulWidget {
  final BuildContext parentContext;
  final String type;
  final String id;
  final Map<String, dynamic>? sharedEventData;

  const _InviteMembersBottomSheet({
    required this.parentContext,
    required this.type,
    required this.id,
    this.sharedEventData,
  });

  @override
  State<_InviteMembersBottomSheet> createState() =>
      _InviteMembersBottomSheetState();
}

class _InviteMembersBottomSheetState extends State<_InviteMembersBottomSheet> {
  final Set<String> _sentIds = <String>{};
  late final ScrollController _membersScrollController;
  final List<String> shareIcons = const [
    'assets/icons/shareIcon.png',
    'assets/icons/whatsappIcon.png',
    'assets/icons/instaIcon.png',
    'assets/icons/snapIcon.png',
  ];

  String get _readableDeepLinkUrl =>
      '${AppConfigProvider.apiUrl}common/deepLink?type=${widget.type}&id=${widget.id}&link=hii://${widget.type}/${widget.id}';

  String get _appSchemeLink => 'hii://${widget.type}/${widget.id}';

  String get _shareText =>
      'Check this ${widget.type} on Hii app.\n$_appSchemeLink\n$_readableDeepLinkUrl';

  Future<bool> _safeLaunchExternal(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _membersScrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InviteEventVenueListController>().fetchMembers(
            context,
            page: 0,
            limit: 10,
            reset: true,
          );
    });
  }

  @override
  void dispose() {
    _membersScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_membersScrollController.position.pixels >=
        _membersScrollController.position.maxScrollExtent - 120) {
      context.read<InviteEventVenueListController>().loadMoreMembers(context);
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

  Map<String, dynamic> _sharedItemPayload() {
    final source = widget.sharedEventData == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(widget.sharedEventData!);
    final isVenue = widget.type.toLowerCase() == 'venue';
    final type = isVenue ? 'venue' : 'event';
    final id = _firstNonEmpty(<dynamic>[
      source['_id'],
      source['id'],
      source[isVenue ? 'venue_id' : 'event_id'],
      widget.id,
    ]);
    final name = _firstNonEmpty(<dynamic>[
      source['name'],
      source['title'],
      source[isVenue ? 'venue_name' : 'event_name'],
    ]);
    final image = _firstNonEmpty(<dynamic>[
      source['image'],
      source[isVenue ? 'venue_image' : 'event_image'],
      source['profile_image'],
    ]);
    final time = _firstNonEmpty(<dynamic>[
      source['time'],
      source['date'],
      source['timing'],
      source[isVenue ? 'venue_time' : 'event_time'],
      source['event_date'],
    ]);
    final address = _firstNonEmpty(<dynamic>[
      source['address'],
      source['location'],
      source[isVenue ? 'venue_address' : 'event_address'],
      source['venue_location'],
    ]);
    final about =
        _firstNonEmpty(<dynamic>[source['about'], source['description']]);
    final categories = source['categories'];

    return <String, dynamic>{
      ...source,
      'type': type,
      'entity_type': type,
      'id': id,
      '_id': id,
      'name': name,
      'image': image,
      'time': time,
      'address': address,
      if (about.isNotEmpty) 'about': about,
      if (categories != null) 'categories': categories,
      if (isVenue) 'venue_id': id,
      if (isVenue) 'venue_name': name,
      if (isVenue) 'venue_image': image,
      if (isVenue) 'venue_time': time,
      if (isVenue) 'timing': time,
      if (isVenue) 'venue_address': address,
      if (!isVenue) 'event_id': id,
      if (!isVenue) 'event_name': name,
      if (!isVenue) 'event_image': image,
      if (!isVenue) 'event_time': time,
      if (!isVenue) 'date': time,
      if (!isVenue) 'event_address': address,
    };
  }

  String _memberId(Map<String, dynamic> item) =>
      _str(item['id'].toString() == 'null' ? '' : item['id']).isNotEmpty
          ? _str(item['id'])
          : _str(item['user_id']).isNotEmpty
              ? _str(item['user_id'])
              : _str(item['_id']);

  String _memberName(Map<String, dynamic> item) =>
      _str(item['full_name']).isNotEmpty
          ? _str(item['full_name'])
          : _str(item['name']);

  String _memberImage(Map<String, dynamic> item) =>
      _str(item['profile_image']).isNotEmpty
          ? _str(item['profile_image'])
          : _str(item['image']);

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

  Future<void> _handleShareTap(int index) async {
    Navigator.pop(context);
    if (index == 0) {
      await Share.share(_shareText);
      return;
    }

    if (index == 1) {
      final uri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(_shareText)}',
      );
      final launched = await _safeLaunchExternal(uri);
      if (!launched) {
        await Share.share(_shareText);
      }
      return;
    }

    if (index == 2) {
      final appLaunch = await _safeLaunchExternal(Uri.parse('instagram://app'));
      if (!appLaunch) {
        final webLaunch =
            await _safeLaunchExternal(Uri.parse('https://www.instagram.com/'));
        if (!webLaunch) {
          await Share.share(_shareText);
        }
      }
      return;
    }

    if (index == 3) {
      final appLaunch = await _safeLaunchExternal(Uri.parse(
        'snapchat://share?text=${Uri.encodeComponent(_shareText)}',
      ));
      if (!appLaunch) {
        final webLaunch =
            await _safeLaunchExternal(Uri.parse('https://www.snapchat.com/'));
        if (!webLaunch) {
          await Share.share(_shareText);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<InviteEventVenueListController>(
      builder: (context, controller, _) {
        final bool hasMembers =
            !controller.isMembersLoading && controller.memberItems.isNotEmpty;

        final double sheetHeight =
            hasMembers ? size.height * 0.6 : size.height * 0.38;
        // ─────────────────────────────────────────────────────────────────

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
            // ── CHANGE: dynamic height ──
            height: sheetHeight,
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
                  SizedBox(height: size.height * 0.01),

                  // ── Share icons row ──────────────────────────────────
                  Center(
                    child: SizedBox(
                      width: size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(shareIcons.length, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 3 / 100,
                              vertical: size.height * 2 / 100,
                            ),
                            child: GestureDetector(
                              onTap: () => _handleShareTap(index),
                              child: Image.asset(
                                shareIcons[index],
                                width: size.width * 14 / 100,
                                height: size.width * 14 / 100,
                                fit: BoxFit.cover,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),
                  Divider(
                    height: 0.1,
                    thickness: 0.5,
                    color: AppColor.secondryColor(context),
                    indent: 28,
                    endIndent: 28,
                  ),
                  SizedBox(height: size.height * 0.015),

                  // ── Members section ──────────────────────────────────
                  Expanded(
                    child: _buildMembersSection(
                      context,
                      controller,
                      size,
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembersSection(
    BuildContext context,
    InviteEventVenueListController controller,
    Size size,
  ) {
    // Loading state
    if (controller.isMembersLoading && controller.memberItems.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: AppColor.buttonColor),
      );
    }

    // ── CHANGE: Empty state ──────────────────────────────────────────────
    if (controller.memberItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 38,
              color: AppColor.secondryColor(context).withOpacity(0.4),
            ),
            SizedBox(height: size.height * 0.012),
            Text(
              'No members found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: AppFont.fontFamily,
                color: AppColor.secondryColor(context).withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }
    // ────────────────────────────────────────────────────────────────────

    // Normal list
    return SingleChildScrollView(
      controller: _membersScrollController,
      child: Column(
        children: [
          ...List.generate(controller.memberItems.length, (index) {
            final item = controller.memberItems[index];
            final id = _memberId(item);
            final key = id.isEmpty ? index.toString() : id;
            final isSend = _sentIds.contains(key);
            final name = _memberName(item);
            final username = _str(item['username']);
            final image = _fullImage(_memberImage(item));
            final resolved = image.isEmpty ? AppImage.dummyImageIcon : image;

            return Column(
              children: [
                SizedBox(
                  width: size.width * 0.9,
                  height: size.height * 0.085,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SizedBox(
                      height: size.width * 0.13,
                      width: size.width * 0.13,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image(
                          image: _providerFor(resolved),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            AppImage.dummyImageIcon,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      name,
                      maxLines: 2,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColor.secondryColor(context),
                      ),
                    ),
                    subtitle: Text(
                      username.isEmpty ? '' : '@$username',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColor.secondryColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: GestureDetector(
                      onTap: () async {
                        setState(() => _sentIds.add(key));
                        print(
                          '[EventShareBottomSheet] memberTap => '
                          'memberId=$id, memberName=$name, memberImage=$resolved, '
                          'shareType=${widget.type}, sharedEventData=${widget.sharedEventData}',
                        );
                        final conversationController =
                            Provider.of<ConversionListController>(
                          context,
                          listen: false,
                        );
                        final conversationId = await conversationController
                            .fetchConversationIdByUserId(otherUserId: id);
                        if (!mounted) return;
                        final sharedItem = _sharedItemPayload();
                        Navigator.of(context).pop();
                        Future.delayed(const Duration(milliseconds: 200), () {
                          if (!widget.parentContext.mounted) return;
                          Navigator.push(
                            widget.parentContext,
                            PageTransition(
                              type: PageTransitionType.bottomToTop,
                              child: ChatMessageScreen(
                                name: name,
                                image: resolved,
                                receiverId: id,
                                conversationId: conversationId.isEmpty
                                    ? null
                                    : conversationId,
                                sharedEventData: sharedItem,
                                autoSendSharedEvent: true,
                              ),
                            ),
                          );
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isSend
                              ? AppColor.logoutContainerColor(context)
                              : AppColor.secondryColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: isSend
                              ? Border.all(
                                  color: AppColor.buttonColor,
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Text(
                          isSend ? 'Done' : 'Send',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontFamily,
                            color: isSend
                                ? AppColor.secondryColor(context)
                                : AppColor.primaryColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.002),
              ],
            );
          }),
          if (controller.isMembersLoadingMore)
            Center(
              child: CircularProgressIndicator(color: AppColor.buttonColor),
            ),
        ],
      ),
    );
  }
}
