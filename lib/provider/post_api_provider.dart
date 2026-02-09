// ignore_for_file: avoid_print, use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../utilities/app_config_provider.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_footer.dart';
import '../utilities/app_snack_bar_toast_message.dart';
import '../view/authentication/otp_verify_screen.dart';
import '../view/other/city_Preference/citypreference_screen.dart';
import '../view/other/city_Preference/music_genres.dart';
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
        AppConstant.token = res['data']['token'] ?? '12345';
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        TopNotification.success(context, res['message'][language]);

        // Extract user data
        final userData = res['data']['user'];
        bool isEmailVerified = userData['isEmailVerified'] ?? false;
        bool isProfileCompleted = userData['isProfileCompleted'] ?? false;

        // Navigation logic
        if (isProfileCompleted) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => WoroAppFooter(),
          //   ),
          // );
        } else if (isEmailVerified && !isProfileCompleted) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => const ProfileSetupScreen(),
          //   ),
          // );
        } else {}
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

    final res = await postJsonData(
      'auth/signup_step_one',
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
        // AppConstant.token = res['data']['token'] ?? '12345';
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
        await CacheHelper.save("user_details", jsonEncode(result['data']));
        TopNotification.success(context, result['message'][language]);

        setLoading(false);

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: const MyAppFooter(initialIndex: 0),
          ),
        );

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

  forgotPasswordApiCalling(
    BuildContext context,
    String email,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      'email': email.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/forgot_send_otp',
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

      // Get.to(() => ForgotOtpScreen(email: email));
    }
    setLoading(false);
  }

  // ---------------forgot Otp Verification -----------
  forgotOtpVerificationApiCalling(
    BuildContext context,
    String otp,
    String email,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      'otp': otp.toString(),
      'email': email.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/forgot_verify_otp',
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
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        // Get.to(() => CreateNewPasswordScreen(
        //       email: email,
        //     ));
      }
    }

    setLoading(false);
  }

