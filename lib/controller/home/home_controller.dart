import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class HomeController with ChangeNotifier {
  // Lists for different data types
  List<dynamic> _membersList = [];
  List<dynamic> _eventsList = [];
  List<dynamic> _venuesList = [];

  // Current data type
  String _currentType = 'member'; // member, event, venue

  // Getters
  List<dynamic> get getMembersList => _membersList;
  List<dynamic> get getEventsList => _eventsList;
  List<dynamic> get getVenuesList => _venuesList;
  String get getCurrentType => _currentType;

  // Loading states
  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  // Get current active list based on type
  List<dynamic> getCurrentList() {
    switch (_currentType) {
      case 'member':
        return _membersList;
      case 'event':
        return _eventsList;
      case 'venue':
        return _venuesList;
      default:
        return [];
    }
  }

  // Fetch home data from API
  Future<void> fetchHomeData(
    BuildContext context, {
    required String type,
    int page = 1,
    int limit = 5,
  }) async {
    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    // Show loading only if the specific list is empty
    if (_shouldShowLoading(type)) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'feed/home_data?type=$type&page=$page&limit=$limit',
        context,
        headers: headers,
      );

      print("API Response for $type: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null) {
          _currentType = response['data']['type'] ?? type;

          List<dynamic> list = response['data']['list'] ?? [];

          // Update the appropriate list based on type
          _updateListByType(_currentType, list);

          print("$_currentType List updated: ${list.length} items");
        } else {
          _clearListByType(type);
          print("No data found for $type");
        }
        notifyListeners();
      } else {
        _clearListByType(type);
        if (response != null) {
          CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchHomeData for $type: $e");
      _clearListByType(type);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to check if loading should be shown
  bool _shouldShowLoading(String type) {
    switch (type) {
      case 'member':
        return _membersList.isEmpty;
      case 'event':
        return _eventsList.isEmpty;
      case 'venue':
        return _venuesList.isEmpty;
      default:
        return false;
    }
  }

  // Update list based on type
  void _updateListByType(String type, List<dynamic> list) {
    switch (type) {
      case 'member':
        _membersList = list;
        break;
      case 'event':
        _eventsList = list;
        break;
      case 'venue':
        _venuesList = list;
        break;
    }
  }

  // Clear list based on type
  void _clearListByType(String type) {
    switch (type) {
      case 'member':
        _membersList = [];
        break;
      case 'event':
        _eventsList = [];
        break;
      case 'venue':
        _venuesList = [];
        break;
    }
  }

  // Change current type and fetch data if needed
  Future<void> changeType(BuildContext context, String type) async {
    if (_currentType != type) {
      _currentType = type;
      notifyListeners();

      // Fetch data if the list is empty
      if (getCurrentList().isEmpty) {
        await fetchHomeData(context, type: type);
      }
    }
  }

  // Refresh data for current type
  Future<void> refreshCurrentData(BuildContext context) async {
    await fetchHomeData(context, type: _currentType);
  }

  // Refresh all data
  Future<void> refreshAllData(BuildContext context) async {
    await Future.wait([
      fetchHomeData(context, type: 'member'),
      fetchHomeData(context, type: 'event'),
      fetchHomeData(context, type: 'venue'),
    ]);
  }

  // Get item by index from current list
  dynamic getItemByIndex(int index) {
    final list = getCurrentList();
    if (index >= 0 && index < list.length) {
      return list[index];
    }
    return null;
  }

  // Get member by ID
  dynamic getMemberById(String id) {
    try {
      return _membersList.firstWhere((member) => member['_id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get event by ID
  dynamic getEventById(String id) {
    try {
      return _eventsList.firstWhere((event) => event['_id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get venue by ID
  dynamic getVenueById(String id) {
    try {
      return _venuesList.firstWhere((venue) => venue['_id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Remove item from current list (for swipe actions)
  void removeItemFromCurrentList(int index) {
    final list = getCurrentList();
    if (index >= 0 && index < list.length) {
      switch (_currentType) {
        case 'member':
          _membersList.removeAt(index);
          break;
        case 'event':
          _eventsList.removeAt(index);
          break;
        case 'venue':
          _venuesList.removeAt(index);
          break;
      }
      notifyListeners();
    }
  }

  // Clear all data (useful for logout)
  void clearAllData() {
    _membersList = [];
    _eventsList = [];
    _venuesList = [];
    _currentType = 'member';
    _isLoading = false;
    notifyListeners();
  }

  // Get current list count
  int getCurrentListCount() {
    return getCurrentList().length;
  }

  // Check if current list is empty
  bool isCurrentListEmpty() {
    return getCurrentList().isEmpty;
  }

  // Like/Unlike actions (you can implement API calls here)
  Future<void> likeItem(BuildContext context, String id, String type) async {
    // Implement like API call
    print("Liked $type with id: $id");
    // TODO: Add API call for like action
  }

  Future<void> dislikeItem(BuildContext context, String id, String type) async {
    // Implement dislike API call
    print("Disliked $type with id: $id");
    // TODO: Add API call for dislike action
  }
}
