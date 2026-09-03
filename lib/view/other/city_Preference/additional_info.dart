// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';

import 'package:provider/provider.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../provider/post_api_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_validation.dart';
import '../../../utilities/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AdditionalInfoScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? preferredCities;
  // Real, top-level feed-filtering coordinates — see CityPreference's
  // "All Cities" option and the fix in signupStepTwo on the backend for
  // why these are now passed through separately from preferredCities.
  final double? latitude;
  final double? longitude;
  final double? radius;

  const AdditionalInfoScreen({
    super.key,
    this.preferredCities,
    this.latitude,
    this.longitude,
    this.radius,
  });
  static String routeName = './AdditionalInfoScreen';
  @override
  State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
  TextEditingController BioTextEditingController = TextEditingController();
  TextEditingController instagramTextEditingController =
  TextEditingController();
  TextEditingController spotifyTextEditingController = TextEditingController();
  TextEditingController snapchattexteditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController hobbiesTextController = TextEditingController();
  TextEditingController hobbyInputController = TextEditingController();

  int reportId = 0;
  String location = "";
  String locationDetails = "NA";
  String imageController = "NA";
  late FocusNode _hobbiesFocusNode;
  bool _isHobbiesFocusNode = false;
  List<String> hobbies = [];
  String selectLocation = "NA";
  final FocusNode _focusNode = FocusNode();
  bool _isInstagramFocused = false;
  final FocusNode _instagramFocusNode = FocusNode();
  late FocusNode _spotifyFocusNode;
  late FocusNode _snapchatFocusNode;
  bool _isSpotifyFocused = false;
  bool _isSnapchatFocused = false;

  @override
  void initState() {
    super.initState();
    _updateHobbiesDisplay();

    _instagramFocusNode.addListener(() {
      setState(() {
        _isInstagramFocused = _instagramFocusNode.hasFocus;
      });
    });

    _focusNode.addListener(() {
      setState(() {});
    });

    _spotifyFocusNode = FocusNode();
    _spotifyFocusNode.addListener(() {
      setState(() {
        _isSpotifyFocused = _spotifyFocusNode.hasFocus;
      });
    });

    _snapchatFocusNode = FocusNode();
    _snapchatFocusNode.addListener(() {
      setState(() {
        _isSnapchatFocused = _snapchatFocusNode.hasFocus;
      });
    });
    _hobbiesFocusNode = FocusNode();
    _hobbiesFocusNode.addListener(() {
      setState(() {
        _isHobbiesFocusNode = _hobbiesFocusNode.hasFocus;
      });
    });
    print("Cities: ${widget.preferredCities}");
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _instagramFocusNode.dispose();
    _spotifyFocusNode.dispose();
    _snapchatFocusNode.dispose();
    _hobbiesFocusNode.dispose();
    hobbiesTextController.dispose();
    hobbyInputController.dispose();
    super.dispose();
  }

  void _updateHobbiesDisplay() {
    hobbiesTextController.text = hobbies.isEmpty ? "" : hobbies.join(", ");
  }

  void _addHobby(String hobby) {
    // Kept for the individual-row edit flow only (_editHobby handles edits);
    // this direct-add path is no longer used now that hobbies are chosen via
    // the chip picker in _showAddHobbyBottomSheet, but left here in case any
    // other screen calls it directly.
    if (hobby.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(context, "Please enter a hobby");
      return;
    }

    if (hobbies.any(
            (element) => element.toLowerCase() == hobby.trim().toLowerCase())) {
      SnackBarToastMessage.showSnackBar(context, "This hobby already exists");
      return;
    }

    setState(() {
      hobbies.add(hobby.trim());
      _updateHobbiesDisplay();
    });
    hobbyInputController.clear();
  }

  void _editHobby(int index, String newHobby) {
    if (newHobby.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(context, "Please enter a hobby");
      return;
    }

    // Check if the new hobby already exists (excluding current index)
    if (hobbies
        .asMap()
        .entries
        .any((entry) =>
    entry.key != index &&
        entry.value.toLowerCase() == newHobby.trim().toLowerCase())) {
      SnackBarToastMessage.showSnackBar(context, "This hobby already exists");
      return;
    }

    setState(() {
      hobbies[index] = newHobby.trim();
      _updateHobbiesDisplay();
    });
    hobbyInputController.clear();
  }

  void _deleteHobby(int index) {
    setState(() {
      hobbies.removeAt(index);
      _updateHobbiesDisplay();
    });
  }

  void AdditionalInfoValidation() {
    // ✅ Bio validation
    if (BioTextEditingController.text.trim().isEmpty) {
      SnackBarToastMessage.showSnackBar(context, "Please enter your bio");
      return;
    }

    if (!Validation.isInstagramValid(
      context,
      value: instagramTextEditingController.text,
    )) {
      return;
    }
    if (!Validation.isSpotifyValid(
      context,
      value: spotifyTextEditingController.text,
    )) {
      return;
    }
    if (!Validation.isSnapchatValid(
      context,
      value: snapchattexteditingController.text,
    )) {
      return;
    }

    // ✅ Hobbies validation
    if (hobbies.isEmpty) {
      SnackBarToastMessage.showSnackBar(
          context, "Please add at least one hobby");
      return;
    }

    // ✅ All validations passed - API call
    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    apiProvider.signupStepTwoUserApi(
      context,
      widget.preferredCities,
      BioTextEditingController.text.trim(),
      instagramTextEditingController.text.trim(),
      spotifyTextEditingController.text.trim(),
      snapchattexteditingController.text.trim(),
      hobbies,
      1,
      widget.latitude,
      widget.longitude,
      widget.radius,
    );
  }

  TextEditingController messageTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
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
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Consumer<PostApiProvider>(
            builder: (context, apiprovider, child) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    apiprovider.loading
                        ? const CircularProgressIndicator(
                      color: AppColor.pinkColor,
                    )
                        : AppButton(
                      text: AppLanguage.skip[language],
                      // Secondary color so it's still a real, prominent
                      // button (not a plain text link like before), but
                      // visually distinct from Continue so Continue still
                      // reads as the primary action.
                      backgroundColor: AppColor.borderColor,
                      onPress: () {
                        if (apiprovider.loading) return;
                        final apiProvider = Provider.of<PostApiProvider>(
                          context,
                          listen: false,
                        );
                        apiProvider.signupStepTwoUserApi(
                          context,
                          widget.preferredCities,
                          "",
                          "",
                          "",
                          "",
                          <String>[],
                          0,
                          widget.latitude,
                          widget.longitude,
                          widget.radius,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    apiprovider.loading
                        ? const SizedBox.shrink()
                        : AppButton(
                      text: AppLanguage.continueText[language],
                      onPress: () {
                        FocusScope.of(context).unfocus();
                        AdditionalInfoValidation();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          body: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            decoration: BoxDecoration(
                gradient: AppColor.backgroundGradientcolor(context)),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Column(
                            children: [
                              Column(
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
                                        width:
                                        MediaQuery.of(context).size.width *
                                            80 /
                                            100,
                                        child: Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            AppLanguage
                                                .additionalInfoText[language],
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          1.5 /
                                          100),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    4 /
                                    100,
                              ),

                              //! Bio
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      7 /
                                      100,
                                  child: CustomTextField(
                                    hintText:
                                    AppLanguage.bioOptionalText[language],
                                    maxLength: AppConstant.fullNameText,
                                    // keyboardType: TextInputType.name,
                                    controller: BioTextEditingController,
                                    readOnly: false,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),

                              //! Instagram Profile
                              Center(
                                child: TextFormField(
                                  style: TextStyle(
                                      color: AppColor.secondryColor(context)),
                                  keyboardType: TextInputType.name,
                                  controller: instagramTextEditingController,
                                  focusNode: _instagramFocusNode,
                                  maxLength: AppConstant.fullNameText,
                                  decoration: InputDecoration(
                                    prefixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                6 /
                                                100),
                                        Image.asset(
                                          AppImage.instagramIcon,
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              6 /
                                              100,
                                          height: MediaQuery.of(context)
                                              .size
                                              .width *
                                              6 /
                                              100,
                                          color: AppColor
                                              .greyLightColor(context),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                3 /
                                                100),
                                      ],
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 0,
                                      minHeight: 0,
                                    ),
                                    suffixIcon: ValueListenableBuilder(
                                      valueListenable: instagramTextEditingController,
                                      builder: (context, value, _) {
                                        final username = value.text.trim();
                                        if (username.isEmpty) return const SizedBox.shrink();
                                        return IconButton(
                                          icon: const Icon(Icons.open_in_new, size: 18),
                                          color: AppColor.greyLightColor(context),
                                          tooltip: 'Verify on Instagram',
                                          onPressed: () async {
                                            final extracted = Validation.extractSocialUsername(username, 'instagram.com');
                                            final url = Uri.parse('https://instagram.com/\$extracted');
                                            if (await canLaunchUrl(url)) {
                                              launchUrl(url, mode: LaunchMode.externalApplication);
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    suffixIconConstraints: const BoxConstraints(
                                      minWidth: 35,
                                      minHeight: 10,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColor.buttonColor
                                            : AppColor
                                            .greyLightColor(context),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(40),
                                      borderSide: const BorderSide(
                                        color: AppColor.buttonColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    fillColor: _isInstagramFocused
                                        ? AppColor.whiteBlackcolor(context)
                                        : AppColor.textFieldColor(context),
                                    filled: true,
                                    counterText: '',
                                    hintText: AppLanguage
                                        .yourInstagramProfileText[language],
                                    hintStyle:
                                    AppConstant.textFilledStyle(context),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                      vertical: 15,
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),

                              //! Spotify Account
                              TextFormField(
                                style: TextStyle(
                                    color: AppColor.secondryColor(context)),
                                keyboardType: TextInputType.name,
                                controller: spotifyTextEditingController,
                                focusNode: _spotifyFocusNode,
                                maxLength: AppConstant.fullNameText,
                                decoration: InputDecoration(
                                  prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              6 /
                                              100),
                                      Image.asset(
                                        AppImage.spotifyIcon,
                                        width:
                                        MediaQuery.of(context).size.width *
                                            6 /
                                            100,
                                        height:
                                        MediaQuery.of(context).size.width *
                                            6 /
                                            100,
                                        color: AppColor
                                            .greyLightColor(context),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              3 /
                                              100),
                                    ],
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  suffixIcon: ValueListenableBuilder(
                                    valueListenable: snapchattexteditingController,
                                    builder: (context, value, _) {
                                      final username = value.text.trim();
                                      if (username.isEmpty) return const SizedBox.shrink();
                                      return IconButton(
                                        icon: const Icon(Icons.open_in_new, size: 18),
                                        color: AppColor.greyLightColor(context),
                                        tooltip: 'Verify on Snapchat',
                                        onPressed: () async {
                                          final extracted = Validation.extractSocialUsername(username, 'snapchat.com');
                                          final url = Uri.parse('https://snapchat.com/add/\$extracted');
                                          if (await canLaunchUrl(url)) {
                                            launchUrl(url, mode: LaunchMode.externalApplication);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 35,
                                    minHeight: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? AppColor.buttonColor
                                          : AppColor
                                          .greyLightColor(context),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: const BorderSide(
                                      color: AppColor.buttonColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  fillColor: _isSpotifyFocused
                                      ? AppColor.whiteBlackcolor(context)
                                      : AppColor.textFieldColor(context),
                                  filled: true,
                                  counterText: '',
                                  hintText: AppLanguage
                                      .yourSpotifyaccountText[language],
                                  hintStyle:
                                  AppConstant.textFilledStyle(context),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                ),
                                onTap: () {},
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),

                              //! Snapchat
                              TextFormField(
                                style: TextStyle(
                                    color: AppColor.secondryColor(context)),
                                keyboardType: TextInputType.name,
                                controller: snapchattexteditingController,
                                focusNode: _snapchatFocusNode,
                                maxLength: AppConstant.fullNameText,
                                decoration: InputDecoration(
                                  prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              6 /
                                              100),
                                      Image.asset(
                                        AppImage.snapchatIcon,
                                        width:
                                        MediaQuery.of(context).size.width *
                                            6 /
                                            100,
                                        height:
                                        MediaQuery.of(context).size.width *
                                            6 /
                                            100,
                                        color: AppColor
                                            .greyLightColor(context),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              3 /
                                              100),
                                    ],
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 35,
                                    minHeight: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? AppColor.buttonColor
                                          : AppColor
                                          .greyLightColor(context),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: const BorderSide(
                                      color: AppColor.buttonColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  fillColor: _isSnapchatFocused
                                      ? AppColor.whiteBlackcolor(context)
                                      : AppColor.textFieldColor(context),
                                  filled: true,
                                  counterText: '',
                                  hintText: AppLanguage
                                      .yourSnapchataccountText[language],
                                  hintStyle:
                                  AppConstant.textFilledStyle(context),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                ),
                                onTap: () {},
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),

                              //! Hobbies Input Field
                              TextFormField(
                                style: TextStyle(
                                    color: AppColor.secondryColor(context)),
                                controller: hobbiesTextController,
                                focusNode: _hobbiesFocusNode,
                                readOnly: true,
                                decoration: InputDecoration(
                                  prefixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              6 /
                                              100),
                                      Image.asset(
                                        AppImage.hobbiesImage,
                                        width:
                                        MediaQuery.of(context).size.width *
                                            6 /
                                            100,
                                        height:
                                        MediaQuery.of(context).size.width *
                                            6 /
                                            100,
                                        color: AppColor
                                            .greyLightColor(context),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              3 /
                                              100),
                                    ],
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 35,
                                    minHeight: 10,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? AppColor.buttonColor
                                          : AppColor
                                          .greyLightColor(context),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: const BorderSide(
                                      color: AppColor.buttonColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  fillColor: _isHobbiesFocusNode
                                      ? AppColor.whiteBlackcolor(context)
                                      : AppColor.textFieldColor(context),
                                  filled: true,
                                  counterText: '',
                                  hintText:
                                  AppLanguage.yourHobbiesText[language],
                                  hintStyle:
                                  AppConstant.textFilledStyle(context),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                ),
                                onTap: () => _showAddHobbyBottomSheet(),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.02),

                              //! Hobbies List
                              if (hobbies.isNotEmpty)
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: hobbies.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColor.primaryColor(context),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                            Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              hobbies[index],
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AppFont.fontFamily,
                                                color: AppColor.secondryColor(
                                                    context),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () =>
                                                _showEditHobbyBottomSheet(
                                                    index),
                                            child: Icon(
                                              Icons.edit_outlined,
                                              color: AppColor.secondryColor(
                                                  context),
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: () =>
                                                _showDeleteConfirmationDialog(
                                                    index),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                              SizedBox(
                                height:
                                MediaQuery.of(context).size.height * 0.22,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  setHobbies(String hobby) {
    hobbies.add(hobby);
    setState(() {
      hobbiesTextController.text = hobbies.join(", ");
    });
  }

  // Preset hobby options shown as selectable chips now live in
  // AppConstant.hobbyOptions (lib/utilities/app_constant.dart) so this
  // list stays in sync with the edit-hobbies screen.
  static const List<Map<String, String>> _hobbyOptions =
      AppConstant.hobbyOptions;

  static const int _maxHobbies = AppConstant.maxHobbies;

  // Add Hobby Bottom Sheet - chip-based multi-select with a custom-entry
  // fallback for hobbies not in the preset list.
  void _showAddHobbyBottomSheet() {
    hobbyInputController.clear();

    // Working copy so Cancel doesn't affect the real list until "Done".
    final Set<String> tempSelected = hobbies.toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void toggle(String label) {
              final alreadySelected = tempSelected
                  .any((h) => h.toLowerCase() == label.toLowerCase());
              if (alreadySelected) {
                setSheetState(() {
                  tempSelected.removeWhere(
                          (h) => h.toLowerCase() == label.toLowerCase());
                });
                return;
              }
              if (tempSelected.length >= _maxHobbies) {
                SnackBarToastMessage.showSnackBar(
                    context, "You can select up to $_maxHobbies hobbies");
                return;
              }
              setSheetState(() => tempSelected.add(label));
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: const BoxDecoration(
                  color: AppColor.themeColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select your hobbies",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFont.fontFamily,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pick up to $_maxHobbies, or add your own",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppFont.fontFamily,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _hobbyOptions.map((option) {
                            final label = option['label']!;
                            final isSelected = tempSelected
                                .any((h) => h.toLowerCase() == label.toLowerCase());
                            return GestureDetector(
                              onTap: () => toggle(label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColor.pinkColor.withOpacity(0.18)
                                      : AppColor.primaryColor(context),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColor.pinkColor
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(option['emoji']!,
                                        style: const TextStyle(fontSize: 15)),
                                    const SizedBox(width: 6),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontFamily: AppFont.fontFamily,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.check,
                                          size: 14, color: AppColor.pinkColor),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            context: context,
                            hint: "Not listed? Type your own...",
                            controller: hobbyInputController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            final custom = hobbyInputController.text.trim();
                            if (custom.isEmpty) return;
                            final alreadySelected = tempSelected.any(
                                    (h) => h.toLowerCase() == custom.toLowerCase());
                            if (alreadySelected) {
                              SnackBarToastMessage.showSnackBar(
                                  context, "This hobby already exists");
                              return;
                            }
                            if (tempSelected.length >= _maxHobbies) {
                              SnackBarToastMessage.showSnackBar(context,
                                  "You can select up to $_maxHobbies hobbies");
                              return;
                            }
                            setSheetState(() => tempSelected.add(custom));
                            hobbyInputController.clear();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: AppColor.pinkColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColor.primaryColor(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                hobbies = tempSelected.toList();
                                _updateHobbiesDisplay();
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColor.pinkColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Edit Hobby Bottom Sheet
  void _showEditHobbyBottomSheet(int index) {
    hobbyInputController.text = hobbies[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColor.themeColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit hobby",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontFamily,
                    color: AppColor.secondryColor(context),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  context: context,
                  hint: "Type here...",
                  controller: hobbyInputController,
                  // inputFormatters: AppConstant.alphabetFormatter,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _editHobby(index, hobbyInputController.text);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.pinkColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Update",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.themeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Hobby",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFont.fontFamily,
              color: AppColor.secondryColor(context),
            ),
          ),
          content: Text(
            "Are you sure you want to delete '${hobbies[index]}'?",
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppFont.fontFamily,
              color: AppColor.secondryColor(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: AppColor.secondryColor(context),
                  fontFamily: AppFont.fontFamily,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteHobby(index);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void cancelRideBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        // String? tempSelected = selectedState;

        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 40 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 100 / 100,
                    height: MediaQuery.of(context).size.height * 40 / 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(46),
                            topRight: Radius.circular(46)),
                        color: AppColor.secondryColor(context)),
                    child: Column(
                      children: [
                        SizedBox(
                            height:
                            MediaQuery.of(context).size.height * 5 / 100),
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 90 / 100,
                              child: Column(
                                children: [
                                  SizedBox(
                                    child: Text(
                                      AppLanguage
                                          .selectdocumentTypetext[language],
                                      style: TextStyle(
                                        fontSize: 18,
                                        decoration: TextDecoration.none,
                                        color: AppColor.primaryColor(context),
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          1 /
                                          100),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          5 /
                                          100),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          3 /
                                          100),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          3 /
                                          100),
                                  SizedBox(
                                      height:
                                      MediaQuery.of(context).size.height *
                                          1 /
                                          100),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
      },
    );
  }
}

// Build TextField Widget
Widget _buildTextField({
  required BuildContext context,
  required String hint,
  required TextEditingController controller,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    inputFormatters: inputFormatters,
    style: TextStyle(
      color: AppColor.secondryColor(context),
      fontFamily: AppFont.fontFamily,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Theme.of(context).hintColor,
        fontFamily: AppFont.fontFamily,
      ),
      filled: true,
      fillColor: AppColor.primaryColor(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}