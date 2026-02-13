import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class MyVisibilityController with ChangeNotifier {
  bool _myVisibility = true;
  bool _isLoading = false;
  bool _isUpdating = false;

  bool get myVisibility => _myVisibility;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;

  Future<void> fetchMyVisibility(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    final res = await getData(
      'user/get_my_visibility',
      context,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (res != null && res['success'] == true) {
      final data = res['data'];
      if (data is Map && data['my_visibility'] is bool) {
        _myVisibility = data['my_visibility'] == true;
      }
    } else if (res != null) {
      CommonHelper.handleInactiveUserRedirect(context, res);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateMyVisibility(
    BuildContext context, {
    required bool value,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return false;

    final previousValue = _myVisibility;
    _myVisibility = value;
    _isUpdating = true;
    notifyListeners();

    final res = await postJsonData(
      'user/update_my_visibility',
      {
        'my_visibility': value,
      },
      context,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (res != null && res['success'] == true) {
      _isUpdating = false;
      notifyListeners();
      return true;
    }

    _myVisibility = previousValue;
    if (res != null) {
      CommonHelper.handleInactiveUserRedirect(context, res);
    }

    _isUpdating = false;
    notifyListeners();
    return false;
  }
}
