// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:night_life/view/other/block_user_screen.dart';
import 'package:night_life/utilities/page_transition.dart';
import '../../controller/my_profile/my_visibility_controller.dart';
import '../../provider/user_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import 'change_password_screen.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool isSelected = true;
  String socialType = '';
  List<bool> switches = [
    false,
    false,
  ];
  int selectedRadioIndex = -1;
  bool broadenedSwitch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyVisibilityController>(context, listen: false)
          .fetchMyVisibility(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibilityController = Provider.of<MyVisibilityController>(context);
    final userController = Provider.of<UserController>(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor(context),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light));

    final size = MediaQuery.of(context).size;
    socialType = userController.getLoginType.toString();
    final normalizedSocialType = socialType.trim().toLowerCase();
    final isSocialLogin =
        normalizedSocialType == "google" || normalizedSocialType == "apple";
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        color: AppColor.primaryColor(context),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 5 / 100),
              AppHeader(
                onPress: () => Navigator.pop(context),
                text: AppLanguage.privacyPolicyText[language],
              ),
              SizedBox(height: size.height * 1 / 100),

              // /// --- Visibility Section Heading ---
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 17.0),
              //   child: Text(
              //     AppLanguage.visibilityText[language],
              //     textAlign: TextAlign.left,
              //     style: TextStyle(
              //       fontFamily: AppFont.fontFamily,
              //       fontSize: 18,
              //       fontWeight: FontWeight.w700,
              //       color: AppColor.secondryColor(context),
              //     ),
              //   ),
              // ),

              // /// --- Visibility Container ---
              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              //   margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              //   decoration: BoxDecoration(
              //     color: AppColor.notificationContainerColor(context),
              //     borderRadius: BorderRadius.circular(8),
              //     boxShadow: [
              //       BoxShadow(
              //         color: AppColor.primaryColor(context),
              //         spreadRadius: 3,
              //         blurRadius: 7,
              //         offset: Offset(0, 1),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             AppLanguage.showMeonText[language],
              //             style: TextStyle(
              //               color: AppColor.secondryColor(context),
              //               fontSize: 15,
              //               fontFamily: AppFont.fontFamily,
              //               fontWeight: FontWeight.w500,
              //               height: 1.0,
              //             ),
              //           ),
              //           Transform.scale(
              //             scale: 0.80,
              //             child: CupertinoSwitch(
              //               value: visibilityController.myVisibility,
              //               onChanged: visibilityController.isUpdating
              //                   ? null
              //                   : (value) async {
              //                       await visibilityController
              //                           .updateMyVisibility(
              //                         context,
              //                         value: value,
              //                       );
              //                     },
              //               activeColor: AppColor.pinkColor,
              //               thumbColor: Colors.white,
              //               trackColor: AppColor.toggleColor(context),
              //             ),
              //           ),
              //         ],
              //       ),
              //       Text(
              //         AppLanguage.allowOthersText[language],
              //         style: TextStyle(
              //           color: AppColor.notificationtextColor(context),
              //           fontSize: 14,
              //           fontFamily: AppFont.fontFamily,
              //           fontWeight: FontWeight.w400,
              //           height: 0,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
                child: Text(
                  AppLanguage.blockedUsersText[language],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: AppFont.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColor.secondryColor(context),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: BlockUserScreen(),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColor.notificationContainerColor(context),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor(context),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: size.width * 2 / 100),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLanguage.blockedUsersText[language],
                            style: TextStyle(
                              color: AppColor.secondryColor(context),
                              fontSize: 16,
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: size.width * 8 / 100,
                            width: size.width * 9 / 100,
                            child: Image.asset(
                              AppImage.frontArrowIcon,
                              fit: BoxFit.contain,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
              //   child: Text(
              //     AppLanguage.locationSharingText[language],
              //     textAlign: TextAlign.left,
              //     style: TextStyle(
              //       fontFamily: AppFont.fontFamily,
              //       fontSize: 18,
              //       fontWeight: FontWeight.w700,
              //       color: AppColor.secondryColor(context),
              //     ),
              //   ),
              // ),

              // Container(
              //   height: size.height * 6 / 100,
              //   width: size.width * 94 / 100,
              //   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              //   margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              //   decoration: BoxDecoration(
              //     color: AppColor.notificationContainerColor(context),
              //     borderRadius: BorderRadius.circular(8),
              //     boxShadow: [
              //       BoxShadow(
              //         color: AppColor.primaryColor(context),
              //         spreadRadius: 3,
              //         blurRadius: 7,
              //         offset: const Offset(0, 1),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         AppLanguage.managePermissionsText[language],
              //         style: TextStyle(
              //           color: AppColor.secondryColor(context),
              //           fontSize: 16,
              //           fontFamily: AppFont.fontFamily,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       ),
              //       SizedBox(
              //         height: size.width * 8 / 100,
              //         width: size.width * 9 / 100,
              //         child: Image.asset(
              //           AppImage.frontArrowIcon,
              //           fit: BoxFit.contain,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              if (!isSocialLogin)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.dataAndsecurity[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),

              // Container(
              //   height: size.height * 7 / 100,
              //   width: size.width * 94 / 100,
              //   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              //   margin: const EdgeInsets.symmetric(
              //     horizontal: 10,
              //   ),
              //   decoration: BoxDecoration(
              //     color: AppColor.notificationContainerColor(context),
              //     borderRadius: BorderRadius.circular(8),
              //     boxShadow: [
              //       BoxShadow(
              //         color: AppColor.primaryColor(context),
              //         spreadRadius: 3,
              //         blurRadius: 7,
              //         offset: const Offset(0, 1),
              //       ),
              //     ],
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         AppLanguage.downloadDatatext[language],
              //         style: TextStyle(
              //           color: AppColor.secondryColor(context),
              //           fontSize: 16,
              //           fontFamily: AppFont.fontFamily,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       ),
              //       SizedBox(
              //         height: size.width * 8 / 100,
              //         width: size.width * 9 / 100,
              //         child: Image.asset(
              //           AppImage.frontArrowIcon,
              //           fit: BoxFit.contain,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              if (!isSocialLogin)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: ChangePasswordScreen(),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  child: Container(
                    height: size.height * 7 / 100,
                    width: size.width * 94 / 100,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.notificationContainerColor(context),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor(context),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguage.changePasswordText[language],
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 16,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: size.width * 8 / 100,
                          width: size.width * 9 / 100,
                          child: Image.asset(
                            AppImage.frontArrowIcon,
                            fit: BoxFit.contain,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
            ],
          ),
        ),
      ),
    );
  }
}



















// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/foundation.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:night_life/view/other/block_user_screen.dart';
// import 'package:night_life/utilities/page_transition.dart';
// import '../../controller/my_profile/my_visibility_controller.dart';
// import '../../utilities/app_color.dart';
// import '../../utilities/app_constant.dart';
// import '../../utilities/app_font.dart';
// import '../../utilities/app_header.dart';
// import '../../utilities/app_image.dart';
// import '../../utilities/app_language.dart';
// import 'change_password_screen.dart';

// class PrivacySecurityScreen extends StatefulWidget {
//   const PrivacySecurityScreen({Key? key}) : super(key: key);

//   @override
//   State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
// }

// class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
//   bool isSelected = true;
//   List<bool> switches = [
//     false,
//     false,
//   ];
//   int selectedRadioIndex = -1;
//   bool broadenedSwitch = false;
//   final Map<Permission, PermissionStatus> _permissionStatuses = {};

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<MyVisibilityController>(context, listen: false)
//           .fetchMyVisibility(context);
//       _loadPermissionStatuses();
//     });
//   }

//   List<Map<String, dynamic>> get _permissionItems {
//     final items = <Map<String, dynamic>>[
//       {'label': 'Location', 'permission': Permission.locationWhenInUse},
//       {'label': 'Camera', 'permission': Permission.camera},
//       {'label': 'Microphone', 'permission': Permission.microphone},
//       {'label': 'Notifications', 'permission': Permission.notification},
//     ];

//     if (defaultTargetPlatform == TargetPlatform.iOS) {
//       items.add({'label': 'Photos', 'permission': Permission.photos});
//     } else {
//       items.add({'label': 'Storage', 'permission': Permission.storage});
//     }
//     return items;
//   }

//   Future<void> _loadPermissionStatuses() async {
//     final next = <Permission, PermissionStatus>{};
//     for (final item in _permissionItems) {
//       final permission = item['permission'] as Permission;
//       next[permission] = await permission.status;
//     }
//     if (!mounted) return;
//     setState(() {
//       _permissionStatuses
//         ..clear()
//         ..addAll(next);
//     });
//   }

