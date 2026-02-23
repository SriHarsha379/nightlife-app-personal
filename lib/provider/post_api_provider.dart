// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../animation/purple_screen.dart';
import '../controller/home/home_controller.dart';
import '../controller/my_profile/get_my_profile.dart';
import '../controller/my_profile/get_my_swipe_profile_controller.dart';
import '../utilities/app_config_provider.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_footer.dart';
import '../utilities/app_snack_bar_toast_message.dart';
import '../view/authentication/login_screen.dart';
import '../view/authentication/otp_verify_screen.dart';
import '../view/other/city_Preference/citypreference_screen.dart';
import '../view/other/city_Preference/music_genres.dart';
import '../view/other/city_Preference/stay_connected_otp_verification.dart';
import '../view/other/city_Preference/stay_connected_screen.dart';
import 'common_api_helper.dart';
import 'common_sharedpreferences.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

import 'user_controller.dart';

class PostApiProvider with ChangeNotifier {
  bool _loading = false;
  bool _secondaryLoading = false;
  bool get loading => _loading;
  bool get secondaryLoading => _secondaryLoading;
  List<String> favouriteClub = [];
  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void setSecondaryLoading(bool value) {
    _secondaryLoading = value;
    notifyListeners();
  }

  void _clearSessionState(BuildContext context) {
    Provider.of<UserController>(context, listen: false).reset();
    Provider.of<HomeController>(context, listen: false).clearAllData();
    Provider.of<ProfileController>(context, listen: false).clearProfileData();
    Provider.of<GetMySwipeProfileController>(context, listen: false)
        .resetState();
    AppContentCache().clear();
    AppConstant.selectFooterIndex = 0;
  }

  // =============Login Api=================//
  loginUserApiCall(BuildContext context, String email, String password) async {
    setLoading(true);

    Map<String, String> fields = {
      'email': email.toString(),
      "password": password.toString(),
      'player_id': AppConstant.playerID.toString(),
      'device_type': AppConstant.deviceType,
    };
    log("fields$fields");
    final res = await postJsonData('auth/login', fields, context);

    if (res != null) {
      if (res['success'] == true) {
        final data = res['data'] ?? <String, dynamic>{};
        AppConstant.token = data['token'] ?? '12345';
        await CacheHelper.save("user_details", jsonEncode(data));
        TopNotification.success(context, res['message'][language]);

        final dynamic userData =
            (data is Map && data['user'] is Map) ? data['user'] : data;

        if (userData is! Map) {
          setLoading(false);
          return;
        }

        final bool isVerified =
            userData['is_verified'] ?? userData['isEmailVerified'] ?? false;
        final bool isProfileCompleted = userData['is_profile_completed'] ??
            userData['isProfileCompleted'] ??
            false;
        final bool isAnotherEmailVerify =
            userData['is_another_email_verify'] == true;
        final String anotherEmail =
            (userData['another_email'] ?? '').toString();

        int signupStep = 0;
        final dynamic stepValue = userData['signup_step'];
        if (stepValue is int) {
          signupStep = stepValue;
        } else if (stepValue is String) {
          signupStep = int.tryParse(stepValue) ?? 0;
        }

        if (!context.mounted) {
          setLoading(false);
          return;
        }

        // Ensure old user's in-memory state never flashes for the new session.
        _clearSessionState(context);
        Provider.of<UserController>(context, listen: false)
            .setUserFromMap(Map<String, dynamic>.from(userData));

        // If additional email OTP is pending after step 3, go to stay-connected OTP.
        if (signupStep >= 3 &&
            anotherEmail.trim().isNotEmpty &&
            !isAnotherEmailVerify) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: StayConnectedOTPVerify(
                isEmail: true,
                email: anotherEmail,
              ),
              duration: const Duration(milliseconds: 400),
            ),
          );
        } else if (isProfileCompleted) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: const MyAppFooter(initialIndex: 0),
              duration: const Duration(milliseconds: 400),
            ),
          );
        } else if (signupStep >= 3) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: StayConnectedScreen(),
              duration: const Duration(milliseconds: 400),
            ),
          );
        } else if (signupStep == 1 && isVerified) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: CityPreference(),
              duration: const Duration(milliseconds: 400),
            ),
          );
        } else if (signupStep == 2) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: const MusicGenresScreen(),
              duration: const Duration(milliseconds: 400),
            ),
          );
        } else if (signupStep == 1 && !isVerified) {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: OtpVerify(
                mobile: userData['phone_number']?.toString() ?? '',
              ),
              duration: const Duration(milliseconds: 400),
            ),
          );
        }
      }
    }
    setLoading(false);
  }

  // ================Signup Api================//
  signupUserApi(
    BuildContext context,
    String name,
    String lastName,
    String userName,
    String email,
    String mobile,
    String password,
    String dob,
    String gender,
    String height,
    String cityId,
    XFile? profileImage,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      'first_name': name.toString(),
      'last_name': lastName.toString(),
      'username': userName.toString(),
      'email': email.toString(),
      'phone_number': mobile.toString(),
      'password': password.toString(),
      'dob': dob.toString(),
      'gender': gender.toString(),
      'height': height.toString(),
      'city_id': cityId.toString(),
      'player_id': AppConstant.playerID.toString(),
      "device_type": AppConstant.deviceType
    };

    print("Line 105 $fields");

    Map<String, XFile>? files;
    if (profileImage != null) {
      files = {'profile_image': profileImage};
    }

    final res = await postMultipartData(
      'auth/signup_step_one',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
      files: files,
    );

    if (res != null) {
      if (!context.mounted) return;

      setLoading(false);

      if (res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
        AppConstant.token = res['data']['token'] ?? '12345';
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        TopNotification.success(context, res['message'][language]);

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: OtpVerify(
              mobile: mobile,
            ),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    }

    setLoading(false);
  }

  // --------------- Otp Verification -----------
  otpVerificationApiCalling(
    BuildContext context,
    String otp,
    String mobile,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      'phone_number': mobile.toString(),
      'otp': otp.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/otp_verify',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    print("Line 105 $fields");

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        setLoading(false);
        AppConstant.token = res['data']['token'] ?? '12345';
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        TopNotification.success(context, res['message'][language]);

        // Navigate to next screen
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: CityPreference(),
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    }

    setLoading(false);
  }

