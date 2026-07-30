import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controller/my_profile/get_my_profile.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../provider/post_api_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_snack_bar_toast_message.dart';

/// The curated vibe picker (a fetched grid of fixed options with images,
/// tap to select up to 5) has been removed entirely - there is no
/// curated list anymore, and no replacement picker was introduced. This
/// screen now edits the member's free-text vibes directly: it opens
/// pre-populated with their current vibes as removable chips, lets them
/// type and add new ones (up to 5 total), then saves via the same
/// `add_vibes` endpoint as before - that endpoint now stores whatever
/// free text is sent into custom_vibes rather than curated IDs.
class EditVibePreference extends StatefulWidget {
  static String routeName = './EditVibePreference';
  final List<String> initialVibes;

  const EditVibePreference({
    super.key,
    List<String>? initialVibes,
  }) : initialVibes = initialVibes ?? const [];

  @override
  State<EditVibePreference> createState() => _EditVibePreferenceState();
}

class _EditVibePreferenceState extends State<EditVibePreference> {
  final TextEditingController vibeInputController = TextEditingController();
  final int maxSelection = 5;
  late List<String> _vibes;

  @override
  void initState() {
    super.initState();
    _vibes = List<String>.from(widget.initialVibes);
  }

  @override
  void dispose() {
    vibeInputController.dispose();
    super.dispose();
  }

  void _addVibe() {
    final text = vibeInputController.text.trim();
    if (text.isEmpty) return;
    if (_vibes.contains(text)) {
      vibeInputController.clear();
      return;
    }
    if (_vibes.length >= maxSelection) {
      SnackBarToastMessage.info(context, "Max $maxSelection vibes allowed");
      return;
    }
    setState(() {
      _vibes.add(text);
    });
    vibeInputController.clear();
  }

  void _removeVibe(String vibe) {
    setState(() {
      _vibes.remove(vibe);
    });
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
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          // Save button lives in this Column, on the gradient - not a
          // floatingActionButton (which renders on the Scaffold's own
          // black background instead and looks like it's floating over a
          // black gap).
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 3 / 100),
                        SizedBox(
                          width: size.width * 90 / 100,
                          height: size.height * 8 / 100,
                          child: Row(
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
                        ),
                        SizedBox(
                          width: size.width * 92 / 100,
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.whatKindofVibeText[language],
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 2 / 100),
                        SizedBox(
                          width: size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.vibeTypetext[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                              Text(
                                '${_vibes.length}/$maxSelection',
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
                        SizedBox(height: size.height * 2 / 100),

                        // Free-text input to add a vibe.
                        SizedBox(
                          width: size.width * 90 / 100,
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
                                      color: AppColor.secondryColor(context),
                                    ),
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _addVibe(),
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
                                        color:
                                        AppColor.lightGreyColor(context),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _addVibe,
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: AppColor.buttonColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: size.height * 2 / 100),

                        if (_vibes.isNotEmpty)
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _vibes.map((vibe) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.filledcolor(context),
                                    borderRadius: BorderRadius.circular(30),
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
                                          color:
                                          AppColor.secondryColor(context),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () => _removeVibe(vibe),
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

                        SizedBox(height: size.height * 4 / 100),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: () async {
                      if (_vibes.isEmpty) {
                        SnackBarToastMessage.info(
                            context, "Please add at least one vibe");
                        return;
                      }

                      final postProvider =
                      Provider.of<PostApiProvider>(context, listen: false);
                      final profileController = Provider.of<ProfileController>(
                          context,
                          listen: false);
                      final isSuccess = await postProvider.addVibesApi(
                        context,
                        vibeIds: _vibes,
                      );

                      if (!isSuccess || !mounted) return;

                      await profileController.fetchProfileData(context);
                      if (!mounted) return;

                      Navigator.pop(context, {
                        'selectedVibes': _vibes.join(','),
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}