import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';

class VibePreferenceController with ChangeNotifier {
  List<dynamic> _vibesList = [];
  List<dynamic> get getVibesList => _vibesList;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  // Store selected vibe IDs as Strings to match API response
  // Initialize as empty List<String>
  List<String> _selectedVibeIds = <String>[];

  // Getter returns a COPY to prevent modification issues
  List<String> get getSelectedVibeIds => List<String>.from(_selectedVibeIds);

  int maxSelection = 5;

  // Constructor to ensure proper initialization
  VibePreferenceController() {
    _selectedVibeIds = <String>[]; // Explicit List initialization
  }

  // Fetch vibes from API
  Future<void> fetchVibesData(BuildContext context) async {
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
    if (_vibesList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'auth/vibes',
        context,
        headers: headers,
      );

      print("API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'] is List) {
          _vibesList = response['data'];
          print("Vibes List: $_vibesList");
        } else {
          _vibesList = [];
          print("No vibes data found");
        }
        notifyListeners();
      } else {
        _vibesList = [];
        if (response != null) {
          CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchVibesData: $e");
      _vibesList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle vibe selection
  void toggleVibeSelection(String vibeId) {
    if (_selectedVibeIds.contains(vibeId)) {
      _selectedVibeIds.remove(vibeId);
    } else {
      if (_selectedVibeIds.length < maxSelection) {
        _selectedVibeIds.add(vibeId);
      }
    }
    notifyListeners();
  }

  // Check if vibe is selected
  bool isVibeSelected(String vibeId) {
    return _selectedVibeIds.contains(vibeId);
  }

  // Get selected count - FIXED: Ensure we're returning int
  int get selectedCount => _selectedVibeIds.length;

  // Get comma-separated string of selected IDs for API
  String getSelectedVibesString() {
    return _selectedVibeIds.join(',');
  }

  // Get vibe image URL
  String getVibeImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${AppConfigProvider.imageUrl}$imagePath';
  }

  // Clear selections
  void clearSelections() {
    _selectedVibeIds.clear();
    notifyListeners();
  }

  // Clear all data (useful for logout)
  void clearData() {
    _vibesList = [];
    _selectedVibeIds = <String>[]; // Explicit List initialization
    _isLoading = false;
    notifyListeners();
  }

  // Set preselected vibes (if coming back from next screen)
  void setSelectedVibes(List<String> vibeIds) {
    // Ensure we're working with a List, not a Set
    if (vibeIds is List<String>) {
      _selectedVibeIds = List<String>.from(vibeIds);
    } else {
      // If it's a Set, convert it to List
      _selectedVibeIds = vibeIds.toList().cast<String>();
    }
    notifyListeners();
  }
}