//=============== Resend Otp Api=================//

  resendotpApiCalling(
    BuildContext context,
  ) async {
    setSecondaryLoading(true);

    final Map<String, String> fields = {
      // 'phone_number': mobile.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/resend_otp',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        setSecondaryLoading(false);
        TopNotification.success(context, res['message'][language]);
      }
    }

    setSecondaryLoading(false);
  }

  // ================Signup Api================//
  signupStepTwoUserApi(
      BuildContext context,
      List<Map<String, dynamic>>? preferredCities,
      String bio,
      String instagramAccount,
      String spotify,
      String snapchat,
      List<String> hobbies) async {
    setLoading(true);

    final Map<String, dynamic> fields = {
      'preferred_cities': preferredCities ?? <Map<String, dynamic>>[],
      'bio': bio.toString(),
      'instagram_account': instagramAccount.toString(),
      'spotify_account': spotify.toString(),
      'snapchat_account': snapchat.toString(),
      'hobbies': hobbies,
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/signup_step_two',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      if (!context.mounted) return;

      setLoading(false);

      if (res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
        AppConstant.token = res['data']['token'] ?? '12345';
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        TopNotification.success(context, res['message'][language]);

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: const MusicGenresScreen(),
            duration: const Duration(milliseconds: 400),
          ),
        );
      }
    }

    setLoading(false);
  }

