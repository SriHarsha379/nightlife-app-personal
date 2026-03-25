import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '/controller/bookingEvent/booking_event_controller.dart';
import '/utilities/app_constant.dart';
import '/utilities/app_language.dart';
import '/view/other/MySplashSection/VenuesSection/reviewbooking_details_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../controller/eventDetails/events_details_controller.dart';
import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';

class BookEvent extends StatefulWidget {
  const BookEvent({super.key, this.eventId});

  final String? eventId;

  @override
  State<BookEvent> createState() => _BookEventState();
}

class _BookEventState extends State<BookEvent> {
  Future<void> _openEventLocationInMaps(Map<String, dynamic> eventData) async {
    final latitude = eventData['latitude'];
    final longitude = eventData['longitude'];
    final address = (eventData['address'] ?? '').toString().trim();

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController =
          Provider.of<BookingEventDetails>(context, listen: false);
      homeController.fetchPassesData(context, widget.eventId.toString());
    });
  }

  // Set<int> selectedIndexes = {};
  // List<dynamic> selectedTicketsAndCounts = [];
  int selectedPassIndex = 0;
  int selectedGuests = 2;

  // Track which containers are expanded
  bool isEventLayoutExpanded = false;
  bool isProhibitedItemsExpanded = false;
  bool isFAQExpanded = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        final bookingDetails =
            Provider.of<BookingEventDetails>(context, listen: false);
        bookingDetails.clearSelections();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Consumer<BookingEventDetails>(
                    builder: (BuildContext context, controller, _) {
                      return AppButton(
                          backgroundColor:
                              controller.getSelectedTicketsList.isEmpty
                                  ? Colors.grey
                                  : AppColor.buttonColor,
                          text: AppLanguage.continueText[language],
                          onPress: () {
                            if (controller.getSelectedTicketsList.isEmpty) {
                              return;
                            }
                            controller.calculateTotalGuest();
                            Navigator.push(
                              context,
                              PageTransition(
                                type: PageTransitionType.rightToLeftWithFade,
                                child: const ReviewBookingDetails(),
                                duration: const Duration(milliseconds: 500),
                              ),
                            );
                          });
                    },
                  ),
                ),
                body: SizedBox(
                    height: size.height * 100 / 100,
                    width: size.width * 100 / 100,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),

                          //! Event Image
                          Consumer<EventDetailsController>(
                            builder: (BuildContext context, controller, _) {
                              if (controller.getEventDetails.isEmpty) {
                                return const CircularProgressIndicator();
                              }
                              return Stack(
                                children: [
                                  SizedBox(
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
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                          AppImage.dummyImageIcon,
                                          fit: BoxFit.cover,
                                        ),
                                        placeholder: (context, url) => Center(
                                          child: LoadingAnimationWidget
                                              .dotsTriangle(
                                            color: AppColor.themeColor,
                                            size: 35,
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
                                        final bookingDetails =
                                            Provider.of<BookingEventDetails>(
                                                context,
                                                listen: false);
                                        bookingDetails.clearSelections();
                                        Navigator.pop(context);
                                      },
                                      child: Image.asset(
                                        AppImage.backarrow,
                                        color: AppColor.secondryColor(context),
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
                            height: size.height * 0.9 / 100,
                          ),

                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //! Event Name

                                    Text(
                                      "Book Event",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColor.secondryColor(context)),
                                    ),

                                    SizedBox(
                                      height: size.height * 2 / 100,
                                    ),

                                    Consumer<EventDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        String eventName =
                                            controller.getEventDetails[
                                                    'event_name'] ??
                                                "";
                                        return Container(
                                          width: size.width * 75 / 100,
                                          child: Text(
                                            eventName,
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    //! Addrss and Distance
                                    Consumer<EventDetailsController>(
                                      builder: (BuildContext context,
                                          controller, _) {
                                        final eventDetails =
                                            Map<String, dynamic>.from(
                                          controller.getEventDetails,
                                        );
                                        final eventAddress =
                                            (eventDetails['address'] ?? '')
                                                .toString();
                                        return GestureDetector(
                                          onTap: eventAddress.trim().isEmpty
                                              ? null
                                              : () => _openEventLocationInMaps(
                                                    eventDetails,
                                                  ),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                70 /
                                                100,
                                            child: Text(
                                              eventAddress,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.buttonColor,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
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
                                      child: Consumer<EventDetailsController>(
                                        builder: (BuildContext context,
                                            controller, _) {
                                          String likeCount = (controller
                                                              .getEventDetails[
                                                          'total_likes'] ==
                                                      null ||
                                                  controller.getEventDetails[
                                                          'total_likes'] ==
                                                      0)
                                              ? ""
                                              : controller.getEventDetails[
                                                      'total_likes']
                                                  .toString();
                                          if (likeCount.isEmpty) {
                                            return const SizedBox();
                                          }
                                          return SizedBox(
                                            width: size.width * 12 / 100,
                                            child: Text(
                                              likeCount,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColor.textcolor),
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
                            height: size.height * 2.5 / 100,
                          ),
                          // Container(
                          //   height: size.height * 7.5 / 100,
                          //   width: size.width * 90 / 100,
                          //   decoration: BoxDecoration(
                          //       color: AppColor.primaryColor(context),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: AppColor.secondryColor(context)
                          //               .withOpacity(0.1),
                          //           spreadRadius: 2,
                          //           blurRadius: 8,
                          //           offset: const Offset(0, 4),
                          //         ),
                          //       ],
                          //       borderRadius: BorderRadius.circular(30),
                          //       border: Border.all(
                          //           color: AppColor.pinkColor, width: 0.5)),
                          //   child: Center(
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         SizedBox(
                          //           width: size.width * 1 / 100,
                          //         ),
                          //         Text(
                          //           AppLanguage.selectNumberGiText[language],
                          //           style: TextStyle(
                          //             fontFamily: AppFont.fontFamily,
                          //             fontWeight: FontWeight.w400,
                          //             fontSize: 14,
                          //             color: AppColor.secondryColor(context),
                          //           ),
                          //         ),
                          //         Container(
                          //           height: size.height * 4.5 / 100,
                          //           width: size.width * 18 / 100,
                          //           decoration: BoxDecoration(
                          //               color: AppColor.primaryColor(context),
                          //               borderRadius: BorderRadius.circular(30),
                          //               border: Border.all(
                          //                   color: AppColor.pinkColor,
                          //                   width: 0.5)),
                          //           child: Center(
                          //             child: Row(
                          //               mainAxisAlignment:
                          //                   MainAxisAlignment.center,
                          //               children: [
                          //                 Text(
                          //                   '2',
                          //                   style: TextStyle(
                          //                     fontFamily: AppFont.fontFamily,
                          //                     fontWeight: FontWeight.w400,
                          //                     fontSize: 14,
                          //                     color:
                          //                         AppColor.secondryColor(context),
                          //                   ),
                          //                 ),
                          //                 SizedBox(
                          //                   width: size.width * 3 / 100,
                          //                 ),
                          //                 Image.asset(
                          //                     height: size.width * 3 / 100,
                          //                     width: size.width * 3 / 100,
                          //                     AppImage.downArrow),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //         SizedBox(
                          //           width: size.width * 1 / 100,
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),

                          // SizedBox(
                          //   height: size.height * 4 / 100,
                          // ),
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Column(children: [
                              Container(
                                width: size.width * 65 / 100,
                                height: size.height * 5.2 / 100,
                                decoration: BoxDecoration(
                                  color: AppColor.washpressColor,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(width: size.width * 1.2 / 100),

                                    /// -------- ONE DAY PASS --------
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedPassIndex = 0;
                                          final controller =
                                              Provider.of<BookingEventDetails>(
                                                  context,
                                                  listen: false);
                                          controller.selectPassList(
                                              selectedPassIndex);
                                        });
                                      },
                                      child: Container(
                                        width: size.width * 30 / 100,
                                        height: size.height * 4.2 / 100,
                                        decoration: BoxDecoration(
                                          color: selectedPassIndex == 0
                                              ? AppColor.secondryColor(context)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(44),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 3 / 100,
                                              vertical: size.height * 1 / 100,
                                            ),
                                            child: Text(
                                              "One Day Pass",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                color: selectedPassIndex == 0
                                                    ? AppColor.primaryColor(
                                                        context)
                                                    : AppColor.secondryColor(
                                                        context),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: size.width * 2 / 100),

                                    /// -------- MULTI DAY PASS --------
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedPassIndex = 1;
                                          final controller =
                                              Provider.of<BookingEventDetails>(
                                                  context,
                                                  listen: false);
                                          controller.selectPassList(
                                              selectedPassIndex);
                                        });
                                      },
                                      child: Container(
                                        width: size.width * 30 / 100,
                                        height: size.height * 4.2 / 100,
                                        decoration: BoxDecoration(
                                          color: selectedPassIndex == 1
                                              ? AppColor.secondryColor(context)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(44),
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppLanguage.mutidayText[language],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: selectedPassIndex == 1
                                                  ? AppColor.primaryColor(
                                                      context)
                                                  : AppColor.secondryColor(
                                                      context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Consumer<BookingEventDetails>(
                                builder: (BuildContext context, controller, _) {
                                  List<dynamic> passesList =
                                      controller.getSelectedList;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: passesList.length,
                                    itemBuilder: (context, index) {
                                      final item = passesList[index];
                                      final String ticketId = item['_id'] ?? '';
                                      final bool isSelected =
                                          controller.isTicketSelected(ticketId);
                                      final int ticketCount =
                                          controller.getTicketCount(ticketId);
                                      final int availableTickets =
                                          item['available_tickets'] ?? 0;
                                      final bool isSoldOut =
                                          availableTickets <= 0;

                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['title'] ?? "",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color: AppColor
                                                          .listTextColor(
                                                              context),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height: size.height *
                                                          0.5 /
                                                          100),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '₹ ${item['price'] ?? ""}',
                                                        style: TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily1,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                          color: AppColor
                                                              .secondryColor(
                                                                  context),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.5 /
                                                              100),
                                                      Text(
                                                        ' • $availableTickets seats left',
                                                        style: TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily1,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: AppColor
                                                              .listTextColor(
                                                                  context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                      height: size.height *
                                                          1.5 /
                                                          100),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: isSoldOut
                                                    ? null
                                                    : () {
                                                        if (!isSelected) {
                                                          controller.addTicket(
                                                              ticketId,
                                                              basePrice: double
                                                                      .tryParse(
                                                                          item['price']
                                                                              .toString()) ??
                                                                  0.0,
                                                              ticketTitle: item[
                                                                      'title'] ??
                                                                  "",
                                                              isOneDay:
                                                                  selectedPassIndex);
                                                        }
                                                      },
                                                child: Container(
                                                  height: size.height * 4 / 100,
                                                  width: isSelected
                                                      ? size.width * 26 / 100
                                                      : size.width * 20 / 100,
                                                  decoration: BoxDecoration(
                                                    color: isSoldOut
                                                        ? AppColor
                                                            .logoutContainerColor(
                                                                context)
                                                        : isSelected
                                                            ? AppColor
                                                                .logoutContainerColor(
                                                                    context)
                                                            : AppColor
                                                                .secondryColor(
                                                                    context),
                                                    border: Border.all(
                                                      width: 1,
                                                      color: isSoldOut
                                                          ? AppColor
                                                              .greyLightColor(context)
                                                          : isSelected
                                                              ? AppColor
                                                                  .pinkColor
                                                              : AppColor
                                                                  .secondryColor(
                                                                      context),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: isSoldOut
                                                      ? Center(
                                                          child: Text(
                                                            'Sold Out',
                                                            style: TextStyle(
                                                              fontFamily: AppFont
                                                                  .fontFamily,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColor
                                                                  .greyLightColor(context),
                                                            ),
                                                          ),
                                                        )
                                                      : isSelected
                                                          ? Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                //! Decrease button
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    controller
                                                                        .removeTicket(
                                                                            ticketId);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4,
                                                                        horizontal:
                                                                            6),
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      color: AppColor
                                                                          .secondryColor(
                                                                              context),
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ),

                                                                //! Count display
                                                                Text(
                                                                  ticketCount
                                                                      .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily,
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: AppColor
                                                                        .secondryColor(
                                                                            context),
                                                                  ),
                                                                ),

                                                                //! Increase button
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    controller
                                                                        .increaseTicketCount(
                                                                      ticketId,
                                                                      availableTickets,
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4,
                                                                        horizontal:
                                                                            6),
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      color: AppColor
                                                                          .secondryColor(
                                                                              context),
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Center(
                                                              child: Text(
                                                                AppLanguage
                                                                        .selectText[
                                                                    language],
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppFont
                                                                          .fontFamily,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: AppColor
                                                                      .primaryColor(
                                                                          context),
                                                                ),
                                                              ),
                                                            ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: size.height * 3 / 100),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              SizedBox(height: size.height * 5.5 / 100),
                              Column(
                                children: [
                                  // View Event Layout
                                  customExpandableContainer(
                                    title: "View Event Layout",
                                    isExpanded: isEventLayoutExpanded,
                                    onTap: () {
                                      setState(() {
                                        isEventLayoutExpanded =
                                            !isEventLayoutExpanded;
                                      });
                                    },
                                    child: _buildEventLayout(size),
                                  ),

                                  // Prohibited Items
                                  customExpandableContainer(
                                    title: "Prohibited Items",
                                    isExpanded: isProhibitedItemsExpanded,
                                    onTap: () {
                                      setState(() {
                                        isProhibitedItemsExpanded =
                                            !isProhibitedItemsExpanded;
                                      });
                                    },
                                    child: _buildProhibitedItems(),
                                  ),

                                  // FAQ
                                  customExpandableContainer(
                                    title: "Frequently Asked Questions",
                                    isExpanded: isFAQExpanded,
                                    onTap: () {
                                      setState(() {
                                        isFAQExpanded = !isFAQExpanded;
                                      });
                                    },
                                    child: _buildFAQ(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.height * 20 / 100,
                              )
                            ]),
                          ),
                        ],
                      ),
                    )))),
      ),
    );
  }

  void _showGuestSelector(BuildContext context, int numOfSeats) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: AppColor.primaryColor(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                'Select Number of Guests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFont.fontFamily,
                  color: AppColor.secondryColor(context),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: numOfSeats,
                  itemBuilder: (context, index) {
                    final guestCount = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGuests = guestCount;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColor.lightgreyColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$guestCount ${guestCount == 1 ? 'Guest' : 'Guests'}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: AppFont.fontFamily,
                                color: selectedGuests == guestCount
                                    ? AppColor.pinkColor
                                    : AppColor.secondryColor(context),
                                fontWeight: selectedGuests == guestCount
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            if (selectedGuests == guestCount)
                              const Icon(
                                Icons.check,
                                color: AppColor.pinkColor,
                                size: 20,
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
        );
      },
    );
  }

  Widget customExpandableContainer({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F29),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLayout(Size size) {
    return Column(
      children: [
        // Stage Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text(
              "STAGE",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        // VIP and GA Area
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.purple.shade900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // VIP Area
              Positioned(
                top: 15,
                left: 15,
                right: 15,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "VIP AREA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              // GA Area
              Positioned(
                top: 80,
                left: 15,
                right: 15,
                bottom: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "GA AREA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Center Rectangle
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        // Notes
        const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: 14,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                "This layout is not drawn to the actual scale of the venue.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(
              Icons.square,
              color: Colors.grey,
              size: 14,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                "Sold Out / Unavailable tickets are marked in grey",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProhibitedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint("Outside food and beverages"),
        _buildBulletPoint("Professional cameras and recording equipment"),
        _buildBulletPoint("Weapons or sharp objects"),
        _buildBulletPoint("Illegal substances"),
      ],
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQItem(
          "What time does the event start?",
          "The event starts at 8:00 PM.",
        ),
        const SizedBox(height: 12),
        _buildFAQItem(
          "Is parking available?",
          "Yes, parking is available at the venue.",
        ),
        const SizedBox(height: 12),
        _buildFAQItem(
          "Can I get a refund?",
          "Refunds are available up to 48 hours before the event.",
        ),
        const SizedBox(height: 12),
        _buildFAQItem(
          "Is outside food allowed?",
          "No, outside food is not permitted inside the venue.",
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              color: AppColor.secondryColor(context),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            color: AppColor.secondryColor(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// GestureDetector(
//   onTap: () {
//     _showGuestSelector(
//         context,
//         item['available_tickets'] ??
//             0);
//   },
//   child: Container(
//     // height: size.height * 3.5 / 100,
//     // width: size.width * 20 / 100,
//     decoration: BoxDecoration(
//       color: AppColor
//           .logoutContainerColor(
//               context),
//       border: Border.all(
//         width: 1,
//         color: AppColor.pinkColor,
//       ),
//       borderRadius:
//           BorderRadius.circular(10),
//     ),
//     child: Padding(
//       padding: const EdgeInsets
//           .symmetric(
//           vertical: 4.0,
//           horizontal: 8.0),
//       child: Center(
//         child: Row(
//           mainAxisAlignment:
//               MainAxisAlignment
//                   .center,
//           children: [
//             Text(
//               selectedGuests
//                   .toString(),
//               style: TextStyle(
//                 fontFamily: AppFont
//                     .fontFamily,
//                 fontSize: 14,
//                 fontWeight:
//                     FontWeight.w500,
//                 color: AppColor
//                     .secondryColor(
//                         context),
//               ),
//             ),
//             SizedBox(
//               width: MediaQuery.of(
//                           context)
//                       .size
//                       .width *
//                   2 /
//                   100,
//             ),
//             SizedBox(
//               width: MediaQuery.of(
//                           context)
//                       .size
//                       .width *
//                   4 /
//                   100,
//               height: MediaQuery.of(
//                           context)
//                       .size
//                       .width *
//                   4 /
//                   100,
//               child: Image.asset(
//                 AppImage.downArrow,
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   ),
// ),
