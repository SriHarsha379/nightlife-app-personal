import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class BlockedUsersController extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _blockedUsers = <Map<String, dynamic>>[];
  final Set<String> _unblockingIds = <String>{};

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get blockedUsers => _blockedUsers;

  bool isUnblocking(String userId) => _unblockingIds.contains(userId.trim());

  Future<void> fetchBlockedUsers(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'common/get_blocked_users',
        context,
        headers: <String, String>{
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _blockedUsers = data
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        } else {
          _blockedUsers = <Map<String, dynamic>>[];
        }
      } else {
        _blockedUsers = <Map<String, dynamic>>[];
      }
    } catch (_) {
      _blockedUsers = <Map<String, dynamic>>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unblockUser(
    BuildContext context, {
    required String targetUserId,
  }) async {
    final token = AppConstant.token;
    final userId = targetUserId.trim();
    if (token.isEmpty || userId.isEmpty) return false;
    if (_unblockingIds.contains(userId)) return false;

    _unblockingIds.add(userId);
    notifyListeners();

    try {
      final response = await postJsonData(
        'common/block_unblock',
        <String, dynamic>{
          'target_user_id': userId,
          'action': 'unblock',
        },
        context,
        headers: <String, String>{
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        _blockedUsers.removeWhere((item) {
          final blockedUser = item['blocked_user'];
          if (blockedUser is Map) {
            return (blockedUser['_id'] ?? '').toString().trim() == userId;
          }
          return false;
        });
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _unblockingIds.remove(userId);
      notifyListeners();
    }
  }
}
