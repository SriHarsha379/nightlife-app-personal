// ignore_for_file: avoid_print, use_build_context_synchronously, curly_braces_in_flow_control_structures
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:night_life/utilities/page_transition.dart';

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
import '../utilities/session_manager.dart';
import '../view/authentication/login_screen.dart';
import '../view/authentication/otp_verify_screen.dart';
import '../view/other/city_Preference/citypreference_screen.dart';
import '../view/other/city_Preference/music_genres.dart';
import '../view/other/city_Preference/stay_connected_otp_verification.dart';
import '../view/other/city_Preference/stay_connected_screen.dart';
import '../view/other/profile_details.dart';
import 'common_api_helper.dart';
import 'common_sharedpreferences.dart';
import 'package:http_parser/http_parser.dart' as http_parser;

import 'package:firebase_auth/firebase_auth.dart';

import 'socket_provider.dart';
import 'user_controller.dart';

class PostApiProvider with ChangeNotifier {
  bool _loading = false;
  bool _secondaryLoading = false;
  bool get loading => _loading;
  bool get secondaryLoading => _secondaryLoading;
  List<String> favouriteClub = [];

  void setLoading(bool value) {
    if (_loading == value) return;
    _loading = value;
    notifyListeners();
  }

  void setSecondaryLoading(bool value) {
    if (_secondaryLoading == value) return;
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

  int _parseSignupStep(dynamic stepValue) {
    if (stepValue is int) return stepValue;
    if (stepValue is String) return int.tryParse(stepValue) ?? 0;
    return 0;
  }

  /// Generates a cryptographically random temporary password for social-login
  /// sign-ups (Google / Apple), where the user has not supplied a password.
  ///
  /// The result always satisfies the strong-password policy:
  ///   • At least 12 characters
  ///   • Contains uppercase, lowercase, digit and a special character
  ///
  /// The special character set is limited to URL-safe and form-safe characters
  /// (`@#$%&*!?^()_+-=`) to avoid conflicts with backend validation or HTTP
  /// encoding layers.
  ///
  /// **Security note**: this password is only used as a placeholder during the
  /// social-signup flow and is never shown to or set by the user. The backend
  /// should treat it as a transient credential.
  String _generateTemporarySocialPassword() {
    final random = Random.secure();
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const special = r'@#$%&*!?^()_+-=';
    const all = '$upper$lower$digits$special';

    final buffer = StringBuffer()
      ..write(upper[random.nextInt(upper.length)])
      ..write(lower[random.nextInt(lower.length)])
      ..write(digits[random.nextInt(digits.length)])
      ..write(special[random.nextInt(special.length)]);

    for (int i = 0; i < 8; i++) {
      buffer.write(all[random.nextInt(all.length)]);
    }
    final chars = buffer.toString().split('');
    chars.shuffle(random);
    return chars.join();
  }

  Map<String, dynamic> _extractUserData(dynamic data) {
    if (data is Map && data['user'] is Map) {
      return Map<String, dynamic>.from(data['user']);
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }

  // FIX: safe token extractor — never falls back to a hardcoded string.
  // '12345' / '123456' fallbacks were causing token corruption:
  // AppConstant.token would be set to '12345' + userId = '1234569bbbdc...'
  String _extractToken(dynamic data) {
    if (data == null) return '';
    if (data is Map) {
      final t = (data['token'] ?? '').toString().trim();
      if (t.isNotEmpty) return t;
      // Some responses nest token inside 'user'
      if (data['user'] is Map) {
        final t2 = (data['user']['token'] ?? '').toString().trim();
        if (t2.isNotEmpty) return t2;
      }
    }
    return '';
  }

  Future<void> _syncAuthSession(
      BuildContext context,
      dynamic authPayload,
      ) async {
    final authData = authPayload is Map
        ? Map<String, dynamic>.from(authPayload)
        : <String, dynamic>{};
    final userData =
    authData.isNotEmpty ? _extractUserData(authData) : <String, dynamic>{};

    // FIX: use safe extractor — no '12345' fallback
    final token = _extractToken(authData);
    final authUserId =
    (userData['_id'] ?? authData['_id'] ?? '').toString().trim();

    log('_syncAuthSession token=${token.isEmpty ? "EMPTY" : token.substring(0, token.length.clamp(0, 20))}... userId=$authUserId');

    if (!context.mounted) return;

    // Step 1 — clear old session state FIRST
    _clearSessionState(context);

    // Step 2 — save new user to cache and UserController BEFORE reconnecting
    // socket so ChatScreen reads the NEW user's id, not the old one.
    final cachePayload = authData.isNotEmpty ? authData : userData;
    await CacheHelper.save("user_details", jsonEncode(cachePayload));

    if (!context.mounted) return;
    if (userData.isNotEmpty) {
      Provider.of<UserController>(context, listen: false).setUserFromMap(
        Map<String, dynamic>.from(userData),
      );
    }

    // Step 3 — reconnect socket with new token AFTER user state is set.
    if (token.isNotEmpty) {
      AppConstant.token = token;
      final socketProvider =
      Provider.of<SocketProvider>(context, listen: false);
      await socketProvider.forceReconnect(token, authUserId: authUserId);
    }

    // Step 4 — sign into Firebase with custom token returned by backend.
    // Backend must return a 'firebase_token' field in the auth payload.
    // Generate it server-side: admin.auth().createCustomToken(userId)
    final firebaseToken = (authData['firebase_token'] ?? '').toString().trim();
    if (firebaseToken.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        log('_syncAuthSession Firebase sign-in success userId=$authUserId');
      } catch (e) {
        log('_syncAuthSession Firebase sign-in failed: $e');
      }
    }
  }

  void _navigateFromAuthState(
      BuildContext context,
      Map<String, dynamic> userData, {
        Map<String, dynamic>? socialUser,
        Duration footerDuration = const Duration(milliseconds: 500),
      }) {
    final bool isNewUser = userData['is_new_user'] == true;
    if (isNewUser && socialUser != null) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: ProfileDetailsScreen(
            mobile: userData['phone_number']?.toString(),
            screen: "social",
            socialUser: socialUser,
          ),
          duration: const Duration(milliseconds: 400),
        ),
      );
      return;
    }

    final bool isVerified =
        userData['is_verified'] ?? userData['isEmailVerified'] ?? false;
    final bool isProfileCompleted = userData['is_profile_completed'] ??
        userData['isProfileCompleted'] ??
        false;
    final bool isAnotherEmailVerify =
        userData['is_another_email_verify'] == true;
    final String anotherEmail = (userData['another_email'] ?? '').toString();
    final int signupStep = _parseSignupStep(userData['signup_step']);

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
          duration: footerDuration,
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

  Future<bool> _completeAuthSuccess(
      BuildContext context, {
        required dynamic authPayload,
        required String successMessage,
        Map<String, dynamic>? socialUser,
        bool showSuccessToast = true,
        Duration footerDuration = const Duration(milliseconds: 500),
      }) async {
    // A fresh, successful login means whatever session/user this device was
    // previously acting as is no longer relevant - force-clear any stuck
    // error banner (e.g. a lingering "User not found" from a since-deleted
    // account) so it can't survive into the new session.
    TopNotification.dispose();

    await _syncAuthSession(context, authPayload);
    if (!context.mounted) return false;

    final userData = _extractUserData(authPayload);
    if (userData.isEmpty) return false;

    if (showSuccessToast) {
      TopNotification.success(context, successMessage);
    }

    _navigateFromAuthState(
      context,
      userData,
      socialUser: socialUser,
      footerDuration: footerDuration,
    );
    return true;
  }

  // =============Login Api=================//
  Future<bool> loginUserApiCall(
      BuildContext context, String email, String password) async {
    if (_loading) return false;
    setLoading(true);

    Map<String, String> fields = {
      'email': email.toString().trim(),
      "password": password.toString(),
      'player_id': AppConstant.playerID.toString(),
      'device_type': AppConstant.deviceType,
    };
    log("fields$fields");
    final res = await postJsonData('auth/login', fields, context);

    if (res != null) {
      if (res['success'] == true) {
        final data = res['data'] ?? <String, dynamic>{};
        final didComplete = await _completeAuthSuccess(
          context,
          authPayload: data,
          successMessage: res['message'][language],
          footerDuration: const Duration(milliseconds: 400),
        );
        setLoading(false);
        return didComplete;
      }
    }
    setLoading(false);
    return false;
  }

  // =============social Api=================//
  socialLoginApiCalling(BuildContext context, user) async {
    setLoading(true);

    final String fullName =
    (user['full_name'] ?? user['name'] ?? '').toString();
    final String firstName = (user['first_name'] ?? '').toString().trim();
    final String lastName = (user['last_name'] ?? '').toString().trim();
    final List<String> fullNameParts = fullName.trim().split(' ');
    final String fallbackFirstName =
    fullNameParts.isNotEmpty ? fullNameParts.first : '';
    final String fallbackLastName =
    fullNameParts.length > 1 ? fullNameParts.sublist(1).join(' ') : '';

    Map<String, String> fields = {
      'socialType': (user['login_type'] ?? '').toString(),
      "social_id": (user['social_id'] ?? '').toString(),
      'email': (user['email'] ?? '').toString(),
      'first_name': firstName.isNotEmpty ? firstName : fallbackFirstName,
      'last_name': lastName.isNotEmpty ? lastName : fallbackLastName,
      'device_type': AppConstant.deviceType,
      'player_id': AppConstant.playerID.toString(),
    };
    log("fields$fields");
    final res = await postJsonData('auth/social_login', fields, context);

    if (res != null) {
      if (res['success'] == true) {
        final data = res['data'] ?? <String, dynamic>{};
        final userData = _extractUserData(data);
        final bool shouldShowSuccessToast = !(userData['is_new_user'] == true);
        await _completeAuthSuccess(
          context,
          authPayload: data,
          successMessage: res['message'][language],
          socialUser: Map<String, dynamic>.from(user),
          showSuccessToast: shouldShowSuccessToast,
        );
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
      String referalcode,
      String email,
      String mobile,
      String password,
      String dob,
      String gender,
      String height,
      String cityId,
      XFile? profileImage,
      {String loginType = 'email',
        bool isSocialSignup = false}) async {
    if (_loading) return;
    setLoading(true);

    final String trimmedPassword = password.toString().trim();

    final Map<String, String> fields = {
      'first_name': name.toString(),
      'last_name': lastName.toString(),
      'username': userName.toString().trim(),
      'email': email.toString().trim(),
      'phone_number': mobile.toString().trim(),
      'dob': dob.toString(),
      'gender': gender.toString(),
      'height': height.toString(),
      'city_id': cityId.toString(),
      'player_id': AppConstant.playerID.toString(),
      "device_type": AppConstant.deviceType,
      'login_type': loginType.toString(),
      'referral_code': referalcode.toString()
    };

    if (trimmedPassword.isNotEmpty) {
      fields['password'] = trimmedPassword;
    } else if (isSocialSignup) {
      fields['password'] = _generateTemporarySocialPassword();
    }

    Map<String, XFile>? files;
    if (profileImage != null) {
      files = {'profile_image': profileImage};
    }

    final res = await postMultipartData(
      'auth/signup_step_one',
      fields,
      context,
      files: files,
    );

    if (res != null) {
      if (!context.mounted) return;
      setLoading(false);

      if (res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
        await _syncAuthSession(context, res['data']);
        if (!context.mounted) return;
        final userData = _extractUserData(res['data']);

        if (isSocialSignup) {
          _navigateFromAuthState(context, userData);
        } else {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeftWithFade,
              child: OtpVerify(mobile: mobile),
              duration: const Duration(milliseconds: 500),
            ),
          );
        }
      }
    }

    setLoading(false);
  }

