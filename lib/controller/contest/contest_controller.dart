import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

/// A single admin-created contest, as returned by `GET /contest/active`.
class ContestData {
  final String id;
  final String title;
  final String rules;
  final String reward;
  final DateTime? deadline;
  final int participants;
  final bool alreadyEntered;

  const ContestData({
    required this.id,
    required this.title,
    required this.rules,
    required this.reward,
    required this.deadline,
    required this.participants,
    required this.alreadyEntered,
  });

  ContestData copyWith({int? participants, bool? alreadyEntered}) {
    return ContestData(
      id: id,
      title: title,
      rules: rules,
      reward: reward,
      deadline: deadline,
      participants: participants ?? this.participants,
      alreadyEntered: alreadyEntered ?? this.alreadyEntered,
    );
  }
}

/// Fetches real, admin-created contests from `GET /contest/active` and
/// submits entries via `POST /contest/:id/enter`.
///
/// Contests previously had zero app-side implementation at all — the
/// admin dashboard could create them, but there was no screen, popup, or
/// API call anywhere in the app to show or enter them.
class ContestController with ChangeNotifier {
  bool _isLoading = false;
  List<ContestData> _activeContests = [];
  bool _hasLoadedOnce = false;

  bool get isLoading => _isLoading;
  List<ContestData> get activeContests => _activeContests;
  bool get hasLoadedOnce => _hasLoadedOnce;

  Map<String, String> get _authHeaders {
    final token = AppConstant.token;
    return token.isEmpty ? {} : {'authorization': 'Bearer $token'};
  }

  ContestData _contestFromJson(Map<String, dynamic> json) {
    DateTime? deadline;
    final rawDeadline = json['deadline'];
    if (rawDeadline is String && rawDeadline.isNotEmpty) {
      deadline = DateTime.tryParse(rawDeadline);
    }

    return ContestData(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      rules: (json['rules'] ?? '').toString(),
      reward: (json['reward'] ?? '').toString(),
      deadline: deadline,
      participants: (json['participants'] is num) ? (json['participants'] as num).toInt() : 0,
      alreadyEntered: json['already_entered'] == true,
    );
  }

  /// Loads active contests for the current user. Silently no-ops on
  /// failure so a contest fetch never blocks the rest of the home feed.
  Future<void> fetchActiveContests(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await getData('contest/active', context, headers: _authHeaders);
      if (res != null && res['success'] == true && res['data'] is List) {
        _activeContests = (res['data'] as List)
            .whereType<Map>()
            .map((e) => _contestFromJson(Map<String, dynamic>.from(e)))
            .where((c) => c.id.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch active contests: $e');
    } finally {
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enters [contestId] with an optional [note]. Updates local state
  /// (participant count + entered flag) on success. Returns true on
  /// success, false otherwise (including "already entered", which the
  /// caller can surface as a message rather than a hard error).
  Future<bool> enterContest(
      BuildContext context,
      String contestId, {
        String? note,
      }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return false;

    try {
      final res = await postJsonData(
        'contest/$contestId/enter',
        note != null && note.isNotEmpty ? {'note': note} : {},
        context,
        headers: _authHeaders,
      );
      if (res != null && res['success'] == true) {
        final index = _activeContests.indexWhere((c) => c.id == contestId);
        if (index != -1) {
          final data = res['data'];
          if (data is Map) {
            _activeContests[index] = _contestFromJson(Map<String, dynamic>.from(data));
          } else {
            _activeContests[index] = _activeContests[index].copyWith(
              alreadyEntered: true,
              participants: _activeContests[index].participants + 1,
            );
          }
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to enter contest: $e');
    }
    return false;
  }
}