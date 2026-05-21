// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import '../../../../../commonWidget/artist_image_preview.dart';
import '../../../../../provider/darkmode_provider.dart';
import '/controller/eventDetails/events_details_controller.dart';
import '/utilities/app_color.dart';
import '/utilities/app_constant.dart';
import '/utilities/app_font.dart';
import '/utilities/app_image.dart';
import '/utilities/app_language.dart';
import '/view/other/view_all_lineup.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../utilities/app_config_provider.dart';
import '../../../../../commonWidget/event_types_bottomsheet.dart';
import '../../../../../utilities/app_image_media_viewer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:intl/intl.dart';
import '../../VenuesSection/book_event.dart';

class LikedEventDetail extends StatefulWidget {
  final String? eventId;
  final bool forceDislikeOnly;
  LikedEventDetail({
    super.key,
    this.eventId,
    this.forceDislikeOnly = false,
  });

  @override
  State<LikedEventDetail> createState() => _LikedEventDetailState();
}

class _LikedEventDetailState extends State<LikedEventDetail> {
  Timer? _countdownTimer;
  String _timerText = "🔥 Limited time";
  bool isEnded = false;
  Map<String, String>? _swipeResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController =
          Provider.of<EventDetailsController>(context, listen: false);
      homeController.fetchEventData(context, widget.eventId.toString());
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  //! Start timer based on end date
  void _startTimer(String? endDateString) {
    _countdownTimer?.cancel();

    if (endDateString == null || endDateString.isEmpty) {
      setState(() {
        _timerText = "🔥 Limited time";
        isEnded = false;
      });
      return;
    }

    try {
      DateTime endDate = DateTime.parse(endDateString);
      DateTime now = DateTime.now();

      // Set end time to 11:59:59 PM of the day BEFORE the event
      DateTime dayBeforeEvent = endDate.subtract(Duration(days: 1));
      DateTime endDateMidnight = DateTime(
        dayBeforeEvent.year,
        dayBeforeEvent.month,
        dayBeforeEvent.day,
        23,
        59,
        59,
      );

      // Check if event booking has ended
      if (now.isAfter(endDateMidnight)) {
        setState(() {
          _timerText = "🔥 Ended";
          isEnded = true;
        });
        return;
      }

      setState(() {
        isEnded = false;
      });

      bool isSameDay = now.year == dayBeforeEvent.year &&
          now.month == dayBeforeEvent.month &&
          now.day == dayBeforeEvent.day;

      if (isSameDay) {
        _updateCountdown(endDateMidnight);

        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          DateTime currentTime = DateTime.now();

          if (currentTime.isAfter(endDateMidnight)) {
            timer.cancel();
            setState(() {
              _timerText = "🔥 Ended";
              isEnded = true;
            });
          } else {
            _updateCountdown(endDateMidnight);
          }
        });
      } else {
        // Show days remaining if deadline is in the future
        int daysRemaining = endDateMidnight.difference(now).inDays + 1;
        setState(() {
          if (daysRemaining == 1) {
            _timerText = "🔥 Ends in 1 day";
          } else {
            _timerText = "🔥 Ends in $daysRemaining days";
          }
        });
      }
    } catch (e) {
      setState(() {
        _timerText = "🔥 Limited time";
        isEnded = false;
      });
    }
  }

  DateTime? _resolveEventEndDateTime(
    String? endDateString,
    String? endTimeString,
  ) {
    final endDateRaw = (endDateString ?? '').trim();
    if (endDateRaw.isEmpty) return null;

    try {
      final endDate = DateTime.parse(endDateRaw);
      final timeRaw = (endTimeString ?? '').trim();
      if (timeRaw.isEmpty) {
        return DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      }

      final normalizedTime = timeRaw.contains('-')
          ? timeRaw.split('-').last.trim()
          : timeRaw.contains(',')
              ? timeRaw.split(',').last.trim()
              : timeRaw;

      final formats = <DateFormat>[
        DateFormat('h:mm a'),
        DateFormat('hh:mm a'),
        DateFormat('H:mm'),
        DateFormat('HH:mm'),
      ];

      for (final format in formats) {
        try {
          final parsed = format.parseStrict(normalizedTime);
          return DateTime(
            endDate.year,
            endDate.month,
            endDate.day,
            parsed.hour,
            parsed.minute,
          );
        } catch (_) {}
      }
    } catch (_) {}

    return null;
  }

  void _startTimerWithEndTime(String? endDateString, String? endTimeString) {
    _countdownTimer?.cancel();

    final endDateTime = _resolveEventEndDateTime(endDateString, endTimeString);
    if (endDateTime == null) {
      setState(() {
        _timerText = "🔥 Limited time";
        isEnded = false;
      });
      return;
    }

    final now = DateTime.now();
    if (now.isAfter(endDateTime)) {
      setState(() {
        _timerText = "🔥 Ended";
        isEnded = true;
      });
      return;
    }

    setState(() {
      isEnded = false;
    });

    final isSameDay = now.year == endDateTime.year &&
        now.month == endDateTime.month &&
        now.day == endDateTime.day;

    if (isSameDay) {
      _updateCountdown(endDateTime);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentTime = DateTime.now();
        if (currentTime.isAfter(endDateTime)) {
          timer.cancel();
          setState(() {
            _timerText = "🔥 Ended";
            isEnded = true;
          });
        } else {
          _updateCountdown(endDateTime);
        }
      });
      return;
    }

    final daysRemaining = endDateTime.difference(now).inDays + 1;
    setState(() {
      _timerText = daysRemaining == 1
          ? "🔥 Ends in 1 day"
          : "🔥 Ends in $daysRemaining days";
    });
  }

  //! Add the _updateCountdown helper function
  void _updateCountdown(DateTime endDate) {
    DateTime now = DateTime.now();
    Duration remaining = endDate.difference(now);

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(remaining.inHours);
    String minutes = twoDigits(remaining.inMinutes.remainder(60));
    String seconds = twoDigits(remaining.inSeconds.remainder(60));

    setState(() {
      _timerText = "🔥 Ends in $hours:$minutes:$seconds";
    });
  }

  int selectedIndex = 0;

  void showMediaViewerBottomSheet({
    required BuildContext context,
    required List<dynamic> mediaList,
    required int initialIndex,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent.withOpacity(0.4),
      barrierColor: Colors.transparent.withOpacity(0.4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.98,
          child: MediaViewerBottomSheet(
            mediaList: mediaList,
            initialIndex: initialIndex,
          ),
        );
      },
    );
  }

  String formatDateWithSuffix(String isoDate) {
    if (isoDate.isEmpty) return "N/A";
    DateTime date = DateTime.parse(isoDate);

    String day = DateFormat('d').format(date);
    String month = DateFormat('MMM').format(date);
    String weekday = DateFormat('EEEE').format(date);

    return "${_getDayWithSuffix(int.parse(day))} $month, $weekday";
  }

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return "${day}th";
    }

    switch (day % 10) {
      case 1:
        return "${day}st";
      case 2:
        return "${day}nd";
      case 3:
        return "${day}rd";
      default:
        return "${day}th";
    }
  }

  String _str(dynamic value) => (value ?? '').toString().trim();

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    final str = _str(value).toLowerCase();
    return str == 'true' || str == '1';
  }

  String _targetEventId(dynamic eventDataId) {
    final fromData = _str(eventDataId);
    if (fromData.isNotEmpty) return fromData;
    return _str(widget.eventId);
  }

  Future<void> _openEventLocationInMaps(
    Map<String, dynamic> eventDetails,
  ) async {
    final latitudeRaw = _str(eventDetails['latitude']);
    final longitudeRaw = _str(eventDetails['longitude']);
    final address = _str(eventDetails['address']);

    Uri? uri;
    if (latitudeRaw.isNotEmpty && longitudeRaw.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitudeRaw,$longitudeRaw',
      );
    } else if (address.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    }

    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      SnackBarToastMessage.error(context, 'Unable to open location');
    }
  }

  Future<void> _submitEventSwipeAction(
    String action, {
    required String targetEventId,
  }) async {
    if (targetEventId.isEmpty) return;
    _swipeResult = {
      'action': action, // like | dislike
      'targetEventId': targetEventId,
    };
    if (!mounted) return;
    Navigator.pop(context, _swipeResult);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = context.watch<EventDetailsController>();
    final isLoading = controller.getIsLoading;
    final eventDetails = controller.getEventDetails;

    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColor.buttonColor,
          ),
        ),
      );
    }

    if (eventDetails is! Map || eventDetails.isEmpty) {
      return Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: Center(
          child: Text(
            'Failed to load event details',
            style: TextStyle(
              color: AppColor.secondryColor(context),
              fontSize: 16,
              fontFamily: AppFont.fontFamily,
            ),
          ),
        ),
      );
    }

    final isLiked = _toBool(eventDetails['is_liked']);
    final showDislikeOnly = widget.forceDislikeOnly || isLiked;
    final targetEventId = _targetEventId(eventDetails['_id']);

    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              isDark ? Brightness.dark : Brightness.light, // iOS
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Container(
              decoration: BoxDecoration(
                color:
                    AppColor.sendinvitecontainercolor(context).withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
              ),
              width: showDislikeOnly
                  ? size.width * 52 / 100
                  : size.width * 85 / 100,
              height: size.height * 7 / 100,
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 3 / 100,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () async {
                      await _submitEventSwipeAction(
                        'dislike',
                        targetEventId: targetEventId,
                      );
                    },
                    child: SizedBox(
                      width: size.width * 12 / 100,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: Image.asset(
                            AppImage.crossIcon,
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 3 / 100,
                  ),
                  GestureDetector(
                    onTap: () {
                      eventstypebottomsheet(
                        context,
                        sharedEventData:
                            Map<String, dynamic>.from(eventDetails),
                      );
                    },
                    child: Container(
                      width: size.width * 30 / 100,
                      height: size.height * 4.6 / 100,
                      decoration: BoxDecoration(
                        color: AppColor.secondryColor(context),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppColor.secondryColor(context),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppLanguage.sendInviteText[language],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.pinkColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!showDislikeOnly) ...[
                    SizedBox(
                      width: size.width * 3 / 100,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _submitEventSwipeAction(
                          'like',
                          targetEventId: targetEventId,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColor.buttonColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppImage.heartImg,
                              height: 20,
                              width: 20,
                              color: Colors.white, // optional tint color
                            ),
                            Text(
                              AppLanguage.likeText[language],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppFont.fontFamily,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            body: Container(
              width: size.width * 100 / 100,
              height: size.height * 100 / 100,
              color: AppColor.primaryColor(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 4 / 100),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: SizedBox(
                          width: size.width * 100 / 100,
                          child: Column(
                            children: [
                              //! Event Image
                              Consumer<EventDetailsController>(
                                builder: (BuildContext context, controller, _) {
                                  if (controller.getEventDetails.isEmpty) {
                                    return CircularProgressIndicator();
                                  }
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _openLineupImagePreview(
                                            context,
                                            (controller.getEventDetails[
                                                        'event_image'] ??
                                                    "")
                                                .toString(),
                                          );
                                        },
                                        child: SizedBox(
                                          width: size.width * 100 / 100,
                                          height: size.height * 30 / 100,
                                          child: ClipRRect(
                                            child: CachedNetworkImage(
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              imageUrl:
                                                  "${AppConfigProvider.imageUrl}${controller.getEventDetails['event_image']}",
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Image.asset(
                                                AppImage.dummyImageIcon,
                                                fit: BoxFit.cover,
                                              ),
                                              placeholder: (context, url) =>
                                                  Center(
                                                child: LoadingAnimationWidget
                                                    .dotsTriangle(
                                                  color: AppColor.themeColor,
                                                  size: 35,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 26,
                                        left: 16,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Image.asset(
                                            AppImage.backarrow,
                                            color:
                                                AppColor.secondryColor(context),
                                            fit: BoxFit.cover,
                                            height: size.width * 5 / 100,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(
                                height: size.height * 1 / 100,
                              ),
                              SizedBox(
                                width: size.width * 90 / 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //! Event Name
                                                Consumer<
                                                    EventDetailsController>(
                                                  builder:
                                                      (BuildContext context,
                                                          controller, _) {
                                                    String eventName = controller
                                                                .getEventDetails[
                                                            'event_name'] ??
                                                        "";
                                                    return Text(
                                                      eventName,
                                                      style: TextStyle(
                                                          fontSize: 24,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context)),
                                                    );
                                                  },
                                                ),
                                                SizedBox(
                                                  height: size.height * 2 / 100,
                                                ),

                                                //! Categories List
                                                Consumer<
                                                    EventDetailsController>(
                                                  builder:
                                                      (BuildContext context,
                                                          controller, _) {
                                                    List<dynamic>
                                                        categoriesList =
                                                        controller.getEventDetails[
                                                                'categories'] ??
                                                            [];
                                                    if (categoriesList
                                                        .isEmpty) {
                                                      return CircularProgressIndicator();
                                                    }
                                                    return Wrap(
                                                      spacing:
                                                          size.width * 2 / 100,
                                                      runSpacing: 8,
                                                      children: categoriesList
                                                          .take(3)
                                                          .map((category) {
                                                        final categoryName = (category
                                                                        is Map
                                                                    ? category[
                                                                        'name']
                                                                    : '')
                                                                ?.toString() ??
                                                            '';
                                                        return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              width: 1,
                                                              color: AppColor
                                                                  .pinkColor,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              horizontal:
                                                                  size.width *
                                                                      3 /
                                                                      100,
                                                              vertical: 1,
                                                            ),
                                                            child: Text(
                                                              categoryName,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    );
                                                  },
                                                )
                                              ],
                                            ),
                                          ),

                                          //! Like Icon and Count
                                          Stack(
                                            children: [
                                              SizedBox(
                                                width: size.width * 12 / 100,
                                                child: Image.asset(
                                                  AppImage.likeIcon,
                                                  fit: BoxFit.cover,
                                                  height: size.width * 17 / 100,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                child: Consumer<
                                                    EventDetailsController>(
                                                  builder:
                                                      (BuildContext context,
                                                          controller, _) {
                                                    String likeCount = (controller
                                                                        .getEventDetails[
                                                                    'total_likes'] ==
                                                                null ||
                                                            controller.getEventDetails[
                                                                    'total_likes'] ==
                                                                0)
                                                        ? ""
                                                        : controller
                                                            .getEventDetails[
                                                                'total_likes']
                                                            .toString();
                                                    if (likeCount.isEmpty) {
                                                      return SizedBox();
                                                    }
                                                    return SizedBox(
                                                      width:
                                                          size.width * 12 / 100,
                                                      child: Text(
                                                        likeCount,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: AppColor
                                                                .textcolor),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 3 / 100,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 4.5 / 100,
                                          height: size.width * 4.5 / 100,
                                          child: ClipRRect(
                                            child: Image.asset(
                                              AppImage.calenderPinkIcon,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              2 /
                                              100,
                                        ),

                                        //! Event Date
                                        Consumer<EventDetailsController>(
                                          builder: (BuildContext context,
                                              controller, _) {
                                            String eventDate =
                                                controller.getEventDetails[
                                                        'event_date'] ??
                                                    "";

                                            return Text(
                                              formatDateWithSuffix(eventDate),
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.secondryColor(
                                                      context)),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 2 / 100,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 4.5 / 100,
                                          height: size.width * 4.5 / 100,
                                          child: ClipRRect(
                                            child: Image.asset(
                                              AppImage.clock,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              2 /
                                              100,
                                        ),

                                        //! Event timing
                                        Consumer<EventDetailsController>(
                                          builder: (BuildContext context,
                                              controller, _) {
                                            String eventTime =
                                                controller.getEventDetails[
                                                        'event_time'] ??
                                                    "";
                                            return Text(
                                              eventTime,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.secondryColor(
                                                      context)),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 2 / 100,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: size.width * 4.5 / 100,
                                          height: size.width * 4.5 / 100,
                                          child: ClipRRect(
                                            child: Image.asset(
                                              AppImage.locationIcon,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              2 /
                                              100,
                                        ),

                                        //! Addrss and Distance
                                        Consumer<EventDetailsController>(
                                          builder: (BuildContext context,
                                              controller, _) {
                                            String eventAddress =
                                                controller.getEventDetails[
                                                        'address'] ??
                                                    "";
                                            String distance = controller
                                                    .getEventDetails[
                                                        'distance_km']
                                                    ?.toString() ??
                                                "";

                                            return GestureDetector(
                                                onTap: () =>
                                                    _openEventLocationInMaps(
                                                      Map<String, dynamic>.from(
                                                        controller
                                                            .getEventDetails,
                                                      ),
                                                    ),
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              80 /
                                                              100,
                                                          child: Text(
                                                            eventAddress,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                        ),
                                                      ),
                                                      if (distance.isNotEmpty)
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "${distance} km away",
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: AppColor
                                                                      .greyLightColor(
                                                                          context)),
                                                            ),
                                                          ],
                                                        ),
                                                    ],
                                                  ),
                                                ));
                                          },
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 4 / 100,
                                    ),

                                    //! Gallery Text and View All
                                    Consumer<EventDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        List<dynamic> galleryList = (controller
                                                            .getEventDetails[
                                                        'gallery'] ==
                                                    null ||
                                                controller
                                                    .getEventDetails['gallery']
                                                    .isEmpty)
                                            ? []
                                            : controller
                                                .getEventDetails['gallery'];
                                        if (galleryList.isEmpty) {
                                          return SizedBox();
                                        }
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Text(
                                                AppLanguage
                                                    .GalleryText[language],
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context)),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // showMediaViewerBottomSheet(
                                                //     context: context,
                                                //     mediaList: galleryImagesList,
                                                //     initialIndex: 0);
                                                _openGalleryBottomSheet(
                                                    context, galleryList, 0);
                                              },
                                              child: Container(
                                                child: Text(
                                                  AppLanguage
                                                      .viewAlltext[language],
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColor.pinkColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: size.height * 2 / 100,
                                    ),

                                    //! Gallery Images List
                                    Consumer<EventDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        List<dynamic> galleryList = (controller
                                                            .getEventDetails[
                                                        'gallery'] ==
                                                    null ||
                                                controller
                                                    .getEventDetails['gallery']
                                                    .isEmpty)
                                            ? []
                                            : controller
                                                .getEventDetails['gallery'];
                                        if (galleryList.isEmpty) {
                                          return SizedBox();
                                        }
                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            spacing: 8, // space between items
                                            children: List.generate(
                                              galleryList.length > 3
                                                  ? 3
                                                  : galleryList.length,
                                              (index) {
                                                return InkWell(
                                                  onTap: () {
                                                    _openGalleryBottomSheet(
                                                        context,
                                                        galleryList,
                                                        index);
                                                  },
                                                  child: Container(
                                                    width:
                                                        size.width * 60 / 100,
                                                    height:
                                                        size.height * 15 / 100,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: CachedNetworkImage(
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        imageUrl:
                                                            "${AppConfigProvider.imageUrl}${galleryList[index]}",
                                                        fit: BoxFit.cover,
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Image.asset(
                                                          AppImage
                                                              .dummyImageIcon,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        placeholder:
                                                            (context, url) =>
                                                                Center(
                                                          child:
                                                              LoadingAnimationWidget
                                                                  .dotsTriangle(
                                                            color: AppColor
                                                                .themeColor,
                                                            size: 35,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(
                                      height: size.height * 4 / 100,
                                    ),

                                    //! About Text
                                    Consumer<EventDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        String about = controller
                                                .getEventDetails['about'] ??
                                            "";
                                        return Column(
                                          children: [
                                            SizedBox(
                                              width: size.width * 0.90,
                                              child: Text(
                                                AppLanguage.aboutText[language],
                                                style: TextStyle(
                                                  color: AppColor.secondryColor(
                                                      context),
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 1 / 100),
                                            SizedBox(
                                              width: size.width * 90 / 100,
                                              child: ReadMoreText(
                                                about,
                                                trimLines: 3,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText: 'Read More',
                                                trimExpandedText: ' Read Less',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.normal,
                                                  color:
                                                      AppColor.greyLightColor(
                                                          context),
                                                ),
                                                moreStyle: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColor.buttonColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                                lessStyle: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColor.buttonColor,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 2 / 100),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      height: size.height * 2 / 100,
                                    ),

                                    //! Line Up list
                                    Consumer<EventDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        List<dynamic> lineUpList =
                                            (controller.getEventDetails[
                                                        'lineup'] ==
                                                    null)
                                                ? []
                                                : controller
                                                    .getEventDetails['lineup'];
                                        if (lineUpList.isEmpty) {
                                          return SizedBox();
                                        }
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    AppLanguage
                                                        .LineupText[language],
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context)),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeftWithFade,
                                                        child:
                                                            ViewAllLinupScreen(
                                                          viewAllLineUpList:
                                                              lineUpList,
                                                        ),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    child: Text(
                                                      AppLanguage.viewAlltext[
                                                          language],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .pinkColor),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.height * 2 / 100,
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: List.generate(
                                                      lineUpList.length,
                                                      (index) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              _openLineupImagePreview(
                                                                context,
                                                                (lineUpList[index]
                                                                            [
                                                                            "image"] ??
                                                                        "")
                                                                    .toString(),
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 80,
                                                              height: 80,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            35),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.25),
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            35),
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      "${AppConfigProvider.imageUrl}${lineUpList[index]['image']}",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      Image
                                                                          .asset(
                                                                    AppImage
                                                                        .placeHolderIcon,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  placeholder:
                                                                      (context,
                                                                              url) =>
                                                                          Center(
                                                                    child: LoadingAnimationWidget
                                                                        .dotsTriangle(
                                                                      color: AppColor
                                                                          .themeColor,
                                                                      size: 35,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                2 /
                                                                100,
                                                          ),
                                                          Text(
                                                            lineUpList[index]
                                                                    ["name"] ??
                                                                "No Name",
                                                            style: TextStyle(
                                                              color: AppColor
                                                                  .secondryColor(
                                                                      context),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              // height: MediaQuery.of(context).size.height * 0.2/100,
                                                              ),
                                                          Text(
                                                            lineUpList[index]
                                                                    ["title"] ??
                                                                "No Name",
                                                            style: TextStyle(
                                                              color: AppColor
                                                                  .secondryColor(
                                                                      context),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.height * 3 / 100,
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    //! Ticket Details
                                    Consumer<EventDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        dynamic ticketDetails = controller
                                                .getEventDetails['tickets'] ??
                                            {};
                                        if (ticketDetails.isEmpty) {
                                          return SizedBox();
                                        }
                                        String endDate =
                                            ticketDetails['end_date'] ?? '';
                                        final String endTime = controller
                                                .getEventDetails['end_time'] ??
                                            '';

                                        // START TIMER WHEN TICKET DETAILS ARE AVAILABLE
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                          _startTimerWithEndTime(
                                            endDate,
                                            endTime,
                                          );
                                        });

                                        return Column(
                                          children: [
                                            SizedBox(
                                              width: size.width * 88 / 100,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      AppLanguage
                                                          .TicketText[language],
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context)),
                                                    ),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                      _timerText,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColor
                                                              .textcolor),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: size.height * 3 / 100,
                                            ),
                                            Container(
                                              width: size.width * 90 / 100,
                                              height: size.height * 18 / 100,
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              decoration: BoxDecoration(
                                                color: AppColor.backgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              4 /
                                                              100,
                                                      vertical:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              2 /
                                                              100,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  size.width *
                                                                      15 /
                                                                      100,
                                                              child: Text(
                                                                AppLanguage
                                                                        .fromText[
                                                                    language],
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                            Text(
                                                              "₹${ticketDetails['min_price']?.toString() ?? ""}",
                                                              style: TextStyle(
                                                                  fontSize: 24,
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (isEnded) {
                                                              SnackBarToastMessage
                                                                  .info(context,
                                                                      "This event has ended");
                                                              return;
                                                            }
                                                            Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                type: PageTransitionType
                                                                    .rightToLeftWithFade,
                                                                child:
                                                                    BookEvent(
                                                                  eventId: widget
                                                                      .eventId,
                                                                ),
                                                                duration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            500),
                                                              ),
                                                            );
                                                          },
                                                          child: Container(
                                                            width: size.width *
                                                                45 /
                                                                100,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            40)),
                                                            child: Center(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      3 /
                                                                      100,
                                                                  vertical: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      1.8 /
                                                                      100,
                                                                ),
                                                                child: Text(
                                                                  AppLanguage
                                                                          .BookNowText[
                                                                      language],
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontFamily:
                                                                          AppFont
                                                                              .fontFamily,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: isEnded
                                                                          ? AppColor
                                                                              .textcolor
                                                                          : AppColor
                                                                              .pinkColor),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              6 /
                                                              100,
                                                      vertical: 4,
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        AppLanguage
                                                                .secureYourspotText[
                                                            language],
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  4 /
                                                  100,
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                    Center(
                                      child: Container(
                                        width: 180, // adjust size as needed
                                        height: 1,
                                        color: AppColor.lightgreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: size.height * 12 / 100,
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
        ));
  }

  void eventstypebottomsheet(
    BuildContext context, {
    Map<String, dynamic>? sharedEventData,
  }) =>
      showEventTypesBottomSheet(
        context,
        type: 'event',
        id: _str(widget.eventId),
        sharedEventData: sharedEventData,
      );

  void _openGalleryBottomSheet(
      BuildContext context, List<dynamic> galleryImages, int curentPage) {
    final size = MediaQuery.of(context).size;

    PageController pageController = PageController(
      initialPage: curentPage, // ✅ Start from passed index
    );

    int currentPage = curentPage; // ✅ Sync current page

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: size.height * 0.8,
              decoration: BoxDecoration(
                color: AppColor.transparentColor.withOpacity(.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  /// -------- TITLE & CLOSE BUTTON --------
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 5 / 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColor.secondryColor(context),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),

                  /// -------- MAIN IMAGE WITH ARROWS --------
                  SizedBox(
                    height: size.height * 0.35,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: pageController,
                          itemCount: galleryImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 3 / 100),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "${AppConfigProvider.imageUrl}${galleryImages[index]}",
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    AppImage.dummyImageIcon,
                                    fit: BoxFit.cover,
                                  ),
                                  placeholder: (context, url) => Center(
                                    child: LoadingAnimationWidget.dotsTriangle(
                                      color: AppColor.themeColor,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        /// -------- LEFT ARROW --------
                        if (currentPage > 0)
                          Positioned(
                            left: size.width * 5 / 100,
                            top: size.height * 0.15,
                            child: GestureDetector(
                              onTap: () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                        /// -------- RIGHT ARROW --------
                        if (currentPage < galleryImages.length - 1)
                          Positioned(
                            right: size.width * 5 / 100,
                            top: size.height * 0.15,
                            child: GestureDetector(
                              onTap: () {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),

                  /// -------- GALLERY GRID --------
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 5 / 100),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: galleryImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage = index;
                              });

                              pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: currentPage == index
                                      ? AppColor.pinkColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "${AppConfigProvider.imageUrl}${galleryImages[index]}",
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    AppImage.dummyImageIcon,
                                    fit: BoxFit.cover,
                                  ),
                                  placeholder: (context, url) => Center(
                                    child: LoadingAnimationWidget.dotsTriangle(
                                      color: AppColor.themeColor,
                                      size: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openLineupImagePreview(
    BuildContext context,
    String imagePath,
  ) {
    if (imagePath.trim().isEmpty) return;

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: LineupArtistPreviewScreen(imagePath: imagePath),
      ),
    );
  }

  Widget _buildTag(String text, Size size, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: AppColor.pinkColor,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 2 / 100,
          vertical: 1,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.normal,
            color: AppColor.secondryColor(context),
          ),
        ),
      ),
    );
  }
}
