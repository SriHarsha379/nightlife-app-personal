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
import 'package:night_life/view/other/chats/chat_message_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../commonWidget/home_widget.dart';
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

  List chats = [
    {
      'id': 1,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Brew&Bloom',
      'lastMessage': '@Brew&BloomCafé',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Techno',
      'lastMessage': '@Techno',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/eventstory3.png',
      'name': 'SUNBURN',
      'lastMessage': '@Sunburn',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/eventstory1.jpg',
      'name': 'Mitro',
      'lastMessage': '@Mitro',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/eventstory2.png',
      'name': 'Razberry',
      'lastMessage': '@Razberry',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/eventstory3.png',
      'name': 'CCD',
      'lastMessage': '@CCD',
      'message': 'Send',
      'message1': 'Send',
      'isSend': false,
    },
  ];

  List chatsLists = [
    {
      'id': 1,
      'image': 'assets/icons/ProfilePhoto.png',
      'name': 'Gaurav Kapoor',
      'lastMessage': '@gkapoor02',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 2,
      'image': 'assets/icons/riya.png',
      'name': 'Riya',
      'lastMessage': '@riya00',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Café',
      'lastMessage': '@cafebloom34',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 4,
      'image': 'assets/icons/aadityaIcon.png',
      'name': 'Aaditya',
      'lastMessage': '@aadi54',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 5,
      'image': 'assets/icons/rushi.png',
      'name': 'Rushi',
      'lastMessage': '@rushi87',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
    {
      'id': 6,
      'image': 'assets/icons/Soham.png',
      'name': 'soham',
      'lastMessage': '@soham23',
      'message': 'Send',
      'message1': 'Done',
      'isSend': false,
    },
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

  String _getHeaderUserName(UserController userController) {
    final localName = userController.getUserName.trim();
    if (localName.isNotEmpty) return localName;
    return "Guest";
  }

  ImageProvider _getHeaderUserImage(UserController userController) {
    final rawImage = userController.getUserImage.trim();
    if (rawImage.isEmpty) {
      return const AssetImage(AppImage.placeHolder2Icon);
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.topToBottom,
                                    child: const Notifications(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100,
                                child: Image.asset(
                                  AppImage.bellicon,
                                ),
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
                          ? Center(
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
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.015),
                                    _undoActionChip(_undoPendingMemberSwipe),
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
                                              documenttypebottomsheet(context);
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
                          ? Center(
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
                                        height:
                                            MediaQuery.of(context).size.height *
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
                                                : AppImage.eventimg,
                                            event['event_name'] ?? 'Event',
                                            () async {
                                              await Navigator.push(
                                                context,
                                                PageTransition(
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  child:
                                                      const LikedEventDetail(),
                                                  duration: const Duration(
                                                      milliseconds: 500),
                                                ),
                                              );
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
                          ? Center(
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
                                        height:
                                            MediaQuery.of(context).size.height *
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
                                                : AppImage.venu1,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void documenttypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, (1 - value) * size.height * 0.3),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 60 / 100,
              color: Colors.transparent,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    height: MediaQuery.of(context).size.height * 60 / 100,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient:
                                  AppColor.backgroundGradientcolor(context),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(46),
                                topRight: Radius.circular(46),
                              ),
                            ),
                            width: size.width * 100 / 100,
                            height: size.height * 80 / 100,
                            child: Column(
                              children: [
                                SizedBox(height: size.height * 2 / 100),

                                /// -------- DRAG INDICATOR --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value.clamp(0.0, 1.0),
                                      child: Transform.scale(
                                        scale: 0.8 + (0.2 * value),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    AppImage.dashIcon,
                                    height: size.height * 0.5 / 100,
                                    width: size.width * 28 / 100,
                                    fit: BoxFit.fill,
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),

                                /// -------- TABS (EVENTS & VENUES) --------
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -20 * (1 - value)),
                                      child: Opacity(
                                        opacity: value.clamp(0.0, 1.0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    color: AppColor.transparentColor,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        8 /
                                        100,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 5 / 100,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// -------- EVENTS TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 0;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 0
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 0
                                                      ? AppColor.secondryColor(
                                                          context)
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 0
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .eventsText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        /// -------- VENUES TAB --------
                                        GestureDetector(
                                          onTap: () {
                                            setStateBottomSheet(() {
                                              selectedIndex = 1;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                45 /
                                                100,
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                style: TextStyle(
                                                  fontWeight: selectedIndex == 1
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: selectedIndex == 1
                                                      ? AppColor.secondryColor(
                                                          context)
                                                      : AppColor.greyLightColor,
                                                  fontSize: selectedIndex == 1
                                                      ? 16
                                                      : 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                child: Text(
                                                  AppLanguage
                                                      .venuesText[language],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                /// -------- TAB INDICATOR (FULL WIDTH) --------
                                Container(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: 2,
                                  child: Stack(
                                    children: [
                                      // Background line (full width)
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 2,
                                        color: AppColor.greyLightColor
                                            .withOpacity(0.3),
                                      ),
                                      // Animated indicator
                                      AnimatedAlign(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        alignment: selectedIndex == 0
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.45,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color:
                                                AppColor.secondryColor(context),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColor.secondryColor(
                                                        context)
                                                    .withOpacity(0.4),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: size.height * 2 / 100),
                                SizedBox(height: size.height * 1 / 100),

                                /// -------- CONTACTS LIST --------
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (Widget child,
                                        Animation<double> animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.1, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: SingleChildScrollView(
                                      key: ValueKey<int>(selectedIndex),
                                      child: Column(
                                        children: [
                                          ...List.generate(
                                            selectedIndex == 0
                                                ? chats.length
                                                : chatsLists.length,
                                            (index) {
                                              final chat = selectedIndex == 0
                                                  ? chats[index]
                                                  : chats[index];
                                              final isSend = selectedIndex == 0
                                                  ? (chats[index]['isSend'] ==
                                                      true)
                                                  : (chatsLists[index]
                                                          ['isSend'] ==
                                                      true);

                                              return TweenAnimationBuilder<
                                                  double>(
                                                tween:
                                                    Tween(begin: 0.0, end: 1.0),
                                                duration: Duration(
                                                    milliseconds:
                                                        300 + (index * 50)),
                                                curve: Curves.easeOutBack,
                                                builder:
                                                    (context, value, child) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                        30 * (1 - value), 0),
                                                    child: Opacity(
                                                      opacity:
                                                          value.clamp(0.0, 1.0),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                child: Wrap(
                                                  children: [
                                                    Container(
                                                      width:
                                                          size.width * 90 / 100,
                                                      height: size.height *
                                                          8.5 /
                                                          100,
                                                      child: ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        leading: Container(
                                                          height: size.height *
                                                              10 /
                                                              100,
                                                          width: size.width *
                                                              13 /
                                                              100,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  chat['image'] ??
                                                                      ''),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        title: Row(
                                                          children: [
                                                            Text(
                                                              chat['name'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width:
                                                                    size.width *
                                                                        2 /
                                                                        100),
                                                            // Bordered label for Event/Venue
                                                            Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                horizontal:
                                                                    size.width *
                                                                        2 /
                                                                        100,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: AppColor
                                                                      .pinkColor,
                                                                  width: .3,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                              ),
                                                              child: Text(
                                                                selectedIndex ==
                                                                        0
                                                                    ? AppLanguage
                                                                            .eventsText[
                                                                        language]
                                                                    : AppLanguage
                                                                            .venuesText[
                                                                        language],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 8,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  color: AppColor
                                                                      .secondryColor(
                                                                          context),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        subtitle: Text(
                                                          chat['lastMessage'] ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        trailing:
                                                            GestureDetector(
                                                          onTap: () {
                                                            setStateBottomSheet(
                                                                () {
                                                              if (selectedIndex ==
                                                                  0) {
                                                                chats[index][
                                                                        'isSend'] =
                                                                    true;
                                                              } else {
                                                                chatsLists[index]
                                                                        [
                                                                        'isSend'] =
                                                                    true;
                                                              }
                                                            });

                                                            Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      200),
                                                              () {
                                                                Navigator.push(
                                                                  context,
                                                                  PageTransition(
                                                                    type: PageTransitionType
                                                                        .bottomToTop,
                                                                    child:
                                                                        ChatMessageScreen(
                                                                      name: chat[
                                                                              'name'] ??
                                                                          '',
                                                                      image:
                                                                          chat['image'] ??
                                                                              '',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          child:
                                                              AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        300),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        17,
                                                                    vertical:
                                                                        7),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isSend
                                                                  ? AppColor
                                                                      .logoutContainerColor(
                                                                          context)
                                                                  : AppColor
                                                                      .secondryColor(
                                                                          context),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: isSend
                                                                  ? Border.all(
                                                                      color: AppColor
                                                                          .buttonColor,
                                                                      width: 1)
                                                                  : null,
                                                            ),
                                                            child: Text(
                                                              isSend
                                                                  ? (chat['message1']
                                                                          ?.toString() ??
                                                                      'Send')
                                                                  : (chat['message']
                                                                          ?.toString() ??
                                                                      'Send'),
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                color: isSend
                                                                    ? AppColor
                                                                        .secondryColor(
                                                                            context)
                                                                    : AppColor
                                                                        .primaryColor(
                                                                            context),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (index <
                                                        (selectedIndex == 0
                                                                ? chats.length
                                                                : chatsLists
                                                                    .length) -
                                                            1)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.1 /
                                                              100),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        });
      },
    );
  }

  void eventstypebottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 60 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 100 / 100,
                  height: MediaQuery.of(context).size.height * 60 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor(context),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(46),
                              topRight: Radius.circular(46),
                            ),
                          ),
                          width: size.width * 100 / 100,
                          height: size.height * 80 / 100,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 2 / 100),
                              Image.asset(
                                AppImage.dashIcon,
                                height: size.height * 0.5 / 100,
                                width: size.width * 28 / 100,
                                fit: BoxFit.fill,
                              ),
                              SizedBox(height: size.height * 2 / 100),
                              Center(
                                child: SizedBox(
                                  width: size.width * 90 / 100,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: List.generate(shareIcons.length,
                                        (index) {
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
                              Divider(
                                height: 0.2,
                                thickness: 0.5,
                                color: AppColor.secondryColor(context),
                                indent: 28,
                                endIndent: 28,
                              ),
                              SizedBox(height: size.height * 3 / 100),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      ...List.generate(chats.length, (index) {
                                        final chat = chatsLists[index];
                                        final isSend =
                                            chats[index]['isSend'] == true;

                                        return Wrap(
                                          children: [
                                            SizedBox(
                                              width: size.width * 90 / 100,
                                              height: size.height * 8.5 / 100,
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                leading: Container(
                                                  height:
                                                      size.height * 10 / 100,
                                                  width: size.width * 13 / 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          chat['image'] ?? ''),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                title: Text(
                                                  chat['name'] ?? '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  chat['lastMessage'] ?? '',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                trailing: GestureDetector(
                                                  onTap: () {
                                                    setStateBottomSheet(() {
                                                      chats[index]['isSend'] =
                                                          true;
                                                    });

                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 200),
                                                        () {
                                                      Navigator.push(
                                                        context,
                                                        PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .bottomToTop,
                                                          child:
                                                              ChatMessageScreen(
                                                            name: chats[index]
                                                                    ['name'] ??
                                                                '',
                                                            image: chats[index]
                                                                    ['image'] ??
                                                                '',
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 20,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: isSend
                                                          ? AppColor
                                                              .logoutContainerColor(
                                                                  context)
                                                          : AppColor
                                                              .secondryColor(
                                                                  context),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: isSend
                                                          ? Border.all(
                                                              color: AppColor
                                                                  .buttonColor,
                                                              width: 1)
                                                          : null,
                                                    ),
                                                    child: Text(
                                                      isSend
                                                          ? (chats[index][
                                                                      'message1']
                                                                  ?.toString() ??
                                                              'Send')
                                                          : (chats[index][
                                                                      'message']
                                                                  ?.toString() ??
                                                              'Send'),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        color: isSend
                                                            ? AppColor
                                                                .secondryColor(
                                                                    context)
                                                            : AppColor
                                                                .primaryColor(
                                                                    context),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (index < chats.length - 0)
                                              if (index < chats.length - 0)
                                                SizedBox(
                                                    height: size.height *
                                                        0.1 /
                                                        100),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
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
    );
  }
}
