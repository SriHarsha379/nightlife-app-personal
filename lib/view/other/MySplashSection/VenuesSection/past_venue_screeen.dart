import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:night_life/controller/book_venue/book_venue_details_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/darkmode_provider.dart';
import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class PastVenueScreen extends StatefulWidget {
  final String? venueId;
  const PastVenueScreen({super.key, this.venueId});

  @override
  State<PastVenueScreen> createState() => _PastVenueScreenState();
}

class _PastVenueScreenState extends State<PastVenueScreen> {
  bool showDetails = false;
  int selectedEmoji = -1;
  TextEditingController feedbackController = TextEditingController();

  List<String> emojis = ["", "😡", "😞", "😐", "😊", "🤩"];

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

  Future<void> _openVenueLocationInMaps(Map<String, dynamic> venueData) async {
    final latitude = venueData['latitude'];
    final longitude = venueData['longitude'];
    final addressParts = [
      (venueData['city_name'] ?? '').toString().trim(),
      (venueData['address'] ?? '').toString().trim(),
    ]..removeWhere((value) => value.isEmpty);
    final address = addressParts.join(', ');

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    // ── Adaptive colors ───────────────────────────────────────────────────
    final cardColor = AppColor.pastbookeventcontainercolor(context);
    final primaryText = AppColor.secondryColor(context);
    final subText = isDark ? Colors.white70 : const Color(0xff555555);
    final dividerColor = isDark ? Colors.white24 : const Color(0xffDDDDDD);
    final guestPillBg = isDark ? Colors.black : const Color(0xff1A0F29);
    final guestPillBorder =
        isDark ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.3);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.primaryColor(context),
          body: Consumer<VenuesBookingDetailsController>(
            builder: (context, controller, _) {
              final d = controller.getVenuesDetail;

              final dateParts = _splitDate(d?['date']?.toString());
              final dayName = dateParts[0];
              final dateNum = dateParts[1];
              final timeStr = d?['time']?.toString() ?? '';
              final timeParts = timeStr.split(' ');
              final timeVal = timeParts.isNotEmpty ? timeParts[0] : timeStr;
              final timeAmPm = timeParts.length > 1 ? timeParts[1] : '';
              final discountPercent =
                  d?['cover_charge_percentage']?.toString() ?? '0';

              final pills = [
                {'top': dayName, 'bottom': dateNum, 'label': 'Date'},
                {'top': timeVal, 'bottom': timeAmPm, 'label': 'Time'},
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
                      SizedBox(height: size.height * 0.04),

                      // ── Hero Image + Back button ──────────────────────
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
                                    color: Colors.white, // image pe white OK
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.9 / 100),

                      // ── Venue name + address + guests ─────────────────
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
                                      color: primaryText,
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.5 / 100),
                                GestureDetector(
                                  onTap: () => _openVenueLocationInMaps(
                                    Map<String, dynamic>.from(d ?? {}),
                                  ),
                                  child: SizedBox(
                                    width: size.width * 70 / 100,
                                    child: Text(
                                      '${d?['city_name'] ?? ''}, ${d?['address'] ?? ''}',
                                      style: const TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.5,
                                        color: AppColor.buttonColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ── Number of guests pill ─────────────────
                            Container(
                              width: size.width * 15 / 100,
                              height: size.height * 8 / 100,
                              decoration: BoxDecoration(
                                color: guestPillBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: guestPillBorder,
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
                                    d!['number_of_guests'].toString(),
                                    style:const TextStyle(
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

                      // ── Date / Time / Discount pills ─────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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

                          // ── Your Details + Price Breakdown card ───────
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Container(
                              width: size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Your Details title ────────────────
                                  Text(
                                    "Your Details",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 3 / 100),

                                  infoItem("Phone Number",
                                      '${d['country_code'] ?? ''} ${d['phone_number'] ?? ''}',
                                      isDark: isDark),
                                  SizedBox(height: size.height * 3 / 100),
                                  infoItem("Full Name",
                                      d['full_name']?.toString() ?? '',
                                      isDark: isDark),
                                  SizedBox(height: size.height * 3 / 100),
                                  infoItem(
                                      "Email Id", d['email']?.toString() ?? '',
                                      isDark: isDark),
                                  SizedBox(height: size.height * 3 / 100),
                                  infoItem(
                                      "City", d['city_name']?.toString() ?? '',
                                      isDark: isDark),

                                  const SizedBox(height: 16),
                                  Divider(color: dividerColor, thickness: 0.6),
                                  const SizedBox(height: 16),

                                  // ── Price breakdown title ─────────────
                                  Text(
                                    "Price breakdown",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  detailsRow(
                                    'Total Charges',
                                    "₹${d['sub_total'] ?? ''}",
                                    isDark: isDark,
                                  ),
                                  Divider(thickness: 0.2, color: dividerColor),
                                  SizedBox(height: size.height * 0.2 / 100),

                                  detailsRow(
                                    "Cover charge",
                                    "₹${d['cover_charge'] ?? ''}",
                                    isDark: isDark,
                                  ),
                                  Divider(thickness: 0.2, color: dividerColor),
                                  SizedBox(height: size.height * 0.2 / 100),

                                  // ── Expandable Booking Fee ────────────
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => showDetails = !showDetails),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Booking Fee",
                                              style: TextStyle(
                                                  fontSize: 14, color: subText),
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
                                          "₹${d['sub_total'] ?? ''}",
                                          style: TextStyle(
                                              fontSize: 14, color: primaryText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.2 / 100),

                                  if (showDetails) ...[
                                    SizedBox(height: size.height * 0.2 / 100),
                                    _subRow(
                                        "Base Price",
                                        "₹${d['reservation_booking_fees'] ?? ''}",
                                        size,
                                        subText),
                                    SizedBox(height: size.height * 0.6 / 100),
                                    _subRow(
                                        "Cover Charge",
                                        "₹${d['cover_charge'] ?? ''}",
                                        size,
                                        subText),
                                    SizedBox(height: size.height * 0.6 / 100),
                                    _subRow(
                                        "Integrated GST (IGST) @${d['gst_percentage'] ?? '18'}%",
                                        "₹${d['gst_amount'] ?? ''}",
                                        size,
                                        subText),
                                    SizedBox(height: size.height * 0.6 / 100),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 3 / 100),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Coupon Discount",
                                            style: TextStyle(
                                              fontSize: 7.30,
                                              color: subText,
                                            ),
                                          ),
                                          Text(
                                            "-₹${d['discount'] ?? ''}",
                                            style: TextStyle(
                                              fontSize: 7.30,
                                              color: subText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                  ],

                                  SizedBox(height: size.height * 2 / 100),

                                  detailsRow(
                                    "Discount",
                                    d['cover_charge_percentage'] == 0
                                        ? "Not Applicable"
                                        : "${d['cover_charge_percentage'] ?? ''}%",
                                    isDark: isDark,
                                  ),
                                  SizedBox(height: size.height * 0.3 / 100),
                                  Divider(thickness: 0.2, color: dividerColor),
                                  SizedBox(height: size.height * 0.8 / 100),

                                  // Total
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: subText,
                                        ),
                                      ),
                                      Text(
                                        "₹${d['total'] ?? ''}",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: primaryText,
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
                                      Text(
                                        "Payment Mode",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color: subText,
                                        ),
                                      ),
                                      Text(
                                        d['payment_mode']?.toString() ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w600,
                                          color: primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: size.height * 2 / 100),

                          // ── Emoji Rating ──────────────────────────────
                          Container(
                            width: size.width * 90 / 100,
                            height: size.height * 27.6 / 100,
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "How's your experience?",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: primaryText,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 1 / 100),
                                Text(
                                  "We'd love to know!",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.lightGreyColor(context)
                                        .withOpacity(0.8),
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 3 / 100),
                                Container(
                                  height: 1,
                                  width: size.width * 80 / 100,
                                  color: dividerColor,
                                ),
                                SizedBox(height: size.height * 2.6 / 100),

                                // Emoji Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children:
                                      List.generate(emojis.length, (index) {
                                    final isSelected = selectedEmoji == index;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => selectedEmoji = index);
                                        log("selected emojiiiii$selectedEmoji");
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        padding:
                                            EdgeInsets.all(isSelected ? 10 : 8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: isSelected
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color.fromARGB(
                                                        255, 195, 151, 236),
                                                    Color.fromARGB(
                                                        255, 80, 91, 216),
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : null,
                                          color: isSelected
                                              ? null
                                              : Colors.transparent,
                                        ),
                                        child: Text(
                                          emojis[index],
                                          style: const TextStyle(fontSize: 30),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: size.height * 2 / 100),

                          // ── Feedback Text Field ───────────────────────
                          Container(
                            width: size.width * 90 / 100,
                            height: size.height * 46 / 100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Thanks for your feedback!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppFont.fontFamily,
                                    color: primaryText,
                                  ),
                                ),
                                SizedBox(height: size.height * 1 / 100),
                                Text(
                                  "Your opinion matters. Tell us what worked and what didn't.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.lightGreyColor(context),
                                  ),
                                ),
                                SizedBox(height: size.height * 1.2 / 100),
                                Container(
                                  width: size.width,
                                  height: size.height * 0.0025,
                                  color: dividerColor,
                                ),
                                SizedBox(height: size.height * 2.2 / 100),

                                // Feedback Text Input
                                Container(
                                  width: size.width * 80 / 100,
                                  height: size.height * 28 / 100,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColor.myperfectcontainercolr(
                                        context),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: TextField(
                                    controller: feedbackController,
                                    maxLines: 6,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xff1A0F29),
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor:
                                          AppColor.myperfectcontainercolr(
                                              context),
                                      hintText: "My perfect night...",
                                      hintStyle: TextStyle(
                                        color: isDark
                                            ? Colors.white60
                                            : const Color(0xff8A82A0),
                                        fontSize: 14,
                                      ),
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 6 / 100),

                      Consumer<VenuesBookingDetailsController>(
                        builder: (context, providerRating, _) {
                          return selectedEmoji != -1
                              ? providerRating.secondaryLoading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        color: AppColor.buttonColor,
                                      ),
                                    )
                                  : AppButton(
                                      text:
                                          '${AppLanguage.submitButtonText[language]}',
                                      onPress: () {
                                        providerRating.ratingApiCalling(
                                          context,
                                          widget.venueId.toString(),
                                          selectedEmoji,
                                          feedbackController.text,
                                        );
                                      })
                              : const SizedBox();
                        },
                      ),

                      SizedBox(height: size.height * 4 / 100),
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

  // ── Sub row helper (inside expandable) ────────────────────────────────────
  Widget _subRow(String title, String value, Size size, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 3 / 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 7.30, fontWeight: FontWeight.w400, color: color)),
          Text(value,
              style: TextStyle(
                  fontSize: 7.30, fontWeight: FontWeight.w400, color: color)),
        ],
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
      FontWeight? fontWeight,
      required bool isDark}) {
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
              color: isDark ? Colors.white : const Color(0xff1A0F29),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoItem(String title, String value, {required bool isDark}) {
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
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white70 : const Color(0xff555555),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
