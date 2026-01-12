// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/city_Preference/music_genres.dart';
import 'package:page_transition/page_transition.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/widgets.dart';

class AdditionalInfoScreen extends StatefulWidget {
  const AdditionalInfoScreen({super.key});
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
  List<String> hobbies = ["Singing", "Gaming"];
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
    if (hobby.trim().isEmpty) {
      _showSnackBar("Please enter a hobby");
      return;
    }

    if (hobbies.contains(hobby.trim())) {
      _showSnackBar("This hobby already exists");
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
      _showSnackBar("Please enter a hobby");
      return;
    }

    // Check if the new hobby already exists (excluding current index)
    if (hobbies
        .asMap()
        .entries
        .any((entry) => entry.key != index && entry.value == newHobby.trim())) {
      _showSnackBar("This hobby already exists");
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.pinkColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  TextEditingController messageTextEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width * 100 / 100,
            height: MediaQuery.of(context).size.height * 100 / 100,
            decoration:
                const BoxDecoration(gradient: AppColor.backgroundGradientcolor),
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
                                              color: AppColor.secondryColor,
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
                                            style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: AppColor.secondryColor,
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
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),

                              //! Instagram Profile
                              Center(
                                child: TextFormField(
                                  style: const TextStyle(
                                      color: AppColor.secondryColor),
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
                                          color: AppColor.greyLightColor,
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
                                      borderSide: const BorderSide(
                                        color: AppColor.buttonColor,
                                        width: 0,
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
                                        ? AppColor.primaryColor
                                        : AppColor.themeColor,
                                    filled: true,
                                    counterText: '',
                                    hintText: AppLanguage
                                        .yourInstagramProfileText[language],
                                    hintStyle: AppConstant.textFilledStyle,
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
                                style: const TextStyle(
                                    color: AppColor.secondryColor),
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
                                        color: AppColor.greyLightColor,
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
                                    borderSide: const BorderSide(
                                      color: AppColor.buttonColor,
                                      width: 0,
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
                                      ? AppColor.primaryColor
                                      : AppColor.themeColor,
                                  filled: true,
                                  counterText: '',
                                  hintText: AppLanguage
                                      .yourSpotifyaccountText[language],
                                  hintStyle: AppConstant.textFilledStyle,
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
                                style: const TextStyle(
                                    color: AppColor.secondryColor),
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
                                        color: AppColor.greyLightColor,
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
                                    borderSide: const BorderSide(
                                      color: AppColor.buttonColor,
                                      width: 0,
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
                                      ? AppColor.primaryColor
                                      : AppColor.themeColor,
                                  filled: true,
                                  counterText: '',
                                  hintText: AppLanguage
                                      .yourSnapchataccountText[language],
                                  hintStyle: AppConstant.textFilledStyle,
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
                                style: const TextStyle(
                                    color: AppColor.secondryColor),
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
                                              0.06),
                                      Image.asset(
                                        AppImage.hobbiesImage,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.06,
                                        color: AppColor.greyLightColor,
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03),
                                    ],
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                      minWidth: 0, minHeight: 0),
                                  suffixIconConstraints: const BoxConstraints(
                                      minWidth: 35, minHeight: 10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: const BorderSide(
                                        color: AppColor.buttonColor, width: 0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: const BorderSide(
                                        color: AppColor.buttonColor,
                                        width: 1.5),
                                  ),
                                  fillColor: _isHobbiesFocusNode
                                      ? AppColor.primaryColor
                                      : AppColor.themeColor,
                                  filled: true,
                                  counterText: '',
                                  hintText:
                                      AppLanguage.yourHobbiesText[language],
                                  hintStyle: AppConstant.textFilledStyle,
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
                                        color: AppColor.primaryColor,
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
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: AppFont.fontFamily,
                                                color: AppColor.secondryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          GestureDetector(
                                            onTap: () =>
                                                _showEditHobbyBottomSheet(
                                                    index),
                                            child: const Icon(
                                              Icons.edit_outlined,
                                              color: AppColor.secondryColor,
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
                                  height: MediaQuery.of(context).size.height *
                                      0.38),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //! Continue Button
                AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const MusicGenresScreen(),
                          duration: const Duration(milliseconds: 400),
                        ),
                      );
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),

                //! Skip Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: const MusicGenresScreen(),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 80 / 100,
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        AppLanguage.skip[language],
                        style: const TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textcolor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
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

  // Add Hobby Bottom Sheet
  void _showAddHobbyBottomSheet() {
    hobbyInputController.clear();
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
                const Text(
                  "Add a hobby",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontFamily,
                    color: AppColor.secondryColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hint: "Type here...",
                  controller: hobbyInputController,
                  inputFormatters: AppConstant.alphabetFormatter,
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
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _addHobby(hobbyInputController.text);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.pinkColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor,
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
                const Text(
                  "Edit hobby",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontFamily,
                    color: AppColor.secondryColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hint: "Type here...",
                  controller: hobbyInputController,
                  inputFormatters: AppConstant.alphabetFormatter,
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
                            color: AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor,
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
                          child: const Text(
                            "Update",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor,
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
          title: const Text(
            "Delete Hobby",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFont.fontFamily,
              color: AppColor.secondryColor,
            ),
          ),
          content: Text(
            "Are you sure you want to delete '${hobbies[index]}'?",
            style: const TextStyle(
              fontSize: 14,
              fontFamily: AppFont.fontFamily,
              color: AppColor.secondryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: AppColor.secondryColor,
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
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(46),
                            topRight: Radius.circular(46)),
                        color: AppColor.secondryColor),
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
                                      style: const TextStyle(
                                        fontSize: 18,
                                        decoration: TextDecoration.none,
                                        color: AppColor.primaryColor,
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
  required String hint,
  required TextEditingController controller,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    style: const TextStyle(
      color: AppColor.secondryColor,
      fontFamily: AppFont.fontFamily,
    ),
    controller: controller,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: AppColor.primaryColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
