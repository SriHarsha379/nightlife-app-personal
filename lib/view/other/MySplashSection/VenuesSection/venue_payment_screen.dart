import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:night_life/commonWidget/booking_success_dialog.dart';
import 'package:night_life/utilities/app_button.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:provider/provider.dart';
import '../../../../controller/book_venue/book_venue_controller.dart';
import '../../../../controller/venues/venues_details_controller.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_snack_bar_toast_message.dart';

class CompletePayment2 extends StatefulWidget {
  final String selectedDateApi;
  final String selectedDateLabel;
  final String selectedSlotTime;
  final int selectedGuests;
  final bool coverChargeApplied;
  final String fullName;
  final String countryCode;
  final String phoneNumber;
  final String email;
  final String cityName;
  final String specialRequest;
  final String transactionId;
  const CompletePayment2({
    super.key,
    this.selectedDateApi = '',
    this.selectedDateLabel = '',
    this.selectedSlotTime = '',
    this.selectedGuests = 2,
    required this.coverChargeApplied,
    this.fullName = '',
    this.countryCode = '+91',
    this.phoneNumber = '',
    this.email = '',
    this.cityName = '',
    this.specialRequest = '',
    this.transactionId = '',
  });

  @override
  State<CompletePayment2> createState() => _CompletePayment2State();
}

