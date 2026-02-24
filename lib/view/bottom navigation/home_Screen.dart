import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:night_life/utilities/app_config_provider.dart';
import 'package:night_life/view/authentication/notification_screen.dart';
import 'package:night_life/view/authentication/profile.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/liked_event_details.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../commonWidget/home_widget.dart';
import '../../commonWidget/event_types_bottomsheet.dart';
import '../../commonWidget/invite_members_type_bottomsheet.dart';
import '../../controller/home/home_controller.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../other/MySplashSection/MembersSection/member_liked_details.dart';
import '../other/MySplashSection/VenuesSection/venuepages.dart';

class Home extends StatefulWidget {
  static String routeName = './Home';

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  CardSwiperController cardController = CardSwiperController();
  final CardSwiperController swipeControllerfollowGuardians =
      CardSwiperController();
  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = Provider.of<HomeController>(context, listen: false);
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeController.refreshAllData(context);
    });
    context.read<UserController>().getUserDetails();
  }

  int reportId = 0;

  DateTime? lastPressed;
  int selectedId = 1;

  List orders = [
    {'id': 1, 'title': 'Members', 'type': 'member'},
    {'id': 2, 'title': 'Events', 'type': 'event'},
    {'id': 3, 'title': 'Venues', 'type': 'venue'},
  ];

  bool showHeart = false;
  bool showCross = false;
  String? lastSwipeType; // 'heart' or 'cross'
  bool isSend = true;
  final CardSwiperController membersSwiperController = CardSwiperController();
  final CardSwiperController eventsSwiperController = CardSwiperController();
  final CardSwiperController venuesSwiperController = CardSwiperController();

  //! Add these for tracking
  int currentMemberIndex = 0;
  int currentEventIndex = 0;
  int currentVenueIndex = 0;
  int selectedIndex = 0;

  bool isYes = false;
  bool isNope = false;
  double swipeProgress = 0.0;
  Timer? _memberSwipeCommitTimer;
  Timer? _eventSwipeCommitTimer;
  Timer? _venueSwipeCommitTimer;
  String? _pendingMemberUserId;
  String? _pendingMemberAction;
  String? _pendingEventId;
  String? _pendingEventAction;
  String? _pendingVenueId;
  String? _pendingVenueAction;
  bool _showMemberUndo = false;
  bool _showEventUndo = false;
  bool _showVenueUndo = false;
  bool _isCommittingMemberSwipe = false;
  bool _isCommittingEventSwipe = false;
  bool _isCommittingVenueSwipe = false;
  final Set<String> _hiddenMemberIds = <String>{};
  final Set<String> _hiddenEventIds = <String>{};
  final Set<String> _hiddenVenueIds = <String>{};

  String _itemId(dynamic item) =>
      (item is Map ? (item['_id'] ?? '') : '').toString().trim();

  List<dynamic> _visibleItems(List<dynamic> source, Set<String> hiddenIds) {
    return source.where((item) {
      final id = _itemId(item);
      return id.isEmpty || !hiddenIds.contains(id);
    }).toList(growable: false);
  }

  Widget _undoActionChip(VoidCallback onTap) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.008,
      ),
      decoration: BoxDecoration(
        color: AppColor.themeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLanguage.undoText[language],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
            Image.asset(
              AppImage.arrow,
              width: MediaQuery.of(context).size.width * 0.04,
              height: MediaQuery.of(context).size.height * 0.02,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _queueMemberSwipeAction({
    required String targetUserId,
    required String action,
  }) {
    // Prevent duplicate callbacks from committing the same swipe immediately.
    final isSamePending =
        _pendingMemberUserId == targetUserId && _pendingMemberAction == action;
    if (isSamePending) {
      _memberSwipeCommitTimer?.cancel();
      _memberSwipeCommitTimer = Timer(const Duration(seconds: 15), () {
        _commitPendingMemberSwipe();
      });
      if (mounted && !_showMemberUndo) {
        setState(() {
          _showMemberUndo = true;
        });
      }
      return;
    }

    _commitPendingMemberSwipe();

    _memberSwipeCommitTimer?.cancel();
    _pendingMemberUserId = targetUserId;
    _pendingMemberAction = action;
    if (mounted) {
      setState(() {
        _showMemberUndo = true;
      });
    }

    _memberSwipeCommitTimer = Timer(const Duration(seconds: 15), () {
      _commitPendingMemberSwipe();
    });
  }

  Future<void> _commitPendingMemberSwipe() async {
    if (_isCommittingMemberSwipe) return;
    final targetUserId = _pendingMemberUserId;
    final action = _pendingMemberAction;
    if (targetUserId == null || action == null) return;

    _isCommittingMemberSwipe = true;
    _memberSwipeCommitTimer?.cancel();
    _pendingMemberUserId = null;
    _pendingMemberAction = null;
    if (mounted) {
      setState(() {
        _showMemberUndo = false;
      });
    }

    final homeController = Provider.of<HomeController>(context, listen: false);
    try {
      await homeController.swipeUserAction(
        context,
        targetUserId: targetUserId,
        action: action,
        allowRedirectOnFailure: false,
      );
    } finally {
      _isCommittingMemberSwipe = false;
    }
  }

  void _undoPendingMemberSwipe() {
    final pendingUserId = _pendingMemberUserId;
    if (pendingUserId == null) return;

    _memberSwipeCommitTimer?.cancel();
    _pendingMemberUserId = null;
    _pendingMemberAction = null;
    if (mounted) {
      setState(() {
        _showMemberUndo = false;
        _hiddenMemberIds.remove(pendingUserId);
      });
    }
    membersSwiperController.undo();
  }

  void _handleMemberDetailResult(dynamic result) {
    if (result == null) return;
    final map = result is Map ? result : <String, dynamic>{};
    final action = (map['action'] ?? '').toString().trim();
    final targetUserId = (map['targetUserId'] ?? '').toString().trim();
    if (targetUserId.isEmpty) return;
    if (action != 'left' && action != 'right') return;

    // Queue once from detail result, then animate actual card swipe on home.
    _queueMemberSwipeAction(
      targetUserId: targetUserId,
      action: action,
    );

    final direction = action == 'right'
        ? CardSwiperDirection.right
        : CardSwiperDirection.left;
    membersSwiperController.swipe(direction);
  }

  void _queueEventSwipeAction({
    required String eventId,
    required String action,
  }) {
    _commitPendingEventSwipe();

    _eventSwipeCommitTimer?.cancel();
    _pendingEventId = eventId;
    _pendingEventAction = action;
    if (mounted) {
      setState(() {
        _showEventUndo = true;
      });
    }

    _eventSwipeCommitTimer = Timer(const Duration(seconds: 15), () {
      _commitPendingEventSwipe();
    });
  }

  Future<void> _commitPendingEventSwipe() async {
    if (_isCommittingEventSwipe) return;
    final eventId = _pendingEventId;
    final action = _pendingEventAction;
    if (eventId == null || action == null) return;

    _isCommittingEventSwipe = true;
    _eventSwipeCommitTimer?.cancel();
    _pendingEventId = null;
    _pendingEventAction = null;
    if (mounted) {
      setState(() {
        _showEventUndo = false;
      });
    }

    final homeController = Provider.of<HomeController>(context, listen: false);
    try {
      await homeController.eventLikeDislikeAction(
        context,
        eventId: eventId,
        action: action,
        allowRedirectOnFailure: false,
      );
    } finally {
      _isCommittingEventSwipe = false;
    }
  }

  void _undoPendingEventSwipe() {
    final pendingEventId = _pendingEventId;
    if (pendingEventId == null) return;

    _eventSwipeCommitTimer?.cancel();
    _pendingEventId = null;
    _pendingEventAction = null;
    if (mounted) {
      setState(() {
        _showEventUndo = false;
        _hiddenEventIds.remove(pendingEventId);
      });
    }
    eventsSwiperController.undo();
  }

  void _handleEventDetailResult(dynamic result) {
    if (result == null) return;
    final map = result is Map ? result : <String, dynamic>{};
    final action = (map['action'] ?? '').toString().trim();
    final targetEventId = (map['targetEventId'] ?? '').toString().trim();
    if (targetEventId.isEmpty) return;
    if (action != 'like' && action != 'dislike') return;

    _queueEventSwipeAction(
      eventId: targetEventId,
      action: action,
    );

    final direction =
        action == 'like' ? CardSwiperDirection.right : CardSwiperDirection.left;
    eventsSwiperController.swipe(direction);
  }

  void _queueVenueSwipeAction({
    required String venueId,
    required String action,
  }) {
    final isSamePending =
        _pendingVenueId == venueId && _pendingVenueAction == action;
    if (isSamePending) {
      _venueSwipeCommitTimer?.cancel();
      _venueSwipeCommitTimer = Timer(const Duration(seconds: 15), () {
        _commitPendingVenueSwipe();
      });
      if (mounted && !_showVenueUndo) {
        setState(() {
          _showVenueUndo = true;
        });
      }
      return;
    }

    _commitPendingVenueSwipe();

    _venueSwipeCommitTimer?.cancel();
    _pendingVenueId = venueId;
    _pendingVenueAction = action;
    if (mounted) {
      setState(() {
        _showVenueUndo = true;
      });
    }

    _venueSwipeCommitTimer = Timer(const Duration(seconds: 15), () {
      _commitPendingVenueSwipe();
    });
  }

  Future<void> _commitPendingVenueSwipe() async {
    if (_isCommittingVenueSwipe) return;
    final venueId = _pendingVenueId;
    final action = _pendingVenueAction;
    if (venueId == null || action == null) return;

    _isCommittingVenueSwipe = true;
    _venueSwipeCommitTimer?.cancel();
    _pendingVenueId = null;
    _pendingVenueAction = null;
    if (mounted) {
      setState(() {
        _showVenueUndo = false;
      });
    }

    final homeController = Provider.of<HomeController>(context, listen: false);
    try {
      await homeController.venueLikeDislikeAction(
        context,
        venueId: venueId,
        action: action,
        allowRedirectOnFailure: false,
      );
    } finally {
      _isCommittingVenueSwipe = false;
    }
  }

  void _undoPendingVenueSwipe() {
    final pendingVenueId = _pendingVenueId;
    if (pendingVenueId == null) return;

    _venueSwipeCommitTimer?.cancel();
    _pendingVenueId = null;
    _pendingVenueAction = null;
    if (mounted) {
      setState(() {
        _showVenueUndo = false;
        _hiddenVenueIds.remove(pendingVenueId);
      });
    }
    venuesSwiperController.undo();
  }

  void _handleVenueDetailResult(dynamic result) {
    if (result == null) return;
    final map = result is Map ? result : <String, dynamic>{};
    final action = (map['action'] ?? '').toString().trim();
    final targetVenueId = (map['targetVenueId'] ?? '').toString().trim();
    if (targetVenueId.isEmpty) return;
    if (action != 'like' && action != 'dislike') return;

    _queueVenueSwipeAction(
      venueId: targetVenueId,
      action: action,
    );

    final direction =
        action == 'like' ? CardSwiperDirection.right : CardSwiperDirection.left;
    venuesSwiperController.swipe(direction);
  }

  bool _onSwipeMembers(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final membersList =
        _visibleItems(homeController.getMembersList, _hiddenMemberIds);

    if (direction == CardSwiperDirection.right) {
      // Liked - Swipe right
      setState(() {
        showCross = true;
        showHeart = false;
        lastSwipeType = 'heart';
      });

      if (previousIndex < membersList.length) {
        final targetUserId =
            (membersList[previousIndex]['_id'] ?? '').toString();
        if (targetUserId.isNotEmpty) {
          _hiddenMemberIds.add(targetUserId);
          _queueMemberSwipeAction(
            targetUserId: targetUserId,
            action: 'right',
          );
        }
      }

      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showCross = false;
            lastSwipeType = null;
          });
        }
      });
    } else if (direction == CardSwiperDirection.left) {
      // Disliked - Swipe left
      setState(() {
        showHeart = true;
        showCross = false;
        lastSwipeType = 'cross';
      });

      if (previousIndex < membersList.length) {
        final targetUserId =
            (membersList[previousIndex]['_id'] ?? '').toString();
        if (targetUserId.isNotEmpty) {
          _hiddenMemberIds.add(targetUserId);
          _queueMemberSwipeAction(
            targetUserId: targetUserId,
            action: 'left',
          );
        }
      }

      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showHeart = false;
            lastSwipeType = null;
          });
        }
      });
    }

    setState(() {
      currentMemberIndex = currentIndex ?? 0;
    });
    _tryLoadMoreForType('member', currentIndex, membersList.length);
    return true;
  }

  bool _onSwipeEvents(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final eventsList =
        _visibleItems(homeController.getEventsList, _hiddenEventIds);

    if (direction == CardSwiperDirection.right) {
      setState(() {
        showHeart = true;
        showCross = false;
        lastSwipeType = 'cross';
      });

      if (previousIndex < eventsList.length) {
        final eventId = (eventsList[previousIndex]['_id'] ?? '').toString();
        if (eventId.isNotEmpty) {
          _hiddenEventIds.add(eventId);
          _queueEventSwipeAction(
            eventId: eventId,
            action: 'like',
          );
        }
      }

      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showHeart = false;
            lastSwipeType = null;
          });
        }
      });
    } else if (direction == CardSwiperDirection.left) {
      setState(() {
        showCross = true;
        showHeart = false;
        lastSwipeType = 'heart';
      });

      if (previousIndex < eventsList.length) {
        final eventId = (eventsList[previousIndex]['_id'] ?? '').toString();
        if (eventId.isNotEmpty) {
          _hiddenEventIds.add(eventId);
          _queueEventSwipeAction(
            eventId: eventId,
            action: 'dislike',
          );
        }
      }

      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showCross = false;
            lastSwipeType = null;
          });
        }
      });
    }

    setState(() {
      log("currentIndex$currentIndex");
      currentEventIndex = currentIndex ?? 0;
    });
    _tryLoadMoreForType('event', currentIndex, eventsList.length);

    return true;
  }

  bool _onSwipeVenues(
      int previousIndex, int? currentIndex, CardSwiperDirection direction) {
    final homeController = Provider.of<HomeController>(context, listen: false);
    final venuesList =
        _visibleItems(homeController.getVenuesList, _hiddenVenueIds);

    if (direction == CardSwiperDirection.right) {
      setState(() {
        showHeart = true;
        showCross = false;
        lastSwipeType = 'cross';
      });

      if (previousIndex < venuesList.length) {
        final venueId = (venuesList[previousIndex]['_id'] ?? '').toString();
        if (venueId.isNotEmpty) {
          _hiddenVenueIds.add(venueId);
          _queueVenueSwipeAction(
            venueId: venueId,
            action: 'like',
          );
        }
      }

      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showHeart = false;
            lastSwipeType = null;
          });
        }
      });
    } else if (direction == CardSwiperDirection.left) {
      setState(() {
        showCross = true;
        showHeart = false;
        lastSwipeType = 'heart';
      });

      if (previousIndex < venuesList.length) {
        final venueId = (venuesList[previousIndex]['_id'] ?? '').toString();
        if (venueId.isNotEmpty) {
          _hiddenVenueIds.add(venueId);
          _queueVenueSwipeAction(
            venueId: venueId,
            action: 'dislike',
          );
        }
      }

      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) {
          setState(() {
            showCross = false;
            lastSwipeType = null;
          });
        }
      });
    }

    setState(() {
      currentVenueIndex = currentIndex ?? 0;
    });
    _tryLoadMoreForType('venue', currentIndex, venuesList.length);
    return true;
  }

  @override
  void dispose() {
    final pendingTargetUserId = _pendingMemberUserId;
    final pendingAction = _pendingMemberAction;
    final pendingEventId = _pendingEventId;
    final pendingEventAction = _pendingEventAction;
    final pendingVenueId = _pendingVenueId;
    final pendingVenueAction = _pendingVenueAction;
    _memberSwipeCommitTimer?.cancel();
    _eventSwipeCommitTimer?.cancel();
    _venueSwipeCommitTimer?.cancel();
    _pendingMemberUserId = null;
    _pendingMemberAction = null;
    _pendingEventId = null;
    _pendingEventAction = null;
    _pendingVenueId = null;
    _pendingVenueAction = null;
    _showMemberUndo = false;
    _showEventUndo = false;
    _showVenueUndo = false;
    if (!_isCommittingMemberSwipe &&
        pendingTargetUserId != null &&
        pendingAction != null) {
      unawaited(
        _homeController.swipeUserAction(
          null,
          targetUserId: pendingTargetUserId,
          action: pendingAction,
          allowRedirectOnFailure: false,
        ),
      );
    }
    if (!_isCommittingEventSwipe &&
        pendingEventId != null &&
        pendingEventAction != null) {
      unawaited(
        _homeController.eventLikeDislikeAction(
          null,
          eventId: pendingEventId,
          action: pendingEventAction,
          allowRedirectOnFailure: false,
        ),
      );
    }
    if (!_isCommittingVenueSwipe &&
        pendingVenueId != null &&
        pendingVenueAction != null) {
      unawaited(
        _homeController.venueLikeDislikeAction(
          null,
          venueId: pendingVenueId,
          action: pendingVenueAction,
          allowRedirectOnFailure: false,
        ),
      );
    }
    membersSwiperController.dispose();
    eventsSwiperController.dispose();
    venuesSwiperController.dispose();
    super.dispose();
  }

  int membersTabVersion = 0;
  int eventTabVersion = 0;
  int venusTabVersion = 0;

  final List<String> shareIcons = [
    AppImage.shareIcon,
    AppImage.whatsappIcon,
    AppImage.instaIcon,
    AppImage.snapIcon,
  ];

  int selectedTab = 0; // 0=Members, 1=Events, 2=Venues

  String _typeFromSelectedId(int id) {
    if (id == 1) return 'member';
    if (id == 2) return 'event';
    return 'venue';
  }

  void _tryLoadMoreForType(String type, int? currentIndex, int visibleLength) {
    if (!mounted || visibleLength == 0) return;
    final homeController = Provider.of<HomeController>(context, listen: false);
    final int nextVisibleIndex = currentIndex ?? visibleLength;
    final int remaining = visibleLength - nextVisibleIndex;
    // Prefetch one card before list end for smoother continuity.
    if (remaining <= 1) {
      unawaited(
        homeController.fetchNextPage(
          context,
          type: type,
          limit: 20,
        ),
      );
    }
  }

  String _getHeaderUserName(UserController userController) {
    final localName = userController.getUserName.trim();
    if (localName.isNotEmpty) return localName;
    return "Guest";
  }

  ImageProvider _getHeaderUserImage(UserController userController) {
    final rawImage = userController.getUserImage.trim();
    if (rawImage.isEmpty) {
      return const AssetImage(AppImage.placeHolderIcon);
    }

    try {
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        return NetworkImage(rawImage);
      }
      if (rawImage.startsWith('file://')) {
        return FileImage(File(Uri.parse(rawImage).toFilePath()));
      }
      if (rawImage.startsWith('/') || rawImage.contains(r':\')) {
        return FileImage(File(rawImage));
      }
      return NetworkImage('${AppConfigProvider.imageUrl}$rawImage');
    } catch (_) {
      return const AssetImage(AppImage.placeHolder2Icon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final homeController = Provider.of<HomeController>(context);
    final userController = Provider.of<UserController>(context);
    final isDark = themeProvider.isDarkMode;
    final headerUserName = _getHeaderUserName(userController);
    final headerUserImage = _getHeaderUserImage(userController);
    final visibleMembers =
        _visibleItems(homeController.getMembersList, _hiddenMemberIds);
    final visibleEvents =
        _visibleItems(homeController.getEventsList, _hiddenEventIds);
    final visibleVenues =
        _visibleItems(homeController.getVenuesList, _hiddenVenueIds);
    final selectedType = _typeFromSelectedId(selectedId);
    final showBottomPaginationLoader =
        homeController.isPaginationLoadingForType(selectedType);
    final hasMoreForSelectedType = homeController.hasMoreForType(selectedType);

    int selectedVisibleCount = visibleMembers.length;
    if (selectedId == 2) {
      selectedVisibleCount = visibleEvents.length;
    } else if (selectedId == 3) {
      selectedVisibleCount = visibleVenues.length;
    }

    final shouldShowCenterPaginationLoader = showBottomPaginationLoader ||
        (selectedVisibleCount == 0 && hasMoreForSelectedType);

    if (!homeController.getIsLoading &&
        selectedVisibleCount == 0 &&
        hasMoreForSelectedType &&
        !showBottomPaginationLoader) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          homeController.fetchNextPage(
            context,
            type: selectedType,
            limit: 20,
          ),
        );
      });
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          final now = DateTime.now();
          const maxDuration = Duration(seconds: 2);
          final isWarning =
              lastPressed == null || now.difference(lastPressed!) > maxDuration;
          if (isWarning) {
            lastPressed = now;
            SnackBarToastMessage.showSnackBar(
                context, AppLanguage.pressAgainExitText[language]);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: AppColor.primaryColor(context),
          body: SafeArea(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 100 / 100,
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 95 / 100,
                    height: MediaQuery.of(context).size.height * 9 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 14 / 100,
                              child: Image.asset(
                                AppImage.hiilogo,
                                color: isDark
                                    ? AppColor.darkTextColor
                                    : AppColor.richBlackColor,
                                width: MediaQuery.of(context).size.width *
                                    10 /
                                    100,
                              ),
                            ),
                            SizedBox(width: size.width * 2 / 100),
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
                                    color: isDark
                                        ? AppColor.darkTextColor
                                        : AppColor.richBlackColor,
                                  ),
                                ),
                                Text(
                                  headerUserName,
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColor.secondryColor(context)
                                        : AppColor.richBlackColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                homeController.clearNotificationStatus();
                                await Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.topToBottom,
                                    child: const Notifications(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        3 /
                                        100,
                                    child: Image.asset(
                                      AppImage.bellicon,
                                    ),
                                  ),
                                  if (homeController.getNotificationStatus)
                                    Positioned(
                                      right: 2,
                                      top: 2,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 163, 86, 199),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                Colors.white,
                                            width: 2, // thickness
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
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
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: const Profile(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 38,
                                height: 38,
                                child: CircleAvatar(
                                  backgroundImage: headerUserImage,
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 1 / 100,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Wrap(
                          direction: Axis.horizontal,
                          children: List.generate(
                            orders.length,
                            (index) {
                              bool isAll = orders[index]['id'] == 4;
                              return GestureDetector(
                                onTap: isAll
                                    ? null
                                    : () async {
                                        setState(() {
                                          if (orders[index]['id'] == 1) {
                                            membersTabVersion++;
                                          } else if (orders[index]['id'] == 2) {
                                            eventTabVersion++;
                                          } else if (orders[index]['id'] == 3) {
                                            venusTabVersion++;
                                          }
                                          selectedId = orders[index]['id'];
                                        });

                                        // Fetch latest data for selected type.
                                        String type = orders[index]['type'];
                                        await homeController.fetchHomeData(
                                          context,
                                          type: type,
                                          page: 0,
                                          limit: 20,
                                        );
                                      },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            4 /
                                            100,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            1 /
                                            100,
                                  ),
                                  alignment: Alignment.center,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                      color: selectedId == orders[index]['id']
                                          ? isDark
                                              ? Colors.black
                                              : Colors.white
                                          : isDark
                                              ? Colors.black
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                          color:
                                              selectedId == orders[index]['id']
                                                  ? AppColor.buttonColor
                                                  : AppColor.textfilledColor)),
                                  child: Text(
                                    orders[index]['title'],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selectedId == orders[index]['id']
                                            ? AppColor.buttonColor
                                            : AppColor.textcolor),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 2 / 100,
                  ),

                  //! Loading Indicator
                  if (homeController.getIsLoading)
                    Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColor.buttonColor,
                        ),
                      ),
                    )

                  //! Members Card
                  else if (selectedId == 1)
                    Expanded(
                      child: visibleMembers.isEmpty
                          ? shouldShowCenterPaginationLoader
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.buttonColor,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'No members found',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColor.darkTextColor
                                              : AppColor.richBlackColor,
                                        ),
                                      ),
                                      if (_showMemberUndo) ...[
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015),
                                        _undoActionChip(
                                            _undoPendingMemberSwipe),
                                      ],
                                    ],
                                  ),
                                )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                              child: KeyedSubtree(
                                key: ValueKey(
                                    "members_tab_${membersTabVersion}_$selectedId"),
                                child: CardSwiper(
                                  controller: membersSwiperController,
                                  padding: EdgeInsets.zero,
                                  onSwipe: _onSwipeMembers,
                                  cardsCount: visibleMembers.length,
                                  allowedSwipeDirection:
                                      const AllowedSwipeDirection.only(
                                    left: true,
                                    right: true,
                                    down: false,
                                    up: false,
                                  ),
                                  numberOfCardsDisplayed: 1,
                                  cardBuilder: (context, index, _, __) {
                                    if (index < 0 ||
                                        index >= visibleMembers.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final member = visibleMembers[index];
                                    return Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1 /
                                                100,
                                          ),
                                          HomeWidget.membersCard(
                                            context,
                                            member['profile_image'] != null &&
                                                    member['profile_image']
                                                        .isNotEmpty
                                                ? '${AppConfigProvider.imageUrl}${member['profile_image']}'
                                                : AppImage
                                                    .userImage1, // fallback image
                                            member['name'] ?? 'Unknown',
                                            () async {
                                              final String memberId =
                                                  (member['_id'] ?? '')
                                                      .toString();
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child: LikedMemberDetail(
                                                    memberId: memberId,
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                ),
                                              );
                                              _handleMemberDetailResult(result);
                                            },
                                            key: ValueKey(
                                                "member_image_${membersTabVersion}_$index"),
                                            showHeart: showHeart,
                                            showCross: showCross,
                                            lastSwipeType: lastSwipeType,
                                            onMessageTap: () {
                                              showInviteMemberstypebottomsheet(
                                                  context);
                                            },
                                            onHeartTap: () {
                                              membersSwiperController.swipe(
                                                  CardSwiperDirection.right);
                                            },
                                            bio: member['bio'] ?? '',
                                            vibes: List<String>.from(
                                                member['vibes'] ?? []),
                                            distance:
                                                member['distance_km'] != null
                                                    ? '${member['distance_km']}'
                                                    : '',
                                            memberId: (member['_id'] ?? '')
                                                .toString(),
                                            onDetailResult:
                                                _handleMemberDetailResult,
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015),
                                          if (_showMemberUndo)
                                            _undoActionChip(
                                                _undoPendingMemberSwipe),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),

                  //! Events Card
                  if (selectedId == 2)
                    Expanded(
                      child: visibleEvents.isEmpty
                          ? shouldShowCenterPaginationLoader
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.buttonColor,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'No events found',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColor.darkTextColor
                                              : AppColor.richBlackColor,
                                        ),
                                      ),
                                      if (_showEventUndo) ...[
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015),
                                        _undoActionChip(_undoPendingEventSwipe),
                                      ],
                                    ],
                                  ),
                                )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                              child: KeyedSubtree(
                                key: ValueKey(
                                    "events_tab_${eventTabVersion}_$selectedId"),
                                child: CardSwiper(
                                  controller: eventsSwiperController,
                                  padding: EdgeInsets.zero,
                                  onSwipe: _onSwipeEvents,
                                  cardsCount: visibleEvents.length,
                                  allowedSwipeDirection:
                                      const AllowedSwipeDirection.only(
                                    left: true,
                                    right: true,
                                    down: false,
                                    up: false,
                                  ),
                                  numberOfCardsDisplayed: 1,
                                  cardBuilder: (context, index, _, __) {
                                    if (index < 0 ||
                                        index >= visibleEvents.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final event = visibleEvents[index];
                                    return Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1 /
                                                100,
                                          ),
                                          HomeWidget.eventsCard(
                                            context,
                                            event['event_image'] != null &&
                                                    event['event_image']
                                                        .isNotEmpty
                                                ? '${AppConfigProvider.imageUrl}${event['event_image']}'
                                                : AppImage.dummyImageIcon,
                                            event['event_name'] ?? 'Event',
                                            () async {
                                              final String eventId =
                                                  (event['_id'] ?? '')
                                                      .toString();
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child: LikedEventDetail(
                                                    eventId: eventId,
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                ),
                                              );
                                              _handleEventDetailResult(result);
                                            },
                                            key: ValueKey(
                                                "events_tab_${eventTabVersion}_$index"),
                                            showHeart: showHeart,
                                            showCross: showCross,
                                            lastSwipeType: lastSwipeType,
                                            onShareTap: () {
                                              eventstypebottomsheet(context);
                                            },
                                            onHeartTap: () {
                                              eventsSwiperController.swipe(
                                                  CardSwiperDirection.right);
                                            },
                                            about: event['about'] ?? '',
                                            categories: List<String>.from(
                                                event['categories'] ?? []),
                                            date: event['date'] ?? '',
                                            venueName:
                                                event['venue_name'] ?? '',
                                            address: event['address'] ?? '',
                                            distance: event['distance_km'] !=
                                                    null
                                                ? '${event['distance_km']} km'
                                                : '',
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015),
                                          if (_showEventUndo)
                                            _undoActionChip(
                                                _undoPendingEventSwipe),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),

                  //! Venues Card
                  if (selectedId == 3)
                    Expanded(
                      child: visibleVenues.isEmpty
                          ? shouldShowCenterPaginationLoader
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: AppColor.buttonColor,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'No venues found',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColor.darkTextColor
                                              : AppColor.richBlackColor,
                                        ),
                                      ),
                                      if (_showVenueUndo) ...[
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.015),
                                        _undoActionChip(_undoPendingVenueSwipe),
                                      ],
                                    ],
                                  ),
                                )
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                              child: KeyedSubtree(
                                key: ValueKey(
                                    "venues_tab_${venusTabVersion}_$selectedId"),
                                child: CardSwiper(
                                  controller: venuesSwiperController,
                                  padding: EdgeInsets.zero,
                                  onSwipe: _onSwipeVenues,
                                  cardsCount: visibleVenues.length,
                                  allowedSwipeDirection:
                                      const AllowedSwipeDirection.only(
                                    left: true,
                                    right: true,
                                    down: false,
                                    up: false,
                                  ),
                                  numberOfCardsDisplayed: 1,
                                  cardBuilder: (context, index, _, __) {
                                    if (index < 0 ||
                                        index >= visibleVenues.length) {
                                      return const SizedBox.shrink();
                                    }
                                    final venue = visibleVenues[index];
                                    return Center(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1 /
                                                100,
                                          ),
                                          HomeWidget.venuesCard(
                                            context,
                                            venue['venue_image'] != null &&
                                                    venue['venue_image']
                                                        .isNotEmpty
                                                ? '${AppConfigProvider.imageUrl}${venue['venue_image']}'
                                                : AppImage.dummyImageIcon,
                                            venue['venue_name'] ?? 'Venue',
                                            venue['_id'] ?? '',
                                            () async {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child: VenuePages(
                                                    venueId:
                                                        venue['_id'].toString(),
                                                  ),
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                ),
                                              );
                                              _handleVenueDetailResult(result);
                                            },
                                            key: ValueKey(
                                                "venues_tab_${venusTabVersion}_$index"),
                                            showHeart: showHeart,
                                            showCross: showCross,
                                            lastSwipeType: lastSwipeType,
                                            onShareTap: () {
                                              eventstypebottomsheet(context);
                                            },
                                            onHeartTap: () {
                                              venuesSwiperController.swipe(
                                                  CardSwiperDirection.right);
                                            },
                                            about: venue['about'] ?? '',
                                            categories: List<String>.from(
                                                venue['categories'] ?? []),
                                            timing: venue['timing'] ?? '',
                                            address: venue['address'] ?? '',
                                            distance: venue['distance_km'] !=
                                                    null
                                                ? '${venue['distance_km']} km'
                                                : '',
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.015),
                                          if (_showVenueUndo)
                                            _undoActionChip(
                                                _undoPendingVenueSwipe),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  if (showBottomPaginationLoader)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppColor.buttonColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showInviteMemberstypebottomsheet(BuildContext context) =>
      showInviteMembersTypeBottomSheet(context);
  void eventstypebottomsheet(BuildContext context) =>
      showEventTypesBottomSheet(context);
}
