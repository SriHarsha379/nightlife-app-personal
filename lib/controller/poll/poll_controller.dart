import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';
import '../../view/other/poll_popup.dart';

/// Fetches real, admin-created polls from `GET /poll/active` and submits
/// votes via `POST /poll/:id/vote`.
///
/// This replaces the previous behavior where the poll popup only ever
/// showed the hardcoded `samplePolls` list from poll_popup.dart — admin
/// could create polls, but the app never called the API at all.
class PollController with ChangeNotifier {
  bool _isLoading = false;
  List<PollData> _activePolls = [];
  bool _hasLoadedOnce = false;

  bool get isLoading => _isLoading;
  List<PollData> get activePolls => _activePolls;
  bool get hasLoadedOnce => _hasLoadedOnce;

  Map<String, String> get _authHeaders {
    final token = AppConstant.token;
    return token.isEmpty ? {} : {'authorization': 'Bearer $token'};
  }

  PollData _pollFromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List? ?? [])
        .map((o) => PollOption(
      id: (o['id'] ?? '').toString(),
      text: (o['text'] ?? '').toString(),
      votes: (o['votes'] is num) ? (o['votes'] as num).toInt() : 0,
    ))
        .toList();

    return PollData(
      id: (json['id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      options: options,
    );
  }

  /// Loads active polls for the current user. Silently no-ops on failure
  /// (e.g. no connection) — a missing poll popup should never block the
  /// rest of the home feed.
  Future<void> fetchActivePolls(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    try {
      final res = await getData('poll/active', context, headers: _authHeaders);
      if (res != null && res['success'] == true && res['data'] is List) {
        _activePolls = (res['data'] as List)
            .whereType<Map>()
            .map((e) => _pollFromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.id.isNotEmpty && p.options.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch active polls: $e');
    } finally {
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a vote for [optionIndex] on poll [pollId]. Returns the
  /// updated PollData (with real vote counts) on success, or null if the
  /// request failed — callers should keep their optimistic local update
  /// either way so the UI doesn't feel broken on a flaky connection.
  Future<PollData?> submitVote(
      BuildContext context,
      String pollId,
      int optionIndex,
      ) async {
    final token = AppConstant.token;
    if (token.isEmpty) return null;

    try {
      final res = await postJsonData(
        'poll/$pollId/vote',
        {'option_index': optionIndex},
        context,
        headers: _authHeaders,
      );
      if (res != null && res['success'] == true && res['data'] is Map) {
        return _pollFromJson(Map<String, dynamic>.from(res['data']));
      }
    } catch (e) {
      debugPrint('Failed to submit poll vote: $e');
    }
    return null;
  }
}