//   String _permissionStatusText(PermissionStatus? status) {
//     if (status == null) return 'Unknown';
//     if (status.isGranted) return 'Allowed';
//     if (status.isPermanentlyDenied || status.isRestricted) {
//       return "Don't Allow";
//     }
//     if (status.isDenied) return 'Not Allowed';
//     if (status.isLimited) return 'Limited';
//     return 'Not Allowed';
//   }

//   Future<void> _requestPermission(Permission permission) async {
//     final status = await permission.status;
//     if (status.isPermanentlyDenied || status.isRestricted) {
//       await openAppSettings();
//       await _loadPermissionStatuses();
//       return;
//     }
//     await permission.request();
//     await _loadPermissionStatuses();
//   }

//   Future<void> _showManagePermissionSheet() async {
//     await _loadPermissionStatuses();
//     if (!mounted) return;

//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColor.notificationContainerColor(context),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (sheetContext) {
//         return StatefulBuilder(
//           builder: (context, setSheetState) {
//             return SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       AppLanguage.managePermissionsText[language],
//                       style: TextStyle(
//                         color: AppColor.secondryColor(context),
//                         fontFamily: AppFont.fontFamily,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     ..._permissionItems.map((item) {
//                       final permission = item['permission'] as Permission;
//                       final label = item['label'] as String;
//                       final status = _permissionStatuses[permission];

//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 10),
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: AppColor.primaryColor(context),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     label,
//                                     style: TextStyle(
//                                       color: AppColor.secondryColor(context),
//                                       fontFamily: AppFont.fontFamily,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 2),
//                                   Text(
//                                     _permissionStatusText(status),
//                                     style: TextStyle(
//                                       color: AppColor.notificationtextColor(
//                                           context),
//                                       fontFamily: AppFont.fontFamily,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () async {
//                                 await _requestPermission(permission);
//                                 setSheetState(() {});
//                               },
//                               child: Text('Allow'),
//                             ),
//                             TextButton(
//                               onPressed: () async {
//                                 await openAppSettings();
//                                 await _loadPermissionStatuses();
//                                 setSheetState(() {});
//                               },
//                               child: Text("Don't Allow"),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final visibilityController = Provider.of<MyVisibilityController>(context);
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//         systemNavigationBarColor: AppColor.primaryColor(context),
//         systemNavigationBarIconBrightness: Brightness.light,
//         statusBarBrightness: Brightness.dark,
//         statusBarColor: AppColor.primaryColor(context),
//         statusBarIconBrightness: Brightness.light));

//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: Container(
//         width: size.width,
//         height: size.height,
//         color: AppColor.primaryColor(context),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: size.height * 5 / 100),
//               AppHeader(
//                 onPress: () => Navigator.pop(context),
//                 text: AppLanguage.privacyPolicyText[language],
//               ),
//               SizedBox(height: size.height * 2 / 100),

//               /// --- Visibility Section Heading ---
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 17.0),
//                 child: Text(
//                   AppLanguage.visibilityText[language],
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontFamily: AppFont.fontFamily,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: AppColor.secondryColor(context),
//                   ),
//                 ),
//               ),

