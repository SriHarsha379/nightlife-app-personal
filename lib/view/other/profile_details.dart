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
import '../../utilities/app_language.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../../utilities/app_text_field.dart';
import '../../utilities/app_validation.dart';

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
  XFile? profilePhoto;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController  = TextEditingController();
  final TextEditingController _usernameController  = TextEditingController();
  final TextEditingController _emailController     = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  final TextEditingController _dobController       = TextEditingController();
  final TextEditingController _mobileController    = TextEditingController();
  final TextEditingController _heightController    = TextEditingController();
  final TextEditingController _cityController      = TextEditingController();
  final TextEditingController _referController     = TextEditingController();

  String? selectedGender;
  String? selectedCity;
  String? selectedCityId;

  bool get _isSocialSignup => widget.screen == "social";

  @override
  void initState() {
    super.initState();
    _mobileController.text = widget.mobile ?? '';
    _referController.text  = widget.refercode ?? '';

    if (_isSocialSignup && widget.socialUser != null) {
      _firstNameController.text =
          (widget.socialUser!['first_name'] ?? '').toString();
      _lastNameController.text =
          (widget.socialUser!['last_name'] ?? '').toString();
      _emailController.text =
          (widget.socialUser!['email'] ?? '').toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CityPreferenceController>(context, listen: false)
          .fetchCityList(context);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPwController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _heightController.dispose();
    _cityController.dispose();
    _referController.dispose();
    super.dispose();
  }

  void _showCitySheet(BuildContext context) {
    final cityController =
        Provider.of<CityPreferenceController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: CitySelectionBottomSheet(
          cities: cityController.getCityList,
          selectedCityId: selectedCityId,
          onCitySelected: (cityId, cityName) {
            setState(() {
              selectedCityId = cityId;
              selectedCity   = cityName;
              _cityController.text = cityName;
            });
          },
        ),
      ),
    );
  }

  void _validate() {
    if (profilePhoto == null) {
      SnackBarToastMessage.info(context, "Please upload a photo");
      return;
    }
    if (Validation.isFieldEmpty(context,
        value: _firstNameController.text,
        fieldName: AppLanguage.firstNameText[language])) { return; }
    if (Validation.isFieldEmpty(context,
        value: _lastNameController.text,
        fieldName: AppLanguage.lastNameText[language])) { return; }
    if (Validation.isFieldEmpty(context,
        value: _usernameController.text,
        fieldName: AppLanguage.username[language])) { return; }
    if (Validation.isFieldEmpty(context,
        value: _emailController.text,
        fieldName: AppLanguage.emailText[language])) { return; }
    if (!Validation.isEmailValid(context, _emailController.text)) { return; }

    if (!_isSocialSignup) {
      if (Validation.isFieldEmpty(context,
          value: _passwordController.text,
          fieldName: AppLanguage.passwordtext[language])) { return; }
      if (!Validation.isStrongPassword(context, _passwordController.text)) {
        return;
      }
      if (Validation.isFieldEmpty(context,
          value: _confirmPwController.text,
          fieldName: AppLanguage.confirmPassword[language])) { return; }
      if (!Validation.isPasswordMatch(
          context, _passwordController.text, _confirmPwController.text)) {
        return;
      }
    }

    if (Validation.isFieldEmpty(context,
        value: _dobController.text,
        fieldName: AppLanguage.dateOfbirth[language])) { return; }
    if (Validation.isFieldSelect(context,
        value: selectedGender ?? '',
        fieldName: AppLanguage.gendertext[language])) { return; }
    if (Validation.isFieldEmpty(context,
        value: _cityController.text, fieldName: 'City')) { return; }

    Provider.of<PostApiProvider>(context, listen: false).signupUserApi(
      context,
      _firstNameController.text,
      _lastNameController.text,
      _usernameController.text,
      _referController.text,
      _emailController.text,
      _mobileController.text,
      _passwordController.text,
      _dobController.text,
      selectedGender.toString(),
      _heightController.text,
      selectedCityId.toString(),
      profilePhoto,
      loginType: _isSocialSignup
          ? (widget.socialUser?['login_type']?.toString() ?? 'google')
          : 'email',
      isSocialSignup: _isSocialSignup,
    );
  }

  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    DateTime selected = eighteenYearsAgo;

    await showModalBottomSheet(
      backgroundColor: AppColor.themeColor,
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  CupertinoButton(
                    child: const Text('Done',
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      setState(() {
                        _dobController.text =
                            DateFormat('yyyy/MM/dd').format(selected);
                      });
                      Navigator.pop(ctx);
                    },
                  ),
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
                    onDateTimeChanged: (dt) => selected = dt,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.themeColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: Colors.white),
              title:
                  const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final f = await ImagePicker().pickImage(
                    source: ImageSource.camera, imageQuality: 90);
                if (f != null && mounted) setState(() => profilePhoto = f);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Colors.white),
              title: const Text('Gallery',
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(ctx);
                final f = await ImagePicker().pickImage(
                    source: ImageSource.gallery, imageQuality: 90);
                if (f != null && mounted) setState(() => profilePhoto = f);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                      vertical: size.height * 0.02,
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppLanguage.profileDetailstext[language],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 28,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppLanguage.fillupDetailstext[language],
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.secondryColor(context)
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05),
                      child: Column(
                        children: [
                          // Photo picker
                          GestureDetector(
                            onTap: _showImagePicker,
                            child: Column(
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColor.themeColor
                                        : const Color(0xFFEBEAEA),
                                    border: Border.all(
                                        color: AppColor.buttonColor,
                                        width: 2),
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
                                          size: 36, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLanguage.uploadPhotoText[language],
                                  style: const TextStyle(
                                    fontSize: 13,
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

                          const SizedBox(height: 28),

                          // ✅ All fields use AppTextField — labels always visible
                          AppTextField(
                            controller: _firstNameController,
                            label: AppLanguage.firstNameText[language],
                            maxLength: AppConstant.fullNameText,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _lastNameController,
                            label: AppLanguage.lastNameText[language],
                            maxLength: AppConstant.fullNameText,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _usernameController,
                            label: AppLanguage.username[language],
                            maxLength: AppConstant.fullNameText,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _emailController,
                            label: AppLanguage.emailAddressText[language],
                            maxLength: AppConstant.emailMaxLength,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            readOnly: _isSocialSignup,
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _mobileController,
                            label: AppLanguage.phoneNumberText[language],
                            maxLength: AppConstant.mobileMaxLenth,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            readOnly: widget.screen != 'refer' &&
                                !_isSocialSignup,
                          ),
                          const SizedBox(height: 16),

                          if (!_isSocialSignup) ...[
                            AppTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Min 8 chars, uppercase, number, symbol',
                              maxLength: 50,
                              isPassword: true,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 6),
                            // ✅ Password rules shown before error — audit #05
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                'Must contain uppercase, lowercase, number and symbol',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColor.hinttextcolor(context),
                                  fontFamily: AppFont.fontFamily,
                                ),
                              ),
                            ),

                            AppTextField(
                              controller: _confirmPwController,
                              label: 'Confirm Password',
                              maxLength: 50,
                              isPassword: true,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // DOB
                          GestureDetector(
                            onTap: _showDatePicker,
                            child: AbsorbPointer(
                              child: AppTextField(
                                controller: _dobController,
                                label: 'Date of Birth',
                                hint: 'Tap to select',
                                readOnly: true,
                                suffixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  color: AppColor.hinttextcolor(context),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Gender
                          _buildGenderField(),
                          const SizedBox(height: 16),

                          // City
                          GestureDetector(
                            onTap: () {
                              final c =
                                  Provider.of<CityPreferenceController>(
                                      context,
                                      listen: false);
                              if (c.getCityList.isEmpty) {
                                TopNotification.error(
                                    context, 'Loading cities...');
                              } else {
                                _showCitySheet(context);
                              }
                            },
                            child: AbsorbPointer(
                              child: AppTextField(
                                controller: _cityController,
                                label: 'City',
                                hint: 'Select your city',
                                readOnly: true,
                                suffixIcon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColor.hinttextcolor(context),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _heightController,
                            label: AppLanguage.heightOptionalText[language],
                            hint: 'e.g. 175 cm',
                            maxLength: AppConstant.mobileMaxLenth,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                          ),

                          if (widget.screen == 'refer') ...[
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _referController,
                              label: 'Referral Code',
                              maxLength: AppConstant.fullNameText,
                              readOnly: true,
                            ),
                          ],

                          const SizedBox(height: 32),

                          Consumer<PostApiProvider>(
                            builder: (_, api, __) => AppButton(
                              text: AppLanguage.continueText[language],
                              isLoading: api.loading,
                              onPress: () {
                                FocusScope.of(context).unfocus();
                                _validate();
                              },
                            ),
                          ),

                          // ✅ Safe area bottom padding — audit #02
                          SizedBox(
                            height:
                                MediaQuery.of(context).padding.bottom + 24,
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
      ),
    );
  }

  Widget _buildGenderField() {
    final List<String> genders = ['Male', 'Female', 'Other'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      initialValue: selectedGender,
      dropdownColor: AppColor.textFieldColor(context),
      style: TextStyle(
        color: AppColor.secondryColor(context),
        fontFamily: AppFont.fontFamily,
        fontSize: 15,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColor.hinttextcolor(context),
      ),
      decoration: InputDecoration(
        labelText: AppLanguage.selectGendertext[language],
        labelStyle: TextStyle(
          color: AppColor.hinttextcolor(context),
          fontSize: 14,
          fontFamily: AppFont.fontFamily,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(
          color: AppColor.hinttextcolor(context),
          fontSize: 12,
          fontFamily: AppFont.fontFamily,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColor.textFieldColor(context),
        counterText: '',
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? AppColor.buttonColor.withValues(alpha: 0.4)
                : AppColor.greyLightColor(context),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColor.buttonColor,
            width: 1.5,
          ),
        ),
      ),
      items: genders
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (val) => setState(() => selectedGender = val),
    );
  }
}
