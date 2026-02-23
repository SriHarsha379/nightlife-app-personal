// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../controller/invite/invite_event_venue_list_controller.dart';
import '../utilities/app_color.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_font.dart';
import '../utilities/app_image.dart';
import '../view/other/chats/chat_message_screen.dart';

void showEventTypesBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(),
    context: context,
    builder: (_) => const _InviteMembersBottomSheet(),
  );
}

class _InviteMembersBottomSheet extends StatefulWidget {
  const _InviteMembersBottomSheet();

  @override
  State<_InviteMembersBottomSheet> createState() =>
      _InviteMembersBottomSheetState();
}

class _InviteMembersBottomSheetState extends State<_InviteMembersBottomSheet> {
  final Set<String> _sentIds = <String>{};
  late final ScrollController _membersScrollController;
  final List<String> shareIcons = const [
    "assets/icons/shareIcon.png",
    "assets/icons/whatsappIcon.png",
    "assets/icons/instaIcon.png",
    "assets/icons/snapIcon.png",
  ];

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
              ),
              SizedBox(height: size.height * 0.01),
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
                            vertical: size.height * 2 / 100),
                        child: Image.asset(
                          shareIcons[index],
                          width: size.width * 14 / 100,
                          height: size.width * 14 / 100,
                          fit: BoxFit.cover,
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
              Expanded(
                child: Consumer<InviteEventVenueListController>(
                  builder: (context, controller, _) {
                    if (controller.isMembersLoading &&
                        controller.memberItems.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColor.buttonColor,
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      controller: _membersScrollController,
                      child: Column(children: [
                        ...List.generate(controller.memberItems.length,
                            (index) {
                          final item = controller.memberItems[index];
                          final id = _str(item['id']);
                          final key = id.isEmpty ? index.toString() : id;
                          final isSend = _sentIds.contains(key);
                          final name = _str(item['full_name']);
                          final username = _str(item['username']);
                          final image = _fullImage(_str(item['profile_image']));
                          final resolved =
                              image.isEmpty ? AppImage.dummyImageIcon : image;
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
                                        errorBuilder: (_, __, ___) =>
                                            Image.asset(
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
                                    onTap: () {
                                      setState(() => _sentIds.add(key));
                                      Future.delayed(
                                          const Duration(milliseconds: 200),
                                          () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type:
                                                PageTransitionType.bottomToTop,
                                            child: ChatMessageScreen(
                                              name: name,
                                              image: resolved.startsWith('http')
                                                  ? AppImage.dummyImageIcon
                                                  : resolved,
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
                                        borderRadius: BorderRadius.circular(10),
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
                            child: CircularProgressIndicator(
                              color: AppColor.buttonColor,
                            ),
                          )
                      ]),
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
}
