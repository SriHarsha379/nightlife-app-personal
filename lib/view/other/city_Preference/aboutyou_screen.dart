import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import 'package:night_life/view/other/city_Preference/gallery_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';

class AboutYouScreen extends StatefulWidget {
  final String? selectedGenres;
  final String? customGenre;
  final String? selectedEvents;
  final String? customEvent;
  final String? selectedVibes;

  const AboutYouScreen({
    super.key,
    this.selectedGenres,
    this.customGenre,
    this.selectedEvents,
    this.customEvent,
    this.selectedVibes,
  });

  @override
  State<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  final List<String> aboutOptions = ["Men", "Women", "Everyone"];
  final List<String> sexuality = [
    "Straight",
    "Gay",
    "Lesbian",
    "Bisexual",
    "Unsure / Exploring",
  ];
  final List<String> pronouns = ["She/Her", "He/Him", "They/Them", "Other"];

  TextEditingController enterYourpronounsController = TextEditingController();
  TextEditingController otherPronounController = TextEditingController();

  int selectedAboutIndex = 0;
  int selectedSexualityIndex = 0;
  int selectedPronounIndex = 0;

  bool showOtherPronounField = false;

  @override
  void initState() {
    super.initState();
    logAllPreferences();
  }

  void logAllPreferences() {
    print("=== ALL PREFERENCES PASSED TO ABOUT YOU SCREEN ===");
    print("Selected Genres: ${widget.selectedGenres}");
    print("Custom Genre: ${widget.customGenre}");
    print("Selected Events: ${widget.selectedEvents}");
    print("Custom Event: ${widget.customEvent}");
    print("Selected Vibes: ${widget.selectedVibes}");
    print("================================================");
  }

  // Get selected text values (for API)
  String getSelectedSexuality() {
    if (selectedSexualityIndex >= 0 &&
        selectedSexualityIndex < sexuality.length) {
      return sexuality[selectedSexualityIndex];
    }
    return "";
  }

  String getSelectedInterestedIn() {
    if (selectedAboutIndex >= 0 && selectedAboutIndex < aboutOptions.length) {
      return aboutOptions[selectedAboutIndex];
    }
    return "";
  }

  String getSelectedPronoun() {
    if (selectedPronounIndex >= 0 && selectedPronounIndex < pronouns.length) {
      if (pronouns[selectedPronounIndex] == "Other") {
        return otherPronounController.text.trim();
      }
      return pronouns[selectedPronounIndex];
    }
    return "";
  }

