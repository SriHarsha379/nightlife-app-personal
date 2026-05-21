// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:night_life/controller/venues/venues_details_controller.dart';
import 'package:night_life/utilities/app_button.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venue_payment_screen.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../provider/user_controller.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_snack_bar_toast_message.dart';
import '../../../../utilities/app_validation.dart';

class ReviewBooking2Details extends StatefulWidget {
  final String selectedDateApi;
  final String selectedDateLabel;
  final String selectedSlotTime;
  final int selectedGuests;
  final bool coverChargeApplied;

  ReviewBooking2Details({
    super.key,
    this.selectedDateApi = '',
    this.selectedDateLabel = '',
    this.selectedSlotTime = '',
    this.selectedGuests = 2,
    required this.coverChargeApplied,
  });

  @override
  State<ReviewBooking2Details> createState() => _ReviewBooking2DetailsState();
}

class _ReviewBooking2DetailsState extends State<ReviewBooking2Details> {
  bool _noteExpanded = false;

  int select = 0;
  bool isOpen = false;
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

  // Text Editing Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController specialRequestController =
      TextEditingController();

  String userName = '';
  String userPhone = '';
  String userEmail = '';
  String cityName = '';
  String countryCode = '+91';

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    final userController = Provider.of<UserController>(context, listen: false);
    userName = userController.getUserName;
    userPhone = userController.getUserMobile;
    userEmail = userController.getUserEmail;
    nameController.text = userController.getUserName;
    phoneController.text = userController.getUserMobile;
    emailController.text = userController.getUserEmail;
    cityName = userController.getCityData['city_name'];
    countryCode =
        (userController.getUserData['country_code'] ?? '+91').toString().trim();
  }

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String formatDateTime(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate).toLocal();
      String formattedDate = DateFormat("d MMM 'at' h:mm a").format(dateTime);
      return formattedDate;
    } catch (e) {
      return '';
    }
  }

  String get bookingSummary {
    final String date = widget.selectedDateLabel.trim();
    final String slot = widget.selectedSlotTime.trim();
    final String guests = '${widget.selectedGuests} guests';

    if (date.isEmpty && slot.isEmpty) {
      return '\u00B7 $guests';
    }
    if (date.isEmpty) {
      return '$slot \u00B7 $guests';
    }
    if (slot.isEmpty) {
      return '$date \u00B7 $guests';
    }
    return '$date at $slot \u00B7 $guests';
  }

  validation() {
    if (nameController.text.isEmpty) {
      SnackBarToastMessage.info(context, "Please enter you name");
      return;
    } else if (phoneController.text.isEmpty) {
      SnackBarToastMessage.info(context, "Please enter your phone number");
      return;
    } else if (phoneController.text.length < 10) {
      SnackBarToastMessage.error(context, "Please a valid phone number");
      return;
    } else if (emailController.text.isEmpty) {
      SnackBarToastMessage.info(context, "Please enter your email");
      return;
    } else if (!Validation.isEmailValid(context, emailController.text)) {
      return;
    } else if (select == 0) {
      SnackBarToastMessage.info(
          context, "Please accept the terms and conditions");
      return;
    } else {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: CompletePayment2(
            selectedDateApi: widget.selectedDateApi,
            selectedDateLabel: widget.selectedDateLabel,
            selectedSlotTime: widget.selectedSlotTime,
            selectedGuests: widget.selectedGuests,
            coverChargeApplied: widget.coverChargeApplied,
            fullName: nameController.text.trim(),
            phoneNumber: phoneController.text.trim(),
            email: emailController.text.trim(),
            cityName: cityName.trim(),
            countryCode: countryCode.isEmpty ? '+91' : countryCode,
            specialRequest: specialRequestController.text.trim(),
          ),
          duration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor(context),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: AppLanguage.continueText[language],
                onPress: () {
                  validation();
                },
              ),
              SizedBox(height: size.height * 1.5 / 100),
              GestureDetector(
                onTap: () {
                  setState(() {
                    select = select == 1 ? 0 : 1;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height * 3 / 100,
                      width: size.height * 3 / 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: select == 1
                              ? AppColor.darkPurpleColor
                              : AppColor.lightgreyColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: size.height * 1.5 / 100,
                          width: size.height * 1.5 / 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: select == 1
                                ? AppColor.darkPurpleColor
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 1 / 100),
                    Text(
                      'Accept the terms and conditions',
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColor.lightGreyColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 1 / 100),
            ],
          ),
        ),
        body: SafeArea(
          child: SizedBox(
            height: size.height * 100 / 100,
            width: size.width * 100 / 100,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 1 / 100,
                ),
                SizedBox(
                  width: size.width * 90 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                            color: AppColor.secondryColor(context),
                            height: size.width * 5 / 100,
                            width: size.width * 5 / 100,
                            AppImage.backArrowIcon),
                      ),
                      Text(
                        AppLanguage.reviewBookingDetailsText[language],
                        style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColor.secondryColor(context)),
                      ),
                      SizedBox(
                        height: size.width * 5 / 100,
                        width: size.width * 5 / 100,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 2 / 100,
                ),
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                        child: SizedBox(
                      width: size.width * 90 / 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),
                          // State variable upar add karo:

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _noteExpanded = !_noteExpanded;
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  AppImage.infoIcon,
                                  height: size.width * 6 / 100,
                                  width: size.width * 6 / 100,
                                  color: AppColor.secondryColor(context),
                                ),
                                SizedBox(width: size.width * 5 / 100),
                                Expanded(
                                  child: AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: Text(
                                      AppLanguage.noteMsgText[language],
                                      maxLines: _noteExpanded ? null : 1,
                                      overflow: _noteExpanded
                                          ? TextOverflow.visible
                                          : TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: size.height * 5 / 100,
                          ),

                          //! Event Details
                          Consumer<VenuesDetailsController>(
                            builder: (BuildContext context, controller, _) {
                              dynamic eventData = controller.getVenuesDetail;
                              if (eventData.isEmpty) {
                                return const SizedBox();
                              }
                              String eventName = eventData['venue_name'] ?? "";
                              String eventImage =
                                  eventData['venue_image'] ?? "";
                              // String eventDate = eventData['event_date'] ?? "";
                              String address = eventData['address'] ?? "";
                              return GestureDetector(
                                onTap: address.trim().isEmpty
                                    ? null
                                    : () => _openVenueLocationInMaps(eventData),
                                child: Row(
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
                                              color: AppColor.pinkColor),
                                        ),
                                        SizedBox(
                                          height: size.height * 0.1 / 100,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              45 /
                                              100,
                                          child: Text(
                                            eventName,
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: AppColor.secondryColor(
                                                    context)),
                                          ),
                                        ),
                                        SizedBox(
                                          height: size.height * 0.1 / 100,
                                        ),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              45 /
                                              100,
                                          // color: AppColor.pinkColor,
                                          child: Text(
                                            address,
                                            maxLines: 2,
                                            style: const TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                overflow: TextOverflow.ellipsis,
                                                color: AppColor.pinkColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Consumer<VenuesDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        return SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              35 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              10 /
                                              100,
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
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          SizedBox(
                            height: size.height * 3 / 100,
                          ),

                          GestureDetector(
                            onTap: () {
                              _showSpecialRequestBottomSheet();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLanguage.addSpecialRequestText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColor.secondryColor(context)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _showSpecialRequestBottomSheet();
                                  },
                                  child: Text(
                                    AppLanguage.plusText[language],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 30,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (specialRequestController.text.isNotEmpty)
                            Text(
                              specialRequestController.text,
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: AppColor.pinkColor),
                            ),
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),
                          //! Your Details
                          Text(
                            AppLanguage.yourDetailsText[language],
                            style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColor.secondryColor(context)),
                          ),
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),

                          // Name Field
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Name',
                                      style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _showEditNameBottomSheet,
                                  child: Text(
                                    AppLanguage.editText[language],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),

                          // Phone Field
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phone Number',
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                  Text(
                                    "+91 ${userPhone}",
                                    style: const TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: AppColor.pinkColor),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showEditPhoneBottomSheet,
                                child: Text(
                                  AppLanguage.editText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: AppColor.secondryColor(context)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),

                          // Email Field
                          SizedBox(
                            width: size.width * 92 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email id',
                                      style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                    Text(
                                      userEmail,
                                      style: const TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: _showEditEmailBottomSheet,
                                  child: Text(
                                    AppLanguage.editText[language],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),

                          // Select City (kept as is)
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'City',
                                      style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 81.0),
                                      child: Text(
                                        cityName,
                                        style: const TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: AppColor.pinkColor),
                                      ),
                                    ),
                                  ],
                                ),
                                // GestureDetector(
                                //   onTap: () {},
                                //   child: Text(
                                //     AppLanguage.editText[language],
                                //     style: TextStyle(
                                //         fontFamily: AppFont.fontFamily,
                                //         fontWeight: FontWeight.w500,
                                //         fontSize: 16,
                                //         color: AppColor.secondryColor(context)),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),

                          // Terms and Conditions
                          Consumer<VenuesDetailsController>(
                            builder: (context, venueController, _) {
                              final List<dynamic> termsList = (() {
                                final data = venueController.getVenuesDetail;
                                if (data != null &&
                                    data['terms_and_conditions'] is List) {
                                  return data['terms_and_conditions']
                                      as List<dynamic>;
                                }
                                return <dynamic>[];
                              })();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isOpen = !isOpen;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLanguage
                                              .termAndconditionsText[language],
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                        Transform.rotate(
                                          angle: !isOpen ? 0 : 3.14,
                                          child: Image.asset(
                                            AppImage.downArrow,
                                            height: size.height * 2 / 100,
                                            width: size.width * 4 / 100,
                                            fit: BoxFit.cover,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 2 / 100),
                                  if (isOpen && termsList.isNotEmpty)
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: termsList.length,
                                      itemBuilder: (context, index) {
                                        final item = termsList[index];
                                        final String text = (item is Map)
                                            ? (item['item'] ?? '').toString()
                                            : item.toString();
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          child: Text(
                                            text,
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                          SizedBox(
                            height: isOpen
                                ? size.height * 24 / 100
                                : size.height * 16 / 100,
                          ),
                        ],
                      ),
                    )))
              ],
            ),
          ),
        ),
      ),
    );
  }

