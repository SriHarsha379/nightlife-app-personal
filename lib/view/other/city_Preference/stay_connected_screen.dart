// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:night_life/utilities/app_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../provider/post_api_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_footer.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_snack_bar_toast_message.dart';
import 'stay_connected_otp_verification.dart';

class StayConnectedScreen extends StatefulWidget {
  final String? selectedGenres;
  final String? customGenre;
  final String? selectedEvents;
  final String? customEvent;
  final String? selectedVibes;
  final String? customVibes;
  final String? sexuality;
  final String? interestedIn;
  final String? pronouns;
  final List<Map<String, String>>? selectedMediaList;
  final List<Map<String, String>>? formattedAnswers;

  static String routeName = './StayConnectedScreen';

  StayConnectedScreen({
    super.key,
    this.selectedGenres,
    this.customGenre,
    this.selectedEvents,
    this.customEvent,
    this.selectedVibes,
    this.customVibes,
    this.sexuality,
    this.interestedIn,
    this.pronouns,
    this.selectedMediaList,
    this.formattedAnswers,
  });

  @override
  State<StayConnectedScreen> createState() => _StayConnectedScreenState();
}

class _StayConnectedScreenState extends State<StayConnectedScreen> {
  TextEditingController pinputInputController = TextEditingController();
  TextEditingController mobileNumberTextEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    print("=== StayConnectedScreen Data ===");
    print("Music Genre: ${widget.selectedGenres}");
    print("Custom Genre: ${widget.customGenre}");
    print("Event Preferences: ${widget.selectedEvents}");
    print("Custom Events: ${widget.customEvent}");
    print("Vibes: ${widget.selectedVibes}");
    print("Custom Vibes: ${widget.customVibes}");
    print("Sexuality: ${widget.sexuality}");
    print("Interested In: ${widget.interestedIn}");
    print("Pronouns: ${widget.pronouns}");
    print("Media List: ${widget.selectedMediaList}");
    print("Vibe Checks: ${widget.formattedAnswers}");
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  void previousField(String value, FocusNode focusNode) {
    focusNode.requestFocus();
  }

  // Function to submit all data
  static const int _uploadMaxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB

