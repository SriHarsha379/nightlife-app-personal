import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class MyProfleCompltetionController with ChangeNotifier {
  bool _isLoading = false;
  int _profileCompletionPercentage = 0;
  List<String> _completionMessages = [];
  bool _hasLoadedOnce = false;

  bool get isLoading => _isLoading;
  int get profileCompletionPercentage => _profileCompletionPercentage;
  List<String> get completionMessages => _completionMessages;
  bool get hasLoadedOnce => _hasLoadedOnce;

  Future<void> fetchMyProfleCompltetion(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    final res = await getData(
      'common/profile_complete_status',
      context,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (res != null && res['success'] == true) {
      final data = res['data'];
      if (data is Map) {
        final apiPercentage = data['profile_completion_percentage'];
        if (apiPercentage is num) {
          _profileCompletionPercentage = apiPercentage.toInt().clamp(0, 100);
        }

        final apiMessages = data['messages'];
        if (apiMessages is List) {
          _completionMessages = apiMessages
              .whereType<String>()
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
      }
    } else if (res != null) {
      if (!context.mounted) {
        _hasLoadedOnce = true;
        _isLoading = false;
        notifyListeners();
        return;
      }
      CommonHelper.handleInactiveUserRedirect(context, res);
    }

    _hasLoadedOnce = true;
    _isLoading = false;
    notifyListeners();
  }
}