//=============== Resend FORGOT Otp Api=================//

  forgotResendotpApiCalling(
    BuildContext context,
    String email,
  ) async {
    setSecondaryLoading(true);

    final Map<String, String> fields = {
      'email': email.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/forgot_pass_resend_otp',
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

  // ---------------chnage password api -----------
  chnagePasswordApiCalling(
    BuildContext context,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    setLoading(true);

    final Map<String, String> fields = {
      "currentPassword": currentPassword.toString(),
      "newPassword": newPassword.toString(),
      "confirmPassword": confirmPassword.toString()
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/change_password',
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
    String fullName,
    String email,
    String mobile,
    String bio,
    XFile? profileImage,
  ) async {
    setLoading(true);

    String clubIdsString = favouriteClub.join(',');

    Map<String, String> fields = {
      'fullName': fullName,
      'email': email,
      'bio': bio,
      'mobile': mobile,
      'favourite_clubs': clubIdsString,
    };

    Map<String, XFile>? files;
    if (profileImage != null) {
      files = {'profileImage': profileImage};
    }

    final res = await postMultipartData(
      'auth/update_profile',
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
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => const WoroAppFooter(
      //             initialIndex: 4,
      //           )),
      //   (route) => false,
      // );
    }
    setLoading(false);
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

    Provider.of<UserController>(context, listen: false).reset();

    AppContentCache().clear();

    AppConstant.token = '';
    setSecondaryLoading(false);

    if (res != null && res['success'] == true) {
      TopNotification.success(context, res['message'][language]);
    }

    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (_) => const Login()),
    //   (_) => false,
    // );
  }

// ================Create Post Api================//
  createPostApi(
    BuildContext context, {
    required bool isPop,
    required String postType, // 'text' | 'image' | 'video' | 'poll'
    required String description,
    String? clubId,
    XFile? image,
    XFile? video,
    XFile? videoThumbnail,
    String? pollQuestion,
    List<String>? pollOptions,
    bool allowMultiple = false,
  }) async {
    setLoading(true);

    try {
      // Determine postFor and clubId based on isPop
      String postFor = isPop ? 'club' : 'user';

      // Validation: clubId is required when posting for club
      if (isPop && (clubId == null || clubId.isEmpty)) {
        TopNotification.error(context, "Club ID is required for club posts");
        setLoading(false);
        return null;
      }

      // Create multipart request
      final Uri url =
          Uri.parse("${AppConfigProvider.apiUrl}service/create_post");
      print('Create Post URL: $url');

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['authorization'] = 'Bearer ${AppConstant.token}';

      // Add fields
      Map<String, String> fields = {
        'postFor': postFor,
        'postType': postType.toLowerCase(),
      };

      // Add clubId only if posting for club
      if (isPop && clubId != null) {
        fields['clubId'] = clubId;
      }

      // Add description for text, image, and video posts
      if (postType.toLowerCase() != 'poll') {
        fields['description'] = description;
      }

      // Add poll-specific fields
      if (postType.toLowerCase() == 'poll') {
        if (pollQuestion != null) {
          fields['question'] = pollQuestion;
        }
        if (pollOptions != null && pollOptions.isNotEmpty) {
          fields['options'] = jsonEncode(pollOptions);
        }
        fields['allowMultiple'] = allowMultiple.toString();
      }

      request.fields.addAll(fields);
      print("Create Post Fields: $fields");

      // Handle image upload
      if (postType.toLowerCase() == 'image' && image != null) {
        List<int> imageBytes = await image.readAsBytes();
        String fileName = image.path.split('/').last;
        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
        );
        request.files.add(imageFile);
        print("Image file added: $fileName");
      }

      // Handle video and thumbnail upload with correct MIME type
      if (postType.toLowerCase() == 'video') {
        if (video != null) {
          List<int> videoBytes = await video.readAsBytes();
          String videoFileName = video.path.split('/').last;

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
            'video',
            videoBytes,
            filename: videoFileName,
            contentType: http_parser.MediaType.parse(mimeType),
          );
          request.files.add(videoFile);
          print("Video file added: $videoFileName (MIME: $mimeType)");
        }

        if (videoThumbnail != null) {
          List<int> thumbnailBytes = await videoThumbnail.readAsBytes();
          String thumbnailFileName = videoThumbnail.path.split('/').last;
          http.MultipartFile thumbnailFile = http.MultipartFile.fromBytes(
            'video_thumbnail',
            thumbnailBytes,
            filename: thumbnailFileName,
            contentType: http_parser.MediaType.parse('image/png'),
          );
          request.files.add(thumbnailFile);
          print("Thumbnail file added: $thumbnailFileName");
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

      // if (result != null && result['success'] == true) {
      //   TopNotification.success(context, result['message'][language]);
      //   if (!isPop) {
      //     Provider.of<HomeController>(context, listen: false)
      //         .getHomePosts(refresh: true);

      //     Provider.of<GetMyProfileController>(context, listen: false).reset();
      //     setLoading(false);

      //     Get.offAll(() => const WoroAppFooter(initialIndex: 0));
      //     return result;
      //   } else {
      //     setLoading(false);
      //     Get.off(() => ClubDetails(
      //           clubId: clubId!,
      //         ));
      //     return result;
      //   }
      // }

      setLoading(false);
      return null;
    } catch (e) {
      print("Create Post Error: $e");
      TopNotification.error(context, "Failed to create post");
      setLoading(false);
      return null;
    }
  }

// ================Edit Post Api================//
  editPostApi(
    BuildContext context, {
    required String postId,
    required String postType, // 'text' | 'image' | 'video' | 'poll'
    required String description,
    XFile? image,
    XFile? video,
    XFile? videoThumbnail,
    String? pollQuestion,
    List<String>? pollOptions,
    bool allowMultiple = false,
    bool removeImage = false,
    bool removeVideo = false,
    bool? isPop,
    String? clubid,
    String? type,
  }) async {
    setLoading(true);

    try {
      // Create multipart request
      final Uri url = Uri.parse("${AppConfigProvider.apiUrl}service/edit_post");
      print('Edit Post URL: $url');

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['authorization'] = 'Bearer ${AppConstant.token}';

      // Add fields
      Map<String, String> fields = {
        'postId': postId,
      };

      // Add description for text, image, and video posts
      if (postType.toLowerCase() != 'poll') {
        fields['description'] = description;
      }

      // Add poll-specific fields
      if (postType.toLowerCase() == 'poll') {
        if (pollQuestion != null) {
          fields['question'] = pollQuestion;
        }
        if (pollOptions != null && pollOptions.isNotEmpty) {
          fields['options'] = jsonEncode(pollOptions);
        }
        fields['allowMultiple'] = allowMultiple.toString();
      }

      request.fields.addAll(fields);
      print("Edit Post Fields: $fields");

      // Handle NEW image upload
      if (postType.toLowerCase() == 'image' && image != null) {
        List<int> imageBytes = await image.readAsBytes();
        String fileName = image.path.split('/').last;
        http.MultipartFile imageFile = http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
        );
        request.files.add(imageFile);
        print("New image file added: $fileName");
      }

      // Handle NEW video and thumbnail upload
      if (postType.toLowerCase() == 'video') {
        if (video != null) {
          List<int> videoBytes = await video.readAsBytes();
          String videoFileName = video.path.split('/').last;

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
            'video',
            videoBytes,
            filename: videoFileName,
            contentType: http_parser.MediaType.parse(mimeType),
          );
          request.files.add(videoFile);
          print("New video file added: $videoFileName (MIME: $mimeType)");
        }

        if (videoThumbnail != null) {
          try {
            List<int> thumbnailBytes = await videoThumbnail.readAsBytes();
            String thumbnailFileName;

            // Check if thumbnail has a path (from gallery) or is created from bytes
            if (videoThumbnail.path.isNotEmpty &&
                (videoThumbnail.path.endsWith('.jpg') ||
                    videoThumbnail.path.endsWith('.jpeg') ||
                    videoThumbnail.path.endsWith('.png'))) {
              thumbnailFileName = videoThumbnail.path.split('/').last;
            } else {
              // If it's created from bytes, give it a proper name
              thumbnailFileName =
                  'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
            }

            http.MultipartFile thumbnailFile = http.MultipartFile.fromBytes(
              'video_thumbnail',
              thumbnailBytes,
              filename: thumbnailFileName,
              contentType: http_parser.MediaType.parse('image/jpeg'),
            );
            request.files.add(thumbnailFile);
            print(
                "New thumbnail file added: $thumbnailFileName (${thumbnailBytes.length} bytes)");
          } catch (e) {
            print("Error adding thumbnail file: $e");
          }
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

      // if (result != null && result['success'] == true) {
      //   TopNotification.success(context, result['message'][language]);

      //   Provider.of<HomeController>(context, listen: false)
      //       .getHomePosts(refresh: true);

      //   Provider.of<GetMyProfileController>(context, listen: false)
      //       .getMyProfilePosts(refresh: true);
      //   setLoading(false);
      //   if (type == "Home") {
      //     Get.offAll(() => const WoroAppFooter(initialIndex: 0));
      //   } else {
      //     isPop == true
      //         ? Get.off(() => ClubDetails(
      //               clubId: clubid!,
      //             ))
      //         : Get.offAll(() => const WoroAppFooter(initialIndex: 4));
      //     setLoading(false);

      //     return result;
      //   }
      // }

      setLoading(false);
      return null;
    } catch (e) {
      print("Edit Post Error: $e");
      TopNotification.error(context, "Failed to edit post");
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
      'deleteReason': message.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'auth/delete_account',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      await CacheHelper.clearAll();
      AppConstant.token = '';
      AppConstant.selectFooterIndex = 0;
      AppContentCache().clear();

      if (!context.mounted) return;

      setLoading(false);

      if (res != null && res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
      }

      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => const Login()),
      //   (route) => false,
      // );
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
