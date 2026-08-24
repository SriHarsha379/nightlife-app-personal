import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';
import '../../view/other/contest_popup.dart';

/// Fetches real active contests from the backend and submits entries.
///
/// Mirrors PollController exactly. Contests created in the admin
/// dashboard's "Polls & Contests" page now actually reach real users
/// through this controller — there was no app-side surface for this at
/// all before (not even mock data, unlike Polls).
class ContestController with ChangeNotifier {
  List<ContestData> _activeContests = [];
  bool _isLoading = false;

  List<ContestData> get activeContests => _activeContests;
  bool get isLoading => _isLoading;

  Future<void> fetchActiveContests(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      _activeContests = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'contest/active',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _activeContests = data
              .map((e) => ContestData.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _activeContests = [];
        }
      } else {
        _activeContests = [];
      }
    } catch (e) {
      _activeContests = [];
      debugPrint("Exception in fetchActiveContests: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enters [contestId]. Returns the updated contest (with a real,
  /// server-side participant count) on success, or null on failure —
  /// the caller falls back to a local optimistic update in that case.
  Future<ContestData?> enterContest(
      BuildContext context,
      String contestId,
      ) async {
    final token = AppConstant.token;
    if (token.isEmpty) return null;

    try {
      final response = await postJsonData(
        'contest/$contestId/enter',
        const {},
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          return ContestData.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Exception in enterContest: $e");
      return null;
    }
  }
}