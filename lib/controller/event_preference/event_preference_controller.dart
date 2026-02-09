import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class EventPreferenceController with ChangeNotifier {
  List<dynamic> _eventsList = [];
  List<dynamic> get getEventsList => _eventsList;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  // Store selected event IDs
  Set<String> _selectedEventIds = {};
  Set<String> get getSelectedEventIds => _selectedEventIds;

  int maxSelection = 5;

  // Fetch events from API
  Future<void> fetchEventsData(BuildContext context) async {
    // String token = AppConstant.token;
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NzQ2NDhjNzUzMDc2MDY5MDg0ZmIzNCIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc2OTIzNjUzOSwiZXhwIjoxNzcxODI4NTM5fQ.AC6BJrsvAvqoAFhwWWDR8AuKkaVr5k4ShjdNlFWDw2A";
    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    // Show loading only if list is empty
    if (_eventsList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'auth/event-preferences',
        context,
        headers: headers,
      );

      print("API Response: $response");

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
      print("Exception in fetchEventsData: $e");
      _eventsList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle event selection
  void toggleEventSelection(String eventId) {
    if (_selectedEventIds.contains(eventId)) {
      _selectedEventIds.remove(eventId);
    } else {
      if (_selectedEventIds.length < maxSelection) {
        _selectedEventIds.add(eventId);
      }
    }
    notifyListeners();
  }

  // Check if event is selected
  bool isEventSelected(String eventId) {
    return _selectedEventIds.contains(eventId);
  }

  // Get selected count
  int get selectedCount => _selectedEventIds.length;

  // Get comma-separated string of selected IDs for API
  String getSelectedEventsString() {
    return _selectedEventIds.join(',');
  }

  // Clear selections
  void clearSelections() {
    _selectedEventIds.clear();
    notifyListeners();
  }

  // Clear all data (useful for logout)
  void clearData() {
    _eventsList = [];
    _selectedEventIds = {};
    _isLoading = false;
    notifyListeners();
  }

  // Set preselected events (if coming back from next screen)
  void setSelectedEvents(Set<String> eventIds) {
    _selectedEventIds = eventIds;
    notifyListeners();
  }
}
