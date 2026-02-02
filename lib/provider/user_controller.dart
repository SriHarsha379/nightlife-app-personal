import 'dart:convert';
import 'package:flutter/material.dart';
import '../../provider/common_sharedpreferences.dart';

class UserController with ChangeNotifier {
  static final UserController _instance = UserController._internal();
  factory UserController() => _instance;
  UserController._internal();

  String _userId = "";
  String get getUserId => _userId;

  String _userImage = "";
  String get getUserImage => _userImage;

  String _userName = "";
  String get getUserName => _userName;

  String _userMobile = "";
  String get getUserMobile => _userMobile;

  String _userEmail = "";
  String get getUserEmail => _userEmail;

  String _userBio = "";
  String get getUserBio => _userBio;

  List<Map<String, String>> _favoriteClubs = [];
  List<Map<String, String>> get getFavoriteClubs => _favoriteClubs;

  Future<void> getUserDetails() async {
    final userDetails = await CacheHelper.get('user_details');
    print("userDetails10: $userDetails");

    if (userDetails != null) {
      try {
        final data = json.decode(userDetails);

        if (data is Map<String, dynamic>) {
          final user = data['user'];

          if (user != null && user is Map<String, dynamic>) {
            _userId = user['_id'] ?? "";
            _userImage = user['profileImage'] ?? "";
            _userName = user['fullName'] ?? "";
            _userMobile = user['mobile'] ?? "";
            _userEmail = user['email'] ?? "";
            _userBio = user['bio'] ?? "";

            // Extract favorite clubs
            if (user['favoriteClubs'] != null &&
                user['favoriteClubs'] is List) {
              _favoriteClubs = (user['favoriteClubs'] as List)
                  .map((club) => {
                        '_id': club['_id']?.toString() ?? "",
                        'name': club['name']?.toString() ?? "",
                      })
                  .toList();
            } else {
              _favoriteClubs = [];
            }

            print("userId188: $_userId");
            print("userName: $_userName");
            print("userEmail: $_userEmail");
            print("userBio: $_userBio");
            print("favoriteClubs: $_favoriteClubs");

            notifyListeners();
          } else {
            print("User object is null or invalid");
            _clearUserData();
          }
        } else {
          print("Decoded data is not a valid Map");
          _clearUserData();
        }
      } catch (e) {
        print("Error decoding userDetails: $e");
        _clearUserData();
      }
    } else {
      print("No user details found in cache");
      _clearUserData();
    }
  }

  void _clearUserData() {
    _userId = "";
    _userImage = "";
    _userName = "";
    _userMobile = "";
    _userEmail = "";
    _userBio = "";
    _favoriteClubs = [];
    notifyListeners();
  }
  void reset() {
    _userId = "";
    _userImage = "";
    _userName = "";
    _userMobile = "";
    _userEmail = "";
    _userBio = "";
    _favoriteClubs.clear();
    notifyListeners();
  }


  Future<void> clearCache() async {
    await CacheHelper.remove('user_details');
    _clearUserData();
  }
}
