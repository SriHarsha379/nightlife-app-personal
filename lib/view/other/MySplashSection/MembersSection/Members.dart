import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_config_provider.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/my_events.dart';
import 'package:night_life/view/other/MySplashSection/MembersSection/member_liked_details.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/my_venue.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../controller/home/home_controller.dart';
import '../../../../controller/members/conversion_list_controller.dart';
import '../../../../controller/members/members_controller.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_footer.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';
import '../../chats/chat_message_screen.dart';

class splashMembers extends StatefulWidget {
  static const String routeName = '/splashMembers';
  const splashMembers({super.key});

  @override
  State<splashMembers> createState() => _splashMembersState();
}

class _splashMembersState extends State<splashMembers> {
  int selectedIndex = 0;

  bool isDropdownOpen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MembersController>(context, listen: false).fetchMyMembers(
        context,
        type: 'liked',
        page: 1,
        limit: 10,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current < (max - 180)) return;

    final membersController =
        Provider.of<MembersController>(context, listen: false);
    membersController.loadMoreMembers(
      context,
      type: selectedIndex == 0 ? 'liked' : 'connected',
      limit: 10,
    );
  }

  String _str(dynamic value) => (value ?? '').toString().trim();

  String _buildMemberImage(dynamic rawPath) {
    dynamic source = rawPath;

    // Some APIs return `profile_image` as map/list instead of plain string.
    if (source is Map) {
      source = source['url'] ??
          source['path'] ??
          source['image'] ??
          source['profile_image'];
    } else if (source is List && source.isNotEmpty) {
      final first = source.first;
      if (first is Map) {
        source = first['url'] ??
            first['path'] ??
            first['image'] ??
            first['profile_image'];
      } else {
        source = first;
      }
    }

    var path = _str(source);
    if (path.isEmpty) return AppImage.placeHolder2Icon;

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Normalize known relative variants from backend.
    if (path.startsWith('/')) path = path.substring(1);
    if (path.startsWith('uploads/')) path = path.substring('uploads/'.length);
    if (path.startsWith('app/server/uploads/')) {
      path = path.substring('app/server/uploads/'.length);
    }

    return '${AppConfigProvider.imageUrl}$path';
  }

  String _memberAddress(Map member) {
    final city = _str(member['address']);
    if (city.isNotEmpty && city.isNotEmpty) {
      return '$city';
    }
    if (city.isNotEmpty) return city;
    if (city.isNotEmpty) return '$city ';
    return '';
  }

  String _memberSinceYearsText(Map member) {
    final raw = _str(member['member_since']);
    if (raw.isEmpty) return '';

    final now = DateTime.now();
    bool isLessThanOneYear(DateTime date) {
      final days = now.difference(date).inDays;
      return days >= 0 && days < 365;
    }

    String formatDate(DateTime date) {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    final digitMatch = RegExp(r'(\d+)').firstMatch(raw);

    if (digitMatch != null &&
        RegExp(r'yr|year', caseSensitive: false).hasMatch(raw)) {
      return '${digitMatch.group(1)} yrs';
    }

    final number = int.tryParse(raw);
    if (number != null) {
      if (number >= 1900 && number <= now.year) {
        final years = (now.year - number).clamp(0, 100);
        return '${years == 0 ? 1 : years} yrs';
      }
      if (number > 1000000000) {
        final epoch = number > 1000000000000
            ? DateTime.fromMillisecondsSinceEpoch(number)
            : DateTime.fromMillisecondsSinceEpoch(number * 1000);
        if (isLessThanOneYear(epoch)) {
          return formatDate(epoch);
        }
        final years = now.year - epoch.year;
        return '${years <= 0 ? 1 : years} yrs';
      }
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) {
      if (isLessThanOneYear(parsed)) {
        return formatDate(parsed);
      }
      final years = now.year - parsed.year;
      return '${years <= 0 ? 1 : years} yrs';
    }

    if (digitMatch != null) {
      return '${digitMatch.group(1)} yrs';
    }

    return '2 yrs';
  }

  Widget _memberCardImage(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade300,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.buttonColor,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Image.asset(
          AppImage.placeHolder2Icon,
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
    );
  }

  Future<void> _handleMemberDetailResult(dynamic result) async {
    if (result is! Map) return;

    final action = _str(result['action']).toLowerCase();
    final targetUserId = _str(result['targetUserId']);
    if (targetUserId.isEmpty) return;

    final homeController = Provider.of<HomeController>(context, listen: false);
    if (action == 'left') {
      await homeController.dislikeItem(context, targetUserId, 'member');
    } else if (action == 'right') {
      await homeController.likeItem(context, targetUserId, 'member');
    } else {
      return;
    }

    if (!mounted) return;
    await Provider.of<MembersController>(context, listen: false).fetchMyMembers(
      context,
      type: selectedIndex == 0 ? 'liked' : 'connected',
      page: 1,
      limit: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final membersController = Provider.of<MembersController>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: size.width * 100 / 100,
          height: size.height * 100 / 100,
          color: AppColor.primaryColor(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 4 / 100,
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 7 / 100,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: MyAppFooter(initialIndex: 0),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: Container(
                          height: MediaQuery.of(context).size.height * 7 / 100,
                          alignment: Alignment.center,
                          child: Image.asset(
                            AppImage.backarrow,
                            fit: BoxFit.cover,
                            color: AppColor.secondryColor(context),
                            height: MediaQuery.of(context).size.width * 5 / 100,
                            width: MediaQuery.of(context).size.width * 5 / 100,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 26 / 100,
                      ),
                      GestureDetector(
                        onTap: () {
                          documenttypebottomsheet(context);
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            AppLanguage.membersText[language],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 2 / 100),
                      GestureDetector(
                        onTap: () {
                          documenttypebottomsheet(context);
                        },
                        child: Image.asset(
                          AppImage.downArrow,
                          fit: BoxFit.cover,
                          color: AppColor.secondryColor(context),
                          height: MediaQuery.of(context).size.width * 5 / 100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 2 / 100),
              Container(
                color: AppColor.primaryColor(context),
                width: MediaQuery.of(context).size.width * 100 / 100,
                height: MediaQuery.of(context).size.height * 8 / 100,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0;
                          });
                          Provider.of<MembersController>(context, listen: false)
                              .fetchMyMembers(
                            context,
                            type: 'liked',
                            page: 1,
                            limit: 10,
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 50 / 100,
                          // height:
                          //     MediaQuery.of(context).size.height * 6 / 100,
                          child: Center(
                            child: Text(
                              AppLanguage.likedText[language],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: selectedIndex == 0
                                    ? AppColor.pinkColor
                                    : AppColor.secondryColor(context),
                                fontSize: 15,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 1;
                          });
                          Provider.of<MembersController>(context, listen: false)
                              .fetchMyMembers(
                            context,
                            type: 'connected',
                            page: 1,
                            limit: 10,
                          );
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 50 / 100,
                          // height:
                          //     MediaQuery.of(context).size.height * 6 / 100,
                          child: Center(
                            child: Text(
                              AppLanguage.myconectionstext[language],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: selectedIndex == 1
                                    ? AppColor.pinkColor
                                    : AppColor.secondryColor(context),
                                fontSize: 15,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = 0;
                        });
                        Provider.of<MembersController>(context, listen: false)
                            .fetchMyMembers(
                          context,
                          type: 'liked',
                          page: 1,
                          limit: 10,
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 50 / 100,
                        height: MediaQuery.of(context).size.height * 0.3 / 100,
                        color: selectedIndex == 0
                            ? AppColor.pinkColor
                            : AppColor.secondryColor(context),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = 1;
                        });
                        Provider.of<MembersController>(context, listen: false)
                            .fetchMyMembers(
                          context,
                          type: 'connected',
                          page: 1,
                          limit: 10,
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 50 / 100,
                        height: MediaQuery.of(context).size.height * 0.3 / 100,
                        color: selectedIndex == 1
                            ? AppColor.pinkColor
                            : AppColor.secondryColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Center(
                    child: Container(
                      width: size.width * 90 / 100,
                      child: Column(
                        children: [
                          if (selectedIndex == 0)
                            if (membersController.isLikedMembersLoading &&
                                membersController.likedMembers.isEmpty)
                              Padding(
                                padding:
                                    EdgeInsets.only(top: size.height * 4 / 100),
                                child: const CircularProgressIndicator(
                                  color: AppColor.buttonColor,
                                ),
                              ),
                          if (selectedIndex == 0)
                            membersController.likedMembers.isEmpty
                                ? Container(
                                    height: size.height * 60 / 100,
                                    child: Center(
                                      child: Text(
                                        'No liked members yet',
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : Wrap(
                                    runSpacing: 10,
                                    children: List.generate(
                                      membersController.likedMembers.length,
                                      (index) {
                                        final member = membersController
                                            .likedMembers[index] as Map;
                                        final memberName = _str(member['name']);
                                        final memberId = _str(member['_id']);
                                        final memberSince =
                                            _memberSinceYearsText(member);
                                        final memberAddress =
                                            _memberAddress(member);
                                        final memberImage = _buildMemberImage(
                                            member['profile_image']);
                                        return GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: size.width * 90 / 100,
                                            decoration: BoxDecoration(
                                              color: AppColor.primaryColor(
                                                  context),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: size.width * 3 / 100,
                                                ),
                                                Container(
                                                  width: size.width * 90 / 100,
                                                  height: size.width * 42 / 100,
                                                  decoration:
                                                      const BoxDecoration(),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                      ),
                                                      child: _memberCardImage(
                                                        memberImage,
                                                      )),
                                                ),
                                                SizedBox(
                                                  width: size.width * 3 / 100,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 3 / 100,
                                                    vertical:
                                                        size.height * 1 / 100,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            memberName.isEmpty
                                                                ? ''
                                                                : memberName,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context)),
                                                          ),
                                                          Container(
                                                            width: size.width *
                                                                8 /
                                                                100,
                                                            height: size.width *
                                                                8 /
                                                                100,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    boxShadow: []),
                                                            child: ClipRRect(
                                                                child:
                                                                    Image.asset(
                                                              AppImage
                                                                  .liked_heart_icon,
                                                              fit: BoxFit.cover,
                                                              // color: AppColor
                                                              //     .secondryColor(
                                                              //         context),
                                                            )),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height *
                                                            0.4 /
                                                            100,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: size.width *
                                                                4.5 /
                                                                100,
                                                            height: size.width *
                                                                4.5 /
                                                                100,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    boxShadow: []),
                                                            child: ClipRRect(
                                                              child:
                                                                  Image.asset(
                                                                AppImage
                                                                    .calenderPinkIcon,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                1 /
                                                                100,
                                                          ),
                                                          Text(
                                                            "Member since $memberSince",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context)),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height *
                                                            1 /
                                                            100,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: size.width *
                                                                5 /
                                                                100,
                                                            height: size.width *
                                                                5 /
                                                                100,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    boxShadow: []),
                                                            child: ClipRRect(
                                                                child:
                                                                    Image.asset(
                                                              AppImage
                                                                  .locationIcon,
                                                              fit: BoxFit.cover,
                                                            )),
                                                          ),
                                                          SizedBox(
                                                            width: size.width *
                                                                0.8 /
                                                                100,
                                                          ),
                                                          Text(
                                                            memberAddress,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context)),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            1.5 /
                                                            100,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          final result =
                                                              await Navigator
                                                                  .push(
                                                            context,
                                                            PageTransition(
                                                              type: PageTransitionType
                                                                  .rightToLeftWithFade,
                                                              child:
                                                                  LikedMemberDetail(
                                                                memberId:
                                                                    memberId,
                                                                forceDislikeOnly:
                                                                    true,
                                                                deferSwipeActionToParent:
                                                                    true,
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                            ),
                                                          );
                                                          await _handleMemberDetailResult(
                                                              result);
                                                        },
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              6 /
                                                              100,
                                                          decoration: BoxDecoration(
                                                              color: AppColor
                                                                  .secondryColor(
                                                                      context),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Center(
                                                            child: Text(
                                                              AppLanguage
                                                                      .viewProfiletext[
                                                                  language],
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: AppColor
                                                                      .pinkColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          if (selectedIndex == 0 &&
                              membersController.isLikedMembersLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(
                                color: AppColor.buttonColor,
                                strokeWidth: 2,
                              ),
                            ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 3 / 100,
                          ),
                          if (selectedIndex == 1)
                            if (membersController.isConnectedMembersLoading &&
                                membersController.connectedMembers.isEmpty)
                              Padding(
                                padding:
                                    EdgeInsets.only(top: size.height * 4 / 100),
                                child: const CircularProgressIndicator(
                                  color: AppColor.buttonColor,
                                ),
                              ),
                          if (selectedIndex == 1)
                            membersController.connectedMembers.isEmpty
                                ? Container(
                                    height: size.height * 50 / 100,
                                    child: Center(
                                      child: Text(
                                        'No connections yet',
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : Wrap(
                                    runSpacing: 10,
                                    children: List.generate(
                                      membersController.connectedMembers.length,
                                      (index) {
                                        final member = membersController
                                            .connectedMembers[index] as Map;
                                        final memberName = _str(member['name']);
                                        final memberId = _str(member['_id']);
                                        final memberSince =
                                            _memberSinceYearsText(member);
                                        final memberAddress =
                                            _memberAddress(member);
                                        final memberImage = _buildMemberImage(
                                            member['profile_image']);
                                        final chatImage = memberImage;
                                        return GestureDetector(
                                          onTap: () {},
                                          child: Container(
                                            width: size.width * 90 / 100,
                                            decoration: BoxDecoration(
                                              color: AppColor.primaryColor(
                                                  context),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: size.width * 3 / 100,
                                                ),
                                                Container(
                                                  width: size.width * 90 / 100,
                                                  height: size.width * 42 / 100,
                                                  decoration:
                                                      const BoxDecoration(),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                      ),
                                                      child: _memberCardImage(
                                                          memberImage)),
                                                ),
                                                SizedBox(
                                                  width: size.width * 3 / 100,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        size.width * 3 / 100,
                                                    vertical:
                                                        size.height * 1 / 100,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            memberName.isEmpty
                                                                ? 'Unknown'
                                                                : memberName,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context)),
                                                          ),
                                                          // Container(
                                                          //   width: size.width * 8 / 100,
                                                          //   height:
                                                          //       size.width * 8 / 100,
                                                          //   decoration:
                                                          //       const BoxDecoration(
                                                          //           boxShadow: []),
                                                          //   child: ClipRRect(
                                                          //       child: Image.asset(
                                                          //     AppImage.liked_heart_icon,
                                                          //     fit: BoxFit.cover,
                                                          //     color: AppColor
                                                          //         .secondryColor,
                                                          //   )),
                                                          // ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height *
                                                            0.4 /
                                                            100,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: size.width *
                                                                4.5 /
                                                                100,
                                                            height: size.width *
                                                                4.5 /
                                                                100,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    boxShadow: []),
                                                            child: ClipRRect(
                                                              child:
                                                                  Image.asset(
                                                                AppImage
                                                                    .calenderPinkIcon,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                1 /
                                                                100,
                                                          ),
                                                          Text(
                                                            "Member since $memberSince",
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context)),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: size.height *
                                                            1 /
                                                            100,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: size.width *
                                                                5 /
                                                                100,
                                                            height: size.width *
                                                                5 /
                                                                100,
                                                            decoration:
                                                                const BoxDecoration(
                                                                    boxShadow: []),
                                                            child: ClipRRect(
                                                                child:
                                                                    Image.asset(
                                                              AppImage
                                                                  .locationIcon,
                                                              fit: BoxFit.cover,
                                                            )),
                                                          ),
                                                          SizedBox(
                                                            width: size.width *
                                                                0.8 /
                                                                100,
                                                          ),
                                                          Text(
                                                            memberAddress,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context)),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            1.5 /
                                                            100,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () async {
                                                          final conversationController =
                                                              Provider.of<
                                                                      ConversionListController>(
                                                                  context,
                                                                  listen:
                                                                      false);

                                                          final conversationId =
                                                              await conversationController
                                                                  .fetchConversationIdByUserId(
                                                            otherUserId:
                                                                memberId,
                                                          );

                                                          if (!context.mounted) {
                                                            return;
                                                          }

                                                          Navigator.push(
                                                            context,
                                                            PageTransition(
                                                              type: PageTransitionType
                                                                  .rightToLeftWithFade,
                                                              child:
                                                                  ChatMessageScreen(
                                                                name: memberName
                                                                        .isEmpty
                                                                    ? 'Unknown'
                                                                    : memberName,
                                                                image:
                                                                    chatImage,
                                                                receiverId:
                                                                    memberId,
                                                                conversationId:
                                                                    conversationId
                                                                            .isEmpty
                                                                        ? null
                                                                        : conversationId,
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          500),
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              6 /
                                                              100,
                                                          decoration: BoxDecoration(
                                                              color: AppColor
                                                                  .secondryColor(
                                                                      context),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Center(
                                                            child: Text(
                                                              AppLanguage
                                                                      .messageText[
                                                                  language],
                                                              style: const TextStyle(
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: AppColor
                                                                      .pinkColor),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          if (selectedIndex == 1 &&
                              membersController.isConnectedMembersLoadingMore)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: CircularProgressIndicator(
                                color: AppColor.buttonColor,
                                strokeWidth: 2,
                              ),
                            ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 3 / 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 78 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 78 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor(context),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          width: size.width * 1.0,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Container(
                                width: size.width * 0.88,
                                child: Column(
                                  children: [
                                    // First Image

                                    Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        AppImage.dashIcon,
                                        height: size.height * 0.5 / 100,
                                        width: size.width * 22 / 100,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 4 / 100),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage.myspacetext[language],
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .eventStatementtext[language],
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.2,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.04),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: splashMembers(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.memberBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        height: size.height *
                                            0.02), // spacing between images
                                    // Second Image
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: MyVenue(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.venuesBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: MyEvents(),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: size.width * 0.86,
                                        height: size.height * 0.17,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                AppImage.eventsBanner),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(
                              //     height: size.height * 0.06),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    ).then((_) {
      // Reset selected index when bottom sheet is dismissed
      // Optional: uncomment if you want to reset to previous page
      // setState(() {
      //   selectedIndex = pageController.page?.round() ?? 0;
      // });
    });
  }

  Widget divider() {
    return const Divider(
      color: Colors.grey,
      height: 1,
      thickness: 0.5,
    );
  }
}
