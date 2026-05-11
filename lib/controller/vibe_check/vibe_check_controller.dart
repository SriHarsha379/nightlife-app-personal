import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../provider/common_sharedpreferences.dart';
import '../../utilities/app_constant.dart';
import 'dart:convert';

class VibeCheckController with ChangeNotifier {
  List<dynamic> _vibeCheckList = [];
  List<dynamic> get getVibeCheckList => _vibeCheckList;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  Map<String, String> _answers = {};
  Map<String, String> get getAnswers => _answers;

  // Fetch vibe check questions from API
  Future<void> fetchVibeCheckData(BuildContext context) async {
    String token = AppConstant.token;
    if (token.isEmpty) {
      final userDetailsRaw = await CacheHelper.get('user_details');
      if (userDetailsRaw != null && userDetailsRaw.isNotEmpty) {
        try {
          final decoded = jsonDecode(userDetailsRaw);
          if (decoded is Map) {
            token = (decoded['token'] ?? '').toString().trim();
            if (token.isNotEmpty) {
              AppConstant.token = token;
            }
          }
        } catch (_) {}
      }
    }
    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    // Show loading only if list is empty
    if (_vibeCheckList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'auth/get_vibe_checks',
        context,
        headers: headers,
      );

      print("Vibe Check API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'] is List) {
          _vibeCheckList = response['data'];
          print("Vibe Check List: $_vibeCheckList");
        } else {
          _vibeCheckList = [];
          print("No vibe check data found");
        }
        notifyListeners();
      } else {
        _vibeCheckList = [];
        if (response != null) {
          // CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchVibeCheckData: $e");
      _vibeCheckList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save answer for a question
  void saveAnswer(String questionId, String answer) {
    if (answer.trim().isEmpty) {
      _answers.remove(questionId);
    } else {
      _answers[questionId] = answer.trim();
    }
    notifyListeners();
  }

  // Get answer for a question
  String getAnswer(String questionId) {
    return _answers[questionId] ?? '';
  }

  // Check if question is answered
  bool isQuestionAnswered(String questionId) {
    return _answers.containsKey(questionId) && _answers[questionId]!.isNotEmpty;
  }

  // Get formatted list for API submission
  List<Map<String, String>> getFormattedAnswers() {
    List<Map<String, String>> formattedList = [];
    _answers.forEach((questionId, answer) {
      formattedList.add({
        "question_id": questionId,
        "answer": answer,
      });
    });
    return formattedList;
  }

  // Get answered count
  int get answeredCount => _answers.length;

  // Clear all answers
  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }

  // Clear all data (useful for logout)
  void clearData() {
    _vibeCheckList = [];
    _answers = {};
    _isLoading = false;
    notifyListeners();
  }

  // Set pre-filled answers (if coming back from next screen)
  void setAnswers(Map<String, String> answers) {
    _answers = Map.from(answers);
    notifyListeners();
  }

  // Distribute questions across pages
  List<List<dynamic>> distributeQuestionsToPages() {
    int totalQuestions = _vibeCheckList.length;

    if (totalQuestions == 0) return [[], [], []];

    List<List<dynamic>> pages = [[], [], []];

    int questionsPerPage = (totalQuestions / 3).ceil();
    int remainder = totalQuestions % 3;

    int currentIndex = 0;

    // Page 1 gets extra questions if not evenly divisible
    int page1Count = questionsPerPage;
    if (currentIndex < totalQuestions) {
      pages[0] =
          _vibeCheckList.sublist(currentIndex, currentIndex + page1Count);
      currentIndex += page1Count;
    }

    // Page 2
    int page2Count = (totalQuestions - currentIndex) >= 2
        ? ((totalQuestions - currentIndex) / 2).ceil()
        : (totalQuestions - currentIndex);
    if (currentIndex < totalQuestions) {
      int end = currentIndex + page2Count;
      if (end > totalQuestions) end = totalQuestions;
      pages[1] = _vibeCheckList.sublist(currentIndex, end);
      currentIndex = end;
    }

    // Page 3 gets remaining
    if (currentIndex < totalQuestions) {
      pages[2] = _vibeCheckList.sublist(currentIndex, totalQuestions);
    }

    return pages;
  }
}
