import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import 'package:provider/provider.dart';

import 'package:night_life/view/other/city_Preference/vibe_preference.dart';
import 'package:page_transition/page_transition.dart';

import '../../../controller/event_preference/event_preference_controller.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class EventPreference extends StatefulWidget {
  final String? selectedGenres;
  final String? customGenre;

  static String routeName = './EventPreference';

  const EventPreference({super.key, this.selectedGenres, this.customGenre});

  @override
  State<EventPreference> createState() => _EventPreferenceState();
}

class _EventPreferenceState extends State<EventPreference> {
  var fileName;

  TextEditingController otherEventController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log("music genres: ${widget.selectedGenres}");
    log("custom genre: ${widget.customGenre}");

    // Fetch events data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventPreferenceController>(context, listen: false)
          .fetchEventsData(context);
    });
  }

  @override
  void dispose() {
    otherEventController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer<EventPreferenceController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: AppButton(
                text: '${AppLanguage.continueText[language]}',
                onPress: () {
                  // Get selected events as comma-separated string
                  String selectedEvents = controller.getSelectedEventsString();
                  String customEvent = otherEventController.text.trim();

                  // Validation: At least one selection or custom event required
                  if (selectedEvents.isEmpty && customEvent.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Please select at least one event or enter a custom event"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  log("Selected Event IDs: $selectedEvents");
                  log("Custom Event: $customEvent");

                  // Navigate to next screen with selected data
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: VibePreference(
                        selectedGenres: widget.selectedGenres,
                        customGenre: widget.customGenre,
                        selectedEvents: selectedEvents,
                        customEvent: customEvent,
                      ),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            );
          },
        ),
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          child: Consumer<EventPreferenceController>(
            builder: (context, controller, child) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 3 / 100),

                    // Header
                    SizedBox(
                      width: size.width * 90 / 100,
                      height: size.height * 8 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: SizedBox(
                                  width: size.width * 4 / 100,
                                  child: SizedBox(
                                    height: size.height * 5 / 100,
                                    child: Image.asset(
                                      AppImage.backArrowIcon,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: size.width * 80 / 100,
                                child: Center(
                                  child: Text(
                                    textAlign: TextAlign.center,
                                    AppLanguage.eventPreferencetext[language],
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Subtitle
                    SizedBox(
                      width: size.width * 75 / 100,
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          AppLanguage.selectEventstatementText[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    // Event Type heading with selection counter
                    SizedBox(
                      width: size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLanguage.eventTypetext[language],
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                          Text(
                            '${controller.selectedCount}/${controller.maxSelection}',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.buttonColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 1 / 100),

                    // Select 1-5 text
                    SizedBox(
                      width: size.width * 90 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.select1to5Text[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.filledText(context),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 3 / 100),

                    // Loading or Events List
                    if (controller.getIsLoading)
                      SizedBox(
                        height: size.height * 30 / 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.buttonColor,
                          ),
                        ),
                      )
                    else if (controller.getEventsList.isEmpty)
                      SizedBox(
                        height: size.height * 30 / 100,
                        child: Center(
                          child: Text(
                            'No events available',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        width: size.width * 90 / 100,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            controller.getEventsList.length,
                            (index) {
                              var event = controller.getEventsList[index];
                              String eventId = event['_id'] ?? '';
                              String eventName =
                                  event['category_name'] ?? 'Unknown';
                              bool isSelected =
                                  controller.isEventSelected(eventId);

                              return GestureDetector(
                                onTap: () {
                                  if (!isSelected &&
                                      controller.selectedCount >=
                                          controller.maxSelection) {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   SnackBar(
                                    //     content: Text(
                                    //         "Max ${controller.maxSelection} selections allowed"),
                                    //     backgroundColor: Colors.orange,
                                    //     duration: Duration(seconds: 1),
                                    //   ),
                                    // );
                                    SnackBarToastMessage.info(context,
                                        "Max ${controller.maxSelection} selections allowed");
                                  } else {
                                    controller.toggleEventSelection(eventId);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColor.filledcolor(context),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColor.buttonColor
                                          : AppColor.borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    eventName,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    SizedBox(height: size.height * 2 / 100),

                    // Others text
                    SizedBox(
                      width: size.width * 90 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.otherstext[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.pinkColor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    // Custom event input field
                    Container(
                      width: size.width * 90 / 100,
                      height: size.height * 6 / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColor.filledcolor(context),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 1),
                            spreadRadius: 0,
                            blurRadius: 0,
                            color: AppColor.transparentColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: otherEventController,
                        cursorColor: AppColor.secondryColor(context),
                        style:
                            TextStyle(color: AppColor.secondryColor(context)),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: size.width * 4 / 100,
                              right: size.width * 2 / 100,
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: size.width * 2 / 100,
                            minHeight: size.height * 6 / 100,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColor.borderColor,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColor.borderColor,
                              width: 2,
                            ),
                          ),
                          border: InputBorder.none,
                          hintText:
                              AppLanguage.typeYoureventpreferenceText[language],
                          hintStyle: AppConstant.textFilledStyle1(context),
                          contentPadding: EdgeInsets.only(
                            right: size.width * 4 / 100,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 18 / 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
