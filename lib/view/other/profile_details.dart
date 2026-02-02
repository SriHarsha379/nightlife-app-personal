import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../commonWidget/city_bottomsheet.dart';
import '../../controller/city_preference.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_validation.dart';
import '../../utilities/widgets.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String? mobile;
  const ProfileDetailsScreen({super.key, this.mobile});
  static String routeName = './ProfileDetailsScreen';
  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  int reportId = 0;
  String location = "";
  String locationDetails = "NA";

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
  String selectLocation = "NA";

  final FocusNode _focusNode = FocusNode();
  bool _isDobFocused = false;
  final FocusNode _dobFocusNode = FocusNode();

  String? selectedGender;
  TextEditingController cityTextEditingController = TextEditingController();
  String? selectedCity;
  String? selectedCityId;

  @override
  void initState() {
    super.initState();
    mobileNumberTextEditingController.text = widget.mobile.toString();
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
    if (Validation.isFieldEmpty(context,
        value: NameTextEditingController.text,
        fieldName: AppLanguage.nameText[language])) return;

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
    if (Validation.isFieldEmpty(
      context,
      value: passwordTextEditingController.text,
      fieldName: AppLanguage.passwordtext[language],
    )) return;

    if (!Validation.isPasswordLength(
        context, passwordTextEditingController.text)) return;

    if (Validation.isFieldEmpty(
      context,
      value: confirmpasswordTextEditingController.text,
      fieldName: AppLanguage.confirmPassword[language],
    )) return;

    if (!Validation.isPasswordLength(
        context, confirmpasswordTextEditingController.text)) return;

    if (!Validation.isPasswordMatch(
      context,
      passwordTextEditingController.text,
      confirmpasswordTextEditingController.text,
    )) return;

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
        emailController.text,
        mobileNumberTextEditingController.text,
        passwordTextEditingController.text,
        dobtexteditingController.text,
        selectedGender.toString(),
        heightTextEditingController.text,
        selectedCityId.toString()); // Pass city ID to API
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 36,
                                        fontFamily: AppFont.fontFamily,
                                        color: AppColor.secondryColor,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      AppLanguage.fillupDetailstext[language],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        fontFamily: AppFont.fontFamily,
                                        color: AppColor.secondryColor,
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
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                width: MediaQuery.of(context).size.width *
                                    90 /
                                    100,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.width * 0.02,
                                  ),
                                  child: Text(
                                    AppLanguage.firstNameText[language],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: AppFont.lexendFontFamily,
                                        color: AppColor.appHeadTextColor),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.5 /
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
                                    hintText: AppLanguage.nameText[language],
                                    maxLength: AppConstant.fullNameText,
                                    controller: NameTextEditingController,
                                    readOnly: false,
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
                                    0.5 /
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
                                        AppLanguage.phoneNumberText[language],
                                    maxLength: AppConstant.mobileMaxLenth,
                                    controller:
                                        mobileNumberTextEditingController,
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
                                    style: const TextStyle(
                                        color: AppColor.secondryColor),
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
                                          color: AppColor.greyLightColor,
                                        ),
                                      ),
                                      suffixIconConstraints:
                                          const BoxConstraints(
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
                                      fillColor: _isDobFocused
                                          ? AppColor.primaryColor
                                          : AppColor.themeColor,
                                      filled: true,
                                      counterText: '',
                                      hintText: 'DOB',
                                      hintStyle: AppConstant.textFilledStyle,
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
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content:
                                                    Text('Loading cities...'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          } else {
                                            _showCitySelectionSheet(context);
                                          }
                                        },
                                        style: const TextStyle(
                                            color: AppColor.secondryColor),
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
                                              color: AppColor.greyLightColor,
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
                                            borderSide: const BorderSide(
                                              color: AppColor.buttonColor,
                                              width: 0.5,
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
                                          fillColor: AppColor.themeColor,
                                          filled: true,
                                          hintText: "Select City",
                                          hintStyle:
                                              AppConstant.textFilledStyle,
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
                                    1 /
                                    100,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    13 /
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
          style: const TextStyle(
            color: AppColor.secondryColor,
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
              dropdownColor: AppColor.themeColor,
              style: const TextStyle(
                color: AppColor.secondryColor,
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
                    color: AppColor.greyLightColor,
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 10,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(
                    color: AppColor.buttonColor,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(
                    color: AppColor.buttonColor,
                    width: 0.5,
                  ),
                ),
                fillColor: AppColor.themeColor,
                filled: true,
                hintText: AppLanguage.selectGendertext[language],
                hintStyle: AppConstant.textFilledStyle,
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
                        color: AppColor.secondryColor,
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
                          color: AppColor.secondryColor,
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
                      print("selectedDate $selectedDate");
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
}