// Bottom sheet for editing name
  void _showEditNameBottomSheet() {
    nameController.text = userName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  // bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.primaryColor(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Name',
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: AppColor.secondryColor(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        color: AppColor.secondryColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: const TextStyle(
                          fontFamily: AppFont.fontFamily,
                          color: AppColor.pinkColor,
                        ),
                        filled: true,
                        fillColor: AppColor.primaryColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColor.pinkColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColor.pinkColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColor.darkPurpleColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: AppButton(
                        text: 'Save',
                        onPress: () {
                          if (nameController.text.isEmpty) {
                            SnackBarToastMessage.info(
                                context, "Please enter you name");
                            return;
                          }
                          setState(() {
                            userName = nameController.text;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //! Bottom sheet for editing phone
  void _showEditPhoneBottomSheet() {
    phoneController.text = userPhone;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: GestureDetector(
              onTap: () {}, // Prevents closing when tapping on the content
              child: Container(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Phone Number',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor(context),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
                              hintStyle: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.pinkColor,
                              ),
                              filled: true,
                              fillColor: AppColor.primaryColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColor.pinkColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColor.pinkColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColor.darkPurpleColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: AppButton(
                              text: 'Save',
                              onPress: () {
                                if (phoneController.text.isEmpty) {
                                  SnackBarToastMessage.info(context,
                                      "Please enter your phone number");
                                  return;
                                } else if (phoneController.text.length < 10) {
                                  SnackBarToastMessage.error(
                                      context, "Please a valid phone number");
                                  return;
                                }
                                setState(() {
                                  userPhone = phoneController.text;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //! Bottom sheet for editing email
  void _showEditEmailBottomSheet() {
    emailController.text = userEmail;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: GestureDetector(
              onTap: () {}, // Prevents closing when tapping on the content
              child: Container(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Email',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor(context),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.pinkColor,
                              ),
                              filled: true,
                              fillColor: AppColor.primaryColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColor.pinkColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColor.pinkColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColor.darkPurpleColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: AppButton(
                              text: 'Save',
                              onPress: () {
                                if (emailController.text.isEmpty) {
                                  SnackBarToastMessage.info(
                                      context, "Please enter your email");
                                  return;
                                } else if (!Validation.isEmailValid(
                                    context, emailController.text)) {
                                  return;
                                }
                                setState(() {
                                  userEmail = emailController.text;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //! Bottom sheet for editing email
  void _showSpecialRequestBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: GestureDetector(
              onTap: () {}, // Prevents closing when tapping on the content
              child: Container(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add special request',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: specialRequestController,
                            maxLength: 250,
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor(context),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your special request',
                              hintStyle: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                color: AppColor.pinkColor,
                              ),
                              filled: true,
                              fillColor: AppColor.primaryColor(context),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColor.pinkColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColor.pinkColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: AppColor.darkPurpleColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: AppButton(
                              text: 'Add',
                              onPress: () {
                                if (emailController.text.isEmpty) {
                                  SnackBarToastMessage.info(
                                      context, "Please enter your request");
                                  return;
                                }

                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ExpandableText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: ConstrainedBox(
          constraints: isExpanded
              ? const BoxConstraints()
              : const BoxConstraints(maxHeight: 25),
          child: Text(
            widget.text,
            style: widget.style,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
      ),
    );
  }
}