// ================Signup Step Three Api================//
  signupStepThreeUserApi(
    BuildContext context, {
    required String musicGenre,
    String? customMusicGenres,
    required String eventPreferences,
    String? customEventPreferences,
    required String vibes,
    String? customVibes,
    required List<Map<String, String>> vibeChecks,
    required String sexuality,
    required String interestedIn,
    required String pronouns,
    String? anotherEmail,
    required List<XFile> images,
    required List<XFile> videos,
    required List<XFile> thumbnails,
  }) async {
    setLoading(true);

    try {
      // Create multipart request
      final Uri url =
          Uri.parse("${AppConfigProvider.apiUrl}auth/signup_step_three");
      print('Signup Step Three URL: $url');

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['authorization'] = 'Bearer ${AppConstant.token}';

      // Add text fields
      Map<String, String> fields = {
        'music_genre': musicGenre,
        'event_preferences': eventPreferences,
        'vibes': vibes,
        'sexuality': sexuality,
        'interested_in': interestedIn,
        'pronouns': pronouns,
      };

      // Add optional fields
      if (customMusicGenres != null && customMusicGenres.isNotEmpty) {
        fields['custom_music_genres'] = customMusicGenres;
      }
      if (customEventPreferences != null && customEventPreferences.isNotEmpty) {
        fields['custom_event_preferences'] = customEventPreferences;
      }
      if (customVibes != null && customVibes.isNotEmpty) {
        fields['custom_vibes'] = customVibes;
      }
      if (anotherEmail != null && anotherEmail.isNotEmpty) {
        fields['another_email'] = anotherEmail;
      }

      // Add vibe_checks as JSON string
      fields['vibe_checks'] = jsonEncode(vibeChecks);

      request.fields.addAll(fields);
      print("Signup Step Three Fields: $fields");

      // Add images
      for (int i = 0; i < images.length; i++) {
        List<int> imageBytes = await images[i].readAsBytes();
        String fileName = images[i].path.split('/').last;
        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: fileName,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        );
        request.files.add(imageFile);
        print("Image ${i + 1} added: $fileName");
      }

      // Add videos and thumbnails
      for (int i = 0; i < videos.length; i++) {
        // Add video
        List<int> videoBytes = await videos[i].readAsBytes();
        String videoFileName = videos[i].path.split('/').last;

        // Get proper MIME type based on file extension
        String mimeType = 'video/mp4'; // default
        if (videoFileName.toLowerCase().endsWith('.mov')) {
          mimeType = 'video/quicktime';
        } else if (videoFileName.toLowerCase().endsWith('.avi')) {
          mimeType = 'video/x-msvideo';
        } else if (videoFileName.toLowerCase().endsWith('.mkv')) {
          mimeType = 'video/x-matroska';
        } else if (videoFileName.toLowerCase().endsWith('.webm')) {
          mimeType = 'video/webm';
        }

        http.MultipartFile videoFile = http.MultipartFile.fromBytes(
          'videos',
          videoBytes,
          filename: videoFileName,
          contentType: http_parser.MediaType.parse(mimeType),
        );
        request.files.add(videoFile);
        print("Video ${i + 1} added: $videoFileName (MIME: $mimeType)");

        // Add corresponding thumbnail
        if (i < thumbnails.length) {
          List<int> thumbnailBytes = await thumbnails[i].readAsBytes();
          String thumbnailFileName;

          if (thumbnails[i].path.isNotEmpty &&
              (thumbnails[i].path.endsWith('.jpg') ||
                  thumbnails[i].path.endsWith('.jpeg') ||
                  thumbnails[i].path.endsWith('.png'))) {
            thumbnailFileName = thumbnails[i].path.split('/').last;
          } else {
            thumbnailFileName =
                'thumbnail_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }

          http.MultipartFile thumbnailFile = http.MultipartFile.fromBytes(
            'thumbnails',
            thumbnailBytes,
            filename: thumbnailFileName,
            contentType: http_parser.MediaType.parse('image/jpeg'),
          );
          request.files.add(thumbnailFile);
          print("Thumbnail ${i + 1} added: $thumbnailFileName");
        }
      }

      print("request.fields: ${request.fields}");
      print(
          "request.files: ${request.files.map((f) => '${f.field}: ${f.filename}')}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Handle response
      final result = _handleStatusCode(response, context);

      if (result != null && result['success'] == true) {
        AppConstant.token = result['data']['token'] ?? '12345';
        await CacheHelper.save("user_details", jsonEncode(result['data']));
        TopNotification.success(context, result['message'][language]);

        setLoading(false);

        return result;
      }

      setLoading(false);
      return null;
    } catch (e) {
      print("Signup Step Three Error: $e");
      TopNotification.error(context, "Failed to complete signup");
      setLoading(false);
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyEmailOtpApiCalling(
    BuildContext context, {
    required String otp,
    String? email,
  }) async {
    setLoading(true);

    final Map<String, String> fields = {
      'otp': otp.trim(),
    };
    if (email != null && email.trim().isNotEmpty) {
      fields['another_email'] = email.trim();
    }

    final res = await postJsonData(
      'auth/verify_email_otp',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null && res['success'] == true) {
      final dynamic data = res['data'];
      if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        AppConstant.token = mapData['token'] ?? AppConstant.token;
        await CacheHelper.save("user_details", jsonEncode(mapData));
        if (context.mounted) {
          Provider.of<UserController>(context, listen: false)
              .setUserFromMap(mapData);
        }
      }
      if (context.mounted) {
        TopNotification.success(context, res['message'][language]);
      }
      setLoading(false);
      return res;
    }

    setLoading(false);
    return null;
  }

  Future<Map<String, dynamic>?> resendEmailOtpApiCalling(
    BuildContext context, {
    String? email,
  }) async {
    setSecondaryLoading(true);

    final Map<String, String> fields = {};
    if (email != null && email.trim().isNotEmpty) {
      fields['another_email'] = email.trim();
    }

    final res = await postJsonData(
      'auth/resend_email_otp',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null && res['success'] == true) {
      if (context.mounted) {
        TopNotification.success(context, res['message'][language]);
      }
      setSecondaryLoading(false);
      return res;
    }

    setSecondaryLoading(false);
    return null;
  }

  // ================setup profile Api================//
  setupProfileApi(
    BuildContext context,
    String bio,
    XFile? profileImage,
  ) async {
    setLoading(true);

    String clubIdsString = favouriteClub.join(',');

    Map<String, String> fields = {
      'bio': bio,
      'favourite_clubs': clubIdsString,
    };

    Map<String, XFile>? files;
    if (profileImage != null) {
      files = {'profileImage': profileImage};
    }

    final res = await postMultipartData(
      'auth/profile_setup',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
      files: files,
    );

    log("token: ${AppConstant.token}");
    log("favourite_clubs: $clubIdsString");

    if (res != null && res['success'] == true) {
      await CacheHelper.save("user_details", jsonEncode(res['data']));
      TopNotification.success(context, res['message'][language]);
      // Get.to(() => WoroAppFooter());
    }

    setLoading(false);
  }

//======================forgot password===============//

  Future<Map<String, dynamic>?> forgotPasswordApiCalling(
    BuildContext context, {
    String? email,
    String? phoneNumber,
  }) async {
    setLoading(true);

    final Map<String, String> fields = {};
    if (email != null && email.trim().isNotEmpty) {
      fields['email'] = email.trim();
    } else if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      fields['phone_number'] = phoneNumber.trim();
    } else {
      setLoading(false);
      return null;
    }

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/forgot_password',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      if (!context.mounted) return res;

      setLoading(false);

      if (res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
      }

      return res;
    }
    setLoading(false);
    return null;
  }

  // ---------------forgot Otp Verification -----------
  Future<Map<String, dynamic>?> forgotOtpVerificationApiCalling(
    BuildContext context, {
    required String otp,
    String? email,
    String? phoneNumber,
  }) async {
    setLoading(true);

    final Map<String, String> fields = {'otp': otp.toString()};
    if (email != null && email.trim().isNotEmpty) {
      fields['email'] = email.trim();
    } else if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      fields['phone_number'] = phoneNumber.trim();
    } else {
      setLoading(false);
      return null;
    }

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/verify_forgot_otp',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    print("Line 105 $fields");

    if (res != null) {
      if (res['success'] == true) {
        setLoading(false);

        AppConstant.token = res['data']['token'] ?? '12345';
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        TopNotification.success(context, res['message'][language]);
        return res;
      }
    }

    setLoading(false);
    return null;
  }

