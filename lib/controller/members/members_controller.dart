import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class MembersController with ChangeNotifier {
  bool _isLikedMembersLoading = false;
  bool _isConnectedMembersLoading = false;
  List<dynamic> _likedMembers = [];
  List<dynamic> _connectedMembers = [];

  bool get isLikedMembersLoading => _isLikedMembersLoading;
  bool get isConnectedMembersLoading => _isConnectedMembersLoading;
  List<dynamic> get likedMembers => _likedMembers;
  List<dynamic> get connectedMembers => _connectedMembers;

  Future<void> fetchMyMembers(
    BuildContext context, {
    String type = 'liked',
    int page = 1,
    int limit = 10,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;
    final isConnectedType = type == 'connected';

    if (isConnectedType) {
      _isConnectedMembersLoading = true;
    } else {
      _isLikedMembersLoading = true;
    }
    notifyListeners();

    try {
      final response = await getData(
        'common/my_members?type=$type&page=$page&limit=$limit',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        List<dynamic> parsed = [];
        if (data is List) {
          parsed = data;
        } else if (data is Map && data['list'] is List) {
          parsed = List<dynamic>.from(data['list']);
        }

        if (isConnectedType) {
          _connectedMembers = parsed;
        } else {
          _likedMembers = parsed;
        }
      } else if (response != null) {
        if (isConnectedType) {
          _connectedMembers = [];
        } else {
          _likedMembers = [];
        }
        CommonHelper.handleInactiveUserRedirect(context, response);
      }
    } catch (_) {
      if (isConnectedType) {
        _connectedMembers = [];
      } else {
        _likedMembers = [];
      }
    } finally {
      if (isConnectedType) {
        _isConnectedMembersLoading = false;
      } else {
        _isLikedMembersLoading = false;
      }
      notifyListeners();
    }
  }
}
