import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_config_provider.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_header.dart';
import '../../../utilities/app_image.dart';
import '../../controller/search/search_calender_filter_controller.dart';
import 'MySplashSection/EventSection/Liked/liked_event_details.dart';

class CalendarScreen extends StatefulWidget {
  static String routeName = './CalendarScreen';
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  List<String> disabledDays = [];

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  bool isDayDisabled(DateTime day) {
    if (disabledDays.isEmpty) return false;
    String dayName = _getDayName(day);
    return disabledDays.any(
        (disabledDay) => disabledDay.toLowerCase() == dayName.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<CalendarController>()
          .fetchCalendarEvents(context, selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor(context),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light));

    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.primaryColor(context),
          body: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * 100 / 100,
              width: MediaQuery.of(context).size.width * 100 / 100,
              color: AppColor.primaryColor(context),
              child: Column(children: [
                AppHeader(
                    text: AppLanguage.calendarText[language],
                    onPress: () {
                      Navigator.pop(context);
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.dateText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.pinkColor),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 94 / 100,
                            child: TableCalendar(
                              availableGestures: AvailableGestures.none,
                              firstDay: DateTime.now(),
                              lastDay: DateTime.utc(2030, 8, 14),
                              focusedDay: selectedDay,
                              enabledDayPredicate: (day) {
                                if (day.isBefore(DateTime.now()
                                    .subtract(const Duration(days: 1)))) {
                                  return false;
                                }
                                return !isDayDisabled(day);
                              },
                              selectedDayPredicate: (day) =>
                                  isSameDay(selectedDay, day),
                              onDaySelected: (selected, focused) {
                                if (!isDayDisabled(selected)) {
                                  setState(() {
                                    selectedDay = selected;
                                  });
                                  print("Selected date: $selectedDay");
                                  print(
                                      "sendDate date: ${selectedDay.toLocal().toString().split(' ')[0]}");
                                  // Fetch events for selected date
                                  context
                                      .read<CalendarController>()
                                      .fetchCalendarEvents(context, selected);
                                }
                              },
                              calendarFormat: CalendarFormat.month,
                              calendarStyle: CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  color: AppColor.themeColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColor.pinkColor,
                                      blurRadius: 12,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                selectedTextStyle: TextStyle(
                                  color: AppColor.secondryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: AppColor.themeColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColor.pinkColor.withOpacity(0.7),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                disabledTextStyle: TextStyle(
                                  color: AppColor.secondryColor(context),
                                ),
                                defaultTextStyle: TextStyle(
                                    color: AppColor.secondryColor(context)),
                                weekendTextStyle: TextStyle(
                                    color: AppColor.secondryColor(context)),
                                outsideTextStyle: TextStyle(
                                    color: AppColor.secondryColor(context)),
                                cellMargin: const EdgeInsets.all(4),
                                cellPadding: const EdgeInsets.all(0),
                              ),
                              daysOfWeekStyle: const DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: AppColor.buttonColor,
                                ),
                                weekendStyle:
                                    TextStyle(color: AppColor.buttonColor),
                              ),
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                leftChevronPadding:
                                    EdgeInsets.symmetric(horizontal: 0),
                                titleTextStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.buttonColor,
                                  fontSize: 18,
                                ),
                                leftChevronIcon: Icon(Icons.chevron_left,
                                    color: AppColor.textcolor),
                                rightChevronIcon: Icon(Icons.chevron_right,
                                    color: AppColor.textcolor),
                              ),
                              rowHeight: 40,
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 90 / 100,
                            child: Text(
                              AppLanguage.eventsText[language],
                              style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.secondryColor(context)),
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
                          ),
                          // API-driven events list
                          Consumer<CalendarController>(
                            builder: (context, controller, child) {
                              if (controller.getIsLoading) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              3 /
                                              100),
                                  child: const CircularProgressIndicator(
                                    color: AppColor.pinkColor,
                                  ),
                                );
                              }

                              if (controller.getEventsList.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              3 /
                                              100),
                                  child: Text(
                                    "No events found",
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.secondryColor(context)
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: controller.getEventsList.length,
                                  itemBuilder: (context, index) {
                                    final event =
                                        controller.getEventsList[index];
                                    final String eventName =
                                        event['event_name'] ?? '';
                                    final String eventDate =
                                        event['event_date'] ?? '';
                                    final String address =
                                        event['address'] ?? '';
                                    final String eventImage =
                                        event['event_image'] ?? '';

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type: PageTransitionType
                                                .rightToLeftWithFade,
                                            child: LikedEventDetail(
                                              eventId: event['event_id'],
                                            ),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                90 /
                                                100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: AppColor.themeColor,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1.5 /
                                                100,
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                2.5 /
                                                100,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    15 /
                                                    100,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    15 /
                                                    100,
                                                child: eventImage.isNotEmpty
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Image.network(
                                                          '${AppConfigProvider.imageUrl}$eventImage',
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Image.asset(
                                                              AppImage
                                                                  .ticketImage,
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : Image.asset(
                                                        AppImage.ticketImage,
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    2 /
                                                    100,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            45 /
                                                            100,
                                                        child: Text(
                                                          eventName,
                                                          style: TextStyle(
                                                            fontFamily: AppFont
                                                                .fontFamily,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: AppColor
                                                                .secondryColor(
                                                                    context),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        AppLanguage
                                                                .viewdetailsText[
                                                            language],
                                                        style: const TextStyle(
                                                          fontFamily: AppFont
                                                              .fontFamily,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColor
                                                              .pinkColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            60 /
                                                            100,
                                                    child: Text(
                                                      "$eventDate • $address",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: AppColor
                                                            .secondryColor(
                                                                context),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),
                        ],
                      ),
                    ))
              ]),
            ),
          ),
        ));
  }
}