//=============== Resend FORGOT Otp Api=================//

  Future<Map<String, dynamic>?> forgotResendotpApiCalling(
    BuildContext context, {
    String? email,
    String? phoneNumber,
  }) async {
    setSecondaryLoading(true);

    final Map<String, String> fields = {};
    if (email != null && email.trim().isNotEmpty) {
      fields['email'] = email.trim();
    } else if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      fields['phone_number'] = phoneNumber.trim();
    } else {
      setSecondaryLoading(false);
      return null;
    }

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/resend_forgot_otp',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      if (res['success'] == true) {
        setSecondaryLoading(false);
        TopNotification.success(context, res['message'][language]);
        return res;
      }
    }

    setSecondaryLoading(false);
    return null;
  }

  // ---------------reset password api -----------
  resetPasswordApiCalling(
    BuildContext context,
    String newPassword,
    String email,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      'new_password': newPassword.toString(),
      'email': email.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/reset_password',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    print("Line 105 $fields");

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        setLoading(false);
        TopNotification.success(context, res['message'][language]);
        // Get.to(() => Login());
      }
    }
    setLoading(false);
  }

  // ---------------confirm forgot password api -----------
  Future<Map<String, dynamic>?> confirmPasswordApiCalling(
    BuildContext context, {
    required String newPassword,
  }) async {
    setLoading(true);

    final Map<String, String> fields = {
      'new_password': newPassword.trim(),
    };

    final res = await postJsonData(
      'auth/confirm_password',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null && res['success'] == true) {
      TopNotification.success(context, res['message'][language]);
      setLoading(false);
      return res;
    }

    setLoading(false);
    return null;
  }

  // ---------------chnage password api -----------
  chnagePasswordApiCalling(
    BuildContext context,
    String currentPassword,
    String newPassword,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      "old_password": currentPassword.toString(),
      "new_password": newPassword.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'user/change_password',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    print("Line 105 $fields");

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        TopNotification.success(context, res['message'][language]);
        Navigator.pop(
          context,
        );
      }
    }
    setLoading(false);
  }

  // ================Edit profile Api================//
  editProfileApi(
    BuildContext context,
    String firstName,
    String lastName,
    String userName,
    String bio,
    String email,
    String mobile,
    String gender,
    String cityId,
    XFile? profileImage,
  ) async {
    setLoading(true);

    Map<String, String> fields = {
      'first_name': firstName,
      'last_name': lastName,
      'username': userName,
      'gender': gender,
      'email': email,
      'bio': bio,
      'mobile': mobile,
      'city_id': cityId,
    };

    Map<String, XFile>? files;
    if (profileImage != null) {
      files = {'profile_image': profileImage};
    }

    final res = await postMultipartData(
      'user/edit_profile',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
      files: files,
    );

    log("token: ${AppConstant.token}");

    if (res != null && res['success'] == true) {
      await CacheHelper.save("user_details", jsonEncode(res['data']));
      AppConstant.token = res['data']['token'] ?? "123456";
      TopNotification.success(context, res['message'][language]);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MyAppFooter(
                  initialIndex: 4,
                )),
        (route) => false,
      );
    }
    setLoading(false);
  }

  // ================ Add Event Preferences Api ================//
  Future<bool> addEventPreferencesApi(
    BuildContext context, {
    String? eventPreferencesCsv,
    List<String>? eventPreferenceIds,
    List<String>? customEventPreferences,
  }) async {
    setLoading(true);

    final List<String> ids = (eventPreferenceIds ??
            (eventPreferencesCsv ?? '')
                .split(',')
                .map((id) => id.trim())
                .where((id) => id.isNotEmpty)
                .toList())
        .toSet()
        .toList();

    final Map<String, dynamic> fields = {
      'event_preferences': ids,
    };
    final List<String> custom = (customEventPreferences ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (custom.isNotEmpty) {
      fields['custom_event_preferences'] = custom;
    }
    print("addEventPreferences payload: $fields");

    final res = await postJsonData(
      'user/add_event_preferences',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    setLoading(false);

    if (res != null && res['success'] == true) {
      TopNotification.success(
          context, "Event Preferenece Updated Successfully");
      return true;
    }

    return false;
  }

  // ================ Add Vibes Api ================//
  Future<bool> addVibesApi(
    BuildContext context, {
    String? vibesCsv,
    List<String>? vibeIds,
  }) async {
    setLoading(true);

    final List<String> ids = (vibeIds ??
            (vibesCsv ?? '')
                .split(',')
                .map((id) => id.trim())
                .where((id) => id.isNotEmpty)
                .toList())
        .toSet()
        .toList();

    final Map<String, dynamic> fields = {
      'vibes': ids,
    };
    print("addVibes payload: $fields");

    final res = await postJsonData(
      'user/add_vibes',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    setLoading(false);

    if (res != null && res['success'] == true) {
      TopNotification.success(context, "Vibe Updated Successfully");
      return true;
    }

    return false;
  }

  // ================ Update Hobbies Api ================//
  Future<Map<String, dynamic>?> updateHobbiesApi(
    BuildContext context,
    List<String> hobbies,
  ) async {
    setLoading(true);

    final Map<String, dynamic> fields = {
      'hobbies': hobbies,
    };
    print("updateHobbies payload: $fields");

    final res = await postJsonData(
      'user/update_hobbies',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    setLoading(false);

    if (res != null && res['success'] == true) {
      if (context.mounted) {
        TopNotification.success(context, res['message'][language]);
      }
      if (res['data'] is Map) {
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        AppConstant.token = res['data']['token'] ?? "123456";
        TopNotification.success(context, res['message'][language]);
        if (context.mounted) {
          Provider.of<UserController>(context, listen: false)
              .setUserFromMap(Map<String, dynamic>.from(res['data']));
        }
      }
    }

    return res;
  }

  // ================ Delete Gallery Item Api ================//
  Future<Map<String, dynamic>?> deleteGalleryItemApi(
    BuildContext context,
    String url,
  ) async {
    setLoading(true);

    final Map<String, dynamic> fields = {
      'url': url,
    };
    print("deleteGalleryItem payload: $fields");

    final res = await postJsonData(
      'user/delete_gallery_item',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    setLoading(false);

    if (res != null && res['success'] == true) {
      if (context.mounted) {
        TopNotification.success(context, res['message']);
      }
    }

    return res;
  }



  // Booking Event API
  Future<Map<String, dynamic>?> bookingEventApi(
    BuildContext context, {
    required String eventId,
    required int numberOfGuests,
    required String transactionId,
    required num discount,
    required num allTicketsPrice,
    required num total,
    required String cityName,
    required String countryCode,
    required String phoneNumber,
    required String email,
    required String fullName,
    required List<dynamic> ticketList,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return null;
    setLoading(true);

    final Map<String, dynamic> fields = {
      "event_id": eventId.toString(),
      "ticket_id": ticketList
          .map((ticket) => {
                "_id": ticket["_id"],
                "count": ticket["count"],
                "base_price": ticket["base_price"],
                "total_price": ticket["total_price"],
                "title": ticket["title"],
                "isOneDay": ticket["isOneDay"] == 1 ||
                    ticket["isOneDay"] == true, // ✅ force bool
              })
          .toList(),
      "quantity": numberOfGuests,
      "transaction_id": transactionId.toString(),
      "booking_type": "event",
      "discount": discount,
      "sub_total": allTicketsPrice,
      "total": total,
      "country_code": countryCode.toString(),
      "phone_number": phoneNumber.toString(),
      "email": email.toString(),
      "full_name": fullName.toString(),
      "city_name": cityName
    };

    print(jsonEncode(fields));
    try {
      final response = await postJsonData(
        'booking/event_booking',
        fields,
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );
      log("bookingEventApi fields: $fields");
      return response;
    } catch (_) {
      return null;
    } finally {
      setLoading(false);
    }
  }





// ====================log out API=============//

  logOutApiCalling(BuildContext context) async {
    if (!context.mounted) return;

    setSecondaryLoading(true);

    final res = await postData(
      'auth/logout',
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    _clearSessionState(context);
    AppConstant.token = '';
    await CacheHelper.clearAll();
    setSecondaryLoading(false);

    if (res != null && res['success'] == true) {
      // TopNotification.success(context, res['message'][language]);
    }
  }

// ================Report Problem Api================//
  Future<Map<String, dynamic>?> reportProblemApi(
    BuildContext context, {
    required String description,
    required List<XFile> images,
    required List<XFile> videos,
    required List<XFile> thumbnails,
  }) async {
    setLoading(true);

    try {
      final Uri url =
          Uri.parse("${AppConfigProvider.apiUrl}user/report_problem");
      var request = http.MultipartRequest('POST', url);
      request.headers['authorization'] = 'Bearer ${AppConstant.token}';
      request.fields['description'] = description;

      for (final image in images) {
        final imageBytes = await image.readAsBytes();
        final fileName = image.path.split('/').last;
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes,
            filename: fileName,
            contentType: http_parser.MediaType.parse('image/jpeg'),
          ),
        );
      }

      for (final video in videos) {
        final videoBytes = await video.readAsBytes();
        final videoFileName = video.path.split('/').last;
        String mimeType = 'video/mp4';
        if (videoFileName.toLowerCase().endsWith('.mov')) {
          mimeType = 'video/quicktime';
        } else if (videoFileName.toLowerCase().endsWith('.avi')) {
          mimeType = 'video/x-msvideo';
        } else if (videoFileName.toLowerCase().endsWith('.mkv')) {
          mimeType = 'video/x-matroska';
        } else if (videoFileName.toLowerCase().endsWith('.webm')) {
          mimeType = 'video/webm';
        }

        request.files.add(
          http.MultipartFile.fromBytes(
            'videos',
            videoBytes,
            filename: videoFileName,
            contentType: http_parser.MediaType.parse(mimeType),
          ),
        );
      }

      for (final thumbnail in thumbnails) {
        final thumbnailBytes = await thumbnail.readAsBytes();
        final thumbName = thumbnail.path.split('/').last;
        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnails',
            thumbnailBytes,
            filename: thumbName,
            contentType: http_parser.MediaType.parse('image/jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final result = _handleStatusCode(response, context);

      if (result != null && result['success'] == true) {
        TopNotification.success(context,
            "Report submitted successfully.Our team will review it soon");
      }
      setLoading(false);
      return result;
    } catch (e) {
      print("Report Problem Error: $e");
      TopNotification.error(context, "Failed to submit problem report");
      setLoading(false);
      return null;
    }
  }

// Helper method to handle status codes (if not already in your code)
  Map<String, dynamic>? _handleStatusCode(
      http.Response response, BuildContext? context) {
    final statusCode = response.statusCode;

    try {
      final body = jsonDecode(response.body);

      // Success
      if (statusCode == 200) {
        return body;
      }

      String errorMessage = _getErrorMessage(body);

      if (statusCode == 400) {
        if (context != null) {
          TopNotification.error(context, errorMessage);
        }
        return null;
      }

      if (statusCode == 401 || statusCode == 403 || statusCode == 423) {
        if (context != null) {
          TopNotification.error(context, errorMessage);
        }
        return null;
      }

      if (statusCode == 500) {
        if (context != null) {
          TopNotification.error(
              context, "Server error. Please try again later.");
        }
        return null;
      }

      if (context != null) {
        TopNotification.error(context, errorMessage);
      }
      return null;
    } catch (e) {
      print("Error parsing response: $e");
      return null;
    }
  }

// Helper method to get error message
  String _getErrorMessage(dynamic body) {
    if (body == null) return "An error occurred";

    if (body['message'] != null) {
      if (body['message'] is List && body['message'].length > language) {
        return body['message'][language].toString();
      }
      if (body['message'] is Map && body['message'][language] != null) {
        return body['message'][language].toString();
      }
      return body['message'].toString();
    }

    return "An error occurred";
  }

  //============ contact us api===========//
  contactUsApiCalling(
    BuildContext context,
    String name,
    String email,
    String message,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      // 'full_name': name.toString(),
      // 'email': email.toString(),
      'description': message.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'common/send_messageTo_admin',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      if (!context.mounted) return;

      setLoading(false);

      if (res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
      }

      Navigator.pop(
        context,
      );
    }

    setLoading(false);
  }

//============ delete account api===========//
  deleteAccountApiCalling(
    BuildContext context,
    String message,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      'reason': message.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'user/delete_account',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      _clearSessionState(context);
      AppConstant.token = '';
      await CacheHelper.clearAll();
      if (!context.mounted) return;

      setLoading(false);

      if (res != null && res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
      }

      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: const PurpleScreen(
            nextScreen: LoginScreen(),
          ),
          duration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );
    }

    setLoading(false);
  }
}

//=======Content Screen Cache-----------

class AppContentCache {
  static final AppContentCache _instance = AppContentCache._internal();
  factory AppContentCache() => _instance;
  AppContentCache._internal();

  List<dynamic>? contentArr;

  void clear() {
    contentArr = null;
  }

  bool get hasData => contentArr != null && contentArr!.isNotEmpty;
}
