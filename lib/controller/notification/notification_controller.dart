import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class NotificationController extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadingMore = false;
  List<dynamic> _recentNotifications = <dynamic>[];
  List<dynamic> _olderNotifications = <dynamic>[];
  int _currentPage = 0;
  int _totalPages = 0;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  List<dynamic> get recentNotifications => _recentNotifications;
  List<dynamic> get olderNotifications => _olderNotifications;
  bool get hasMore => _currentPage < (_totalPages - 1);
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  Future<void> refreshNotifications(
    BuildContext context, {
    int limit = 6,
  }) async {
    await fetchNotifications(
      context,
      page: 0,
      limit: limit,
      append: false,
      isRefresh: true,
    );
  }

  Future<void> fetchNotifications(
    BuildContext context, {
    int page = 0,
    int limit = 6,
    bool append = false,
    bool isRefresh = false,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    if (append) {
      _isLoadingMore = true;
    } else if (!_isLoading || isRefresh) {
      _isLoading = true;
      if (!append) {
        _recentNotifications = <dynamic>[];
        _olderNotifications = <dynamic>[];
      }
    }
    notifyListeners();

    try {
      final response = await getData(
        'notification/get_all_notification?page=$page&limit=$limit',
        context,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        final recent = data is Map ? data['recent_notifications'] : null;
        final older = data is Map ? data['older_notifications'] : null;
        final currentPage =
            data is Map ? (data['current_page'] as num?)?.toInt() : null;
        final totalPages =
            data is Map ? (data['total_pages'] as num?)?.toInt() : null;

        final recentList =
            recent is List ? List<dynamic>.from(recent) : <dynamic>[];
        final olderList =
            older is List ? List<dynamic>.from(older) : <dynamic>[];

        if (append) {
          _recentNotifications.addAll(recentList);
          _olderNotifications.addAll(olderList);
        } else {
          _recentNotifications = recentList;
          _olderNotifications = olderList;
        }

        _currentPage = currentPage ?? page;
        _totalPages = totalPages ?? (_totalPages == 0 ? 1 : _totalPages);
      } else {
        if (!append) {
          _recentNotifications = <dynamic>[];
          _olderNotifications = <dynamic>[];
          _currentPage = 0;
          _totalPages = 0;
        }
      }
    } catch (_) {
      if (!append) {
        _recentNotifications = <dynamic>[];
        _olderNotifications = <dynamic>[];
        _currentPage = 0;
        _totalPages = 0;
      }
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications(
    BuildContext context, {
    int limit = 6,
  }) async {
    if (_isLoading || _isLoadingMore || !hasMore) return;
    final nextPage = _currentPage + 1;
    await fetchNotifications(
      context,
      page: nextPage,
      limit: limit,
      append: true,
    );
  }

  Future<bool> deleteSingleNotification(
    BuildContext context, {
    required String notificationId,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty || notificationId.isEmpty) return false;

    final res = await postJsonData(
      'notification/delete_single_notification',
      <String, dynamic>{
        'notification_id': notificationId,
      },
      context,
      headers: <String, String>{
        'authorization': 'Bearer $token',
      },
    );

    if (res != null && res['success'] == true) {
      _recentNotifications.removeWhere(
        (item) =>
            (item is Map ? (item['notification_id'] ?? '').toString() : '') ==
            notificationId,
      );
      _olderNotifications.removeWhere(
        (item) =>
            (item is Map ? (item['notification_id'] ?? '').toString() : '') ==
            notificationId,
      );
      notifyListeners();
      return true;
    }

    return false;
  }
}
