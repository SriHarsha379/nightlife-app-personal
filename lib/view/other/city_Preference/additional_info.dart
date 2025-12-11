// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/view/other/city_Preference/music_genres.dart';
import 'package:page_transition/page_transition.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_header.dart';
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
  File? _imageSelect;
  // var base64Image;
  // var fileName;
  // late File _image;
  int reportId = 0;
  String location = "";
  String locationDetails = "NA";

  String imageController = "NA";

  TextEditingController BioTextEditingController = TextEditingController();
  TextEditingController instagramTextEditingController =
      TextEditingController();

  TextEditingController spotifyTextEditingController = TextEditingController();
  TextEditingController snapchattexteditingController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();

  String selectLocation = "NA";

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isInstagramFocused = false;
  final FocusNode _instagramFocusNode = FocusNode();

  late FocusNode _spotifyFocusNode;
  late FocusNode _snapchatFocusNode;
  bool _isSpotifyFocused = false;
  bool _isSnapchatFocused = false;

  @override
  void initState() {
    super.initState();

    _instagramFocusNode.addListener(() {
      setState(() {
        _isInstagramFocused = _instagramFocusNode.hasFocus;
      });
    });

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _instagramFocusNode.dispose();
    _spotifyFocusNode.dispose();
    _snapchatFocusNode.dispose();
    super.dispose();
  }
  // editProfileUserValidation(
  //   String firstName,
  //   String lastName,
  //   String email,
  //   String mobileNumber,
  // ) async {
  //   if (firstName.isEmpty) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.firstNameMessage[language]);
  //     return false;
  //   } else if (lastName.isEmpty) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.lastNameMessage[language]);
  //     return false;
  //   } else if (email.isEmpty) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.emailMessage[language]);
  //     return false;
  //   } else if (!AppConstant.emailValidatorRegExp.hasMatch(email)) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.emailValidMessage[language]);
  //     return false;
  //   } else if (mobileNumber.isEmpty) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.mobileNumberMessage[language]);
  //     return false;
  //   } else if (mobileNumber.length < 10) {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.mobilevalidMessage[language]);
  //     return false;
  //   } else if (selectLocation == "NA") {
  //     SnackBarToastMessage.showSnackBar(
  //         context, AppLanguage.selectLoction[language]);
  //     return false;
  //   } else {
  //     editProfileUserApiCall(
  //       firstName,
  //       lastName,
  //       email,
  //       mobileNumber,
  //     );
  //   }
  // }
  // List report = [
  //   {'text': 'Driving License'},
  //   {'text': 'Passport'},
  //   {
  //     'text': 'Identification Card',
  //   },
  //   {'text': 'Insurance'},
  //   {'text': 'Vehicle Registeration Certificate'},
  // ];
  // List report1 = [
  //   {'text': 'Bike'},
  //   {'text': 'Car'},
  //   {
  //     'text': 'Van',
  //   },
  //   {'text': 'Truck'},
  // ];
  // editProfileUserApiCall(
  //   String firstName,
  //   String lastName,
  //   String email,
  //   String mobileNumber,
  // ) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const Profile()),
  //   );
  //   // print("Call Update Api");
  // }

  // Future<void> _imgFromCamera() async {
  //   dynamic image = await ImagePicker().pickImage(
  //       source: ImageSource.camera,
  //       maxHeight: 450.0,
  //       maxWidth: 450.0,
  //       imageQuality: 50);

  //   if (image != null) {
  //     Future.delayed(const Duration(seconds: 2), () {
  //       setState(() {
  //         _imageSelect = File(image!.path);
  //         fileName = image.path.split('/').last;
  //         // var _btnActive = true;
  //       });
  //     });
  //   } else {
  //     setState(() {
  //       // var _btnActive = false;
  //     });
  //   }

  //   // Navigator.of(context).pop();
  // }

  // Future<void> _imgFromGallery() async {
  //   // ignore: deprecated_member_use
  //   dynamic image = await ImagePicker().pickImage(
  //       source: ImageSource.gallery,
  //       maxHeight: 450.0,
  //       maxWidth: 450.0,
  //       imageQuality: 50);

  //   if (image != null) {
  //     Future.delayed(const Duration(seconds: 2), () {
  //       setState(() {
  //         _imageSelect = File(image!.path);
  //         fileName = image.path.split('/').last;
  //         var _btnActive = true;
  //       });
  //     });
  //   } else {
  //     setState(() {
  //       var _btnActive = false;
  //     });
  //   }

  //   Navigator.of(context).pop();
  // }

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
                                            style: TextStyle(
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
                              //           fontFamily: AppFont.fontFamily,
                              //           color: AppColor.buttonColor),
                              //     ),
                              //   ),
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
                                    38 /
                                    100,
                              ),
                              AppButton(
                                  text: AppLanguage.continueText[language],
                                  onPress: () {
                                    // editProfileUserValidation(
                                    //     firstNameTextEditingController.text,
                                    //     lastNameTextEditingController.text,
                                    //     emailTextEditingController.text,
                                    //     mobileNumberTextEditingController.text);
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: MusicGenresScreen(),
                                        duration:
                                            const Duration(milliseconds: 400),
                                      ),
                                    );
                                  }),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    2 /
                                    100,
                              ),
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: MusicGenresScreen(),
                                        duration:
                                            const Duration(milliseconds: 400),
                                      ),
                                    ); 
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      80 /
                                      100,
                                  child: Center(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      AppLanguage.skip[language],
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.textcolor,
                                      ),
                                    ),
                                  ),
                                ),
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
                        color: AppColor.secondryColor),
                    child: Column(
                      children: [
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 5 / 100),
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Container(
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
                                  // SizedBox(
                                  //   child: Text(
                                  //     AppLanguage.vehicleText[language], textAlign: TextAlign.center,
                                  //     style: TextStyle(
                                  //       fontSize: 12,
                                  //       decoration: TextDecoration.none,
                                  //       color: AppColor.primaryColor,
                                  //       fontFamily: AppFont.fontFamily,
                                  //       fontWeight: FontWeight.w500,
                                  //     ),
                                  //   ),
                                  // ),
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

  // void documenttypebottomsheet(BuildContext context) {
  //   showModalBottomSheet<void>(
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(),
  //     context: context,
  //     builder: (BuildContext context) {
  //       // String? tempSelected = selectedState;

  //       return StatefulBuilder(builder: (context, setStateBottomSheet) {
  //         return Container(
  //           width: MediaQuery.of(context).size.width * 100 / 100,
  //           height: MediaQuery.of(context).size.height * 40 / 100,
  //           color: Colors.transparent,
  //           child: Column(
  //             children: [
  //               Container(
  //                   width: MediaQuery.of(context).size.width * 100 / 100,
  //                   height: MediaQuery.of(context).size.height * 40 / 100,
  //                   decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.only(
  //                           topLeft: Radius.circular(46),
  //                           topRight: Radius.circular(46)),
  //                       color: AppColor.secondryColor),
  //                   child: Column(
  //                     children: [
  //                       SizedBox(
  //                           height:
  //                               MediaQuery.of(context).size.height * 5 / 100),
  //                       Expanded(
  //                         flex: 1,
  //                         child: SingleChildScrollView(
  //                           child: Container(
  //                             width:
  //                                 MediaQuery.of(context).size.width * 90 / 100,
  //                             child: Column(
  //                               children: [
  //                                 SizedBox(
  //                                   child: Text(
  //                                     AppLanguage
  //                                         .selectvehicleTypetext[language],
  //                                     style: TextStyle(
  //                                       fontSize: 18,
  //                                       decoration: TextDecoration.none,
  //                                       color: AppColor.primaryColor,
  //                                       fontFamily: AppFont.fontFamily,
  //                                       fontWeight: FontWeight.w600,
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 SizedBox(
  //                                     height:
  //                                         MediaQuery.of(context).size.height *
  //                                             1 /
  //                                             100),
  //                                 // SizedBox(
  //                                 //   child: Text(
  //                                 //     AppLanguage.vehicleText[language], textAlign: TextAlign.center,
  //                                 //     style: TextStyle(
  //                                 //       fontSize: 12,
  //                                 //       decoration: TextDecoration.none,
  //                                 //       color: AppColor.primaryColor,
  //                                 //       fontFamily: AppFont.fontFamily,
  //                                 //       fontWeight: FontWeight.w500,
  //                                 //     ),
  //                                 //   ),
  //                                 // ),
  //                                 SizedBox(
  //                                     height:
  //                                         MediaQuery.of(context).size.height *
  //                                             5 /
  //                                             100),
  //                                 Container(
  //                                   width: MediaQuery.of(context).size.width *
  //                                       90 /
  //                                       100,
  //                                   child: Column(
  //                                     children: [
  //                                       Wrap(
  //                                         runSpacing: 10,
  //                                         children: List.generate(
  //                                           report1.length,
  //                                           (index) => GestureDetector(
  //                                             onTap: () {
  //                                               setStateBottomSheet(() {
  //                                                 reportId = index;
  //                                               });
  //                                             },
  //                                             child: Row(
  //                                               children: [
  //                                                 Image.asset(
  //                                                   index == reportId
  //                                                       ? AppImage
  //                                                           .fillcircleIcon
  //                                                       : AppImage.circleIcon,
  //                                                   height:
  //                                                       MediaQuery.of(context)
  //                                                               .size
  //                                                               .width *
  //                                                           5 /
  //                                                           100,
  //                                                   width:
  //                                                       MediaQuery.of(context)
  //                                                               .size
  //                                                               .width *
  //                                                           5 /
  //                                                           100,
  //                                                 ),
  //                                                 SizedBox(
  //                                                     width:
  //                                                         MediaQuery.of(context)
  //                                                                 .size
  //                                                                 .width *
  //                                                             3 /
  //                                                             100),
  //                                                 SizedBox(
  //                                                   child: Text(
  //                                                     report1[index]['text'],
  //                                                     textAlign:
  //                                                         TextAlign.center,
  //                                                     style: TextStyle(
  //                                                       fontSize: 14,
  //                                                       decoration:
  //                                                           TextDecoration.none,
  //                                                       color: AppColor
  //                                                           .bottomsheettextcolor,
  //                                                       fontFamily:
  //                                                           AppFont.fontFamily,
  //                                                       fontWeight:
  //                                                           FontWeight.w500,
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       )
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 SizedBox(
  //                                     height:
  //                                         MediaQuery.of(context).size.height *
  //                                             3 /
  //                                             100),

  //                                 SizedBox(
  //                                     height:
  //                                         MediaQuery.of(context).size.height *
  //                                             3 /
  //                                             100),

  //                                 SizedBox(
  //                                     height:
  //                                         MediaQuery.of(context).size.height *
  //                                             1 /
  //                                             100),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   )),
  //             ],
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

  // Future<dynamic> getUserDetails() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   dynamic locationDetails = prefs.getString("locationDetails");

  //   print(locationDetails);
  //   if (locationDetails != null) {
  //     dynamic data = json.decode(locationDetails);
  //     location = data['location'];

  //     print(locationDetails);
  //     print(data['location']);
  //   }
  //   setState(() {});
  // }
}
