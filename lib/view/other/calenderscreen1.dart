import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_header.dart';
import '../../utilities/app_button.dart';

class CalendarScreen1 extends StatefulWidget {
  static String routeName = './CalendarScreen';
  const CalendarScreen1({super.key});
  @override
  State<CalendarScreen1> createState() => _CalendarScreen1State();
}

class _CalendarScreen1State extends State<CalendarScreen1> {
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: AppButton(
              text: '${AppLanguage.continueText[language]}',
              onPress: () {
                // Navigator.push(
                //               context,
                //               PageTransition(
                //                 type: PageTransitionType.rightToLeftWithFade,
                //                 child: ReviewBooking2Details(),
                //                 duration: const Duration(milliseconds: 500),
                //               ),
                //             );
              },
            ),
          ),
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

                          //!Calender
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 94 / 100,
                            child: TableCalendar(
                              availableGestures: AvailableGestures
                                  .none, // Disable horizontal scroll
                              firstDay: DateTime.now(),
                              lastDay: DateTime.utc(2030, 8, 14),
                              focusedDay: selectedDay,
                              enabledDayPredicate: (day) {
                                // Disable past dates and off days
                                if (day.isBefore(DateTime.now()
                                    .subtract(const Duration(days: 1)))) {
                                  return false;
                                }
                                return !isDayDisabled(day);
                              },
                              selectedDayPredicate: (day) =>
                                  isSameDay(selectedDay, day), // Uncommented
                              onDaySelected: (selected, focused) {
                                // Uncommented
                                if (!isDayDisabled(selected)) {
                                  setState(() {
                                    selectedDay = selected;
                                    // sendDate = selected.toLocal().toString().split(' ')[0];
                                  });
                                  print("Selected date: $selectedDay");
                                  print(
                                      "sendDate date: ${selectedDay.toLocal().toString().split(' ')[0]}");
                                } else {}
                              },
                              calendarFormat: CalendarFormat
                                  .month, // Added to reduce height
                              calendarStyle: CalendarStyle(
                                selectedDecoration: BoxDecoration(
                                  gradient: AppColor.backgroundGradient,
                                  shape: BoxShape
                                      .circle, // Changed back to circle for rounded shape
                                  boxShadow: [
                                    // Added shadow to selected date
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                selectedTextStyle: TextStyle(
                                  color: AppColor.secondryColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                                todayDecoration: const BoxDecoration(
                                  color: AppColor.statusbar,
                                  shape: BoxShape.circle,
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
                                cellMargin: const EdgeInsets.all(
                                    4), // Reduced margin to compact height
                                cellPadding:
                                    const EdgeInsets.all(0), // Reduced padding
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
                              rowHeight:
                                  40, // Added to reduce overall calendar height
                            ),
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 2 / 100,
                          ),

                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100,
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
