import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/signup.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_comman_setting.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';
import 'profile.dart';

class EditProfile extends StatefulWidget {
  static String routeName = './EditProfile';
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

TextEditingController mobileNumberTextEditingController =
    TextEditingController();
TextEditingController bioController = TextEditingController();
TextEditingController emailController = TextEditingController(text:" abcd@gmail.com");
TextEditingController genderController = TextEditingController();
TextEditingController usernameController = TextEditingController(text: "@Arjun5624");

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    emailController.text = "abcd@gmail.com";
    usernameController.text ="@Arjun5624";
    mobileNumberTextEditingController.text ="9174658235";
    genderController.text ="Male";
  
    final size = MediaQuery.of(context).size;

    return   AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 4 / 100),    
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.editDetailsText[language],
                // actionButton: TextButton(
                //   onPressed: () {},
                //   child: Text(
                //     AppLanguage.clearText[language],
                //     style: const TextStyle(
                //       color: Colors.grey,
                //       fontSize: 13,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ),
        
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 6 / 100),
                    // Profile Image
                    Container(
                      width: MediaQuery.of(context).size.width * 36 / 100,
                      height: MediaQuery.of(context).size.height * 20 / 100,
                      decoration: const BoxDecoration(
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30),
                          top: Radius.circular(30),
                        ),
                      ),
                      child: Image.asset(
                        AppImage.editUserprofile,
                        height: size.height * 18 / 100,
                        width: size.width * 20 / 100,
                        fit: BoxFit.cover,
                      ),
                      // child: CircleAvatar(
                      //   backgroundImage: AssetImage(AppImage.editUserprofile),
                      // ),
                    ),
                    // SizedBox(
                    //     width: MediaQuery.of(context).size.width * 0.1 / 100),
        
                    // Profile Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),
                          Text(
                            AppLanguage.enterYournameText[language],
                            style: TextStyle(
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
                            AppLanguage.date[language],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.textcolor,
                            ),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 100),
                          Row(
                            children: [
                              Text(
                                AppLanguage.edityourInterestsText[language],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.secondryColor,
                                ),
                              ),
                              Image.asset(
                                AppImage.pencilIcon,
                                height: size.height * 4 / 100,
                                width: size.width * 4 / 100,
                              ),
                            ],
                          ),
        
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.2 /
                                  100),
                          Text(
                            AppLanguage.foodieExplorecreativeText[language],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.buttonColor,
                            ),
                          ),
        
                          // buildTaskRow(
                          //     AppLanguage.foodieExplorecreativeText[language],
                          //     Colors.purpleAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        
              // Profile Completion Text
              SizedBox(
                width: MediaQuery.of(context).size.width * 89 / 100,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLanguage.username[language],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFont.fontFamily,
                      color: AppColor.textcolor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 6 / 100,
                  decoration: BoxDecoration(
                    color: AppColor.textfieldcontainercolor, // background color
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColor.textfieldcontainercolor, // shadow color
                        // spreadRadius: 1,
                        blurRadius: 2, // blur effect
                        offset: Offset(1, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                      top: Radius.circular(26),
                    ),
                  ),
                  child: CustomTextFieldInput(
                    hintText: AppLanguage.enterUserandEmailId[language],
                    maxLength: AppConstant.mobileMaxLenth,
                    keyboardType: TextInputType.name,
                    controller: usernameController,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              SizedBox(
                width: MediaQuery.of(context).size.width * 87 / 100,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLanguage.bioText[language],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFont.fontFamily,
                      color: AppColor.textcolor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   AppLanguage.addAboutyourselfText[language],
                    //   style: AppConstant.textFilledStyle,
                    // ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                    Container(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.grayColor.withOpacity(0.4),
                            blurRadius: 4,
                            offset: Offset(0, 2),
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
                              color: AppColor.textfieldcontainercolor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                              color: AppColor.textfieldcontainercolor,
                              width: 1.5,
                            ),
                          ),
                          fillColor: AppColor.textfieldcontainercolor,
                          filled: true,
                          counterText: '',
                          hintText: 'Add about yourself..',
                          hintStyle: AppConstant.textFilledStyle,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 15,
                          ),
                        ),
                        onTap: () {
                          // cancelRideBottomSheet(context);
                        },
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
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
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Email text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(
                      AppLanguage.emailText[language],
                      style: TextStyle(
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
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 2 / 100),
                        Image.asset(
                          AppImage.verifiedIcon,
                          height:
                              size.height * 3 / 100, // smaller, looks balanced
                          width: size.width * 5 / 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        
              SizedBox(
                height: MediaQuery.of(context).size.height * 1 / 100,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 6 / 100,
                  decoration: BoxDecoration(
                    color: AppColor.textfieldcontainercolor, // background color
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColor.grayColor.withOpacity(0.4), // shadow color
                        // spreadRadius: 1,
                        blurRadius: 2, // blur effect
                        offset: Offset(1, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                      top: Radius.circular(26),
                    ),
                  ),
                  child: CustomTextFieldInput(
                    hintText: AppLanguage.enteremailidText[language],
                    maxLength: AppConstant.mobileMaxLenth,
                    keyboardType: TextInputType.name,
                    controller: emailController,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Email text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    child: Text(
                      AppLanguage.mobileNumberText[language],
                      style: TextStyle(
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
                            color: AppColor.primaryColor,
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 2 / 100),
                        Image.asset(
                          AppImage.verifiedIcon,
                          height:
                              size.height * 3 / 100, // smaller, looks balanced
                          width: size.width * 5 / 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 6 / 100,
                  decoration: BoxDecoration(
                    color: AppColor.textfieldfillColor, // background color
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColor.grayColor.withOpacity(0.4), // shadow color
                        // spreadRadius: 1,
                        blurRadius: 2, // blur effect
                        offset: Offset(1, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                      top: Radius.circular(26),
                    ),
                  ),
                  child: CustomTextFieldInput(
                    hintText: AppLanguage.mobileNumberText[language],
                    maxLength: AppConstant.mobileMaxLenth,
                    keyboardType: TextInputType.name,
                    controller: mobileNumberTextEditingController,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              SizedBox(
                width: MediaQuery.of(context).size.width * 87 / 100,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLanguage.genderText[language],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFont.fontFamily,
                      color: AppColor.textcolor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 1 / 100),
        
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 6 / 100,
                  decoration: BoxDecoration(
                    color: AppColor.textfieldfillColor, // background color
                    boxShadow: [
                      BoxShadow(
                        color:
                            AppColor.grayColor.withOpacity(0.4), // shadow color
                        // spreadRadius: 1,
                        blurRadius: 2, // blur effect
                        offset: Offset(1, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                      top: Radius.circular(26),
                    ),
                  ),
                  child: CustomTextFieldInput(
                    hintText: AppLanguage.enterGendertext[language],
                    maxLength: AppConstant.mobileMaxLenth,
                    keyboardType: TextInputType.name,
                    controller: genderController,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 4 / 100),
            ],
          ),
        ),
      ),
    );
  }
}
