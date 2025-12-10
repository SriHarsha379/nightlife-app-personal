
import 'dart:developer';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/view/authentication/edit_profile_screen.dart';
import 'package:night_life/view/authentication/otp_verify_screen.dart';
import 'package:night_life/view/other/city_Preference/additional_info.dart';
import 'package:night_life/view/other/city_Preference/citypreference_screen.dart';
import 'package:night_life/view/other/upload_id_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';

import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

import '../../utilities/widgets.dart';
import '../authentication/profile.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});
  static String routeName = './ProfileDetailsScreen';
  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  File? _imageSelect;
  // var base64Image;
  // var fileName;
  // late File _image;
  int reportId = 0;
  String location = "";
  String locationDetails = "NA";

  String imageController = "NA";

  TextEditingController NameTextEditingController = TextEditingController();
  TextEditingController heightTextEditingController = TextEditingController();

  TextEditingController lastnameTextEditingController = TextEditingController();
  TextEditingController dobtexteditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();

  String selectLocation = "NA";

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isDobFocused = false;
  final FocusNode _dobFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _dobFocusNode.addListener(() {
      setState(() {
        _isDobFocused = _dobFocusNode.hasFocus;
      });
    });
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String? selectedGender;
  TextEditingController emailController = TextEditingController();

  TextEditingController messageTextEditingController = TextEditingController();
  TextEditingController mobileNumberTextEditingController =
      TextEditingController();

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
    mobileNumberTextEditingController.text = "9174658235";
  
    return  AnnotatedRegion<SystemUiOverlayStyle>(
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
                BoxDecoration(gradient: AppColor.backgroundGradientcolor),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
                // AppHeader(
                //   text: AppLanguage.profilesetupText[language],
                //   onPress: () => Navigator.pop(context),
                // ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Center(
                                    child: Text(
                                      AppLanguage.profileDetailstext[language],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 36,
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
                                        color: AppColor.secondryColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        3 /
                                        100,
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
                                        fontFamily: AppFont.fontFamily,
                                        color: AppColor.buttonColor),
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
                                    // keyboardType: TextInputType.name,
                                    controller: NameTextEditingController,
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
                                    maxLength: AppConstant.mobileMaxLenth,
                                    // keyboardType: TextInputType.phone,
                                    controller: lastnameTextEditingController,
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
                                    maxLength: AppConstant.mobileMaxLenth,
                                    // keyboardType: TextInputType.phone,
                                    controller: lastnameTextEditingController,
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
                                    maxLength: AppConstant.mobileMaxLenth,
                                    // keyboardType: TextInputType.phone,
                                    controller: emailController,
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
                                    // keyboardType: TextInputType.phone,
                                    controller:
                                        mobileNumberTextEditingController,
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
                                    focusNode: _dobFocusNode, // Added FocusNode
                                    maxLength: AppConstant.fullNameText,
                                    decoration: InputDecoration(
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.only(right: 20),
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
                                    // onTap: () {
                                    //   // cancelRideBottomSheet(context);
                                    // },
                                  ),
                                ),
                              ),
                              _buildGenderDropdownField(
                                label: "",
                                value: selectedGender,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedGender = newValue;
                                  });
                                },
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
                                    // keyboardType: TextInputType.phone,
                                    controller: heightTextEditingController,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    80 /
                                    100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        textAlign: TextAlign.justify,
                                        AppLanguage
                                            .bySigningupStatementText[language],
                                        style: const TextStyle(
                                            color: AppColor.secondryColor,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 12),
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          1 /
                                          100,
                                    ),
                                    Text(
                                      AppLanguage
                                          .userAgreementStatementText[language],
                                      style: const TextStyle(
                                          color: AppColor.secondryColor,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              AppButton(
                                  text: AppLanguage.continueText[language],
                                  onPress: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: OtpVerify(),
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  }),
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
        // SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
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
                  padding: EdgeInsets.only(right: 22),
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
    // Set the initial date to current date - 18 years
    final DateTime currentDate = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(
      currentDate.year - 18,
      currentDate.month,
      currentDate.day,
    );

    selectedDate = eighteenYearsAgo;

    showModalBottomSheet(
      backgroundColor: AppColor.themeColor, // 👈 Bottomsheet bg color

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

                            dobtexteditingController.text =
                                dateStr; // <-- INSERT FIXED
                            selectDate = dateStr; // <-- UPDATE THIS ALSO
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
                        color:
                            Colors.white, // 👈 DATE, MONTH, YEAR becomes white
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    // Optional: set minimum and maximum date if required
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

  //     print(data['location']);
  //   }
  //   setState(() {});
  // }
}
