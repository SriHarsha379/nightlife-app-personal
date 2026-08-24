import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';
import '../../view/other/poll_popup.dart';

/// Fetches real active polls from the backend and submits votes.
///
/// This replaces the old `samplePolls` hardcoded list in poll_popup.dart —
/// polls created in the admin dashboard's "Polls & Contests" page now
/// actually reach real users through this controller instead of never
/// being seen by anyone.
class PollController with ChangeNotifier {
  List<PollData> _activePolls = [];
  bool _isLoading = false;

  List<PollData> get activePolls => _activePolls;
  bool get isLoading => _isLoading;

  Future<void> fetchActivePolls(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      _activePolls = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'poll/active',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _activePolls = data
              .map((e) => PollData.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _activePolls = [];
        }
      } else {
        _activePolls = [];
      }
    } catch (e) {
      _activePolls = [];
      debugPrint("Exception in fetchActivePolls: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a vote for [optionId] on poll [pollId]. Returns the
  /// server's updated tallies (real counts from every user who's voted,
  /// not just an optimistic local +1) on success, or null on failure —
  /// the caller falls back to a local-only optimistic update in that
  /// case rather than blocking the user's vote from visually registering.
  Future<PollData?> submitVote(
      BuildContext context,
      String pollId,
      String optionId,
      ) async {
    final token = AppConstant.token;
    if (token.isEmpty) return null;

    try {
      final response = await postJsonData(
        'poll/$pollId/vote',
        {'option_index': int.tryParse(optionId) ?? 0},
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return PollData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Exception in submitVote: $e");
      return null;
    }
  }
}