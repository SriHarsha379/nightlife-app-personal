// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/controller/venues/venues_details_controller.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails6_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/darkmode_provider.dart';
import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';

class BookTable extends StatefulWidget {
  String? venueId;

  BookTable({
    super.key,
    this.venueId,
  });

  @override
  State<BookTable> createState() => _BookTableState();
}

class _BookTableState extends State<BookTable> {
  int selectedSlotIndex = -1;
  int dateindex = 0;
  bool coverChargeApplied = true;
  int selectedGuests = 2;
  bool showAllSlots = false;
  String selectedDate = '';
  final GlobalKey _guestDropdownAnchorKey = GlobalKey();
  Offset? _guestTapPosition;
  String currentMonth = '';

  Future<void> _openVenueLocationInMaps(Map<String, dynamic> venueData) async {
    final latitude = venueData['latitude'];
    final longitude = venueData['longitude'];
    final address = (venueData['address'] ?? '').toString().trim();

    Uri? uri;
    if (latitude != null && longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
    } else if (address.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    }

    if (uri == null) return;

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open location')),
      );
    }
  }

  String _formatBookingDate(String fullDate) {
    try {
      final parsed = DateTime.parse(fullDate);
      return DateFormat('d MMM').format(parsed);
    } catch (_) {
      return fullDate;
    }
  }

  // Generate next 15 dates
  List<Map<String, String>> get dates {
    final now = DateTime.now();
    return List.generate(14, (index) {
      final date = now.add(Duration(days: index));
      final dayNum = DateFormat('dd').format(date);
      final dayName = DateFormat('EEE').format(date);
      final monthName = DateFormat('MMM').format(date).toUpperCase();
      return {
        'day': dayNum,
        'dayName': dayName,
        'month': monthName,
        'fullDate': DateFormat('yyyy-MM-dd').format(date),
      };
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = dates[0]['fullDate']!;
    currentMonth = dates[0]['month']!;
    // Fetch venue details and slots for initial date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.venueId != null && widget.venueId!.isNotEmpty) {
        final controller =
            Provider.of<VenuesDetailsController>(context, listen: false);
        controller.fetchVenuesDetail(context, venueId: widget.venueId!);
      }
      _fetchSlots();
    });
  }

  void _fetchSlots() {
    if (widget.venueId != null && selectedDate.isNotEmpty) {
      final controller =
          Provider.of<VenuesDetailsController>(context, listen: false);
      controller.fetchVenueSlots(
        context,
        venueId: widget.venueId!,
        date: selectedDate,
      );
    }
  }

  Widget _buildAdaptiveImage(String url,
      {BoxFit fit = BoxFit.cover, String? fallbackAsset}) {
    if (url.isEmpty) {
      return Image.asset(fallbackAsset ?? AppImage.dummyImageIcon, fit: fit);
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(fallbackAsset ?? AppImage.dummyImageIcon, fit: fit);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
            color: AppColor.buttonColor,
          ),
        );
      },
    );
  }

  void _showGuestSelector(BuildContext context) {
    final anchorContext = _guestDropdownAnchorKey.currentContext;
    if (anchorContext == null) return;
    final RenderBox anchorBox = anchorContext.findRenderObject() as RenderBox;
    final Offset anchorOffset = anchorBox.localToGlobal(Offset.zero);
    final Size anchorSize = anchorBox.size;
    final Size screen = MediaQuery.of(context).size;

    final double dropdownWidth = anchorSize.width;
    final double itemHeight = 35;
    final double maxHeight = screen.height * 0.4;
    final double dropdownHeight =
        ((15 * itemHeight) > maxHeight ? maxHeight : (15 * itemHeight));
    final double popupTop = (_guestTapPosition?.dy ?? anchorOffset.dy)
        .clamp(20.0, screen.height - dropdownHeight - 20.0);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(dialogContext),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox(),
                ),
              ),
              Positioned(
                left: anchorOffset.dx,
                top: anchorOffset.dy + anchorSize.height + -73,
                child: Container(
                  width: dropdownWidth,
                  height: dropdownHeight,
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColor.pinkColor.withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      final guestCount = index + 1;
                      final isSelected = selectedGuests == guestCount;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedGuests = guestCount;
                          });
                          Navigator.pop(dialogContext);
                        },
                        child: SizedBox(
                          height: itemHeight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                '$guestCount',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  color: isSelected
                                      ? AppColor.buttonColor
                                      : AppColor.secondryColor(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColor.buttonColor
                                        : AppColor.secondryColor(context),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? Center(
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool hasSelectedTime = selectedSlotIndex >= 0;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.primaryColor(context),
          body: Container(
            height: size.height * 100 / 100,
            width: size.width * 100 / 100,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // SizedBox(height: size.height * 1 / 100),
                  Stack(
                    children: [
                      Consumer<VenuesDetailsController>(
                        builder:
                            (BuildContext context, controller, Widget? child) {
                          final imageUrl = controller.getImageUrl(
                            controller.getVenuesDetail?['venue_image']
                                ?.toString(),
                          );
                          return Container(
                            width: size.width * 100 / 100,
                            height: size.height * 30 / 100,
                            child: ClipRRect(
                              child: imageUrl.isNotEmpty
                                  ? _buildAdaptiveImage(
                                      imageUrl,
                                      fit: BoxFit.fill,
                                      fallbackAsset: AppImage.dummyImageIcon,
                                    )
                                  : Image.asset(
                                      AppImage.dummyImageIcon,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: size.height * 4 / 100,
                        left: size.width * 5 / 100,
                        child: Container(
                          width: size.width * 8 / 100,
                          height: size.width * 8 / 100,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Image.asset(
                                AppImage.backarrow,
                                width: size.width * 5 / 100,
                                height: size.width * 5 / 100,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 1 / 100),
                  Container(
                    width: size.width * 90 / 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: size.width * 76 / 100,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      AppLanguage.bookTableText[language],
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 2 / 100),
                                Consumer<VenuesDetailsController>(
                                  builder: (BuildContext context, controller,
                                      Widget? child) {
                                    return SizedBox(
                                      width: size.width * 75 / 100,
                                      child: Text(
                                        controller.getVenuesDetail?[
                                                'venue_name'] ??
                                            "",
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Consumer<VenuesDetailsController>(
                                  builder: (BuildContext context, controller,
                                      Widget? child) {
                                    final venueDetails =
                                        Map<String, dynamic>.from(
                                      controller.getVenuesDetail ?? {},
                                    );
                                    final address =
                                        (venueDetails['address'] ?? '')
                                            .toString();
                                    return GestureDetector(
                                      onTap: address.trim().isEmpty
                                          ? null
                                          : () => _openVenueLocationInMaps(
                                              venueDetails),
                                      child: SizedBox(
                                        width: size.width * 75 / 100,
                                        child: Text(
                                          address,
                                          style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: AppColor.buttonColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Consumer<VenuesDetailsController>(
                              builder: (BuildContext context, controller,
                                  Widget? child) {
                                final totalLikes =
                                    controller.getVenuesDetail?['total_likes'];

                                String likesText;
                                if (totalLikes == null) {
                                  likesText = "0";
                                } else if (totalLikes >= 1000) {
                                  likesText =
                                      "${(totalLikes / 1000).toStringAsFixed(1)}K";
                                } else {
                                  likesText = totalLikes.toString();
                                }

                                return Column(
                                  children: [
                                    SizedBox(
                                      width: size.width * 12 / 100,
                                      height: size.width * 12 / 100,
                                      child: Image.asset(
                                        AppImage.likeimg,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Text(
                                      likesText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.spancolor(context),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 2.5 / 100),

                        // Guest Selector
                        GestureDetector(
                          onTapDown: (details) {
                            _guestTapPosition = details.globalPosition;
                          },
                          onTap: () => _showGuestSelector(context),
                          child: Container(
                            height: size.height * 7.5 / 100,
                            width: size.width * 90 / 100,
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor(context),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.secondryColor(context)
                                      .withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColor.pinkColor,
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(width: size.width * 1 / 100),
                                  Text(
                                    AppLanguage.selectNumberGiText[language],
                                    style: TextStyle(
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                  Container(
                                    key: _guestDropdownAnchorKey,
                                    height: size.height * 4.5 / 100,
                                    width: size.width * 18 / 100,
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor(context),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: AppColor.pinkColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$selectedGuests',
                                            style: TextStyle(
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 3 / 100),
                                          Image.asset(
                                              height: size.width * 3 / 100,
                                              width: size.width * 3 / 100,
                                              AppImage.downArrow,
                                              color: AppColor.secondryColor(
                                                  context)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 1 / 100),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 4 / 100),

                        // Select Date
                        Row(
                          children: [
                            // Image.asset(
                            //   width: size.width * 5 / 100,
                            //   height: size.width * 5 / 100,
                            //   AppImage.calenderImage,
                            // ),
                            // SizedBox(width: size.width * 3 / 100),
                            Text(
                              AppLanguage.selectDateTimeText[language],
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily1,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * 2 / 100),

                        // Horizontal Date Scroller with Month Label - 15 Days
                        Container(
                          height: size.height * 11 / 100,
                          child: Row(
                            children: [
                              // Month Label on Left
                              Container(
                                width: size.width * 12 / 100,
                                height: size.height * 11 / 100,
                                decoration: BoxDecoration(
                                  color:
                                      AppColor.lightgreyColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      currentMonth,
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily1,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColor.secondryColor(context),
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: 10),

                              // Scrollable Date List
                              Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: dates.length,
                                  itemBuilder: (context, index) {
                                    final isSelected = dateindex == index;
                                    final dateItem = dates[index];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          dateindex = index;
                                          selectedDate = dateItem['fullDate']!;
                                          currentMonth = dateItem['month']!;
                                          selectedSlotIndex = -1;
                                          showAllSlots = false;
                                        });
                                        log("selectedDate$selectedDate");

                                        _fetchSlots();
                                      },
                                      child: Container(
                                        width: size.width * 16 / 100,
                                        margin: EdgeInsets.only(
                                          right: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColor.primaryColor(context),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColor.buttonColor
                                                : AppColor.secondryColor(
                                                        context)
                                                    .withOpacity(0.3),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dateItem['day']!,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily1,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 20,
                                                color: isSelected
                                                    ? AppColor.buttonColor
                                                    : AppColor.secondryColor(
                                                        context),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    size.height * 0.5 / 100),
                                            Text(
                                              dateItem['dayName']!,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily1,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: isSelected
                                                    ? AppColor.buttonColor
                                                    : AppColor.secondryColor(
                                                        context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 3 / 100),

                        // Select Time
                        Text(
                          AppLanguage.selectTimeDayText[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily1,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColor.secondryColor(context),
                          ),
                        ),

                        SizedBox(height: size.height * 2 / 100),

                        // Time Slots from API
                        Consumer<VenuesDetailsController>(
                          builder: (context, controller, child) {
                            if (controller.isSlotsLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColor.buttonColor,
                                  strokeWidth: 2,
                                ),
                              );
                            }

                            final slotsData = controller.getVenueSlots;
                            if (slotsData == null ||
                                slotsData['slots'] == null) {
                              return Center(
                                child: Text(
                                  'No slots available',
                                  style: TextStyle(
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                              );
                            }

                            final List slots = slotsData['slots'] as List;
                            final displaySlots = showAllSlots
                                ? slots
                                : (slots.length > 6
                                    ? slots.sublist(0, 6)
                                    : slots);

                            return Column(
                              children: [
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeInOut,
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 18,
                                    children: List.generate(
                                      displaySlots.length,
                                      (index) {
                                        final slot = displaySlots[index];
                                        final isSelected =
                                            selectedSlotIndex == index;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedSlotIndex = index;
                                            });
                                          },
                                          child: Container(
                                            height: size.height * 8.5 / 100,
                                            width: size.width * 28 / 100,
                                            decoration: BoxDecoration(
                                              color: AppColor.primaryColor(
                                                  context),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColor.pinkColor
                                                    : AppColor.secondryColor(
                                                        context),
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  slot['display_time'] ?? '',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily1,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: isSelected
                                                        ? AppColor.pinkColor
                                                        : AppColor
                                                            .secondryColor(
                                                                context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                // View All Slots Button
                                if (slots.length > 6)
                                  Column(
                                    children: [
                                      SizedBox(height: size.height * 2 / 100),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showAllSlots = !showAllSlots;
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              showAllSlots
                                                  ? 'View less slots'
                                                  : 'View all slots',
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                color: AppColor.secondryColor(
                                                    context),
                                              ),
                                            ),
                                            SizedBox(
                                                width: size.width * 2 / 100),
                                            AnimatedRotation(
                                              duration: const Duration(
                                                  milliseconds: 280),
                                              curve: Curves.easeInOut,
                                              turns: showAllSlots ? 0.5 : 0,
                                              child: Image.asset(
                                                height: size.width * 3 / 100,
                                                width: size.width * 3 / 100,
                                                AppImage.downArrow,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: size.height * 6 / 100),

                        // Reservation Options
                        Consumer<VenuesDetailsController>(
                          builder: (BuildContext context, controller,
                              Widget? child) {
                            dynamic venuesData = controller.getVenuesDetail;
                            final coverChargeAmount =
                                venuesData['table_reservation_fee'] ?? 0;
                            final coverChargepercent =
                                venuesData['bill_discount_percentage'] ?? 0;

                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(animation);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  ),
                                );
                              },
                              child: hasSelectedTime
                                  ? GestureDetector(
                                      key:
                                          const ValueKey('reservation_options'),
                                      onTap: () {
                                        setState(() {
                                          coverChargeApplied = true;
                                        });
                                      },
                                      child: Container(
                                        height: size.height * 22 / 100,
                                        width: size.width * 90 / 100,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor(context),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColor.secondryColor(
                                                      context)
                                                  .withOpacity(0.1),
                                              spreadRadius: 2,
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                            color: AppColor.pinkColor,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 25),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        coverChargeApplied =
                                                            true;
                                                      });
                                                    },
                                                    child: Container(
                                                      height:
                                                          size.height * 3 / 100,
                                                      width:
                                                          size.height * 3 / 100,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: coverChargeApplied ==
                                                                  true
                                                              ? AppColor
                                                                  .darkPurpleColor
                                                              : AppColor
                                                                  .lightgreyColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Container(
                                                          height: size.height *
                                                              1.5 /
                                                              100,
                                                          width: size.height *
                                                              1.5 /
                                                              100,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: coverChargeApplied ==
                                                                    true
                                                                ? AppColor
                                                                    .darkPurpleColor
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 4 / 100),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Flat $coverChargepercent% OFF on total bill',
                                                        style: TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily1,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context),
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹$coverChargeAmount cover charge required',
                                                        style: const TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily1,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .darkPurpleColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  height:
                                                      size.height * 1 / 100),
                                              const Divider(
                                                  color: AppColor.pinkColor),
                                              SizedBox(
                                                  height:
                                                      size.height * 1 / 100),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        coverChargeApplied =
                                                            false;
                                                      });
                                                    },
                                                    child: Container(
                                                      height:
                                                          size.height * 3 / 100,
                                                      width:
                                                          size.height * 3 / 100,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: coverChargeApplied == false
                                                              ? AppColor
                                                                  .darkPurpleColor
                                                              : AppColor
                                                                  .lightgreyColor,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Container(
                                                          height: size.height *
                                                              1.5 /
                                                              100,
                                                          width: size.height *
                                                              1.5 /
                                                              100,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: coverChargeApplied == false
                                                                ? AppColor
                                                                    .darkPurpleColor
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                          size.width * 4 / 100),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        coverChargeApplied =
                                                            false;
                                                      });
                                                    },
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Regular table reservation',
                                                          style: TextStyle(
                                                            fontFamily: AppFont
                                                                .fontFamily1,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
                                                          ),
                                                        ),
                                                        const Text(
                                                          'No cover charge required',
                                                          style: TextStyle(
                                                            fontFamily: AppFont
                                                                .fontFamily1,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color: AppColor
                                                                .darkPurpleColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(
                                      key: ValueKey('reservation_empty'),
                                    ),
                            );
                          },
                        ),
                        SizedBox(height: size.height * 3 / 100),
                        Center(
                          child: IgnorePointer(
                            ignoring: !hasSelectedTime,
                            child: AppButton(
                              text: AppLanguage.continueText[language],
                              backgroundColor: hasSelectedTime
                                  ? AppColor.buttonColor
                                  : Colors.grey,
                              onPress: () {
                                final controller =
                                    Provider.of<VenuesDetailsController>(
                                  context,
                                  listen: false,
                                );
                                final slotsData = controller.getVenueSlots;
                                final List slots = slotsData != null &&
                                        slotsData['slots'] is List
                                    ? slotsData['slots'] as List
                                    : [];
                                final String selectedSlotTime =
                                    selectedSlotIndex >= 0 &&
                                            selectedSlotIndex < slots.length
                                        ? (slots[selectedSlotIndex]
                                                ['display_time'] ??
                                            '')
                                        : '';

                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: ReviewBooking2Details(
                                      selectedDateApi: selectedDate,
                                      selectedDateLabel:
                                          _formatBookingDate(selectedDate),
                                      selectedSlotTime: selectedSlotTime,
                                      selectedGuests: selectedGuests,
                                      coverChargeApplied: coverChargeApplied,
                                    ),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 5 / 100),
                      ],
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
}
