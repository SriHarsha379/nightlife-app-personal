import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:night_life/controller/book_venue/book_venue_details_controller.dart';
import 'package:provider/provider.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';

class VenueBookedDetails extends StatefulWidget {
  final String? venueId;
  const VenueBookedDetails({super.key, this.venueId});

  @override
  State<VenueBookedDetails> createState() => _VenueBookedDetailsState();
}

class _VenueBookedDetailsState extends State<VenueBookedDetails> {
  bool showDetails = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
          Provider.of<VenuesBookingDetailsController>(context, listen: false);
      controller.fetchVenuesBookingDetail(context,
          venueId: widget.venueId.toString());
    });
  }

  /// Splits "Saturday 28 Feb" → ['Saturday', '28 Feb']
  List<String> _splitDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return ['', ''];
    final parts = dateStr.trim().split(' ');
    if (parts.length >= 3) {
      return [parts[0], parts.sublist(1).join(' ')];
    } else if (parts.length == 2) {
      return [parts[0], parts[1]];
    }
    return [dateStr, ''];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.primaryColor(context),
          body: Consumer<VenuesBookingDetailsController>(
            builder: (context, controller, _) {
              final d = controller.getVenuesDetail;

              // ── Parse date parts ─────────────────────────────────────────
              final dateParts = _splitDate(d?['date']?.toString());
              final dayName = dateParts[0]; // e.g. "Saturday"
              final dateNum = dateParts[1]; // e.g. "28 Feb"
              final timeStr = d?['time']?.toString() ?? '';

              // ── Split time into value + AM/PM ────────────────────────────
              final timeParts = timeStr.split(' ');
              final timeVal = timeParts.isNotEmpty ? timeParts[0] : timeStr;
              final timeAmPm = timeParts.length > 1 ? timeParts[1] : '';

              // ── Discount ─────────────────────────────────────────────────
              final discountPercent =
                  d?['cover_charge_percentage']?.toString() ?? '0';

              // ── Pill data: [Date, Time, Discount] ────────────────────────
              // We build 3 pills: Date | Time | Discount
              final pills = [
                {
                  'top': dayName,
                  'bottom': dateNum,
                  'label': 'Date',
                },
                {
                  'top': timeVal,
                  'bottom': timeAmPm,
                  'label': 'Time',
                },
                {
                  'top':
                      discountPercent == '0' ? "Not" : '$discountPercent% Off',
                  'bottom': discountPercent == '0' ? "Applicable" : 'on Total',
                  'label': 'Discount',
                },
              ];

              return SizedBox(
                height: size.height,
                width: size.width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.03),

                      // ── Hero Image + Back button ──────────────────────────
                      Stack(
                        children: [
                          SizedBox(
                            width: size.width,
                            height: size.height * 30 / 100,
                            child: ClipRRect(
                              child: CachedNetworkImage(
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                imageUrl:
                                    "${AppConfigProvider.imageUrl}${d?['venue_image']}",
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
                          Positioned(
                            top: size.height * 4 / 100,
                            left: size.width * 5 / 100,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: SizedBox(
                                width: size.width * 8 / 100,
                                height: size.width * 8 / 100,
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

                      SizedBox(height: size.height * 0.9 / 100),

                      // ── Venue name + address + guests ─────────────────────
                      SizedBox(
                        width: size.width * 92 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: size.width * 70 / 100,
                                  child: Text(
                                    d?['venue_name'] ?? '',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 24,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.5 / 100),
                                SizedBox(
                                  width: size.width * 70 / 100,
                                  child: Text(
                                    // show city + address
                                    '${d?['city_name'] ?? ''}, ${d?['address'] ?? ''}',
                                    style: const TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.5,
                                      color: AppColor.buttonColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Number of guests pill
                            Container(
                              width: size.width * 15 / 100,
                              height: size.height * 8 / 100,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Number of\nguests",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.5 / 100),
                                  Text(
                                    d?['number_of_guests']?.toString() ?? '0',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 2 / 100),

                      // ── Date / Time / Discount pills ─────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Heading row
                          Row(
                            children: [
                              SizedBox(width: size.width * 12 / 100),
                              _pillLabel('Date', context),
                              SizedBox(width: size.width * 23 / 100),
                              _pillLabel('Time', context),
                              SizedBox(width: size.width * 19 / 100),
                              _pillLabel('Discount', context),
                            ],
                          ),

                          SizedBox(height: size.height * 1 / 100),

                          // Pills row
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: List.generate(pills.length, (index) {
                              return Container(
                                height: size.height * 7 / 100,
                                width: size.width * 28 / 100,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor(context),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: AppColor.pasttimecolor(context),
                                    width: 0.8,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      pills[index]['top']!,
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily1,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppColor.pasttimecolor(context),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.5 / 100),
                                    Text(
                                      pills[index]['bottom']!,
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily1,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColor.pasttimecolor(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),

                          SizedBox(height: size.height * 4 / 100),

                          // ── Your Details + Price Breakdown card ───────────
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Container(
                              width: size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 20),
                              decoration: BoxDecoration(
                                color:
                                    AppColor.bookeventcontainercolor(context),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Your Details title ──────────────────
                                  const Text(
                                    "Your Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 3 / 100),

                                  // ── Info fields from API ────────────────
                                  infoItem(
                                    "Phone Number",
                                    '${d?['country_code'] ?? ''} ${d?['phone_number'] ?? ''}',
                                  ),
                                  SizedBox(height: size.height * 3 / 100),
                                  infoItem(
                                    "Full Name",
                                    d?['full_name']?.toString() ?? '',
                                  ),
                                  SizedBox(height: size.height * 3 / 100),
                                  infoItem(
                                    "Email Id",
                                    d?['email']?.toString() ?? '',
                                  ),
                                  SizedBox(height: size.height * 3 / 100),
                                  infoItem(
                                    "City",
                                    d?['city_name']?.toString() ?? '',
                                  ),
                                  d?['special_request'] == ""
                                      ? SizedBox()
                                      : SizedBox(height: size.height * 3 / 100),
                                  d?['special_request'] == ""
                                      ? SizedBox()
                                      : infoItem(
                                          "Special Request",
                                          d?['special_request']?.toString() ??
                                              '',
                                        ),
                                  const SizedBox(height: 16),
                                  const Divider(
                                      color: Colors.white24, thickness: 0.6),
                                  const SizedBox(height: 16),

                                  // ── Price breakdown title ───────────────
                                  const Text(
                                    "Price breakdown",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Ticket Charges = sub_total
                                  detailsRow(
                                    'Total Charges',
                                    "₹${d?['reservation_booking_fees'] ?? ''}",
                                  ),
                                  Divider(
                                      thickness: 0.2,
                                      color: AppColor.secondryColor(context)),
                                  SizedBox(height: size.height * 0.2 / 100),

                                  // Cover charge
                                  detailsRow(
                                    "Cover charge",
                                    "₹${d?['cover_charge'] ?? ''}",
                                  ),
                                  Divider(
                                      thickness: 0.2,
                                      color: AppColor.secondryColor(context)),
                                  SizedBox(height: size.height * 0.2 / 100),

                                  // ── Expandable Booking Fee (GST) ────────
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => showDetails = !showDetails),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Booking Fee",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white70),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(
                                              showDetails
                                                  ? Icons.keyboard_arrow_down
                                                  : Icons.keyboard_arrow_up,
                                              color: AppColor.lightGreyColor(
                                                  context),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "₹${d?['sub_total'] ?? ''}",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.secondryColor(
                                                  context)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.2 / 100),

                                  if (showDetails) ...[
                                    SizedBox(height: size.height * 0.2 / 100),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Base Price",
                                          style: TextStyle(
                                            fontSize: 7.30,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          "₹${d?['reservation_booking_fees'] ?? ''}",
                                          style: const TextStyle(
                                            fontSize: 7.30,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.6 / 100),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Cover Charge",
                                          style: TextStyle(
                                            fontSize: 7.30,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          "₹${d?['cover_charge'] ?? ''}",
                                          style: const TextStyle(
                                            fontSize: 7.30,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.6 / 100),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Integrated GST (IGST) @${d?['gst_percentage'] ?? '18'}%",
                                          style: const TextStyle(
                                              fontSize: 7.30,
                                              color: Colors.white70),
                                        ),
                                        Text(
                                          "₹${d?['gst_amount'] ?? ''}",
                                          style: const TextStyle(
                                              fontSize: 7.30,
                                              color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.6 / 100),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              "Coupon Discount",
                                              style: TextStyle(
                                                  fontSize: 7.30,
                                                  color: Colors.white70),
                                            ),
                                            // if (_appliedCouponCode.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 6),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColor.themeColor
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: AppColor.themeColor,
                                                    width: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "-₹${d?['discount'] ?? ''}",
                                          style: const TextStyle(
                                              fontSize: 7.30,
                                              color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                  ],

                                  SizedBox(height: size.height * 2 / 100),

                                  // Discount
                                  detailsRow(
                                    "Discount",
                                    d?['cover_charge_percentage'] == 0
                                        ? "Not Applicable"
                                        : "${d?['cover_charge_percentage'] ?? ''}%",
                                  ),
                                  SizedBox(height: size.height * 0.3 / 100),
                                  Divider(
                                      thickness: 0.2,
                                      color: AppColor.secondryColor(context)),
                                  SizedBox(height: size.height * 0.8 / 100),

                                  // Total
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Total",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        "₹${d?['total'] ?? ''}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: size.height * 1.6 / 100),

                                  // Payment Mode
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Payment Mode",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        d?['payment_mode']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 4 / 100),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _pillLabel(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColor.secondryColor(context),
        fontFamily: AppFont.fontFamily1,
      ),
    );
  }

  Widget detailsRow(String title, String value,
      {bool isBold = false,
      bool highlight = false,
      double? fontSize,
      FontWeight? fontWeight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.w400,
              color: AppColor.lightGreyColor(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize ?? 13,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColor.secondryColor(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
