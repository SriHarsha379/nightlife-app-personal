// // ignore_for_file: non_constant_identifier_names

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:night_life/utilities/app_footer.dart';
// import 'package:night_life/view/other/city_Preference/badge_screen.dart';
// import 'package:night_life/view/other/city_Preference/music_genres.dart';
// import 'package:night_life/view/other/city_Preference/party_preference.dart';

// import '../../utilities/app_button.dart';
// import '../../utilities/app_color.dart';
// import '../../utilities/app_constant.dart';
// import '../../utilities/app_font.dart';
// import '../../utilities/app_header.dart';
// import '../../utilities/app_image.dart';
// import '../../utilities/app_language.dart';

// import '../../utilities/widgets.dart';

// class UploadIDScreen extends StatefulWidget {
//   const UploadIDScreen({super.key});
//   static String routeName = './UploadIDScreen';
//   @override
//   State<UploadIDScreen> createState() => _UploadIDScreenState();
// }

// class _UploadIDScreenState extends State<UploadIDScreen> {
//   File? _imageSelect;
//   // var base64Image;
//   // var fileName;
//   // late File _image;
//   int reportId = 0;
//   String location = "";
//   String locationDetails = "NA";

//   String imageController = "NA";

//   TextEditingController NameTextEditingController = TextEditingController();

//   TextEditingController emailTextEditingController = TextEditingController();
//   TextEditingController vehicletypecontroller = TextEditingController();
//   TextEditingController mobileNumberTextEditingController =
//       TextEditingController();

//   String selectLocation = "NA";

//   bool _isUploadidFocused = false;
//   final FocusNode _uploadidFocusNode = FocusNode();
//   @override
//   void initState() {
//     super.initState();
// _uploadidFocusNode.addListener(() {
//     setState(() {
//       _isUploadidFocused = _uploadidFocusNode.hasFocus;
//     });
//   });  }

//   // editProfileUserValidation(
//   //   String firstName,
//   //   String lastName,
//   //   String email,
//   //   String mobileNumber,
//   // ) async {
//   //   if (firstName.isEmpty) {
//   //     SnackBarToastMessage.showSnackBar(
//   //         context, AppLanguage.firstNameMessage[language]);
//   //     return false;
//   //   } else if (lastName.isEmpty) {
//   //     SnackBarToastMessage.showSnackBar(
//   //         context, AppLanguage.lastNameMessage[language]);
//   //     return false;
//   //   } else if (email.isEmpty) {
//   //     SnackBarToastMessage.showSnackBar(
//   //         context, AppLanguage.emailMessage[language]);
//   //     return false;
//   //   } else if (!AppConstant.emailValidatorRegExp.hasMatch(email)) {
//   //     SnackBarToastMessage.showSnackBar(
//   //         context, AppLanguage.emailValidMessage[language]);
//   //     return false;
//   //   } else if (mobileNumber.isEmpty) {
//   //     SnackBarToastMessage.showSnackBar(
//   //         context, AppLanguage.mobileNumberMessage[language]);
//   //     return false;
//   //   } else if (mobileNumber.length < 10) {
//   //     SnackBarToastMessage.showSnackBar(
//   //         context, AppLanguage.mobilevalidMessage[language]);
//   //     return false;
//   //   } else if (selectLocation == "NA") {
//   //     SnackBarToastMessage.showSnackBar(
//   //         context, AppLanguage.selectLoction[language]);
//   //     return false;
//   //   } else {
//   //     editProfileUserApiCall(
//   //       firstName,
//   //       lastName,
//   //       email,
//   //       mobileNumber,
//   //     );
//   //   }
//   // }
//   List report = [
//     {'text': 'Driving License'},
//     {'text': 'Passport'},
//     {
//       'text': 'Identification Card',
//     },
//     {'text': 'Insurance'},
//     {'text': 'Vehicle Registeration Certificate'},
//   ];

//   // editProfileUserApiCall(
//   //   String firstName,
//   //   String lastName,
//   //   String email,
//   //   String mobileNumber,
//   // ) {
//   //   Navigator.push(
//   //     context,
//   //     MaterialPageRoute(builder: (context) => const Profile()),
//   //   );
//   //   // print("Call Update Api");
//   // }

//   // Future<void> _imgFromCamera() async {
//   //   dynamic image = await ImagePicker().pickImage(
//   //       source: ImageSource.camera,
//   //       maxHeight: 450.0,
//   //       maxWidth: 450.0,
//   //       imageQuality: 50);

//   //   if (image != null) {
//   //     Future.delayed(const Duration(seconds: 2), () {
//   //       setState(() {
//   //         _imageSelect = File(image!.path);
//   //         fileName = image.path.split('/').last;
//   //         // var _btnActive = true;
//   //       });
//   //     });
//   //   } else {
//   //     setState(() {
//   //       // var _btnActive = false;
//   //     });
//   //   }

//   //   // Navigator.of(context).pop();
//   // }

//   // Future<void> _imgFromGallery() async {
//   //   // ignore: deprecated_member_use
//   //   dynamic image = await ImagePicker().pickImage(
//   //       source: ImageSource.gallery,
//   //       maxHeight: 450.0,
//   //       maxWidth: 450.0,
//   //       imageQuality: 50);

