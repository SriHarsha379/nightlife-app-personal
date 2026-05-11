import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../controller/event_preference/event_preference_controller.dart';
import '../../../controller/my_profile/get_my_profile.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../provider/post_api_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_snack_bar_toast_message.dart';

class EditEventPreference extends StatefulWidget {
  static String routeName = './EditEventPreference';
  final Set<String> initialSelectedEventIds;
  final String? initialCustomEvent;

  const EditEventPreference({
    super.key,
    Set<String>? initialSelectedEventIds,
    this.initialCustomEvent,
  }) : initialSelectedEventIds = initialSelectedEventIds ?? const {};

  @override
  State<EditEventPreference> createState() => _EditEventPreferenceState();
}

class _EditEventPreferenceState extends State<EditEventPreference> {
  TextEditingController searchController = TextEditingController();
  bool _initialSelectionApplied = false;
  Set<String> _selectedEventIds = {};

  String _eventIdFrom(dynamic event) {
    if (event is Map) {
      return (event['_id'] ?? event['event_id'] ?? event['id'] ?? '')
          .toString();
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    searchController.text = widget.initialCustomEvent ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller =
          Provider.of<EventPreferenceController>(context, listen: false);
      await controller.fetchEventsData(context);

      if (!_initialSelectionApplied) {
        final Set<String> initialIds =
            Set<String>.from(widget.initialSelectedEventIds);
        final Set<String> normalizedSelectedIds = controller.getEventsList
            .map((event) {
              if (event is! Map) return '';
              final String normalizedId = _eventIdFrom(event);
              final String eventId = (event['event_id'] ?? '').toString();
              final String rawId =
                  (event['_id'] ?? event['id'] ?? '').toString();
              if (normalizedId.isEmpty) return '';
              if (initialIds.contains(normalizedId) ||
                  (eventId.isNotEmpty && initialIds.contains(eventId)) ||
                  (rawId.isNotEmpty && initialIds.contains(rawId))) {
                return normalizedId;
              }
              return '';
            })
            .where((id) => id.isNotEmpty)
            .toSet();

        if (mounted) {
          setState(() {
            _selectedEventIds = normalizedSelectedIds;
          });
        } else {
          _selectedEventIds = normalizedSelectedIds;
        }
        _initialSelectionApplied = true;
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
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
              padding: const EdgeInsets.only(bottom: 40),
              child: AppButton(
                text: AppLanguage.continueText[language],
                onPress: () async {
                  final List<String> selectedEventIds =
                      _selectedEventIds.toList();

                  if (selectedEventIds.isEmpty) {
                    SnackBarToastMessage.info(
                        context, "Please select at least one event");
                    return;
                  }

                  final postProvider =
                      Provider.of<PostApiProvider>(context, listen: false);
                  final profileController =
                      Provider.of<ProfileController>(context, listen: false);
                  final String customEvent = searchController.text.trim();
                  final isSuccess = await postProvider.addEventPreferencesApi(
                    context,
                    eventPreferenceIds: selectedEventIds,
                    customEventPreferences:
                        customEvent.isNotEmpty ? [customEvent] : [],
                  );

                  if (!isSuccess) return;
                  if (!mounted) return;

                  await profileController.fetchProfileData(context);

                  if (!mounted) return;
                  Navigator.pop(context, {
                    'selectedEvents': selectedEventIds.join(','),
                    'customEvent': searchController.text.trim(),
                  });
                },
              ),
            );
          },
        ),
        body: Consumer<EventPreferenceController>(
          builder: (context, controller, child) {
            return Container(
              width: MediaQuery.of(context).size.width * 100 / 100,
              height: MediaQuery.of(context).size.height * 100 / 100,
              decoration: BoxDecoration(
                  gradient: AppColor.backgroundGradientcolor(context)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      height: MediaQuery.of(context).size.height * 8 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      4 /
                                      100,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        5 /
                                        100,
                                    child: Image.asset(
                                      AppImage.backArrowIcon,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    80 /
                                    100,
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
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 75 / 100,
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
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
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
                            '${_selectedEventIds.length}/${controller.maxSelection}',
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          textAlign: TextAlign.center,
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 3 / 100,
                    ),
                    if (controller.getIsLoading)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 30 / 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.buttonColor,
                          ),
                        ),
                      )
                    else if (controller.getEventsList.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 30 / 100,
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
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            controller.getEventsList.length,
                            (index) {
                              final event = controller.getEventsList[index];
                              final String eventId = _eventIdFrom(event);
                              final String eventName =
                                  (event['category_name'] ??
                                          event['name'] ??
                                          'Unknown')
                                      .toString();
                              final bool isSelected =
                                  _selectedEventIds.contains(eventId);

                              return GestureDetector(
                                onTap: () {
                                  if (!isSelected &&
                                      _selectedEventIds.length >=
                                          controller.maxSelection) {
                                    SnackBarToastMessage.info(context,
                                        "Max ${controller.maxSelection} selections allowed");
                                  } else {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedEventIds.remove(eventId);
                                      } else {
                                        _selectedEventIds.add(eventId);
                                      }
                                    });
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          textAlign: TextAlign.center,
                          AppLanguage.otherstext[language],
                          style: const TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.pinkColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 2 / 100),
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
                        controller: searchController,
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 18 / 100,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // bottomNavigationBar: const AppFooter(
        //     selectedMenu: BottomMenus.home, notificationCount: 0),
      ),
    );
  }
}
