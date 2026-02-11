import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../provider/post_api_provider.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';
import '../other/edit_hobbies.dart';

class EditProfile extends StatefulWidget {
  static String routeName = './EditProfile';
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  String selectedGender = 'Male';
  String profileImage = '';
  XFile? _selectedProfileImage;
  String fullName = '';
  String dob = '';

  String hobbiesText = '';
  bool hasHobbies = false;
  bool _isLoading = true;

  String _profileImageUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return '${AppConfigProvider.imageUrl}$trimmed';
  }

  bool _isLocalPath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.startsWith('file://')) return true;
    if (trimmed.startsWith('/') || trimmed.startsWith('\\')) return true;
    if (trimmed.contains(':\\') || trimmed.contains(':/')) return true;
    return false;
  }

  String _localFilePath(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('file://')) {
      return Uri.parse(trimmed).toFilePath();
    }
    return trimmed;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userController = Provider.of<UserController>(context, listen: false);
    await userController.getUserDetails();

    final firstName = userController.getFirstName.trim();
    final lastName = userController.getLastName.trim();
    final loadedFullName = userController.getUserName.trim();
    final loadedDob = userController.getBirthdate.trim();

    final hobbies = userController.getHobbies
        .map((hobby) {
          if (hobby is Map) {
            return (hobby['name'] ?? hobby['title'] ?? '').toString().trim();
          }
          return hobby.toString().trim();
        })
        .where((hobby) => hobby.isNotEmpty)
        .toList();

    if (!mounted) return;
    setState(() {
      firstNameController.text = firstName;
      lastNameController.text = lastName;
      dob = loadedDob;

      usernameController.text = userController.getUserNameId;
      bioController.text = userController.getUserBio;
      emailController.text = userController.getUserEmail;
      mobileController.text = userController.getUserMobile;
      selectedGender = userController.getUserGender.isNotEmpty
          ? userController.getUserGender
          : selectedGender;
      profileImage = userController.getUserImage;
      fullName = loadedFullName.isNotEmpty
          ? loadedFullName
          : '$firstName $lastName'.trim();
      hasHobbies = hobbies.isNotEmpty;
      hobbiesText = hasHobbies ? hobbies.join(' · ') : 'No hobbies added';
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final combinedName = '$firstName $lastName'.trim();

    await Provider.of<PostApiProvider>(context, listen: false).editProfileApi(
      context,
      firstNameController.text.trim(),
      lastNameController.text.trim(),
      usernameController.text.trim(),
      bioController.text.trim(),
      emailController.text.trim(),
      mobileController.text.trim(),
      selectedGender,
      _selectedProfileImage,
    );

    final userController = Provider.of<UserController>(context, listen: false);
    userController.setUserFromMap({
      ...userController.getUserData,
      'first_name': firstName,
      'last_name': lastName,
      'name': combinedName,
      'username': usernameController.text.trim(),
      'gender': selectedGender,
      'email': emailController.text.trim(),
      'phone_number': mobileController.text.trim(),
      'bio': bioController.text.trim(),
      'profile_image': _selectedProfileImage?.path ?? profileImage,
    });

    if (!mounted) return;
    setState(() {
      fullName = combinedName;
    });
  }

  Future<void> _pickProfileImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
    );
    if (pickedFile == null || !mounted) return;
    setState(() {
      _selectedProfileImage = pickedFile;
      profileImage = pickedFile.path;
    });
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickProfileImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _pickProfileImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  Widget _buildFieldBox({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 90 / 100,
      height: MediaQuery.of(context).size.height * 6 / 100,
      decoration: BoxDecoration(
        color: AppColor.textfieldcontainercolor(context),
        boxShadow: [
          BoxShadow(
            color: AppColor.grayColor.withOpacity(0.4),
            blurRadius: 2,
            offset: const Offset(1, 2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(26),
          top: Radius.circular(26),
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100),
                    AppHeader(
                      onPress: () => Navigator.pop(context),
                      text: AppLanguage.editDetailsText[language],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 34 / 100,
                            height:
                                MediaQuery.of(context).size.height * 18 / 100,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                GestureDetector(
                                  onTap: _showImagePickerSheet,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        34 /
                                        100,
                                    height: MediaQuery.of(context).size.height *
                                        18 /
                                        100,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        bottom: Radius.circular(30),
                                        top: Radius.circular(30),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(30),
                                        top: Radius.circular(30),
                                      ),
                                      child: profileImage.isNotEmpty
                                          ? (_selectedProfileImage != null
                                              ? Image.file(
                                                  File(_selectedProfileImage!
                                                      .path),
                                                  fit: BoxFit.cover,
                                                )
                                              : _isLocalPath(profileImage)
                                                  ? Image.file(
                                                      File(_localFilePath(
                                                          profileImage)),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.network(
                                                      _profileImageUrl(
                                                          profileImage),
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Image.asset(
                                                          AppImage
                                                              .placeHolder2Icon,
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ))
                                          : Image.asset(
                                              AppImage.placeHolder2Icon,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -5,
                                  right: -5,
                                  child: GestureDetector(
                                    onTap: _showImagePickerSheet,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(
                                        color: AppColor.buttonColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          AppImage.pencilIcon,
                                          width: 14,
                                          height: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 3 / 100),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        1 /
                                        100),
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.textcolor,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.textcolor,
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.2 /
                                        100),
                                Text(
                                  dob,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.textcolor,
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        1 /
                                        100),
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: const EditHobbiesScreen(),
                                        duration:
                                            const Duration(milliseconds: 400),
                                      ),
                                    );
                                    await _loadUserData();
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        hasHobbies
                                            ? AppLanguage
                                                .edityourHobbiesText[language]
                                            : 'Add',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: AppFont.fontFamily,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6 /
                                              100),
                                      Image.asset(
                                        AppImage.pencilIcon,
                                        height: size.height * 3 / 100,
                                        width: size.width * 3 / 100,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.4 /
                                        100),
                                Text(
                                  hobbiesText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.buttonColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 89 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.firstNameText[language],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.textcolor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    _buildFieldBox(
                      context: context,
                      child: CustomTextFieldInput(
                        hintText: AppLanguage.firstNameText[language],
                        maxLength: AppConstant.fullNameText,
                        keyboardType: TextInputType.name,
                        controller: firstNameController,
                        fillColor: AppColor.textfieldcontainercolor(context),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 89 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.lastNameText[language],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.textcolor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    _buildFieldBox(
                      context: context,
                      child: CustomTextFieldInput(
                        hintText: AppLanguage.lastNameText[language],
                        maxLength: AppConstant.fullNameText,
                        keyboardType: TextInputType.name,
                        controller: lastNameController,
                        fillColor: AppColor.textfieldcontainercolor(context),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 89 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.username[language],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.textcolor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    _buildFieldBox(
                      context: context,
                      child: CustomTextFieldInput(
                        hintText: AppLanguage.enterUserandEmailId[language],
                        maxLength: AppConstant.fullNameText,
                        keyboardType: TextInputType.name,
                        controller: usernameController,
                        fillColor: AppColor.textfieldcontainercolor(context),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 87 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.bioText[language],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.textcolor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    Container(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextFormField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.multiline,
                        controller: bioController,
                        maxLines: 2,
                        minLines: 2,
                        maxLength: AppConstant.fullNameText,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColor.textfieldcontainercolor(context),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColor.textfieldcontainercolor(context),
                              width: 1.5,
                            ),
                          ),
                          fillColor: AppColor.textfieldcontainercolor(context),
                          filled: true,
                          counterText: '',
                          hintText: 'Add about yourself..',
                          hintStyle: AppConstant.textFilledStyle(context),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.87,
                      child: Text(
                        AppLanguage.privateinformationText[language],
                        style: const TextStyle(
                          color: AppColor.buttonColor,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26.0),
                          child: Text(
                            AppLanguage.emailText[language],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.textcolor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Text(
                                AppLanguage.verifiedText[language],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      2 /
                                      100),
                              Image.asset(
                                AppImage.verifiedIcon,
                                height: size.height * 3 / 100,
                                width: size.width * 5 / 100,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    _buildFieldBox(
                      context: context,
                      child: CustomTextFieldInput(
                        hintText: AppLanguage.enteremailidText[language],
                        maxLength: AppConstant.emailMaxLength,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        fillColor: AppColor.textfieldcontainercolor(context),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26.0),
                          child: Text(
                            AppLanguage.mobileNumberText[language],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.textcolor,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: [
                              Text(
                                AppLanguage.verifiedText[language],
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      2 /
                                      100),
                              Image.asset(
                                AppImage.verifiedIcon,
                                height: size.height * 3 / 100,
                                width: size.width * 5 / 100,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    _buildFieldBox(
                      context: context,
                      child: CustomTextFieldInput(
                        hintText: AppLanguage.mobileNumberText[language],
                        maxLength: AppConstant.mobileMaxLenth,
                        keyboardType: TextInputType.phone,
                        controller: mobileController,
                        fillColor: AppColor.textfieldcontainercolor(context),
                        readOnly: true,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 87 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.genderText[language],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            fontFamily: AppFont.fontFamily,
                            color: AppColor.textcolor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    _buildFieldBox(
                      context: context,
                      child: DropdownButtonFormField<String>(
                        value: genderOptions.contains(selectedGender)
                            ? selectedGender
                            : genderOptions.first,
                        dropdownColor:
                            AppColor.textfieldcontainercolor(context),
                        iconEnabledColor: AppColor.secondryColor(context),
                        style: TextStyle(
                          color: AppColor.secondryColor(context),
                          fontFamily: AppFont.fontFamily,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        items: genderOptions
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100),
                    Consumer<PostApiProvider>(
                        builder: (context, apiprovider, child) {
                      return apiprovider.loading
                          ? const CircularProgressIndicator(
                              color: AppColor.pinkColor)
                          : AppButton(
                              text: AppLanguage.updateText[language],
                              onPress: _updateProfile,
                            );
                    }),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100),
                  ],
                ),
              ),
      ),
    );
  }
}
