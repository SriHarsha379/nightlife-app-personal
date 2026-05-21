import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  TextEditingController nameTextEditingController = TextEditingController();
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
      nameTextEditingController.text =
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
        value: nameTextEditingController.text,
        fieldName: AppLanguage.firstNameText[language])) {
      return;
    }

    if (Validation.isFieldEmpty(context,
        value: lastnameTextEditingController.text,
        fieldName: AppLanguage.lastNameText[language])) {
      return;
    }

    if (Validation.isFieldEmpty(context,
        value: usernameTextEditingController.text,
        fieldName: AppLanguage.username[language])) {
      return;
    }

    if (Validation.isFieldEmpty(context,
        value: emailController.text,
        fieldName: AppLanguage.emailText[language])) {
      return;
    }

    if (!Validation.isEmailValid(
      context,
      emailController.text,
    )) {
      return;
    }

    if (!_isSocialSignup) {
      if (Validation.isFieldEmpty(
        context,
        value: passwordTextEditingController.text,
        fieldName: AppLanguage.passwordtext[language],
      )) {
        return;
      }

      if (!Validation.isStrongPassword(
          context, passwordTextEditingController.text)) {
        return;
      }

      if (Validation.isFieldEmpty(
        context,
        value: confirmpasswordTextEditingController.text,
        fieldName: AppLanguage.confirmPassword[language],
      )) {
        return;
      }

      if (!Validation.isPasswordMatch(
        context,
        passwordTextEditingController.text,
        confirmpasswordTextEditingController.text,
      )) {
        return;
      }
    }

    if (Validation.isFieldEmpty(context,
        value: dobtexteditingController.text,
        fieldName: AppLanguage.dateOfbirth[language])) {
      return;
    }

    if (Validation.isFieldSelect(context,
        value: selectedGender ?? "",
        fieldName: AppLanguage.gendertext[language])) {
      return;
    }

    if (Validation.isFieldEmpty(context,
        value: cityTextEditingController.text, fieldName: "City")) {
      return;
    }

    // Navigate or API call
    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    apiProvider.signupUserApi(
        context,
        nameTextEditingController.text,
        lastnameTextEditingController.text,
        usernameTextEditingController.text,
        referCodeTextEditingController.text,
        emailController.text,
        mobileNumberTextEditingController.text,
        passwordTextEditingController.text,
        dobtexteditingController.text,
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
    nameTextEditingController.dispose();
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
                        SizedBox(
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
                                               : const Color.fromARGB(
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
                                            ? const Icon(Icons.add,
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
                                    controller: nameTextEditingController,
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
                                        AppLanguage.lastNameText[language],
                                    maxLength: AppConstant.fullNameText,
                                    controller: lastnameTextEditingController,
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
                                    readOnly: true,
                                    onTap: () {
                                      _showDatePicker();
                                    },
                                    style: TextStyle(
                                        color: AppColor.secondryColor(context)),
                                    keyboardType: TextInputType.name,
                                    controller: dobtexteditingController,
                                    focusNode: _dobFocusNode,
                                    maxLength: AppConstant.fullNameText,
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Image.asset(
                                          AppImage.dobCalendericon,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              4 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              5 /
                                              100,
                                          color:
                                              AppColor.greyLightColor(context),
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
                                      hintText: 'DOB',
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
                              Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      90 /
                                      100,
                                  height: MediaQuery.of(context).size.height *
                                      7 /
                                      100,
                                  child: CustomTextField(
                                    hintText: AppLanguage
                                        .heightOptionalText[language],
                                    maxLength: AppConstant.mobileMaxLenth,
                                    controller: heightTextEditingController,
                                    readOnly: false,
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
                                      hintText: "ReferCode",
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
              key: ValueKey(value),
              initialValue: value,
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
    final DateTime currentDate = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(
      currentDate.year - 18,
      currentDate.month,
      currentDate.day,
    );

    selectedDate = eighteenYearsAgo;

    showModalBottomSheet(
      backgroundColor: AppColor.themeColor,
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        if (selectedDate != null) {
                          setState(() {
                            String dateStr =
                                DateFormat('yyyy/MM/dd').format(selectedDate!);
                            dobtexteditingController.text = dateStr;
                            selectDate = dateStr;
                            log("Selected DOB: $dateStr");
                          });
                        }
                        Navigator.pop(context);
                      }),
                ],
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    maximumDate: eighteenYearsAgo,
                    initialDateTime: eighteenYearsAgo,
                    mode: CupertinoDatePickerMode.date,
                    use24hFormat: true,
                    onDateTimeChanged: (DateTime dateTime) {
                      setState(() {
                        selectedDate = dateTime;
                      });
                      log("selectedDate $selectedDate");
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
                    setState(() {
                      profilePhoto = pickedFile;
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
                    setState(() {
                      profilePhoto = pickedFile;
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
