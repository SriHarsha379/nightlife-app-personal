import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class GetMySwipeProfileController with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, bool> _visibility = {
    'age': true,
    'height': true,
    'pronouns': true,
    'location': true,
    'hobbies': true,
    'vibes': true,
    'gallery': true,
    'recent_events': true,
    'recent_venues': true,
    'instagram': true,
    'spotify': true,
  };

  Map<String, bool> get visibility => Map<String, bool>.from(_visibility);

  void resetState() {
    _isLoading = false;
    _visibility = {
      'age': true,
      'height': true,
      'pronouns': true,
      'location': true,
      'hobbies': true,
      'vibes': true,
      'gallery': true,
      'recent_events': true,
      'recent_venues': true,
      'instagram': true,
      'spotify': true,
    };
    notifyListeners();
  }

  Future<void> fetchProfileVisibility(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final res = await getData(
      'user/get_profile_visibility',
      context,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    _isLoading = false;

    if (res != null && res['success'] == true && res['data'] is Map) {
      final data = Map<String, dynamic>.from(res['data']);
      _visibility = {
        'age': (data['age'] ?? _visibility['age']) == true,
        'height': (data['height'] ?? _visibility['height']) == true,
        'pronouns': (data['pronouns'] ?? _visibility['pronouns']) == true,
        'location': (data['location'] ?? _visibility['location']) == true,
        'hobbies': (data['hobbies'] ?? _visibility['hobbies']) == true,
        'vibes': (data['vibes'] ?? _visibility['vibes']) == true,
        'gallery': (data['gallery'] ?? _visibility['gallery']) == true,
        'recent_events':
            (data['recent_events'] ?? _visibility['recent_events']) == true,
        'recent_venues':
            (data['recent_venues'] ?? _visibility['recent_venues']) == true,
        'instagram': (data['instagram'] ?? _visibility['instagram']) == true,
        'spotify': (data['spotify'] ?? _visibility['spotify']) == true,
      };
    }

    notifyListeners();
  }

  Future<void> updateProfileVisibility(
    BuildContext context, {
    required String key,
    required bool value,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      return;
    }

    _visibility[key] = value;
    notifyListeners();

    await postJsonData(
      'user/update_profile_visibility',
      {
        'key': key,
        'value': value,
      },
      context,
      headers: {
        'authorization': 'Bearer $token',
      },
    );
  }
}