//               /// --- Visibility Container ---
//               Container(
//                 padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                 margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: AppColor.notificationContainerColor(context),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: AppColor.primaryColor(context),
//                       spreadRadius: 3,
//                       blurRadius: 7,
//                       offset: Offset(0, 1),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           AppLanguage.showMeonText[language],
//                           style: TextStyle(
//                             color: AppColor.secondryColor(context),
//                             fontSize: 15,
//                             fontFamily: AppFont.fontFamily,
//                             fontWeight: FontWeight.w500,
//                             height: 1.0,
//                           ),
//                         ),
//                         Transform.scale(
//                           scale: 0.80,
//                           child: CupertinoSwitch(
//                             value: visibilityController.myVisibility,
//                             onChanged: visibilityController.isUpdating
//                                 ? null
//                                 : (value) async {
//                                     await visibilityController
//                                         .updateMyVisibility(
//                                       context,
//                                       value: value,
//                                     );
//                                   },
//                             activeColor: AppColor.pinkColor,
//                             thumbColor: Colors.white,
//                             trackColor: AppColor.toggleColor(context),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Text(
//                       AppLanguage.allowOthersText[language],
//                       style: TextStyle(
//                         color: AppColor.notificationtextColor(context),
//                         fontSize: 14,
//                         fontFamily: AppFont.fontFamily,
//                         fontWeight: FontWeight.w400,
//                         height: 0,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
//                 child: Text(
//                   AppLanguage.blockedUsersText[language],
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontFamily: AppFont.fontFamily,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: AppColor.secondryColor(context),
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     PageTransition(
//                       type: PageTransitionType.rightToLeftWithFade,
//                       child: BlockUserScreen(),
//                       duration: const Duration(milliseconds: 500),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: AppColor.notificationContainerColor(context),
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColor.primaryColor(context),
//                         spreadRadius: 3,
//                         blurRadius: 7,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(width: size.width * 2 / 100),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             AppLanguage.blockedUsersText[language],
//                             style: TextStyle(
//                               color: AppColor.secondryColor(context),
//                               fontSize: 16,
//                               fontFamily: AppFont.fontFamily,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           SizedBox(
//                             height: size.width * 8 / 100,
//                             width: size.width * 9 / 100,
//                             child: Image.asset(
//                               AppImage.frontArrowIcon,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
//                 child: Text(
//                   AppLanguage.locationSharingText[language],
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontFamily: AppFont.fontFamily,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: AppColor.secondryColor(context),
//                   ),
//                 ),
//               ),

//               GestureDetector(
//                 onTap: _showManagePermissionSheet,
//                 child: Container(
//                   height: size.height * 6 / 100,
//                   width: size.width * 94 / 100,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: AppColor.notificationContainerColor(context),
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColor.primaryColor(context),
//                         spreadRadius: 3,
//                         blurRadius: 7,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         AppLanguage.managePermissionsText[language],
//                         style: TextStyle(
//                           color: AppColor.secondryColor(context),
//                           fontSize: 16,
//                           fontFamily: AppFont.fontFamily,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       SizedBox(
//                         height: size.width * 8 / 100,
//                         width: size.width * 9 / 100,
//                         child: Image.asset(
//                           AppImage.frontArrowIcon,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 17.0, vertical: 10),
//                 child: Text(
//                   AppLanguage.dataAndsecurity[language],
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     fontFamily: AppFont.fontFamily,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: AppColor.secondryColor(context),
//                   ),
//                 ),
//               ),

//               // Container(
//               //   height: size.height * 7 / 100,
//               //   width: size.width * 94 / 100,
//               //   padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//               //   margin: const EdgeInsets.symmetric(
//               //     horizontal: 10,
//               //   ),
//               //   decoration: BoxDecoration(
//               //     color: AppColor.notificationContainerColor(context),
//               //     borderRadius: BorderRadius.circular(8),
//               //     boxShadow: [
//               //       BoxShadow(
//               //         color: AppColor.primaryColor(context),
//               //         spreadRadius: 3,
//               //         blurRadius: 7,
//               //         offset: const Offset(0, 1),
//               //       ),
//               //     ],
//               //   ),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       Text(
//               //         AppLanguage.downloadDatatext[language],
//               //         style: TextStyle(
//               //           color: AppColor.secondryColor(context),
//               //           fontSize: 16,
//               //           fontFamily: AppFont.fontFamily,
//               //           fontWeight: FontWeight.w400,
//               //         ),
//               //       ),
//               //       SizedBox(
//               //         height: size.width * 8 / 100,
//               //         width: size.width * 9 / 100,
//               //         child: Image.asset(
//               //           AppImage.frontArrowIcon,
//               //           fit: BoxFit.contain,
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),

//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     PageTransition(
//                       type: PageTransitionType.rightToLeftWithFade,
//                       child: ChangePasswordScreen(),
//                       duration: const Duration(milliseconds: 500),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   height: size.height * 7 / 100,
//                   width: size.width * 94 / 100,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColor.notificationContainerColor(context),
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: AppColor.primaryColor(context),
//                         spreadRadius: 3,
//                         blurRadius: 7,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         AppLanguage.changePasswordText[language],
//                         style: TextStyle(
//                           color: AppColor.secondryColor(context),
//                           fontSize: 16,
//                           fontFamily: AppFont.fontFamily,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       SizedBox(
//                         height: size.width * 8 / 100,
//                         width: size.width * 9 / 100,
//                         child: Image.asset(
//                           AppImage.frontArrowIcon,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