  Future<bool> _validateMediaSizes() async {
    if (widget.selectedMediaList == null) return true;

    for (final media in widget.selectedMediaList!) {
      final filePath = media['file'];
      if (filePath == null || filePath.isEmpty) {
        continue;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected file was not found. Please re-select.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      final size = await file.length();
      if (size > _uploadMaxFileSizeInBytes) {
        final sizeMb = (size / (1024 * 1024)).toStringAsFixed(2);
        const limitMb = 10;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'File size ($sizeMb MB) exceeds $limitMb MB limit. Please pick a smaller file.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  Future<Map<String, dynamic>?> _submitSignupStepThree({String? email}) async {
    final postApiProvider =
        Provider.of<PostApiProvider>(context, listen: false);

    if (!await _validateMediaSizes()) {
      return null;
    }

    // Prepare images and videos from selectedMediaList
    List<XFile> images = [];
    List<XFile> videos = [];
    List<XFile> thumbnails = [];

    if (widget.selectedMediaList != null) {
      for (var media in widget.selectedMediaList!) {
        final type = media['type'];
        final filePath = media['file'];
        final thumbnailPath = media['thumbnail'];

        if (type == 'image') {
          if (filePath != null && filePath.isNotEmpty) {
            images.add(XFile(filePath));
          }
        } else if (type == 'video') {
          if (filePath != null && filePath.isNotEmpty) {
            videos.add(XFile(filePath));
          }
          if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
            thumbnails.add(XFile(thumbnailPath));
          }
        }
      }
    }

    // Call API
    return await postApiProvider.signupStepThreeUserApi(
      context,
      musicGenre: widget.selectedGenres ?? '',
      customMusicGenres: widget.customGenre,
      eventPreferences: widget.selectedEvents ?? '',
      customEventPreferences: widget.customEvent,
      vibes: widget.selectedVibes ?? '',
      customVibes: widget.customVibes,
      vibeChecks: widget.formattedAnswers ?? [],
      sexuality: widget.sexuality ?? '',
      interestedIn: widget.interestedIn ?? '',
      pronouns: widget.pronouns ?? '',
      anotherEmail: email,
      images: images,
      videos: videos,
      thumbnails: thumbnails,
    );
  }

  // Continue with email
  void _continueWithEmail() {
    String email = mobileNumberTextEditingController.text.trim();

    if (email.isEmpty) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Submit and navigate to OTP screen
    _submitSignupStepThree(email: email).then((result) {
      if (result == null) return;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: StayConnectedOTPVerify(
            isEmail: true,
            email: email,
          ),
          duration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  // Skip email and submit
  void _skipAndSubmit() async {
    // Submit without email
    final result = await _submitSignupStepThree();
    if (result == null) return;

    final dynamic data = result['data'];
    final Map<String, dynamic> userData =
        (data is Map<String, dynamic>) ? data : <String, dynamic>{};
    final bool isProfileCompleted = userData['is_profile_completed'] == true;
    final bool isAnotherEmailVerify =
        userData['is_another_email_verify'] == true;
    final String anotherEmail = (userData['another_email'] ?? '').toString();
    int signupStep = 0;
    final dynamic stepValue = userData['signup_step'];
    if (stepValue is int) {
      signupStep = stepValue;
    } else if (stepValue is String) {
      signupStep = int.tryParse(stepValue) ?? 0;
    }

    if (!mounted) return;
    if (isProfileCompleted) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const MyAppFooter(initialIndex: 0),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }

    if (signupStep >= 3 &&
        anotherEmail.trim().isNotEmpty &&
        !isAnotherEmailVerify) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: StayConnectedOTPVerify(
            isEmail: true,
            email: anotherEmail,
          ),
          duration: const Duration(milliseconds: 600),
        ),
      );
      return;
    }

    TopNotification.error(
      context,
      "Profile is incomplete. Please complete stay connected verification.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 4 / 100,
              ),

              //! App Header
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
                            width: MediaQuery.of(context).size.width * 4 / 100,
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Image.asset(
                                AppImage.backArrowIcon,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 80 / 100,
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.stayConnectedText[language],
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Text(
                          AppLanguage.stayConnectedHeader[language],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColor.lightGreyColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 10 / 100,
                      ),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 85 / 100,
                          child: TextFormField(
                            controller: mobileNumberTextEditingController,
                            keyboardType: TextInputType.emailAddress,
                            maxLength: 50,
                            cursorColor: AppColor.secondryColor(context),
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontFamily: AppFont.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  AppColor.textfieldcontainercolor(context),
                              counterText: '',
                              hintText: AppLanguage.entterEmailText[language],
                              hintStyle: AppConstant.textFilledStyle(context),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                vertical: MediaQuery.of(context).size.height *
                                    1.8 /
                                    100,
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),

                              /// ✅ Border always visible
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: AppColor.pinkColor,
                                  width: 1,
                                ),
                              ),

                              /// ✅ Focus border
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  color: AppColor.pinkColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                    ],
                  ),
                ),
              ),

              // Continue Button
              Consumer<PostApiProvider>(
                builder: (context, provider, child) {
                  return AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: _continueWithEmail,
                  );
                },
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 2 / 100,
              ),

              // Skip Button
              Consumer<PostApiProvider>(
                builder: (context, provider, child) {
                  return GestureDetector(
                    onTap: provider.loading ? null : _skipAndSubmit,
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.skip[language],
                      style: TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: provider.loading
                            ? AppColor
                                                        .greyLightColor(context).withOpacity(0.5)
                            : AppColor
                                                        .greyLightColor(context),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 4 / 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
