import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class EventDetailsController with ChangeNotifier {
  dynamic _eventDetails = {};
  dynamic get getEventDetails => _eventDetails;

  // String? _lastFetchedEventId;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  //! Fetch genres from API
  Future<void> fetchEventData(BuildContext context, String eventId) async {
    // final bool hasData = _eventDetails is List
    //     ? (_eventDetails as List).isNotEmpty
    //     : _eventDetails is Map
    //         ? (_eventDetails as Map).isNotEmpty
    //         : _eventDetails != null;

    // // Keep existing data if the requested event is already loaded.
    // if (_lastFetchedEventId == eventId && hasData) {
    //   return;
    // }

    String token = AppConstant.token;
    // String token =
    //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NzQ2NDhjNzUzMDc2MDY5MDg0ZmIzNCIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc2OTIzNjUzOSwiZXhwIjoxNzcxODI4NTM5fQ.AC6BJrsvAvqoAFhwWWDR8AuKkaVr5k4ShjdNlFWDw2A";
    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    // Show loading only if list is empty
    if (_eventDetails.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'event/event_detail/$eventId',
        context,
        headers: headers,
      );

      print("API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'].isNotEmpty) {
          _eventDetails = response['data'];
          print("Event Details: $_eventDetails");
          // _lastFetchedEventId = eventId;
          print("Event Details: $_eventDetails");
        } else {
          _eventDetails = [];
          // _lastFetchedEventId = eventId;
          print("No genres data found");
        }
        notifyListeners();
      } else {
        _eventDetails = [];
        if (response != null) {
          CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchGenresData: $e");
      _eventDetails = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}
