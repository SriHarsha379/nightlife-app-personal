import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../commonWidget/city_bottomsheet.dart';
import '../../controller/city/city_preference.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/widgets.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String? mobile;
  final String? screen;
  final String? refercode;
  final Map<String, dynamic>? socialUser;

  const ProfileDetailsScreen({
    super.key,
    this.mobile,
    this.screen,
    this.socialUser,
    this.refercode,
  });
  static String routeName = './ProfileDetailsScreen';
  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  int reportId = 0;
  String location = "";
  String locationDetails = "NA";
  XFile? profilePhoto;

  String imageController = "NA";

  TextEditingController NameTextEditingController = TextEditingController();
  TextEditingController heightTextEditingController = TextEditingController();

  TextEditingController lastnameTextEditingController = TextEditingController();
  TextEditingController usernameTextEditingController = TextEditingController();

  TextEditingController dobtexteditingController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController mobileNumberTextEditingController =
      TextEditingController();
  TextEditingController confirmpasswordTextEditingController =
      TextEditingController();

  TextEditingController referCodeTextEditingController =
      TextEditingController();
  String selectLocation = "NA";

  final FocusNode _focusNode = FocusNode();
  bool _isDobFocused = false;
  final FocusNode _dobFocusNode = FocusNode();

  String? selectedGender;
  TextEditingController cityTextEditingController = TextEditingController();
  String? selectedCity;
  String? selectedCityId;
  bool get _isSocialSignup => widget.screen == "social";

  @override
  void initState() {
    super.initState();
    mobileNumberTextEditingController.text =
        widget.mobile == null ? "" : widget.mobile.toString();
    referCodeTextEditingController.text =
        widget.refercode == null ? "" : widget.refercode.toString();
    if (_isSocialSignup && widget.socialUser != null) {
      final Map<String, dynamic> socialUser = widget.socialUser!;
      NameTextEditingController.text =
          (socialUser['first_name'] ?? '').toString();
      lastnameTextEditingController.text =
          (socialUser['last_name'] ?? '').toString();
      emailController.text = (socialUser['email'] ?? '').toString();
    }
    _dobFocusNode.addListener(() {
      setState(() {
        _isDobFocused = _dobFocusNode.hasFocus;
      });
    });
    _focusNode.addListener(() {
      setState(() {});
    });

    // Fetch city list when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CityPreferenceController>(context, listen: false)
          .fetchCityList(context);
    });

    log("message${widget.mobile}");
  }

  //============profile details===========//
  void profileDetailsValidation() {
    if (profilePhoto == null) {
      SnackBarToastMessage.info(context, "Please upload a photo");
      return;
    }
    if (Validation.isFieldEmpty(context,
        value: NameTextEditingController.text,
        fieldName: AppLanguage.firstNameText[language])) return;

    if (Validation.isFieldEmpty(context,
        value: lastnameTextEditingController.text,
        fieldName: AppLanguage.lastNameText[language])) return;

    if (Validation.isFieldEmpty(context,
        value: usernameTextEditingController.text,
        fieldName: AppLanguage.username[language])) return;

    if (Validation.isFieldEmpty(context,
        value: emailController.text,
        fieldName: AppLanguage.emailText[language])) return;

    if (!Validation.isEmailValid(
      context,
      emailController.text,
    )) return;

    if (!_isSocialSignup) {
      if (Validation.isFieldEmpty(
        context,
        value: passwordTextEditingController.text,
        fieldName: AppLanguage.passwordtext[language],
      )) return;

      if (!Validation.isStrongPassword(
          context, passwordTextEditingController.text)) return;

      if (Validation.isFieldEmpty(
        context,
        value: confirmpasswordTextEditingController.text,
        fieldName: AppLanguage.confirmPassword[language],
      )) return;

      if (!Validation.isPasswordMatch(
        context,
        passwordTextEditingController.text,
        confirmpasswordTextEditingController.text,
      )) return;
    }

    if (Validation.isFieldEmpty(context,
        value: dobtexteditingController.text,
        fieldName: AppLanguage.dateOfbirth[language])) return;

    if (Validation.isFieldSelect(context,
        value: selectedGender ?? "",
        fieldName: AppLanguage.gendertext[language])) return;

    if (Validation.isFieldEmpty(context,
        value: cityTextEditingController.text, fieldName: "City")) return;

    // Navigate or API call
    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    apiProvider.signupUserApi(
        context,
        NameTextEditingController.text,
        lastnameTextEditingController.text,
        usernameTextEditingController.text,
        referCodeTextEditingController.text,
        emailController.text,
        mobileNumberTextEditingController.text,
        passwordTextEditingController.text,
        _formatDobForApi(dobtexteditingController.text),
        selectedGender.toString(),
        heightTextEditingController.text,
        selectedCityId.toString(),
        profilePhoto,
        loginType: _isSocialSignup
            ? (widget.socialUser?['login_type']?.toString() ?? 'google')
            : 'email',
        isSocialSignup: _isSocialSignup); // Pass city ID to API
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _dobFocusNode.dispose();
    NameTextEditingController.dispose();
    lastnameTextEditingController.dispose();
    usernameTextEditingController.dispose();
    emailController.dispose();
    confirmpasswordTextEditingController.dispose();
    passwordTextEditingController.dispose();
    dobtexteditingController.dispose();
    heightTextEditingController.dispose();
    cityTextEditingController.dispose();
    mobileNumberTextEditingController.dispose();
    super.dispose();
  }

  // City selection method
  void _showCitySelectionSheet(BuildContext context) {
    final cityController =
        Provider.of<CityPreferenceController>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: CitySelectionBottomSheet(
          cities: cityController.getCityList,
          selectedCityId: selectedCityId,
          onCitySelected: (cityId, cityName) {
            setState(() {
              selectedCityId = cityId;
              selectedCity = cityName;
              cityTextEditingController.text = cityName;
            });
          },
        ),
      ),
    );
  }

  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int date = DateTime.now().day;
  String dateFormat = "";
  String dateOfBirth = "";
  DateTime? selectedDate;
  DateTime initalDate = DateTime.now();
  String selectDate = '';
  TextEditingController birthTextEditingController = TextEditingController();

  Widget _buildPasswordRule(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 13,
            color: met ? Colors.greenAccent : Colors.white38,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: met ? Colors.greenAccent : Colors.white54,
              fontFamily: AppFont.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDobForApi(String dob) {
    final parts = dob.split('/');
    if (parts.length == 3 && parts[2].length == 4) {
      return '${parts[2]}-${parts[1]}-${parts[0]}'; // DD/MM/YYYY → YYYY-MM-DD
    }
    return dob;
  }

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
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100,
                              ),
                              Column(
                                children: [
                                  Center(
                                    child: Text(
                                      AppLanguage.profileDetailstext[language],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 36,
                                        fontFamily: AppFont.fontFamily,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      AppLanguage.fillupDetailstext[language],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        fontFamily: AppFont.fontFamily,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),

                              GestureDetector(
                                onTap: () {
                                  _showImagePickerSheet();
                                },
                                child: Center(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 110,
                                        width: 110,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColor.themeColor
                                              : Color.fromARGB(
                                                  255, 235, 234, 234),
                                          border: Border.all(
                                              color: AppColor.buttonColor),
                                          shape: BoxShape.circle,
                                          image: profilePhoto != null
                                              ? DecorationImage(
                                                  image: FileImage(
                                                      File(profilePhoto!.path)),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: profilePhoto == null
                                            ? Icon(Icons.add,
                                                size: 40, color: Colors.grey)
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLanguage.uploadPhotoText[language],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationColor:
                                              AppColor.appHeadTextColor,
                                          color: AppColor.appHeadTextColor,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                              ),
                              // SizedBox(
                              //   height: MediaQuery.of(context).size.height *
                              //       5 /
                              //       100,
                              //   width: MediaQuery.of(context).size.width *
                              //       90 /
                              //       100,
                              //   child: Padding(
                              //     padding: EdgeInsets.all(
                              //       MediaQuery.of(context).size.width * 0.02,
                              //     ),
                              //     child: Text(
                              //       AppLanguage.firstNameText[language],
                              //       style: const TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w500,
                              //           fontFamily: AppFont.lexendFontFamily,
                              //           color: AppColor.appHeadTextColor),
                              //     ),
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: MediaQuery.of(context).size.height *
                              //       0.5 /
                              //       100,
                              // ),
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
                                        AppLanguage.firstNameText[language],
                                    maxLength: AppConstant.fullNameText,
                                    controller: NameTextEditingController,
                                    readOnly: false,
                                    inputFormatters: [
                                      TextInputFormatter.withFunction((oldValue, newValue) {
                                        if (newValue.text.isEmpty) return newValue;
                                        final text = newValue.text[0].toUpperCase() + newValue.text.substring(1);
                                        return newValue.copyWith(text: text);
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),

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
                                        AppLanguage.lastNameText[language],
                                    maxLength: AppConstant.fullNameText,
                                    controller: lastnameTextEditingController,
                                    readOnly: false,
                                    inputFormatters: [
                                      TextInputFormatter.withFunction((oldValue, newValue) {
                                        if (newValue.text.isEmpty) return newValue;
                                        final text = newValue.text[0].toUpperCase() + newValue.text.substring(1);
                                        return newValue.copyWith(text: text);
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      7 /
                                      100,
                                  child: CustomTextField(
                                    hintText: AppLanguage.username[language],
                                    maxLength: AppConstant.fullNameText,
                                    controller: usernameTextEditingController,
                                    readOnly: false,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
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
                                        AppLanguage.emailAddressText[language],
                                    maxLength: AppConstant.emailMaxLength,
                                    controller: emailController,
                                    readOnly: _isSocialSignup,
                                    onChanged: (value) {
                                      // Clear any shown error when user types
                                      SnackBarToastMessage.dismiss(context);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
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
                                        AppLanguage.phoneNumberText[language],
                                    maxLength: AppConstant.mobileMaxLenth,
                                    controller:
                                        mobileNumberTextEditingController,
                                    readOnly: (widget.screen == "refer" ||
                                            _isSocialSignup)
                                        ? false
                                        : true,
                                    // keyboardType: TextInputType.name,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              if (!_isSocialSignup) ...[
                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        7 /
                                        100,
                                    child: CustomTextField(
                                      hintText: "Enter Password",
                                      maxLength: 50,
                                      controller: passwordTextEditingController,
                                      isPassword: true,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                                  child: Text(
                                    "Password must be 8+ characters with uppercase, lowercase, a number & special character",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColor.greyLightColor(context),
                                      fontFamily: AppFont.fontFamily,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        7 /
                                        100,
                                    child: CustomTextField(
                                      hintText: "Enter Confirm Password",
                                      maxLength: 50,
                                      controller:
                                          confirmpasswordTextEditingController,
                                      isPassword: true,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                              ],
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      7 /
                                      100,
                                  child: TextFormField(
                                    readOnly: false,
                                    onTap: () {},
                                    style: TextStyle(
                                        color: AppColor.secondryColor(context)),
                                    keyboardType: TextInputType.datetime,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                                      LengthLimitingTextInputFormatter(10),
                                      TextInputFormatter.withFunction((oldValue, newValue) {
                                        String text = newValue.text.replaceAll('/', '');
                                        if (text.length > 2) {
                                          text = text.substring(0, 2) + '/' + text.substring(2);
                                        }
                                        if (text.length > 5) {
                                          text = text.substring(0, 5) + '/' + text.substring(5);
                                        }
                                        if (text.length > 10) text = text.substring(0, 10);
                                        return newValue.copyWith(
                                          text: text,
                                          selection: TextSelection.collapsed(offset: text.length),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      if (value.length == 10) {
                                        try {
                                          final parts = value.split('/');
                                          if (parts.length == 3) {
                                            final date = DateTime(
                                              int.parse(parts[2]), // year
                                              int.parse(parts[1]), // month
                                              int.parse(parts[0]), // day
                                            );
                                            final minAge = DateTime.now().subtract(const Duration(days: 365 * 18));
                                            if (date.isAfter(minAge)) {
                                              SnackBarToastMessage.error(context, "You must be at least 18 years old");
                                              dobtexteditingController.clear();
                                            } else {
                                              setState(() {
                                                selectDate = value;
                                                selectedDate = date;
                                              });
                                            }
                                          }
                                        } catch (e) {
                                          // Invalid date format
                                        }
                                      }
                                    },
                                    controller: dobtexteditingController,
                                    focusNode: _dobFocusNode,
                                    maxLength: null,
                                    decoration: InputDecoration(
                                      suffixIcon: GestureDetector(
                                        onTap: () => _showDatePicker(),
                                        child: Padding(
                                          padding: const EdgeInsets.only(right: 20),
                                          child: Image.asset(
                                            AppImage.dobCalendericon,
                                            width: MediaQuery.of(context).size.width * 4 / 100,
                                            height: MediaQuery.of(context).size.width * 5 / 100,
                                            color: AppColor.greyLightColor(context),
                                          ),
                                        ),
                                      ),
                                      suffixIconConstraints:
                                          const BoxConstraints(
                                        minWidth: 35,
                                        minHeight: 10,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColor.buttonColor
                                              : AppColor.greyLightColor(
                                                  context),
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
                                      fillColor: _isDobFocused
                                          ? AppColor.whiteBlackcolor(context)
                                          : AppColor.textFieldColor(context),
                                      filled: true,
                                      counterText: '',
                                      hintText: 'DD/MM/YYYY (or tap 📅)',
                                      hintStyle: TextStyle(
                                        color: AppColor.hinttextcolor(context),
                                        fontWeight: FontWeight.w400,
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 14,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 30,
                                        vertical: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _buildGenderDropdownField(
                                label: "",
                                value: selectedGender,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedGender = newValue;
                                    log("Selected Gender: $selectedGender");
                                  });
                                },
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),

                              //============City Selection Field========//
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      7 /
                                      100,
                                  child: Consumer<CityPreferenceController>(
                                    builder: (context, cityController, child) {
                                      return TextFormField(
                                        readOnly: true,
                                        onTap: () {
                                          if (cityController
                                              .getCityList.isEmpty) {
                                            // Show loading or fetch cities
                                            TopNotification.error(
                                                context, 'Loading cities...');
                                          } else {
                                            _showCitySelectionSheet(context);
                                          }
                                        },
                                        style: TextStyle(
                                            color: AppColor.secondryColor(
                                                context)),
                                        controller: cityTextEditingController,
                                        decoration: InputDecoration(
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 22),
                                            child: Image.asset(
                                              AppImage.downArrowicon,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  3 /
                                                  100,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1 /
                                                  100,
                                              color: AppColor.greyLightColor(
                                                  context),
                                            ),
                                          ),
                                          suffixIconConstraints:
                                              const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 10,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            borderSide: BorderSide(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? AppColor.buttonColor
                                                  : AppColor.greyLightColor(
                                                      context),
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            borderSide: const BorderSide(
                                              color: AppColor.buttonColor,
                                              width: 1.5,
                                            ),
                                          ),
                                          fillColor:
                                              AppColor.textFieldColor(context),
                                          filled: true,
                                          hintText: "Select City",
                                          hintStyle: TextStyle(
                                            color:
                                                AppColor.hinttextcolor(context),
                                            fontWeight: FontWeight.w400,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 14,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 30,
                                            vertical: 15,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              if (widget.screen == "refer")
                                Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        90 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        7 /
                                        100,
                                    child: CustomTextField(
                                      hintText: "Referral Code",
                                      maxLength: AppConstant.fullNameText,
                                      controller:
                                          referCodeTextEditingController,
                                      readOnly: true,
                                    ),
                                  ),
                                ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    4 /
                                    100,
                              ),
                              Consumer<PostApiProvider>(
                                builder: (context, apiprovider, child) {
                                  return apiprovider.loading
                                      ? const CircularProgressIndicator(
                                          color: AppColor.pinkColor)
                                      : AppButton(
                                          text: AppLanguage
                                              .continueText[language],
                                          onPress: () {
                                            FocusScope.of(context).unfocus();
                                            profileDetailsValidation();
                                          },
                                        );
                                },
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    6 /
                                    100,
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

  Widget _buildGenderDropdownField({
    required String label,
    required String? value,
    required Function(String?) onChanged,
  }) {
    List<String> genderList = ['Male', 'Female', 'Other'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.secondryColor(context),
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 90 / 100,
            height: MediaQuery.of(context).size.height * 7 / 100,
            child: DropdownButtonFormField<String>(
              value: value,
              dropdownColor: AppColor.textFieldColor(context),
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontFamily: AppFont.fontFamily,
              ),
              icon: const SizedBox.shrink(),
              decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 22),
                  child: Image.asset(
                    AppImage.downArrowicon,
                    width: MediaQuery.of(context).size.width * 3 / 100,
                    height: MediaQuery.of(context).size.width * 1 / 100,
                    color: AppColor.greyLightColor(context),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.buttonColor
                        : AppColor.greyLightColor(context),
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
                fillColor: AppColor.textFieldColor(context),
                filled: true,
                hintText: AppLanguage.selectGendertext[language],
                hintStyle: TextStyle(
                  color: AppColor.hinttextcolor(context),
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFont.fontFamily,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
              items: genderList.map((String gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime maxDate = DateTime(
      DateTime.now().year - 18,
      DateTime.now().month,
      DateTime.now().day,
    );
    final DateTime initialDate = (selectedDate != null && selectedDate!.isBefore(maxDate))
        ? selectedDate!
        : maxDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1940),
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE91E8C),
              onPrimary: Colors.white,
              surface: Color(0xFF341A41),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF341A41),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE91E8C),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        final dateStr = DateFormat('dd/MM/yyyy').format(picked);
        dobtexteditingController.text = dateStr;
        selectDate = dateStr;
        log("Selected DOB: $dateStr");
      });
    }
  }

  Future<XFile?> _cropPickedImage(XFile pickedFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Photo',
          toolbarColor: AppColor.themeColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Adjust Photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (croppedFile == null) return null;
    return XFile(croppedFile.path);
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.themeColor,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColor.themeColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined,
                      color: Colors.white),
                  title: const Text(
                    'Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 90,
                    );
                    if (pickedFile == null || !mounted) return;
                    final cropped = await _cropPickedImage(pickedFile);
                    if (cropped == null || !mounted) return;
                    setState(() {
                      profilePhoto = cropped;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                  ),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final pickedFile = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 90,
                    );
                    if (pickedFile == null || !mounted) return;
                    final cropped = await _cropPickedImage(pickedFile);
                    if (cropped == null || !mounted) return;
                    setState(() {
                      profilePhoto = cropped;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
