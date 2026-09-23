import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';
import '../../view/other/poll_popup.dart';

/// Fetches real polls from the backend (poll/active) and submits votes
/// (poll/:id/vote) — replaces the hardcoded `samplePolls` the poll popup
/// used before, which is what makes "polls only repeat if not
/// participated" possible: the backend already tells us, per poll,
/// whether this member has voted (`already_voted`), so we just need to
/// stop offering the ones they've already answered.
class PollController with ChangeNotifier {
  List<PollData> _polls = [];
  List<PollData> get getPolls => _polls;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  bool _hasFetchedOnce = false;
  bool get hasFetchedOnce => _hasFetchedOnce;

  /// Active polls this member hasn't voted on yet — the pool the "show a
  /// poll" trigger should pick from.
  List<PollData> get unvotedPolls =>
      _polls.where((p) => !p.alreadyVoted).toList();

  Future<void> fetchActivePolls(BuildContext context) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final res = await getData(
        'poll/active',
        context,
        headers: {'authorization': 'Bearer ${AppConstant.token}'},
      );

      if (res != null && res['success'] == true && res['data'] is List) {
        _polls = (res['data'] as List)
            .whereType<Map>()
            .map((p) => PollData.fromJson(Map<String, dynamic>.from(p)))
            .toList();
      }
    } catch (_) {
      // Leave whatever polls we already had rather than clearing them on
      // a transient network failure.
    } finally {
      _hasFetchedOnce = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submits a vote and updates local state with the real returned
  /// tallies so the poll immediately drops out of [unvotedPolls].
  Future<PollData?> submitVote(
      BuildContext context,
      String pollId,
      String optionId,
      ) async {
    final optionIndex = int.tryParse(optionId);
    if (optionIndex == null) return null;

    try {
      final res = await postJsonData(
        'poll/$pollId/vote',
        {'option_index': optionIndex},
        context,
        headers: {'authorization': 'Bearer ${AppConstant.token}'},
      );

      if (res != null && res['success'] == true && res['data'] is Map) {
        final updated =
        PollData.fromJson(Map<String, dynamic>.from(res['data']));
        final index = _polls.indexWhere((p) => p.id == pollId);
        if (index != -1) {
          _polls[index] = updated;
        }
        notifyListeners();
        return updated;
      }
    } catch (_) {
      // Handled by the caller (poll popup) — falls back to a local-only
      // tally bump rather than leaving the UI stuck.
    }
    return null;
  }

  void clearData() {
    _polls = [];
    _isLoading = false;
    _hasFetchedOnce = false;
    notifyListeners();
  }
}