// --------------- Otp Verification -----------
  Future<bool> otpVerificationApiCalling(
      BuildContext context,
      String otp,
      String mobile,
      ) async {
    if (_loading) return false;
    setLoading(true);

    // Get the Firebase ID token from the currently signed-in user
    // (Firebase phone auth sign-in must have already succeeded before this is called)
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      setLoading(false);
      if (context.mounted) {
        TopNotification.error(context, "Verification session expired. Please try again.");
      }
      return false;
    }

    final String? firebaseIdToken = await firebaseUser.getIdToken();
    if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
      setLoading(false);
      // Keep Firebase and backend state in sync — sign out since we can't proceed
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        TopNotification.error(context, "Failed to verify. Please try again.");
      }
      return false;
    }

    final Map<String, String> fields = {
      'phone_number': mobile.toString(),
      'firebase_id_token': firebaseIdToken,
      'otp': otp,
    };

    final res = await postJsonData(
      'auth/otp_verify',
      fields,
      context,
    );

// TEMP DEBUG — remove after diagnosing
    log("OTP VERIFY REQUEST FIELDS: $fields");
    log("OTP VERIFY RESPONSE: $res");

    if (res != null && res['success'] == true && res['data'] != "NA") {
      setLoading(false);
      await _syncAuthSession(context, res['data']);
      if (!context.mounted) return true;
      TopNotification.success(context, res['message'][language]);
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: CityPreference(),
          duration: const Duration(milliseconds: 500),
        ),
      );
      return true;
    }

    // ── Backend verification failed ──
    // Firebase thinks the user is signed in, but the backend rejected it.
    // Sign out of Firebase to keep both sides in sync, so no other part of
    // the app later discovers this mismatch and silently redirects to login.
    setLoading(false);
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      final String errorMsg = (res != null &&
          res['message'] is List &&
          (res['message'] as List).isNotEmpty)
          ? res['message'][0].toString()
          : "OTP verification failed. Please try again.";
      TopNotification.error(context, errorMsg);
    }
    return false;
  }


  // ================ AI Chat Api ================//
  Future<Map<String, dynamic>?> sendChatMessageApi(
      BuildContext context,
      List<Map<String, String>> messages,
      ) async {
    if (_secondaryLoading) return null;
    setSecondaryLoading(true);

    final res = await postJsonData(
      'chat/send',
      {'messages': messages},
      context,
    );

    setSecondaryLoading(false);

    if (res != null && res['success'] == true) {
      return res;
    }

    if (context.mounted) {
      TopNotification.error(context, "Couldn't reach the assistant. Please try again.");
    }
    return null;
  }


  // =============== Resend Otp Api =================//
  Future<Map<String, dynamic>?> resendotpApiCalling(BuildContext context) async {
    if (_secondaryLoading) return null;
    setSecondaryLoading(true);

    final res = await postJsonData(
      'auth/resend_otp',
      {},
      context,
    );

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        setSecondaryLoading(false);
        TopNotification.success(context, res['message'][language]);
        return res;
      }
    }

    setSecondaryLoading(false);
    return null;
  }

  // ================Signup Step Two Api================//
  signupStepTwoUserApi(
      BuildContext context,
      List<Map<String, dynamic>>? preferredCities,
      String bio,
      String instagramAccount,
      String spotify,
      String snapchat,
      List<String> hobbies,
      int? status,
      ) async {
    setLoading(true);

    final Map<String, dynamic> fields = {
      'preferred_cities': preferredCities ?? <Map<String, dynamic>>[],
      'bio': bio.toString(),
      'instagram_account': instagramAccount.toString(),
      'spotify_account': spotify.toString(),
      'snapchat_account': snapchat.toString(),
      'hobbies': hobbies,
    };

    final res = await postJsonData(
      'auth/signup_step_two',
      fields,
      context,
    );

    if (res != null) {
      if (!context.mounted) return;
      setLoading(false);

      if (res['success'] == true) {
        if (status == 1) {
          TopNotification.success(context, res['message'][language]);
        }
        await _syncAuthSession(context, res['data']);
        if (!context.mounted) return;
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
      final Uri url =
      Uri.parse("${AppConfigProvider.apiUrl}auth/signup_step_three");

      var request = http.MultipartRequest('POST', url);
      request.headers['authorization'] = 'Bearer ${AppConstant.token}';

      Map<String, String> fields = {
        'music_genre': musicGenre,
        'event_preferences': eventPreferences,
        'vibes': vibes,
        'sexuality': sexuality,
        'interested_in': interestedIn,
        'pronouns': pronouns,
      };

      if (customMusicGenres != null && customMusicGenres.isNotEmpty)
        fields['custom_music_genres'] = customMusicGenres;
      if (customEventPreferences != null && customEventPreferences.isNotEmpty)
        fields['custom_event_preferences'] = customEventPreferences;
      if (customVibes != null && customVibes.isNotEmpty)
        fields['custom_vibes'] = customVibes;
      if (anotherEmail != null && anotherEmail.isNotEmpty)
        fields['another_email'] = anotherEmail.trim();

      fields['vibe_checks'] = jsonEncode(vibeChecks);
      request.fields.addAll(fields);

      for (int i = 0; i < images.length; i++) {
        final imageBytes = await images[i].readAsBytes();
        final fileName = images[i].path.split('/').last;
        request.files.add(http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: fileName,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        ));
      }

      for (int i = 0; i < videos.length; i++) {
        final videoBytes = await videos[i].readAsBytes();
        final videoFileName = videos[i].path.split('/').last;
        String mimeType = 'video/mp4';
        if (videoFileName.toLowerCase().endsWith('.mov'))
          mimeType = 'video/quicktime';
        else if (videoFileName.toLowerCase().endsWith('.avi'))
          mimeType = 'video/x-msvideo';
        else if (videoFileName.toLowerCase().endsWith('.mkv'))
          mimeType = 'video/x-matroska';
        else if (videoFileName.toLowerCase().endsWith('.webm'))
          mimeType = 'video/webm';

        request.files.add(http.MultipartFile.fromBytes(
          'videos',
          videoBytes,
          filename: videoFileName,
          contentType: http_parser.MediaType.parse(mimeType),
        ));

        if (i < thumbnails.length) {
          final thumbnailBytes = await thumbnails[i].readAsBytes();
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
          request.files.add(http.MultipartFile.fromBytes(
            'thumbnails',
            thumbnailBytes,
            filename: thumbnailFileName,
            contentType: http_parser.MediaType.parse('image/jpeg'),
          ));
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final result = _handleStatusCode(response, context);

      if (result != null && result['success'] == true) {
        await _syncAuthSession(context, result['data']);
        if (!context.mounted) return null;
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

    final Map<String, String> fields = {'otp': otp.trim()};
    if (email != null && email.trim().isNotEmpty) {
      fields['another_email'] = email.trim();
    }

    final res = await postJsonData(
      'auth/verify_email_otp',
      fields,
      context,
    );

    if (res != null && res['success'] == true) {
      final dynamic data = res['data'];
      if (data is Map) {
        await _syncAuthSession(context, Map<String, dynamic>.from(data));
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

  // ===================== forgot password =====================//
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

    final res = await postJsonData(
      'auth/forgot_password',
      fields,
      context,
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

    final res = await postJsonData(
      'auth/verify_forgot_otp',
      fields,
      context,
    );

    if (res != null && res['success'] == true) {
      setLoading(false);
      // FIX: use safe extractor — never fall back to '12345'
      final token = _extractToken(res['data'] ?? {});
      if (token.isNotEmpty) {
        AppConstant.token = token;
      }
      await CacheHelper.save("user_details", jsonEncode(res['data']));
      TopNotification.success(context, res['message'][language]);
      return res;
    }

    setLoading(false);
    return null;
  }

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

    final res = await postJsonData(
      'auth/resend_forgot_otp',
      fields,
      context,
    );

    if (res != null && res['success'] == true) {
      setSecondaryLoading(false);
      TopNotification.success(context, res['message'][language]);
      return res;
    }

    setSecondaryLoading(false);
    return null;
  }

  resetPasswordApiCalling(
      BuildContext context,
      String newPassword,
      String email,
      ) async {
    setLoading(true);

    final res = await postJsonData(
      'auth/reset_password',
      {'new_password': newPassword.toString(), 'email': email.toString()},
      context,
    );

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        setLoading(false);
        TopNotification.success(context, res['message'][language]);
      }
    }
    setLoading(false);
  }

  Future<Map<String, dynamic>?> confirmPasswordApiCalling(
      BuildContext context, {
        required String newPassword,
      }) async {
    setLoading(true);

    final res = await postJsonData(
      'auth/confirm_password',
      {'new_password': newPassword.trim()},
      context,
    );

    if (res != null && res['success'] == true) {
      TopNotification.success(context, res['message'][language]);
      setLoading(false);
      return res;
    }

    setLoading(false);
    return null;
  }

  chnagePasswordApiCalling(
      BuildContext context,
      String currentPassword,
      String newPassword,
      ) async {
    setLoading(true);

    final res = await postJsonData(
      'user/change_password',
      {
        "old_password": currentPassword.toString(),
        "new_password": newPassword.toString(),
      },
      context,
    );

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        TopNotification.success(context, res['message'][language]);
        Navigator.pop(context);
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
      String instagramAccount,
      String snapchatAccount,
      String spotifyAccount,
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
      'instagram_account': instagramAccount,
      'snapchat_account': snapchatAccount,
      'spotify_account': spotifyAccount,
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
      files: files,
    );

    log("token: ${AppConstant.token}");

    if (res != null && res['success'] == true) {
      await CacheHelper.save("user_details", jsonEncode(res['data']));
      // FIX: use safe extractor — never fall back to '123456'
      final newToken = _extractToken(res['data'] ?? {});
      if (newToken.isNotEmpty) {
        AppConstant.token = newToken;
      }
      final authUserId = (res['data']?['_id'] ?? '').toString().trim();
      Provider.of<SocketProvider>(context, listen: false)
          .setToken(AppConstant.token, authUserId: authUserId);
      TopNotification.success(context, res['message'][language]);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const MyAppFooter(initialIndex: 4)),
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

    final Map<String, dynamic> fields = {'event_preferences': ids};
    final List<String> custom = (customEventPreferences ?? [])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (custom.isNotEmpty) {
      fields['custom_event_preferences'] = custom;
    }

    final res = await postJsonData(
      'user/add_event_preferences',
      fields,
      context,
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

    final res = await postJsonData(
      'user/add_vibes',
      {'vibes': ids},
      context,
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

    final res = await postJsonData(
      'user/update_hobbies',
      {'hobbies': hobbies},
      context,
    );

    setLoading(false);

    if (res != null && res['success'] == true) {
      if (context.mounted) {
        TopNotification.success(context, res['message'][language]);
      }
      if (res['data'] is Map) {
        await CacheHelper.save("user_details", jsonEncode(res['data']));
        // FIX: safe token extraction
        final newToken = _extractToken(res['data'] ?? {});
        if (newToken.isNotEmpty) AppConstant.token = newToken;
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

    final res = await postJsonData(
      'user/delete_gallery_item',
      {'url': url},
      context,
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
        "isOneDay":
        ticket["isOneDay"] == 1 || ticket["isOneDay"] == true,
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
      "city_name": cityName,
    };

    try {
      final response = await postJsonData(
        'booking/event_booking',
        fields,
        context,
        headers: {'authorization': 'Bearer $token'},
      );
      log("bookingEventApi fields: $fields");
      return response;
    } catch (_) {
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ==================== log out API ====================//
  logOutApiCalling(BuildContext context) async {
    if (!context.mounted) return;

    setSecondaryLoading(true);
    final String logoutToken = AppConstant.token;

    // FIX: disconnect() clears _activeSocketToken + _authUserId properly
    Provider.of<SocketProvider>(context, listen: false).disconnect();
    // Fire and forget logout — bypass common_api_helper
    if (logoutToken.trim().isNotEmpty) {
      http.post(
        Uri.parse('${AppConfigProvider.apiUrl}auth/logout'),
        headers: {
          'authorization': 'Bearer $logoutToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).catchError((_) => http.Response('' , 0));
    }
    AppConstant.token = '';

    _clearSessionState(context);
    await Provider.of<UserController>(context, listen: false)
        .clearSelectedSearchLocation(notify: false);
    await SessionManager.clearAuthSession(
      signOutFromFirebase: true,
      clearAllPreferences: true,
    );
    setSecondaryLoading(false);
  }

  // --------------- check Number -----------
  checkNumberApiCalling(BuildContext context, String mobile) async {
    if (_loading) return;
    setLoading(true);

    final res = await postJsonData(
      'auth/check_phone_number',
      {'phone_number': mobile.toString()},
      context,
    );

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        setLoading(false);
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: ProfileDetailsScreen(mobile: mobile),
            duration: const Duration(milliseconds: 600),
          ),
        );
      }
    }

    setLoading(false);
  }

  // ================Report Problem Api================//
  Future<Map<String, dynamic>?> reportProblemApi(
      BuildContext context, {
        required String description,
        required List<XFile> images,
        required List<XFile> videos,
        required List<XFile> thumbnails,
      }) async {
    final trimmedDescription = description.trim();
    final totalMedia = images.length + videos.length;
    if (trimmedDescription.isEmpty) {
      TopNotification.error(context, "Please enter description");
      return null;
    }
    if (totalMedia > 6) {
      TopNotification.error(context, "You can upload up to 6 media files only");
      return null;
    }

    setLoading(true);

    try {
      final Uri url =
      Uri.parse("${AppConfigProvider.apiUrl}user/report_problem");
      var request = http.MultipartRequest('POST', url);
      request.headers['authorization'] = 'Bearer ${AppConstant.token}';
      request.fields['description'] = trimmedDescription;

      for (final image in images) {
        final fileName = image.path.split('/').last;
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          image.path,
          filename: fileName,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        ));
      }

      for (final video in videos) {
        final videoFileName = video.path.split('/').last;
        String mimeType = 'video/mp4';
        if (videoFileName.toLowerCase().endsWith('.mov'))
          mimeType = 'video/quicktime';
        else if (videoFileName.toLowerCase().endsWith('.avi'))
          mimeType = 'video/x-msvideo';
        else if (videoFileName.toLowerCase().endsWith('.mkv'))
          mimeType = 'video/x-matroska';
        else if (videoFileName.toLowerCase().endsWith('.webm'))
          mimeType = 'video/webm';

        request.files.add(await http.MultipartFile.fromPath(
          'videos',
          video.path,
          filename: videoFileName,
          contentType: http_parser.MediaType.parse(mimeType),
        ));
      }

      for (final thumbnail in thumbnails) {
        final thumbName = thumbnail.path.split('/').last;
        request.files.add(await http.MultipartFile.fromPath(
          'thumbnails',
          thumbnail.path,
          filename: thumbName,
          contentType: http_parser.MediaType.parse('image/jpeg'),
        ));
      }

      final streamedResponse =
      await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamedResponse)
          .timeout(const Duration(seconds: 90));
      final result = _handleStatusCode(response, context);

      if (result != null && result['success'] == true) {
        TopNotification.success(context,
            "Report submitted successfully. Our team will review it soon");
      }
      return result;
    } on TimeoutException {
      TopNotification.error(
          context, "Upload is taking too long. Please try smaller media files");
      return null;
    } catch (e) {
      print("Report Problem Error: $e");
      TopNotification.error(context, "Failed to submit problem report");
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> reportUserApi(
      BuildContext context, {
        required String otherUserId,
      }) async {
    final targetUserId = otherUserId.trim();
    final token = AppConstant.token.trim();
    if (targetUserId.isEmpty || token.isEmpty) {
      return null;
    }

    setLoading(true);
    try {
      final response = await postJsonData(
        'feed/report_user',
        <String, dynamic>{
          'other_user_id': targetUserId,
        },
        context,
        headers: <String, String>{
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true && context.mounted) {
        TopNotification.success(
          context,
          response['message'] is List
              ? response['message'][language].toString()
              : (response['message']?.toString() ??
              'User reported successfully'),
        );
      }
      return response;
    } catch (e) {
      print('Report User Error: $e');
      if (context.mounted) {
        TopNotification.error(context, 'Failed to report user');
      }
      return null;
    } finally {
      setLoading(false);
    }
  }

  Map<String, dynamic>? _handleStatusCode(
      http.Response response, BuildContext? context) {
    final statusCode = response.statusCode;
    try {
      final body = jsonDecode(response.body);
      if (statusCode == 200) return body;
      final String errorMessage = _getErrorMessage(body);
      if (context != null) {
        if (statusCode == 500) {
          TopNotification.error(
              context, "Server error. Please try again later.");
        } else {
          TopNotification.error(context, errorMessage);
        }
      }
      return null;
    } catch (e) {
      print("Error parsing response: $e");
      return null;
    }
  }

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

    final res = await postJsonData(
      'common/send_messageTo_admin',
      {'description': message.toString()},
      context,
    );

    if (res != null) {
      if (!context.mounted) return;
      setLoading(false);
      if (res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
      }
      Navigator.pop(context);
    }

    setLoading(false);
  }

  //============ delete account api===========//
  deleteAccountApiCalling(BuildContext context, String message) async {
    setLoading(true);

    final res = await postJsonData(
      'user/delete_account',
      {'reason': message.toString()},
      context,
    );

    if (res != null) {
      _clearSessionState(context);
      await Provider.of<UserController>(context, listen: false)
          .clearSelectedSearchLocation(notify: false);
      await SessionManager.clearAuthSession(
        signOutFromFirebase: true,
        clearAllPreferences: true,
      );
      if (!context.mounted) return;

      setLoading(false);

      if (res['success'] == true) {
        TopNotification.success(context, res['message'][language]);
      }

      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          type: PageTransitionType.bottomToTop,
          child: const PurpleScreen(nextScreen: LoginScreen()),
          duration: const Duration(milliseconds: 400),
        ),
            (route) => false,
      );
    }

    setLoading(false);
  }
}

//======= Content Screen Cache -----------
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