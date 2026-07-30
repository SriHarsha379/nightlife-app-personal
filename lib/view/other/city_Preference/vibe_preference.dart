import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:night_life/view/other/city_Preference/aboutyou_screen.dart';
import 'package:night_life/utilities/page_transition.dart';

import '../../../controller/vibe_preference/vibe_prefernce_controller.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

/// The curated vibe picker (a fetched grid of fixed options like "Chill
/// pill", "High Energy" with images, tap to select up to 5) has been
/// removed entirely - there is no curated list anymore, and no
/// replacement picker was introduced. This screen is now a simple
/// free-text input: the member types their own vibes, one at a time, up
/// to 5, shown as removable chips. The [selectedVibes] parameter name is
/// kept as-is going forward through AboutYouScreen / GalleryScreen /
/// StayConnectedScreen so those files don't need to change - it now just
/// carries a comma-separated string of free-text vibes instead of
/// curated IDs.
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
  final TextEditingController vibeInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    log("Selected Genres: ${widget.selectedGenres}");
    log("Custom Genre: ${widget.customGenre}");
    log("Selected Events: ${widget.selectedEvents}");
    log("Custom Event: ${widget.customEvent}");
  }

  @override
  void dispose() {
    vibeInputController.dispose();
    super.dispose();
  }

  void _submitVibe(VibePreferenceController controller) {
    final text = vibeInputController.text.trim();
    if (text.isEmpty) return;
    if (controller.selectedCount >= controller.maxSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Max ${controller.maxSelection} vibes allowed"),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    controller.addCustomVibe(text);
    vibeInputController.clear();
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
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          // Continue button lives in this same Column below, on top of
          // the gradient - not a floatingActionButton, which would render
          // on the Scaffold's own (black) background instead and look
          // like it's floating over a black gap.
          child: SafeArea(
            child: Consumer<VibePreferenceController>(
              builder: (context, controller, child) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 3 / 100,
                            ),
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 90 / 100,
                              height: MediaQuery.of(context).size.height *
                                  8 /
                                  100,
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
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              4 /
                                              100,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height *
                                                5 /
                                                100,
                                            child: Image.asset(
                                              AppImage.backArrowIcon,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context)
                                            .size
                                            .width *
                                            80 /
                                            100,
                                        child: Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            AppLanguage.vibePreferenceText[
                                            language],
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.secondryColor(
                                                  context),
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
                              height:
                              MediaQuery.of(context).size.height * 1 / 100,
                            ),
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 92 / 100,
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
                              height:
                              MediaQuery.of(context).size.height * 2 / 100,
                            ),
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 90 / 100,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      AppLanguage.vibeTypetext[language],
                                      style: TextStyle(
                                        fontFamily:
                                        AppFont.plusJakartaSansFamily,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color:
                                        AppColor.secondryColor(context),
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
                              height:
                              MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            // Free-text input to type and add a vibe.
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 90 / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.filledcolor(context),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColor.borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: vibeInputController,
                                        cursorColor:
                                        AppColor.secondryColor(context),
                                        style: TextStyle(
                                          color:
                                          AppColor.secondryColor(context),
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onSubmitted: (_) =>
                                            _submitVibe(controller),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          hintText:
                                          "e.g. Chill pill, High energy",
                                          hintStyle: TextStyle(
                                            color: AppColor.lightGreyColor(
                                                context),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _submitVibe(controller),
                                      icon: Icon(
                                        Icons.add_circle,
                                        color: AppColor.buttonColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 2 / 100,
                            ),

                            // Added vibes shown as removable chips.
                            if (controller.getCustomVibes.isNotEmpty)
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                  controller.getCustomVibes.map((vibe) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.filledcolor(context),
                                        borderRadius:
                                        BorderRadius.circular(30),
                                        border: Border.all(
                                          color: AppColor.buttonColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            vibe,
                                            style: TextStyle(
                                              fontFamily:
                                              AppFont.plusJakartaSansFamily,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          GestureDetector(
                                            onTap: () => controller
                                                .removeCustomVibe(vibe),
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: AppColor.secondryColor(
                                                  context)
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 4 / 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                      child: AppButton(
                        text: '${AppLanguage.continueText[language]}',
                        onPress: () {
                          final String selectedVibes =
                          controller.getSelectedVibesString();

                          if (selectedVibes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                Text("Please add at least one vibe"),
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
                          log("Vibes (free text): $selectedVibes");
                          log("======================");

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
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}