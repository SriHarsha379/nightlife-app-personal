import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class FaqController with ChangeNotifier {
  List<FaqItem> _faqList = [];
  String _supportEmail = '';
  bool _isLoading = false;
  bool _isSupportEmailLoading = false;

  List<FaqItem> get getFaqList => _faqList;
  String get getSupportEmail => _supportEmail;
  bool get getIsLoading => _isLoading;
  bool get getIsSupportEmailLoading => _isSupportEmailLoading;

  Future<void> fetchFaqData(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      _faqList = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'user/get_faq',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _faqList = data
              .map((e) => FaqItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          _faqList = [];
        }
      } else {
        _faqList = [];
      }
    } catch (e) {
      _faqList = [];
      debugPrint("Exception in fetchFaqData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSupportEmailData(BuildContext context) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      _supportEmail = '';
      notifyListeners();
      return;
    }

    _isSupportEmailLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'user/get_support_email',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          _supportEmail = (data['support_email'] ?? '').toString().trim();
        } else {
          _supportEmail = '';
        }
      } else {
        _supportEmail = '';
      }
    } catch (e) {
      _supportEmail = '';
      debugPrint("Exception in fetchSupportEmailData: $e");
    } finally {
      _isSupportEmailLoading = false;
      notifyListeners();
    }
  }
}

class FaqItem {
  final String id;
  final String question;
  final String answer;
  final String target;

  FaqItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.target,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: (json['_id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
      target: (json['target'] ?? '').toString(),
    );
  }
}