  // Validation
  bool validateFields() {
    if (selectedSexualityIndex == -1) {
      showSnackBar("Please select your sexuality");
      return false;
    }

    if (selectedAboutIndex == -1) {
      showSnackBar("Please select who you're interested in");
      return false;
    }

    if (selectedPronounIndex == -1) {
      showSnackBar("Please select your pronouns");
      return false;
    }

    if (pronouns[selectedPronounIndex] == "Other" &&
        otherPronounController.text.trim().isEmpty) {
      SnackBarToastMessage.info(context, "Please enter your pronouns");
      return false;
    }

    return true;
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void navigateToNextScreen() {
    // Get all data to pass to next screen
    String sexualityValue = getSelectedSexuality();
    String interestedInValue = getSelectedInterestedIn();
    String pronounValue = getSelectedPronoun();

    print("=== ABOUT YOU DATA ===");
    print("Sexuality: $sexualityValue");
    print("Interested In: $interestedInValue");
    print("Pronouns: $pronounValue");
    print("======================");

    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: GalleryScreen(
          selectedGenres: widget.selectedGenres,
          customGenre: widget.customGenre,
          selectedEvents: widget.selectedEvents,
          customEvent: widget.customEvent,
          selectedVibes: widget.selectedVibes,
          sexuality: sexualityValue,
          interestedIn: interestedInValue,
          pronouns: pronounValue,
        ),
        duration: const Duration(milliseconds: 500),
      ),
    );
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
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: AppColor.secondryColor(context),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: AppButton(
              text: '${AppLanguage.continueText[language]}',
              onPress: () {
                if (validateFields()) {
                  navigateToNextScreen();
                }
              },
            ),
          ),
          body: Container(
            height: size.height * 100 / 100,
            width: size.width * 100 / 100,
            decoration: BoxDecoration(
                gradient: AppColor.backgroundGradientcolor(context)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 5 / 100),
                  Container(
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
                            width: size.width * 4 / 100,
                            AppImage.backArrowIcon,
                          ),
                        ),
                        Text(
                          AppLanguage.aboutYouText[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        Container(
                          height: size.width * 5 / 100,
                          width: size.width * 5 / 100,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 2 / 100),
                  Container(
                    width: size.width * 90 / 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 2 / 100),
                        Text(
                          AppLanguage.knowYouBetterText[language],
                          style: TextStyle(
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        SizedBox(height: size.height * 2 / 100),
                        Text(
                          AppLanguage.knowYouBetterMsg[language],
                          style: TextStyle(
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.listTextColor(context),
                          ),
                        ),
                        SizedBox(height: size.height * 2 / 100),

                        // Sexuality Section
                        Text(
                          AppLanguage.sexualityText[language],
                          style: TextStyle(
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        SizedBox(height: size.height * 0.1 / 100),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: sexuality.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: size.height * 1.5 / 100),
                              child: AboutRow(
                                text: sexuality[index],
                                isSelected: selectedSexualityIndex == index,
                                onTap: () {
                                  setState(() {
                                    selectedSexualityIndex = index;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: size.height * 1 / 100),

                        // Interested In Section
                        Text(
                          AppLanguage.interestedInText[language],
                          style: TextStyle(
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        SizedBox(height: size.height * 0.1 / 100),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: aboutOptions.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: size.height * 1.5 / 100),
                              child: AboutRow(
                                text: aboutOptions[index],
                                isSelected: selectedAboutIndex == index,
                                onTap: () {
                                  setState(() {
                                    selectedAboutIndex = index;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: size.height * 1 / 100),

                        // Pronouns Section
                        Text(
                          AppLanguage.yourPronounsText[language],
                          style: TextStyle(
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        SizedBox(height: size.height * 0.1 / 100),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pronouns.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: size.height * 1.5 / 100),
                              child: AboutRow(
                                text: pronouns[index],
                                isSelected: selectedPronounIndex == index,
                                onTap: () {
                                  setState(() {
                                    selectedPronounIndex = index;
                                    showOtherPronounField =
                                        (pronouns[index] == "Other");
                                    if (pronouns[index] != "Other") {
                                      otherPronounController.clear();
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),

                        // Other Pronouns Text Field (only shown when "Other" is selected)
                        if (showOtherPronounField)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: size.height * 1.5 / 100,
                            ),
                            child: TextField(
                              controller: otherPronounController,
                              style: TextStyle(
                                fontFamily: AppFont.plusJakartaSansFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColor.secondryColor(context),
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isDark
                                    ? AppColor.whiteBlackcolor(context)
                                    : AppColor.textFieldColor(context),

                                hintText:
                                    AppLanguage.enterYourpronounsText[language],
                                hintStyle: TextStyle(
                                  fontFamily: AppFont.plusJakartaSansFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.secondryColor(context)
                                      .withOpacity(0.5),
                                ),

                                /// ✅ Border always visible
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: AppColor.pinkColor,
                                    width: 1,
                                  ),
                                ),

                                /// ✅ Focus border
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: AppColor.pinkColor,
                                    width: 1.5,
                                  ),
                                ),

                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: size.width * 4 / 100,
                                  vertical: size.height * 1.8 / 100,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),

                        SizedBox(height: size.height * 20 / 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AboutRow extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const AboutRow({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.07,
        decoration: BoxDecoration(
          color: isDark ? AppColor.themeColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 0.3,
            color: AppColor.pinkColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.05),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondryColor(context),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.05),
              child: Container(
                height: size.height * 0.025,
                width: size.height * 0.025,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColor.pinkColor : AppColor.pinkColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Container(
                    height: size.height * 0.012,
                    width: size.height * 0.012,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? AppColor.pinkColor : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
