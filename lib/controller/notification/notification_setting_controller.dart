import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class NotificationSettingController with ChangeNotifier {
  final Map<String, bool> _settings = <String, bool>{
    'event_reminder_notify': false,
    'friend_invites_notify': false,
    'msg_chats_notify': false,
    'club_organizer_notify': false,
    'promotion_offers_notify': false,
  };
  final Map<String, bool> _updatingByType = <String, bool>{};
  bool _isLoading = false;

  Map<String, bool> get settings => _settings;
  bool get isLoading => _isLoading;

  bool isUpdatingType(String type) => _updatingByType[type] == true;

  Future<void> fetchNotificationSettings(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    final res = await getData(
      'user/get_notification_setting',
      context,
      headers: <String, String>{
        'authorization': 'Bearer $token',
      },
    );

    if (res != null && res['success'] == true) {
      final data = res['data'];
      if (data is Map) {
        _applySettingsFromResponseNode(data);
      }
    } else if (res != null && context.mounted) {
      // CommonHelper.handleInactiveUserRedirect(context, res);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateNotificationSetting(
    BuildContext context, {
    required String type,
    required bool value,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty || !_settings.containsKey(type)) return false;

    final bool previousValue = _settings[type] ?? false;
    _settings[type] = value;
    _updatingByType[type] = true;
    notifyListeners();

    final res = await postJsonData(
      'user/update_notification_setting',
      <String, dynamic>{
        'value': value,
        'type': type,
      },
      context,
      headers: <String, String>{
        'authorization': 'Bearer $token',
      },
    );

    if (res != null && res['success'] == true) {
      _updatingByType[type] = false;
      notifyListeners();
      return true;
    }

    _settings[type] = previousValue;
    if (res != null && context.mounted) {
      // CommonHelper.handleInactiveUserRedirect(context, res);
    }

    _updatingByType[type] = false;
    notifyListeners();
    return false;
  }

  void _applySettingsFromResponseNode(dynamic node) {
    if (node is Map) {
      final dynamic key = node['key'];
      final dynamic value = node['value'];
      if (key is String && value is bool && _settings.containsKey(key)) {
        _settings[key] = value;
      }

      for (final dynamic child in node.values) {
        _applySettingsFromResponseNode(child);
      }
      return;
    }

    if (node is List) {
      for (final dynamic item in node) {
        _applySettingsFromResponseNode(item);
      }
    }
  }
}
