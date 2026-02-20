import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class CalendarController with ChangeNotifier {
  List<dynamic> _eventsList = [];
  List<dynamic> get getEventsList => _eventsList;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  // Fetch events from API
  Future<void> fetchCalendarEvents(BuildContext context, DateTime date) async {
    String token = AppConstant.token;
    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    _isLoading = true;
    notifyListeners();

    try {
      final response = await getFormData(
        'common/calender_filter?type=event&date=$formattedDate',
        context,
        headers: headers,
      );

      print("Calendar API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'] is List) {
          _eventsList = response['data'];
          print("Events List: $_eventsList");
        } else {
          _eventsList = [];
          print("No events data found");
        }
        notifyListeners();
      } else {
        _eventsList = [];
        if (response != null) {
          CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchCalendarEvents: $e");
      _eventsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all data
  void clearData() {
    _eventsList = [];
    _isLoading = false;
    notifyListeners();
  }
}
