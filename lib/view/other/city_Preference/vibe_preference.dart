import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:night_life/view/other/city_Preference/aboutyou_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../../controller/vibe_preference/vibe_prefernce_controller.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class VibePreference extends StatefulWidget {
  final String? selectedGenres;
  final String? customGenre;
  final String? selectedEvents;
  final String? customEvent;
  static String routeName = './VibePreference';

  const VibePreference({
    super.key,
    this.selectedGenres,
    this.customGenre,
    this.selectedEvents,
    this.customEvent,
  });

  @override
  State<VibePreference> createState() => _VibePreferenceState();
}

class _VibePreferenceState extends State<VibePreference> {
  var fileName;

  @override
  void initState() {
    super.initState();

    log("Selected Genres: ${widget.selectedGenres}");
    log("Custom Genre: ${widget.customGenre}");
    log("Selected Events: ${widget.selectedEvents}");
    log("Custom Event: ${widget.customEvent}");

    // Fetch vibes data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VibePreferenceController>(context, listen: false)
          .fetchVibesData(context);
    });
  }

  @override
  void dispose() {
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
        floatingActionButton: Consumer<VibePreferenceController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AppButton(
                text: '${AppLanguage.continueText[language]}',
                onPress: () {
                  // Get selected vibes as comma-separated string
                  String selectedVibes = controller.getSelectedVibesString();

                  // Validation
                  if (selectedVibes.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select at least one vibe"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  log("=== ALL PREFERENCES ===");
                  log("Selected Genres: ${widget.selectedGenres}");
                  log("Custom Genre: ${widget.customGenre}");
                  log("Selected Events: ${widget.selectedEvents}");
                  log("Custom Event: ${widget.customEvent}");
                  log("Selected Vibes: $selectedVibes");
                  log("======================");

                  // Navigate to next screen with all collected data
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: AboutYouScreen(
                        selectedGenres: widget.selectedGenres,
                        customGenre: widget.customGenre,
                        selectedEvents: widget.selectedEvents,
                        customEvent: widget.customEvent,
                        selectedVibes: selectedVibes,
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
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          child: Consumer<VibePreferenceController>(
            builder: (context, controller, child) {
              return SingleChildScrollView(
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
                                    AppLanguage.vibePreferenceText[language],
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 92 / 100,
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          AppLanguage.whatKindofVibeText[language],
                          style: TextStyle(
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.vibeTypetext[language],
                              style: TextStyle(
                                fontFamily: AppFont.plusJakartaSansFamily,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: AppColor.secondryColor(context),
                              ),
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
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.filledText(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),

                    // Loading or API Data
                    if (controller.getIsLoading)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 40 / 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.buttonColor,
                          ),
                        ),
                      )
                    else if (controller.getVibesList.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 40 / 100,
                        child: Center(
                          child: Text(
                            'No vibes available',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      )
                    else
                      // Display API data in grid layout
                      _buildVibesFromAPI(controller, size),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 16 / 100,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Build vibes from API in grid layout (2 items per row)
  Widget _buildVibesFromAPI(VibePreferenceController controller, Size size) {
    List<dynamic> apiVibes = controller.getVibesList;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Wrap(
        runSpacing: 12,
        spacing: size.width * 4 / 100,
        children: List.generate(
          apiVibes.length,
          (index) {
            var vibe = apiVibes[index];
            String vibeId = vibe['_id']?.toString() ?? index.toString();
            String vibeName = vibe['vibe'] ?? 'Unknown';
            String vibeDescription = vibe['description'] ?? '';
            String? imagePath = vibe['image'];
            bool isSelected = controller.isVibeSelected(vibeId);

            return GestureDetector(
              onTap: () {
                if (!isSelected &&
                    controller.selectedCount >= controller.maxSelection) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Max ${controller.maxSelection} selections allowed"),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 1),
                    ),
                  );
                } else {
                  controller.toggleVibeSelection(vibeId);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.032,
                  vertical: MediaQuery.of(context).size.height * 0.012,
                ),
                width: MediaQuery.of(context).size.width * 43 / 100,
                decoration: BoxDecoration(
                  color: AppColor.filledcolor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.buttonColor
                        : AppColor.borderColor,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColor.buttonColor.withOpacity(0.35),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Circular Image Container
                    Container(
                      width: size.width * 8 / 100,
                      height: size.width * 8 / 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.borderColor,
                          width: .5,
                        ),
                      ),
                      child: ClipOval(
                        child: imagePath != null && imagePath.isNotEmpty
                            ? Image.network(
                                controller.getVibeImageUrl(imagePath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppColor.buttonColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              )
                            : _buildPlaceholder(),
                      ),
                    ),

                    SizedBox(width: size.width * 2 / 100),

                    // Text Content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vibeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFont.plusJakartaSansFamily,
                              fontSize: 13.2,
                              fontWeight: FontWeight.w500,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                          SizedBox(height: size.height * 0.1 / 100),
                          Text(
                            vibeDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: AppColor.lightGreyColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColor.filledcolor(context),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 15,
          color: AppColor.secondryColor(context).withOpacity(0.3),
        ),
      ),
    );
  }
}