//   //   if (image != null) {
//   //     Future.delayed(const Duration(seconds: 2), () {
//   //       setState(() {
//   //         _imageSelect = File(image!.path);
//   //         fileName = image.path.split('/').last;
//   //         var _btnActive = true;
//   //       });
//   //     });
//   //   } else {
//   //     setState(() {
//   //       var _btnActive = false;
//   //     });
//   //   }

//   //   Navigator.of(context).pop();
//   // }

//   @override
//   void dispose() {
//       _uploadidFocusNode.dispose();

//     super.dispose();
//   }

//   TextEditingController messageTextEditingController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//         statusBarColor: AppColor.secondryColor,
//         statusBarIconBrightness: Brightness.dark));
//     return GestureDetector(
//       onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
//       child: Scaffold(
//         backgroundColor: AppColor.secondryColor,
//         body: SafeArea(
//           child: Container(
//             width: MediaQuery.of(context).size.width * 100 / 100,
//             height: MediaQuery.of(context).size.height * 100 / 100,
//             decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
//             child: Column(
//               children: [
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 5 / 100,
//                 ),
//                 // AppHeader(
//                 //   text: AppLanguage.profilesetupText[language],
//                 //   onPress: () => Navigator.pop(context),
//                 // ),

//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Container(
//                           width: MediaQuery.of(context).size.width * 90 / 100,
//                           child: Column(
//                             children: [
//                               Column(
//                                 children: [
//                                   Center(
//                                     child: Text(
//                                       AppLanguage.uploadIDText[language],
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 36,
//                                         color: AppColor.secondryColor,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         2 /
//                                         100,
//                                   ),
//                                   Center(
//                                     child: Align(
//                                       alignment: Alignment.center,
//                                       child: Text(
//                                         textAlign: TextAlign.center,
//                                         AppLanguage.uploadIdStatement[language],
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.w400,
//                                           fontSize: 18,
//                                           color: AppColor.secondryColor,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         2 /
//                                         100,
//                                   ),
//                                   Center(
//                                     child: SizedBox(
//                                       width: MediaQuery.of(context).size.width *
//                                           90 /
//                                           100,
//                                       height:
//                                           MediaQuery.of(context).size.height *
//                                               7 /
//                                               100,
//                                       child: TextFormField(
//                                         style: const TextStyle(
//                                             color: AppColor.secondryColor),
//                                         keyboardType: TextInputType.name,
//                                         cursorColor: AppColor.secondryColor,
//                                         controller: NameTextEditingController,
//                                                                         focusNode: _uploadidFocusNode,

//                                         maxLength: AppConstant.fullNameText,
//                                         decoration: InputDecoration(
//                                           suffixIcon: Padding(
//                                             // width: 2,
//                                             padding: EdgeInsets.only(right: 22),
//                                             child: Image.asset(
//                                               AppImage.downArrowicon,
//                                               width: MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   2 /
//                                                   100,
//                                               height: MediaQuery.of(context)
//                                                       .size
//                                                       .width *
//                                                   1 /
//                                                   100,
//                                               color: AppColor.greyLightColor,
//                                             ),
//                                           ),
//                                           suffixIconConstraints:
//                                               const BoxConstraints(
//                                             minWidth: 32,
//                                             minHeight: 10,
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(40),
//                                             borderSide: const BorderSide(
//                                               color: AppColor.buttonColor,
//                                               width: 0,
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(40),
//                                             borderSide: const BorderSide(
//                                               color: AppColor.buttonColor,
//                                               width: 1.5,
//                                             ),
//                                           ),
//                                           fillColor: _isUploadidFocused
//                                               ? AppColor.primaryColor
//                                               : AppColor.themeColor,
//                                           filled: true,
//                                           counterText: '',
//                                           hintText:
//                                               AppLanguage.idProoftext[language],
//                                           hintStyle:
//                                               AppConstant.textFilledStyle,
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                             horizontal: 30,
//                                             vertical: 15,
//                                           ),
//                                         ),
//                                         onTap: () {
//                                           // cancelRideBottomSheet(context);
//                                         },
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         2 /
//                                         100,
//                                   ),
//                                   Center(
//                                     child: Image.asset(
//                                       AppImage.uploadDoc,
//                                       width: MediaQuery.of(context).size.width *
//                                           90 /
//                                           100,
//                                       height:
//                                           MediaQuery.of(context).size.width *
//                                               90 /
//                                               100,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         2 /
//                                         100,
//                                   ),
//                                   AppButton(
//                                       text: AppLanguage.continueText[language],
//                                       onPress: () {
//                                         // editProfileUserValidation(
//                                         //     firstNameTextEditingController.text,
//                                         //     lastNameTextEditingController.text,
//                                         //     emailTextEditingController.text,
//                                         //     mobileNumberTextEditingController.text);
//                                         Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   MusicGenresScreen()),
//                                         );
//                                       }),
//                                   SizedBox(
//                                     height: MediaQuery.of(context).size.height *
//                                         2 /
//                                         100,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  
// }
