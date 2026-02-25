import 'dart:convert';
import 'package:flutter/material.dart';
import '../../provider/common_sharedpreferences.dart';

class UserController with ChangeNotifier {
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal();

  Map<String, dynamic> _userData = {};

  Map<String, dynamic> get getUserData => Map<String, dynamic>.from(_userData);

  String _str(dynamic value) => value?.toString() ?? "";

  List<dynamic> _list(dynamic value) {
    if (value is List) return value;
    return <dynamic>[];
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractUserMap(Map<String, dynamic> data) {
    if (data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }
    if (data['user'] is Map) {
      return Map<String, dynamic>.from(data['user']);
    }
    return data;
  }

  String get getUserId => _str(_userData['_id'] ?? _userData['user_id']);
  String get getUserImage =>
      _str(_userData['profile_image'] ?? _userData['profileImage']);
  String get getUserName {
    final name = _str(_userData['name'] ?? _userData['fullName']);
    if (name.trim().isNotEmpty) return name;
    final firstName = _str(_userData['first_name'] ?? _userData['firstName']);
    final lastName = _str(_userData['last_name'] ?? _userData['lastName']);
    return "$firstName $lastName".trim();
  }

  String get getFirstName =>
      _str(_userData['first_name'] ?? _userData['firstName']);
  String get getLastName =>
      _str(_userData['last_name'] ?? _userData['lastName']);
  String get getUserNameId => _str(_userData['username']);
  String get getUserMobile =>
      _str(_userData['phone_number'] ?? _userData['mobile']);
  String get getUserEmail => _str(_userData['email']);
  String get getUserBio => _str(_userData['bio']);
  String get getUserGender => _str(_userData['gender']);
  String get getBirthdate => _str(_userData['birthdate'] ?? _userData['dob']);
  String get getInterestedIn => _str(_userData['interested_in']);
  String get getPronouns => _str(_userData['pronouns']);
  String get getSexuality => _str(_userData['sexuality']);
  String get getInstagramAccount => _str(_userData['instagram_account']);
  String get getSpotifyAccount => _str(_userData['spotify_account']);
  String get getSnapchatAccount => _str(_userData['snapchat_account']);
  String get getLoginType => _str(_userData['login_type']);
  String get getPlayerId => _str(_userData['player_id']);
  String get getDeviceType => _str(_userData['device_type']);
  String get getReferralCode => _str(_userData['referral_code']);
  String get getMyReferralCode => _str(_userData['my_referral_code']);
  String get getDisplayReferralCode {
    final myCode = getMyReferralCode.trim();
    if (myCode.isNotEmpty) return myCode;
    return getReferralCode.trim();
  }
  String get getToken => _str(_userData['token']);
  String get getCreatedAt => _str(_userData['createdAt']);
  String get getUpdatedAt => _str(_userData['updatedAt']);

  bool get isVerified =>
      (_userData['is_verified'] ?? _userData['isEmailVerified'] ?? false) ==
      true;
  bool get isProfileCompleted =>
      (_userData['is_profile_completed'] ??
          _userData['isProfileCompleted'] ??
          false) ==
      true;
  bool get isForgetOtp => (_userData['is_forget_otp'] ?? false) == true;
  bool get notificationPush =>
      (_userData['notification_push'] ?? false) == true;
  bool get notificationPayment =>
      (_userData['notification_payment'] ?? false) == true;
  bool get acceptedTerms => (_userData['accepted_terms'] ?? false) == true;
  bool get acceptedPrivacyPolicy =>
      (_userData['accepted_privacy_policy'] ?? false) == true;
  bool get isActive => (_userData['is_active'] ?? false) == true;
  bool get isDeleted => (_userData['is_deleted'] ?? false) == true;
  bool get myVisibility => (_userData['my_visibility'] ?? false) == true;
  bool get isNewUser => (_userData['is_new_user'] ?? false) == true;

  int get getSignupStep => int.tryParse(_str(_userData['signup_step'])) ?? 0;
  int get getAge => int.tryParse(_str(_userData['age'])) ?? 0;
  int get getTotalLikes => int.tryParse(_str(_userData['total_likes'])) ?? 0;
  int get getTotalFriends =>
      int.tryParse(_str(_userData['total_friends'])) ?? 0;

  Map<String, dynamic> get getCityData => _map(_userData['city_id']);
  Map<String, dynamic> get getProfileVisibility =>
      _map(_userData['profile_visibility']);

  List<dynamic> get getHobbies => _list(_userData['hobbies']);
  List<dynamic> get getInterests => _list(_userData['interests']);
  List<dynamic> get getMusicGenres =>
      _list(_userData['music_genre'] ?? _userData['musicGenre']);
  List<dynamic> get getCustomMusicGenres =>
      _list(_userData['custom_music_genres']);
  List<dynamic> get getEventPreferences =>
      _list(_userData['event_preferences']);
  List<dynamic> get getCustomEventPreferences =>
      _list(_userData['custom_event_preferences']);
  List<dynamic> get getVibes => _list(_userData['vibes']);
  List<dynamic> get getCustomVibes => _list(_userData['custom_vibes']);
  List<dynamic> get getVibeChecks => _list(_userData['vibe_checks']);
  List<dynamic> get getUserGallery => _list(_userData['user_gallery']);
  List<dynamic> get getPreferredCities => _list(_userData['preferred_cities']);

  List<Map<String, String>> get getFavoriteClubs {
    final fav = _list(_userData['favoriteClubs'] ??
        _userData['favourite_clubs'] ??
        _userData['favorite_clubs']);
    return fav.map((club) {
      if (club is Map) {
        return {
          '_id': _str(club['_id']),
          'name': _str(club['name']),
        };
      }
      return {'_id': "", 'name': ""};
    }).toList();
  }

  void setUserFromMap(Map<String, dynamic> user) {
    _userData = _extractUserMap(user);
    notifyListeners();
  }

  Future<void> getUserDetails() async {
    final userDetails = await CacheHelper.get('user_details');
    if (userDetails == null) {
      _clearUserData();
      return;
    }

    try {
      final decoded = json.decode(userDetails);
      if (decoded is Map<String, dynamic>) {
        setUserFromMap(decoded);
      } else {
        _clearUserData();
      }
    } catch (_) {
      _clearUserData();
    }
  }

  void _clearUserData() {
    _userData = {};
    notifyListeners();
  }

  void reset() {
    _clearUserData();
  }

  Future<void> clearCache() async {
    await CacheHelper.remove('user_details');
    _clearUserData();
  }
}