class _CompletePayment2State extends State<CompletePayment2>
    with TickerProviderStateMixin {
  bool isCouponSelected = false;
  bool isBookingFeeExpanded = false;
  final TextEditingController couponController = TextEditingController();
  double discountAmount = 0;

  // ── Coupon popup animations ──
  late AnimationController _popupController;
  late AnimationController _checkmarkController;
  late Animation<double> _popupScaleAnimation;
  late Animation<double> _popupFadeAnimation;
  late Animation<double> _checkmarkAnimation;

  bool _showCouponPopup = false;
  String _appliedCouponCode = '';
  double _appliedDiscountPercent = 0;

  @override
  void initState() {
    super.initState();

    // Coupon popup
    _popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _popupScaleAnimation =
        CurvedAnimation(parent: _popupController, curve: Curves.elasticOut);
    _popupFadeAnimation =
        CurvedAnimation(parent: _popupController, curve: Curves.easeIn);
    _checkmarkAnimation = CurvedAnimation(
        parent: _checkmarkController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    couponController.dispose();
    _popupController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  num _toApiAmount(double value) {
    return value % 1 == 0
        ? value.toInt()
        : double.parse(value.toStringAsFixed(2));
  }

  String _formatAmount(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }

  String get bookingSummary {
    final String date = widget.selectedDateLabel.trim();
    final String slot = widget.selectedSlotTime.trim();
    final String guests = '${widget.selectedGuests} guests';
    if (date.isEmpty && slot.isEmpty) return '\u00B7 $guests';
    if (date.isEmpty) return '$slot \u00B7 $guests';
    if (slot.isEmpty) return '$date \u00B7 $guests';
    return '$date at $slot \u00B7 $guests';
  }

  // ── Coupon popup logic ──
  void _showCouponSuccessPopup(
      String code, double discountPercent, double savedAmount) {
    setState(() {
      _showCouponPopup = true;
      _appliedCouponCode = code;
      _appliedDiscountPercent = discountPercent;
    });
    _popupController.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _checkmarkController.forward(from: 0);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _dismissCouponPopup();
    });
  }

  void _dismissCouponPopup() {
    _popupController.reverse().then((_) {
      if (mounted) setState(() => _showCouponPopup = false);
    });
  }

  // ── Booking success dialog popup ──
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
    final venuesController = context.watch<VenuesDetailsController>();
    final bookVenueController = context.watch<BookVenueController>();
    final Map<String, dynamic> venueData =
        venuesController.getVenuesDetail ?? <String, dynamic>{};
    final Map<String, dynamic> tickets =
        venueData['tickets'] is Map<String, dynamic>
            ? venueData['tickets'] as Map<String, dynamic>
            : <String, dynamic>{};

    final double basePrice = _toDouble(tickets['reservation_fee']);
    final double taxPercentage = _toDouble(tickets['tax_percentage']);
    final double gstAmount = (basePrice * taxPercentage) / 100;
    final double coverChargeAmount =
        _toDouble(venueData['table_reservation_fee']);
    final bool showCoverCharge =
        widget.coverChargeApplied && coverChargeAmount > 0;
    final double bookingFee = basePrice +
        gstAmount +
        (widget.coverChargeApplied ? coverChargeAmount : 0.0);
    final double subtotal = bookingFee;
    final double clampedDiscount =
        discountAmount > basePrice ? basePrice : discountAmount;
    final double payableAmount = subtotal - clampedDiscount;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: AppButton(
            text:
                '${AppLanguage.paySecurelyText[language]} \u20B9${_formatAmount(payableAmount)}',
            onPress: () async {
              if (bookVenueController.isBookingLoading) return;
              final venueId = (venueData['_id'] ??
                      venueData['venue_id'] ??
                      venueData['id'] ??
                      '')
                  .toString()
                  .trim();

              if (venueId.isEmpty) {
                SnackBarToastMessage.error(
                    context, 'Venue ID not found. Please try again.');
                return;
              }

              final dateForApi = widget.selectedDateApi.trim().isNotEmpty
                  ? widget.selectedDateApi.trim()
                  : widget.selectedDateLabel.trim();
              if (dateForApi.isEmpty ||
                  widget.selectedSlotTime.trim().isEmpty) {
                SnackBarToastMessage.info(
                    context, 'Please select booking date and slot');
                return;
              }

              final res =
                  await context.read<BookVenueController>().bookingVenueApi(
                        context,
                        venueId: venueId,
                        date: dateForApi,
                        slot: widget.selectedSlotTime.trim(),
                        numberOfGuests: widget.selectedGuests,
                        isCover: widget.coverChargeApplied,
                        specialRequest: widget.specialRequest.trim(),
                        transactionId: widget.transactionId.trim().isNotEmpty
                            ? widget.transactionId.trim()
                            : "TRANS${DateTime.now().millisecondsSinceEpoch}",
                        coverCharge: _toApiAmount(
                            widget.coverChargeApplied ? coverChargeAmount : 0),
                        coverChargePercentage: _toApiAmount(widget
                                .coverChargeApplied
                            ? _toDouble(venueData['bill_discount_percentage'])
                            : 0),
                        discount: _toApiAmount(clampedDiscount),
                        subTotal: _toApiAmount(subtotal),
                        total: _toApiAmount(payableAmount),
                        cityName: widget.cityName.trim(),
                        countryCode: widget.countryCode.trim(),
                        phoneNumber: widget.phoneNumber.trim(),
                        email: widget.email.trim(),
                        fullName: widget.fullName.trim(),
                        gstPercent: taxPercentage,
                        gstAmount: (gstAmount),
                        couponDiscountPercent:
                              (_appliedDiscountPercent),
                      );

              if (!mounted) return;
              if (res != null && res['success'] == true) {
                final dynamic message = res['message'];
                final String successMessage =
                    message is List && message.isNotEmpty
                        ? message.first.toString()
                        : (message?.toString() ?? 'Booking successful');
                // Show animated success popup
                _showBookingSuccess(successMessage);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: SizedBox(
                height: size.height,
                width: size.width,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 1 / 100),
                    // ── Top Bar ──
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
                    // ── Scrollable Body ──
                    Expanded(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: size.width * 90 / 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 2 / 100),
                              // ── Venue Info ──
                              Consumer<VenuesDetailsController>(
                                builder: (BuildContext context, controller, _) {
                                  dynamic eventData =
                                      controller.getVenuesDetail;
                                  if (eventData == null ||
                                      (eventData is Map && eventData.isEmpty)) {
                                    return const SizedBox();
                                  }
                                  final String eventName =
                                      eventData['venue_name'] ?? "";
                                  final String eventImage =
                                      eventData['venue_image'] ?? "";
                                  final String address =
                                      eventData['address'] ?? "";
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bookingSummary,
                                            style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13.5,
                                              color: AppColor.pinkColor,
                                            ),
                                          ),
                                          SizedBox(
                                              height: size.height * 0.1 / 100),
                                          SizedBox(
                                            width: size.width * 45 / 100,
                                            child: Text(
                                              eventName,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: AppColor.secondryColor(
                                                    context),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              height: size.height * 0.1 / 100),
                                          SizedBox(
                                            width: size.width * 45 / 100,
                                            child: Text(
                                              address,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
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
                              SizedBox(height: size.height * 4 / 100),
                              // ── Price Breakdown Title ──
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
                                    thickness: 0.3,
                                    color: AppColor.secondryColor(context),
                                  ),
                                  SizedBox(height: size.height * 0.02),

                                  // Total Charges
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Charges',
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor,
                                        ),
                                      ),
                                      Text(
                                        '\u20B9${_formatAmount(basePrice)}',
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Cover Charge (optional)
                                  if (showCoverCharge) ...[
                                    SizedBox(height: size.height * 0.02),
                                    Divider(
                                      thickness: 0.2,
                                      color: AppColor.secondryColor(context),
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Cover Charge',
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: AppColor.pinkColor,
                                          ),
                                        ),
                                        Text(
                                          '\u20B9${_formatAmount(coverChargeAmount)}',
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  SizedBox(height: size.height * 0.02),
                                  Divider(
                                    thickness: 0.2,
                                    color: AppColor.secondryColor(context),
                                  ),

                                  // ── Booking Fee Accordion ──
                                  GestureDetector(
                                    onTap: () => setState(() =>
                                        isBookingFeeExpanded =
                                            !isBookingFeeExpanded),
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                AppLanguage
                                                    .bookingfeeText[language],
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color: AppColor.pinkColor,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              AnimatedRotation(
                                                turns: isBookingFeeExpanded
                                                    ? 0.5
                                                    : 0,
                                                duration: const Duration(
                                                    milliseconds: 250),
                                                child: Image.asset(
                                                  height: size.width * 3 / 100,
                                                  width: size.width * 3 / 100,
                                                  AppImage.upArrow,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '\u20B9${_formatAmount(bookingFee)}',
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Accordion expanded content
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    child: isBookingFeeExpanded
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                  height: size.height * 0.008),
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
                                                        fontSize: 13,
                                                        color: AppColor
                                                            .lightGreyColor(
                                                                context),
                                                      ),
                                                    ),
                                                    Text(
                                                      '\u20B9${_formatAmount(basePrice)}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (widget
                                                  .coverChargeApplied) ...[
                                                SizedBox(
                                                    height:
                                                        size.height * 0.008),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 20.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        "Cover Charge",
                                                        style: TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 13,
                                                          color: AppColor
                                                              .lightGreyColor(
                                                                  context),
                                                        ),
                                                      ),
                                                      Text(
                                                        '\u20B9${_formatAmount(coverChargeAmount)}',
                                                        style: TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                              SizedBox(
                                                  height: size.height * 0.008),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Integrated GST (IGST) @${_formatAmount(taxPercentage)}%",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 13,
                                                        color: AppColor
                                                            .lightGreyColor(
                                                                context),
                                                      ),
                                                    ),
                                                    Text(
                                                      '\u20B9${_formatAmount(gstAmount)}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
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
                                          )
                                        : const SizedBox.shrink(),
                                  ),

                                  SizedBox(height: size.height * 0.01),

                                  // ── Coupon Code Row ──
                                  Row(
                                    children: [
                                      const Text(
                                        "Coupon Code",
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor,
                                        ),
                                      ),
                                      Checkbox(
                                        value: isCouponSelected,
                                        onChanged: (value) {
                                          setState(() {
                                            isCouponSelected = value ?? false;
                                            if (!isCouponSelected) {
                                              discountAmount = 0;
                                              _appliedDiscountPercent = 0;
                                              _appliedCouponCode = '';
                                              couponController.clear();
                                              context
                                                  .read<BookVenueController>()
                                                  .clearCoupon();
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  // ── Coupon Input ──
                                  if (isCouponSelected) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: couponController,
                                            maxLength: 15,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: "Enter Coupon Code",
                                              hintStyle: const TextStyle(
                                                color: Color(0xffB7AFC9),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              filled: true,
                                              counterText: '',
                                              fillColor:
                                                  const Color(0xff1E1A24),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 16),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // ── Apply / Remove toggle ──
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          transitionBuilder: (child, anim) =>
                                              ScaleTransition(
                                                  scale: anim, child: child),
                                          child: _appliedCouponCode.isNotEmpty
                                              ? ElevatedButton(
                                                  key: const ValueKey(
                                                      'remove_btn'),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 224, 66, 64),
                                                  ),
                                                  onPressed: () {
                                                    FocusManager
                                                        .instance.primaryFocus
                                                        ?.unfocus();
                                                    setState(() {
                                                      discountAmount = 0;
                                                      _appliedDiscountPercent =
                                                          0;
                                                      _appliedCouponCode = '';
                                                      couponController.clear();
                                                    });
                                                    context
                                                        .read<
                                                            BookVenueController>()
                                                        .clearCoupon();
                                                  },
                                                  child: const Text(
                                                    "Remove",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  key: const ValueKey(
                                                      'apply_btn'),
                                                  onPressed: bookVenueController
                                                          .isCouponLoading
                                                      ? null
                                                      : () async {
                                                          FocusManager.instance
                                                              .primaryFocus
                                                              ?.unfocus();
                                                          final code =
                                                              couponController
                                                                  .text
                                                                  .trim();
                                                          if (code.isEmpty) {
                                                            SnackBarToastMessage
                                                                .info(context,
                                                                    'Please enter coupon code');
                                                            return;
                                                          }
                                                          final discountPercent =
                                                              await context
                                                                  .read<
                                                                      BookVenueController>()
                                                                  .fetchCouponDiscountPercentage(
                                                                    context,
                                                                    couponCode:
                                                                        code,
                                                                  );
                                                          if (!mounted) return;
                                                          if (discountPercent !=
                                                                  null &&
                                                              discountPercent >
                                                                  0) {
                                                            final double saved =
                                                                (basePrice *
                                                                        discountPercent) /
                                                                    100;
                                                            setState(() {
                                                              discountAmount =
                                                                  saved;
                                                              _appliedDiscountPercent =
                                                                  discountPercent;
                                                              _appliedCouponCode =
                                                                  code;
                                                            });
                                                            _showCouponSuccessPopup(
                                                                code,
                                                                discountPercent,
                                                                saved);
                                                          } else {
                                                            setState(() {
                                                              discountAmount =
                                                                  0;
                                                              _appliedDiscountPercent =
                                                                  0;
                                                              _appliedCouponCode =
                                                                  '';
                                                            });
                                                          }
                                                        },
                                                  child: bookVenueController
                                                          .isCouponLoading
                                                      ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : const Text("Apply"),
                                                ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.015),
                                  ],

                                  // ── Discount Row ──
                                  if (clampedDiscount > 0) ...[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Discount",
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: AppColor.pinkColor,
                                              ),
                                            ),
                                            if (_appliedCouponCode.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColor.themeColor
                                                        .withOpacity(0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                      color:
                                                          AppColor.themeColor,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '${_formatAmount(_appliedDiscountPercent)}% OFF',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 11,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Text(
                                          '- \u20B9${_formatAmount(clampedDiscount)}',
                                          style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: Color(0xff4CAF50),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                  ],

                                  Divider(
                                    thickness: 0.2,
                                    color: AppColor.secondryColor(context),
                                  ),

                                  // ── Total ──
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLanguage.totalText[language],
                                        style: const TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: AppColor.pinkColor,
                                        ),
                                      ),
                                      Text(
                                        '\u20B9${_formatAmount(payableAmount)}',
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 20 / 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Coupon Success Popup ──
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
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * 8 / 100),
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: const Color(0xff1E1A24),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColor.themeColor.withOpacity(0.4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.themeColor.withOpacity(0.18),
                                  blurRadius: 32,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColor.themeColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
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
                                      color: AppColor.secondryColor(context),
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
                                            '${_formatAmount(_appliedDiscountPercent)}% off applied on base price\n',
                                      ),
                                      const TextSpan(text: 'You save '),
                                      TextSpan(
                                        text:
                                            '\u20B9${_formatAmount(clampedDiscount)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Color(0xff4CAF50),
                                        ),
                                      ),
                                      const TextSpan(text: ' on this booking!'),
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
                                      borderRadius: BorderRadius.circular(12),
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
    );
  }
}
