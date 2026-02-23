import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../commonWidget/booking_success_dialog.dart';
import '/controller/bookingEvent/booking_event_controller.dart';
import '/provider/post_api_provider.dart';
import '/utilities/app_button.dart';
import '/utilities/app_font.dart';
import '/utilities/app_language.dart';
import '/utilities/app_loader.dart';
import 'package:provider/provider.dart';
import '../../../../controller/eventDetails/events_details_controller.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_image.dart';

class CompletePayment extends StatefulWidget {
  const CompletePayment(
      {super.key,
      required this.fullName,
      required this.phoneNumber,
      required this.email,
      required this.city});
  final String fullName;
  final String phoneNumber;
  final String email;
  final String city;

  @override
  State<CompletePayment> createState() => _CompletePaymentState();
}

class _CompletePaymentState extends State<CompletePayment>
    with TickerProviderStateMixin {
  int select = 0;
  TextEditingController couponController = TextEditingController();
  bool isOpened = false;

  // ── Popup state ──
  bool _showCouponPopup = false;
  String _appliedCouponCode = '';
  double _appliedDiscountPercent = 0;

  // ── Animation controllers ──
  late AnimationController _popupAnimController;
  late AnimationController _checkmarkAnimController;

  // ── Animations ──
  late Animation<double> _popupFadeAnimation;
  late Animation<double> _popupScaleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();

    // Popup fade + scale
    _popupAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _popupFadeAnimation = CurvedAnimation(
      parent: _popupAnimController,
      curve: Curves.easeOut,
    );
    _popupScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _popupAnimController, curve: Curves.easeOutBack),
    );

    // Checkmark bounce
    _checkmarkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _checkmarkAnimController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiProvider =
          Provider.of<BookingEventDetails>(context, listen: false);
      apiProvider.recalculatePricing();
    });
  }

  @override
  void dispose() {
    _popupAnimController.dispose();
    _checkmarkAnimController.dispose();
    couponController.dispose();
    super.dispose();
  }

  // ── Show popup ──
  void _showCouponSuccessPopup({
    required String code,
    required double discountPercent,
  }) {
    setState(() {
      _appliedCouponCode = code;
      _appliedDiscountPercent = discountPercent;
      _showCouponPopup = true;
    });
    _popupAnimController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _checkmarkAnimController.forward(from: 0);
    });
  }

  // ── Dismiss popup ──
  void _dismissCouponPopup() {
    _popupAnimController.reverse().then((_) {
      if (mounted) setState(() => _showCouponPopup = false);
    });
  }

  // ── Format amount (no trailing .0) ──
  String _formatAmount(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }

  String formatDateTime(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate).toLocal();
      return DateFormat("d MMM 'at' h:mm a").format(dateTime);
    } catch (e) {
      return '';
    }
  }

  void _showBookingSuccess(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => BookingSuccessDialog(
        message: message,
        onDone: () {
          Navigator.of(ctx).pop();
          Navigator.popUntil(context, (route) => route.isFirst);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor(context),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light));

    final size = MediaQuery.of(context).size;
    final isLoading = context.watch<PostApiProvider>().loading;
    return ProgressHUD(
      isLoading: isLoading,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.primaryColor(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Consumer<BookingEventDetails>(
              builder: (context, controller, _) {
                return AppButton(
                  text:
                      '${AppLanguage.paySecurelyText[language]} ₹${_formatAmount(controller.getFinalPrice)}',
                  onPress: () async {
                    final apiProvider =
                        Provider.of<PostApiProvider>(context, listen: false);
                    final eventController = Provider.of<EventDetailsController>(
                        context,
                        listen: false);
                    final bookingController = Provider.of<BookingEventDetails>(
                        context,
                        listen: false);
                    String eventId = eventController.getEventDetails['_id'];
                    int numberOfGuests =
                        bookingController.getSelectedTicketsList.length;
                    double discountPrice =
                        bookingController.getCouponDiscountAmount;
                    double totalPrice = bookingController.getFinalPrice;
                    List<dynamic> ticketList =
                        bookingController.getSelectedTicketsList;
                    double allTicketsPrice = bookingController.getGrandTotal;
                    final res = await apiProvider.bookingEventApi(
                      context,
                      eventId: eventId,
                      numberOfGuests: numberOfGuests,
                      transactionId: "XJFKSJQ4342",
                      discount: discountPrice,
                      allTicketsPrice: allTicketsPrice,
                      total: totalPrice,
                      cityName: widget.city,
                      countryCode: "+91",
                      phoneNumber: widget.phoneNumber,
                      email: widget.email,
                      fullName: widget.fullName,
                      ticketList: ticketList,
                    );
                    if (res?['success'] == true) {
                      controller.clearSelections();
                      _showBookingSuccess("Event joined successfully");
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const MyAppFooter(
                      //             initialIndex: 0,
                      //           )),
                      // );
                    }
                  },
                );
              },
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                // ── Main scrollable content ──
                SizedBox(
                  height: size.height,
                  width: size.width,
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 1 / 100),
                      SizedBox(
                        width: size.width * 90 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Image.asset(
                                color: AppColor.secondryColor(context),
                                height: size.width * 5 / 100,
                                width: size.width * 5 / 100,
                                AppImage.backArrowIcon,
                              ),
                            ),
                            Text(
                              AppLanguage.completeYourPaymentText[language],
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                            SizedBox(
                              height: size.width * 5 / 100,
                              width: size.width * 5 / 100,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 3 / 100),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: size.width * 90 / 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 2 / 100),

                                //! Event Details
                                Consumer<EventDetailsController>(
                                  builder: (context, controller, _) {
                                    dynamic eventData =
                                        controller.getEventDetails;
                                    if (eventData.isEmpty) {
                                      return const SizedBox();
                                    }

                                    String eventName =
                                        eventData['event_name'] ?? "";
                                    String eventImage =
                                        eventData['event_image'] ?? "";
                                    String eventDate =
                                        eventData['event_date'] ?? "";
                                    String address = eventData['address'] ?? "";

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Consumer<BookingEventDetails>(
                                              builder: (BuildContext context,
                                                  controller, _) {
                                                int length = controller
                                                    .getTotalGuest
                                                    .toInt();
                                                return Text(
                                                  "${formatDateTime(eventDate)}· $length guest(s)",
                                                  style: const TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      color:
                                                          AppColor.pinkColor),
                                                );
                                              },
                                            ),
                                            SizedBox(
                                                height:
                                                    size.height * 0.1 / 100),
                                            SizedBox(
                                              width: size.width * 50 / 100,
                                              child: Text(
                                                eventName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: AppColor.secondryColor(
                                                      context),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    size.height * 0.1 / 100),
                                            SizedBox(
                                              width: size.width * 50 / 100,
                                              child: Text(
                                                address,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color: AppColor.pinkColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: size.width * 35 / 100,
                                          height: size.height * 10 / 100,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                                  "${AppConfigProvider.imageUrl}$eventImage",
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
                                      ],
                                    );
                                  },
                                ),

                                SizedBox(height: size.height * 5 / 100),
                                Text(
                                  AppLanguage.priceBreakdownText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                                SizedBox(height: size.height * 2 / 100),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      thickness: 0.2,
                                      color: AppColor.secondryColor(context),
                                    ),
                                    SizedBox(height: size.height * 0.02),

                                    //! One Day Pass Details
                                    Consumer<BookingEventDetails>(
                                      builder: (context, controller, _) {
                                        List<dynamic> oneDayList = controller
                                            .getSelectedOneDayTicketsList;
                                        log("oneDayTickets $oneDayList");
                                        if (oneDayList.isEmpty) {
                                          return const SizedBox();
                                        }
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "One Day Passes",
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: AppColor.secondryColor(
                                                    context),
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 2 / 100),
                                            ...List.generate(oneDayList.length,
                                                (index) {
                                              return Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${oneDayList[index]['title'] ?? ""} x ${oneDayList[index]['count'] ?? ""}",
                                                        style: const TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .pinkColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹${oneDayList[index]['total_price']}',
                                                        style: TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: size.height *
                                                          1 /
                                                          100),
                                                ],
                                              );
                                            }),
                                            Divider(
                                              thickness: 0.2,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                          ],
                                        );
                                      },
                                    ),

                                    //! Multi-Day Pass Details
                                    Consumer<BookingEventDetails>(
                                      builder: (context, controller, _) {
                                        List<dynamic> multiDayList = controller
                                            .getSelectedMultiDayTicketsList;
                                        log("multiDayTickets $multiDayList");
                                        if (multiDayList.isEmpty) {
                                          return const SizedBox();
                                        }
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Multi-Day Passes",
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: AppColor.secondryColor(
                                                    context),
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 2 / 100),
                                            ...List.generate(
                                                multiDayList.length, (index) {
                                              return Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${multiDayList[index]['title'] ?? ""} x ${multiDayList[index]['count'] ?? ""}",
                                                        style: const TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .pinkColor,
                                                        ),
                                                      ),
                                                      Text(
                                                        '₹${multiDayList[index]['total_price']}',
                                                        style: TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 16,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: size.height *
                                                          1 /
                                                          100),
                                                ],
                                              );
                                            }),
                                            Divider(
                                              thickness: 0.2,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                          ],
                                        );
                                      },
                                    ),

                                    //! Booking Fee Section
                                    Consumer<BookingEventDetails>(
                                      builder: (context, controller, _) {
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => setState(() =>
                                                      isOpened = !isOpened),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        AppLanguage
                                                                .bookingfeeText[
                                                            language],
                                                        style: const TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .pinkColor,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.02),
                                                      Image.asset(
                                                        height: size.width *
                                                            3 /
                                                            100,
                                                        width: size.width *
                                                            3 /
                                                            100,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context),
                                                        isOpened
                                                            ? AppImage.upArrow
                                                            : AppImage
                                                                .downArrow,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  "₹${_formatAmount(controller.getGstAddedPrice)}",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            if (isOpened) ...[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Base Price",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        color: AppColor
                                                            .lightGreyColor(
                                                                context),
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${_formatAmount(controller.getGrandTotal)}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.01),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Integrated GST (IGST) @18%",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        color: AppColor
                                                            .lightGreyColor(
                                                                context),
                                                      ),
                                                    ),
                                                    Text(
                                                      '₹${_formatAmount(controller.getGstAmount)}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            ],
                                          ],
                                        );
                                      },
                                    ),

                                    //! Coupon Section
                                    Consumer<BookingEventDetails>(
                                      builder: (context, controller, _) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //! Coupon toggle row
                                            Row(
                                              children: [
                                                const Text(
                                                  "Coupon Code",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: AppColor.pinkColor,
                                                  ),
                                                ),
                                                Checkbox(
                                                  value: controller
                                                      .isCouponSelected,
                                                  onChanged: (value) {
                                                    if (value == false) {
                                                      controller.removeCoupon();
                                                      couponController.clear();
                                                    }
                                                    controller
                                                        .toggleCouponCheckbox(
                                                            value!);
                                                  },
                                                ),
                                              ],
                                            ),

                                            //! Coupon input row
                                            if (controller
                                                .isCouponSelected) ...[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller:
                                                          couponController,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                      decoration:
                                                          InputDecoration(
                                                        hintText:
                                                            "Enter Coupon Code",
                                                        hintStyle:
                                                            const TextStyle(
                                                          color:
                                                              Color(0xffB7AFC9),
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        filled: true,
                                                        fillColor: const Color(
                                                            0xff1E1A24),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 14,
                                                                horizontal: 16),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        focusedBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        errorText: controller
                                                            .couponErrorMessage,
                                                        errorStyle:
                                                            const TextStyle(
                                                                color: Colors
                                                                    .redAccent),
                                                        suffixIcon: controller
                                                                .isCouponApplied
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  controller
                                                                      .removeCoupon();
                                                                  couponController
                                                                      .clear();
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .redAccent,
                                                                ),
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  ElevatedButton(
                                                    onPressed: controller
                                                            .isCouponApplied
                                                        ? null
                                                        : () {
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                            final code =
                                                                couponController
                                                                    .text
                                                                    .trim();
                                                            controller
                                                                .validateAndApplyCoupon(
                                                                    context,
                                                                    code);
                                                            // Show popup only on success
                                                            if (controller
                                                                .isCouponApplied) {
                                                              // Wait for the UI to rebuild before showing popup
                                                              Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          100),
                                                                  () {
                                                                if (mounted) {
                                                                  _showCouponSuccessPopup(
                                                                    code: code,
                                                                    discountPercent:
                                                                        controller
                                                                            .getAppliedCouponPercent,
                                                                  );
                                                                }
                                                              });
                                                            }
                                                          },
                                                    child: Text(
                                                      controller.isCouponApplied
                                                          ? "Applied"
                                                          : "Apply",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                            ],

                                            //! Discount row
                                            if (controller.isCouponApplied &&
                                                controller
                                                        .getCouponDiscountAmount >
                                                    0)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Discount (${controller.getAppliedCouponPercent.toStringAsFixed(0)}%)",
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        color:
                                                            AppColor.pinkColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      "- ₹${_formatAmount(controller.getCouponDiscountAmount)}",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),

                                    Divider(
                                      thickness: 0.2,
                                      color: AppColor.secondryColor(context),
                                    ),
                                    SizedBox(height: size.height * 0.02),

                                    //! Grand Total
                                    Consumer<BookingEventDetails>(
                                      builder: (context, controller, _) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLanguage.totalText[language],
                                              style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColor.pinkColor,
                                              ),
                                            ),
                                            Text(
                                              "₹${_formatAmount(controller.getFinalPrice)}",
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: AppColor.secondryColor(
                                                    context),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                SizedBox(height: size.height * 4 / 100),
                                SizedBox(height: size.height * 20 / 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Coupon Success Popup Overlay ──
                if (_showCouponPopup)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _dismissCouponPopup,
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: FadeTransition(
                            opacity: _popupFadeAnimation,
                            child: ScaleTransition(
                              scale: _popupScaleAnimation,
                              child: Consumer<BookingEventDetails>(
                                builder: (context, controller, _) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: size.width * 8 / 100),
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff1E1A24),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: AppColor.themeColor
                                            .withOpacity(0.4),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.themeColor
                                              .withOpacity(0.18),
                                          blurRadius: 32,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Animated checkmark
                                        ScaleTransition(
                                          scale: _checkmarkAnimation,
                                          child: Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xff4CAF50)
                                                  .withOpacity(0.12),
                                              border: Border.all(
                                                color: const Color(0xff4CAF50),
                                                width: 2,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: Color(0xff4CAF50),
                                              size: 38,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        const Text(
                                          'Coupon Applied!',
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Coupon code chip
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: AppColor.themeColor
                                                .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppColor.themeColor,
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            _appliedCouponCode.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: AppColor.secondryColor(
                                                  context),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: AppColor.pinkColor,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${_formatAmount(_appliedDiscountPercent)}% off applied\n',
                                              ),
                                              const TextSpan(text: 'You save '),
                                              TextSpan(
                                                text:
                                                    '₹${_formatAmount(controller.getCouponDiscountAmount)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Color(0xff4CAF50),
                                                ),
                                              ),
                                              const TextSpan(
                                                  text: ' on this booking!'),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        GestureDetector(
                                          onTap: _dismissCouponPopup,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            decoration: BoxDecoration(
                                              color: AppColor.themeColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Great!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
