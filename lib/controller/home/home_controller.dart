import 'dart:developer';

import 'package:flutter/material.dart';
import 'member_details_model.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class HomeController with ChangeNotifier {
  static const int _defaultPageSize = 20;
  static const String _memberType = 'member';
  static const String _eventType = 'event';
  static const String _venueType = 'venue';

  // Lists for different data types
  List<dynamic> _membersList = [];
  List<dynamic> _eventsList = [];
  List<dynamic> _venuesList = [];
  // Tracks vibes of accepted profiles for recommendation
  final Set<String> _preferredVibes = {};
  List<String> get getPreferredVibes => _preferredVibes.toList();

  void recordAcceptedVibes(List<String> vibes) {
    _preferredVibes.addAll(vibes);
    notifyListeners();
  }

  // Current data type
  String _currentType = _memberType; // member, event, venue

  // Browsing city override — lets the user browse a different city's
  // content than their saved profile city (e.g. planning a weekend trip),
  // without changing their permanent profile city. Null means "use my
  // profile city" (the backend falls back to that automatically).
  String? _selectedCityId;
  String? _selectedCityName;
  String? get getSelectedCityId => _selectedCityId;
  String? get getSelectedCityName => _selectedCityName;

  void setSelectedCity(BuildContext context, String cityId, String cityName) {
    _selectedCityId = cityId;
    _selectedCityName = cityName;

    // Clear cached lists/pagination so the switch to the new city shows
    // fresh data immediately instead of stale results from the old city.
    _membersList = [];
    _eventsList = [];
    _venuesList = [];
    _currentPages[_memberType] = 0;
    _currentPages[_eventType] = 0;
    _currentPages[_venueType] = 0;
    _hasMorePages[_memberType] = true;
    _hasMorePages[_eventType] = true;
    _hasMorePages[_venueType] = true;
    notifyListeners();

    fetchHomeData(context, type: _currentType);
  }

  // Getters
  List<dynamic> get getMembersList => _membersList;
  List<dynamic> get getEventsList => _eventsList;
  List<dynamic> get getVenuesList => _venuesList;
  String get getCurrentType => _currentType;

  // Loading states
  bool _isLoading = false;
  bool get getIsLoading => _isLoading;
  final Map<String, int> _currentPages = {
    _memberType: 0,
    _eventType: 0,
    _venueType: 0,
  };
  final Map<String, bool> _hasMorePages = {
    _memberType: true,
    _eventType: true,
    _venueType: true,
  };
  final Map<String, bool> _isPaginationLoading = {
    _memberType: false,
    _eventType: false,
    _venueType: false,
  };
  bool _notificationStatus = false;
  bool get getNotificationStatus => _notificationStatus;
  bool _isMemberDetailLoading = false;
  bool get getIsMemberDetailLoading => _isMemberDetailLoading;
  Map<String, dynamic>? _memberDetail;
  Map<String, dynamic>? get getMemberDetail => _memberDetail;
  MemberDetailsModel? _memberDetailsModel;
  MemberDetailsModel? get getMemberDetailsModel => _memberDetailsModel;

  // Get current active list based on type
  List<dynamic> getCurrentList() {
    switch (_currentType) {
      case _memberType:
        return _membersList;
      case _eventType:
        return _eventsList;
      case _venueType:
        return _venuesList;
      default:
        return [];
    }
  }

  Map<String, String>? _authorizedHeaders() {
    final token = AppConstant.token;
    if (token.isEmpty) return null;
    return {'Authorization': 'Bearer $token'};
  }

  // Fetch home data from API
  Future<void> fetchHomeData(
    BuildContext context, {
    required String type,
    int page = 0,
    int limit = _defaultPageSize,
    bool loadMore = false,
  }) async {
    final headers = _authorizedHeaders();
    if (headers == null) {
      print("Token is missing!");
      return;
    }

    if (!loadMore && _shouldShowLoading(type)) {
      _isLoading = true;
      notifyListeners();
    } else if (loadMore) {
      _setPaginationLoading(type, true);
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'feed/home_data?type=$type&page=$page&limit=$limit${_preferredVibes.isNotEmpty ? '&preferred_vibes=${Uri.encodeComponent(_preferredVibes.join(','))}' : ''}${_selectedCityId != null ? '&city_id=${Uri.encodeComponent(_selectedCityId!)}' : ''}',
        context,
        headers: headers,
      );

      print("API Response for $type - Page $page: $response");

      if (response != null && response['success'] == true) {
        // CRITICAL FIX: Check if this is actually a home_data response
        if (response['data'] != null && response['data']['list'] != null) {
          _currentType = response['data']['type'] ?? type;
          _notificationStatus =
              (response['data']['notification_status'] ?? false) == true;

          List<dynamic> list = _normalizeHomeList(response['data']['list']);

          final int totalPages =
              int.tryParse('${response['data']['total_pages']}') ?? 0;
          final int serverCurrentPage =
              int.tryParse('${response['data']['current_page']}') ?? page;

          // FIXED: Correct pagination logic
          bool hasMore = false;

          // Method 1: Use totalPages if available
          if (totalPages > 0) {
            // Since we use 0-based pages, there are more if current page < totalPages - 1
            // Example: totalPages=2 means pages 0 and 1
            // So page 0 has more (0 < 1), page 1 has no more (1 not < 1)
            hasMore = page < (totalPages - 1);
          }
          // Method 2: If totalPages not reliable, use list length
          else if (list.length >= limit) {
            hasMore = true;
          }

          // Method 3: If list is empty or less than limit, definitely no more
          if (list.isEmpty || list.length < limit) {
            hasMore = false;
          }

          // Update the list
          _updateListByType(_currentType, list, append: loadMore);

          // Store the page
          _currentPages[_currentType] = page; // Use our page, not serverCurrentPage
          _hasMorePages[_currentType] = hasMore;

          print("$_currentType List updated: ${list.length} items");
          print(
              "hasMore: $hasMore, totalPages: $totalPages, currentPage: $page");
        } else {
          print("Ignoring non-home_data response for $type");
          _setPaginationLoading(type, false);
          notifyListeners();
          return;
        }
      } else {
        if (!loadMore) {
          _clearListByType(type);
        }
        if (response == null) {
          // Connection error — stop retrying
          _hasMorePages[type] = false;
        } else {
          // CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
      notifyListeners();
    } catch (e) {
      print("Exception in fetchHomeData for $type: $e");
      if (!loadMore) {
        _clearListByType(type);
      }
      // Stop infinite retry on connection errors
      _hasMorePages[type] = false;
    } finally {
      _isLoading = false;
      _setPaginationLoading(type, false);
      notifyListeners();
    }
  }

  Future<void> fetchNextPage(
    BuildContext context, {
    required String type,
    int limit = _defaultPageSize,
  }) async {
    final bool isLoadingNext = _isPaginationLoading[type] ?? false;
    final bool hasMore = _hasMorePages[type] ?? true;

    if (isLoadingNext || !hasMore) {
      print(
          "Not loading next page for $type - isLoadingNext: $isLoadingNext, hasMore: $hasMore");
      return;
    }

    final int currentPage = _currentPages[type] ?? 0;
    final int nextPage = currentPage + 1;

    print("Fetching next page for $type: page $nextPage");

    await fetchHomeData(
      context,
      type: type,
      page: nextPage,
      limit: limit,
      loadMore: true,
    );
  }

  bool hasMoreForType(String type) => _hasMorePages[type] ?? false;
  bool isPaginationLoadingForType(String type) =>
      _isPaginationLoading[type] ?? false;

  void clearNotificationStatus() {
    if (_notificationStatus) {
      _notificationStatus = false;
      notifyListeners();
    }
  }

  // Helper method to check if loading should be shown
  bool _shouldShowLoading(String type) {
    switch (type) {
      case _memberType:
        return _membersList.isEmpty;
      case _eventType:
        return _eventsList.isEmpty;
      case _venueType:
        return _venuesList.isEmpty;
      default:
        return false;
    }
  }

  // Update list based on type
  void _updateListByType(String type, List<dynamic> list,
      {bool append = false}) {
    switch (type) {
      case _memberType:
        _membersList = append ? [..._membersList, ...list] : list;
        break;
      case _eventType:
        _eventsList = append ? [..._eventsList, ...list] : list;
        break;
      case _venueType:
        _venuesList = append ? [..._venuesList, ...list] : list;
        break;
    }
  }

  List<dynamic> _normalizeHomeList(dynamic rawList) {
    if (rawList is! List) return <dynamic>[];

    return rawList.map((item) {
      if (item is! Map) return item;
      final normalized = Map<String, dynamic>.from(item);
      final type = (normalized['type'] ?? '').toString().trim().toLowerCase();
      if (type == 'ad') {
        normalized['type'] = 'ad';
      }
      return normalized;
    }).toList(growable: false);
  }

  // Clear list based on type
  void _clearListByType(String type) {
    switch (type) {
      case _memberType:
        _membersList = [];
        _currentPages[_memberType] = 0;
        _hasMorePages[_memberType] = true;
        break;
      case _eventType:
        _eventsList = [];
        _currentPages[_eventType] = 0;
        _hasMorePages[_eventType] = true;
        break;
      case _venueType:
        _venuesList = [];
        _currentPages[_venueType] = 0;
        _hasMorePages[_venueType] = true;
        break;
    }
  }

  List<dynamic> _listByType(String type) {
    switch (type) {
      case _memberType:
        return _membersList;
      case _eventType:
        return _eventsList;
      case _venueType:
        return _venuesList;
      default:
        return [];
    }
  }

  void _setPaginationLoading(String type, bool value) {
    if (_isPaginationLoading.containsKey(type)) {
      _isPaginationLoading[type] = value;
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
    _clearListByType(_currentType);
    await fetchHomeData(
      context,
      type: _currentType,
      page: 0,
      limit: _defaultPageSize,
    );
  }

  // Refresh all data
  Future<void> refreshAllData(BuildContext context) async {
    await Future.wait([
      fetchHomeData(context, type: _memberType, page: 0, limit: _defaultPageSize),
      fetchHomeData(context, type: _eventType, page: 0, limit: _defaultPageSize),
      fetchHomeData(context, type: _venueType, page: 0, limit: _defaultPageSize),
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

  Future<Map<String, dynamic>?> fetchMemberDetail(
    BuildContext context, {
    required String memberId,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty || memberId.isEmpty) {
      return null;
    }

    _isMemberDetailLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'feed/member_detail/$memberId',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          _memberDetail = data;
          _memberDetailsModel = MemberDetailsModel.fromJson(data);
          notifyListeners();
          return _memberDetail;
        }
        _memberDetail = null;
        _memberDetailsModel = null;
        notifyListeners();
      } else if (response != null) {
        // CommonHelper.handleInactiveUserRedirect(context, response);
      }
    } catch (e) {
      log("fetchMemberDetail error: $e");
      _memberDetail = null;
      _memberDetailsModel = null;
      notifyListeners();
    } finally {
      _isMemberDetailLoading = false;
      notifyListeners();
    }
    return null;
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
        case _memberType:
          _membersList.removeAt(index);
          break;
        case _eventType:
          _eventsList.removeAt(index);
          break;
        case _venueType:
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
    _currentType = _memberType;
    _isLoading = false;
    _currentPages.updateAll((key, value) => 0);
    _hasMorePages.updateAll((key, value) => true);
    _isPaginationLoading.updateAll((key, value) => false);
    _notificationStatus = false;
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

  Future<bool> _postItemAction(
    BuildContext? context, {
    required String endpoint,
    required Map<String, dynamic> payload,
    bool allowRedirectOnFailure = true,
  }) async {
    final headers = _authorizedHeaders();
    if (headers == null) {
      return false;
    }

    final res = await postJsonData(
      endpoint,
      payload,
      context,
      headers: {
        'authorization': headers['Authorization']!,
      },
    );

    if (res != null && res['success'] == true) {
      return true;
    }
    if (res != null && allowRedirectOnFailure && context != null) {
      // CommonHelper.handleInactiveUserRedirect(context, res);
    }
    return false;
  }

  // Like/Unlike actions (you can implement API calls here)
  Future<bool> swipeUserAction(
    BuildContext? context, {
    required String targetUserId,
    required String action, // right | left
    bool allowRedirectOnFailure = true,
  }) async {
    return _postItemAction(
      context,
      endpoint: 'feed/swipe_user',
      payload: {
        'target_user_id': targetUserId,
        'action': action,
      },
      allowRedirectOnFailure: allowRedirectOnFailure,
    );
  }

  Future<bool> eventLikeDislikeAction(
    BuildContext? context, {
    required String eventId,
    required String action, // like | dislike
    bool allowRedirectOnFailure = true,
  }) async {
    final didSucceed = await _postItemAction(
      context,
      endpoint: 'event/like_dislike',
      payload: {
        'event_id': eventId,
        'action': action,
      },
      allowRedirectOnFailure: allowRedirectOnFailure,
    );
    if (didSucceed) {
      log("show action after 15 seconds ============>>>>eventId=$eventId action=$action");
    }
    return didSucceed;
  }

  Future<bool> venueLikeDislikeAction(
    BuildContext? context, {
    required String venueId,
    required String action, // like | dislike
    bool allowRedirectOnFailure = true,
  }) async {
    return _postItemAction(
      context,
      endpoint: 'venue/like_dislike',
      payload: {
        'venue_id': venueId,
        'action': action,
      },
      allowRedirectOnFailure: allowRedirectOnFailure,
    );
  }

  Future<void> _applyItemAction(
    BuildContext context, {
    required String id,
    required String type,
    required String action,
  }) async {
    if (type == _memberType) {
      await swipeUserAction(
        context,
        targetUserId: id,
        action: action,
      );
      return;
    }
    if (type == _eventType) {
      await eventLikeDislikeAction(
        context,
        eventId: id,
        action: action,
      );
      return;
    }
    if (type == _venueType) {
      await venueLikeDislikeAction(
        context,
        venueId: id,
        action: action,
      );
    }
  }

  Future<void> likeItem(BuildContext context, String id, String type) async {
    await _applyItemAction(
      context,
      id: id,
      type: type,
      action: type == _memberType ? 'right' : 'like',
    );
  }

  Future<void> dislikeItem(BuildContext context, String id, String type) async {
    await _applyItemAction(
      context,
      id: id,
      type: type,
      action: type == _memberType ? 'left' : 'dislike',
    );
  }
}

// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'member_details_model.dart';
// import '../../provider/common_api_helper.dart';
// import '../../utilities/app_constant.dart';

// class HomeController with ChangeNotifier {
//   static const int _defaultPageSize = 20;

//   // Lists for different data types
//   List<dynamic> _membersList = [];
//   List<dynamic> _eventsList = [];
//   List<dynamic> _venuesList = [];

//   // Current data type
//   String _currentType = 'member'; // member, event, venue

//   // Getters
//   List<dynamic> get getMembersList => _membersList;
//   List<dynamic> get getEventsList => _eventsList;
//   List<dynamic> get getVenuesList => _venuesList;
//   String get getCurrentType => _currentType;

//   // Loading states
//   bool _isLoading = false;
//   bool get getIsLoading => _isLoading;
//   final Map<String, int> _currentPages = {'member': 0, 'event': 0, 'venue': 0};
//   final Map<String, bool> _hasMorePages = {
//     'member': true,
//     'event': true,
//     'venue': true,
//   };
//   final Map<String, bool> _isPaginationLoading = {
//     'member': false,
//     'event': false,
//     'venue': false,
//   };

//   // Request tracking to prevent response mixing
//   final Map<String, int> _requestedPages = {
//     'member': -1,
//     'event': -1,
//     'venue': -1,
//   };

//   // Track active requests to cancel them
//   final Map<String, bool> _activeRequests = {
//     'member': false,
//     'event': false,
//     'venue': false,
//   };

//   bool _notificationStatus = false;
//   bool get getNotificationStatus => _notificationStatus;
//   bool _isMemberDetailLoading = false;
//   bool get getIsMemberDetailLoading => _isMemberDetailLoading;
//   Map<String, dynamic>? _memberDetail;
//   Map<String, dynamic>? get getMemberDetail => _memberDetail;
//   MemberDetailsModel? _memberDetailsModel;
//   MemberDetailsModel? get getMemberDetailsModel => _memberDetailsModel;

//   // Get current active list based on type
//   List<dynamic> getCurrentList() {
//     switch (_currentType) {
//       case 'member':
//         return _membersList;
//       case 'event':
//         return _eventsList;
//       case 'venue':
//         return _venuesList;
//       default:
//         return [];
//     }
//   }

//   // Fetch home data from API
//   Future<void> fetchHomeData(
//     BuildContext context, {
//     required String type,
//     int page = 0,
//     int limit = _defaultPageSize,
//     bool loadMore = false,
//   }) async {
//     String token = AppConstant.token;

//     if (token.isEmpty) {
//       print("Token is missing!");
//       return;
//     }

//     // Mark this page as requested
//     _requestedPages[type] = page;

//     // Mark request as active
//     _activeRequests[type] = true;

//     Map<String, String> headers = {
//       'Authorization': 'Bearer $token',
//     };

//     // Show loading indicators
//     if (!loadMore && _shouldShowLoading(type)) {
//       _isLoading = true;
//       notifyListeners();
//     } else if (loadMore) {
//       _setPaginationLoading(type, true);
//       notifyListeners();
//     }

//     try {
//       final response = await getFormData(
//         'feed/home_data?type=$type&page=$page&limit=$limit',
//         context,
//         headers: headers,
//       );

//       // Check if this request was cancelled by checking if a new page was requested
//       if (!_activeRequests[type]! || _requestedPages[type] != page) {
//         print("Request cancelled or stale for $type page $page");
//         _setPaginationLoading(type, false);
//         _activeRequests[type] = false;
//         notifyListeners();
//         return;
//       }

//       print("API Response for $type - Page $page: $response");

//       if (response != null && response['success'] == true) {
//         // Check if this is actually a home_data response
//         if (response['data'] != null && response['data']['list'] != null) {
//           _currentType = response['data']['type'] ?? type;
//           _notificationStatus =
//               (response['data']['notification_status'] ?? false) == true;

//           List<dynamic> list = response['data']['list'] ?? [];

//           final int totalPages =
//               int.tryParse('${response['data']['total_pages']}') ?? 0;

//           // FIXED: Correct pagination logic
//           bool hasMore = false;

//           // Method 1: Use totalPages if available
//           if (totalPages > 0) {
//             // Since we use 0-based pages, there are more if current page < totalPages - 1
//             // Example: totalPages=2 means pages 0 and 1
//             // So page 0 has more (0 < 1), page 1 has no more (1 not < 1)
//             hasMore = page < (totalPages - 1);
//           }
//           // Method 2: If totalPages not reliable, use list length
//           else if (list.length >= limit) {
//             hasMore = true;
//           }

//           // Method 3: If list is empty or less than limit, definitely no more
//           if (list.isEmpty || list.length < limit) {
//             hasMore = false;
//           }

//           // Update the list
//           _updateListByType(_currentType, list, append: loadMore);

//           // Store the page
//           _currentPages[_currentType] = page;
//           _hasMorePages[_currentType] = hasMore;

//           print("$_currentType List updated: ${list.length} items");
//           print(
//               "hasMore: $hasMore, totalPages: $totalPages, currentPage: $page");
//         } else {
//           print("Ignoring non-home_data response for $type");
//         }
//       } else {
//         if (!loadMore) {
//           _clearListByType(type);
//         }
//         if (response != null) {
//           CommonHelper.handleInactiveUserRedirect(context, response);
//         }
//       }
//       notifyListeners();
//     } catch (e) {
//       // Check if this is still the active request
//       if (_activeRequests[type]! && _requestedPages[type] == page) {
//         print("Exception in fetchHomeData for $type: $e");
//         if (!loadMore) {
//           _clearListByType(type);
//         }
//       } else {
//         print("Ignored error for cancelled/stale request $type page $page: $e");
//       }
//     } finally {
//       _isLoading = false;
//       _setPaginationLoading(type, false);
//       _activeRequests[type] = false;
//       notifyListeners();
//     }
//   }

//   Future<void> fetchNextPage(
//     BuildContext context, {
//     required String type,
//     int limit = _defaultPageSize,
//   }) async {
//     final bool isLoadingNext = _isPaginationLoading[type] ?? false;
//     final bool hasMore = _hasMorePages[type] ?? true;

//     if (isLoadingNext || !hasMore) {
//       print(
//           "Not loading next page for $type - isLoadingNext: $isLoadingNext, hasMore: $hasMore");
//       return;
//     }

//     final int currentPage = _currentPages[type] ?? 0;
//     final int nextPage = currentPage + 1;

//     print("Fetching next page for $type: page $nextPage");

//     await fetchHomeData(
//       context,
//       type: type,
//       page: nextPage,
//       limit: limit,
//       loadMore: true,
//     );
//   }

//   bool hasMoreForType(String type) => _hasMorePages[type] ?? false;
//   bool isPaginationLoadingForType(String type) =>
//       _isPaginationLoading[type] ?? false;

//   void clearNotificationStatus() {
//     if (_notificationStatus) {
//       _notificationStatus = false;
//       notifyListeners();
//     }
//   }

//   // Helper method to check if loading should be shown
//   bool _shouldShowLoading(String type) {
//     switch (type) {
//       case 'member':
//         return _membersList.isEmpty;
//       case 'event':
//         return _eventsList.isEmpty;
//       case 'venue':
//         return _venuesList.isEmpty;
//       default:
//         return false;
//     }
//   }

//   // Update list based on type
//   void _updateListByType(String type, List<dynamic> list,
//       {bool append = false}) {
//     switch (type) {
//       case 'member':
//         _membersList = append ? [..._membersList, ...list] : list;
//         break;
//       case 'event':
//         _eventsList = append ? [..._eventsList, ...list] : list;
//         break;
//       case 'venue':
//         _venuesList = append ? [..._venuesList, ...list] : list;
//         break;
//     }
//   }

//   // Clear list based on type
//   void _clearListByType(String type) {
//     switch (type) {
//       case 'member':
//         _membersList = [];
//         _currentPages['member'] = 0;
//         _hasMorePages['member'] = true;
//         break;
//       case 'event':
//         _eventsList = [];
//         _currentPages['event'] = 0;
//         _hasMorePages['event'] = true;
//         break;
//       case 'venue':
//         _venuesList = [];
//         _currentPages['venue'] = 0;
//         _hasMorePages['venue'] = true;
//         break;
//     }
//   }

//   List<dynamic> _listByType(String type) {
//     switch (type) {
//       case 'member':
//         return _membersList;
//       case 'event':
//         return _eventsList;
//       case 'venue':
//         return _venuesList;
//       default:
//         return [];
//     }
//   }

//   void _setPaginationLoading(String type, bool value) {
//     if (_isPaginationLoading.containsKey(type)) {
//       _isPaginationLoading[type] = value;
//     }
//   }

//   // Cancel all ongoing requests
//   void cancelAllRequests() {
//     for (var type in _activeRequests.keys) {
//       _activeRequests[type] = false;
//     }
//   }

//   // Change current type and fetch data if needed
//   Future<void> changeType(BuildContext context, String type) async {
//     if (_currentType != type) {
//       _currentType = type;
//       notifyListeners();

//       // Fetch data if the list is empty
//       if (getCurrentList().isEmpty) {
//         await fetchHomeData(context, type: type);
//       }
//     }
//   }

//   // Refresh data for current type
//   Future<void> refreshCurrentData(BuildContext context) async {
//     // Cancel any ongoing request for current type
//     _activeRequests[_currentType] = false;
//     _clearListByType(_currentType);
//     await fetchHomeData(
//       context,
//       type: _currentType,
//       page: 0,
//       limit: _defaultPageSize,
//     );
//   }

//   // Refresh all data
//   Future<void> refreshAllData(BuildContext context) async {
//     // Cancel all ongoing requests
//     cancelAllRequests();

//     await Future.wait([
//       fetchHomeData(context, type: 'member', page: 0, limit: _defaultPageSize),
//       fetchHomeData(context, type: 'event', page: 0, limit: _defaultPageSize),
//       fetchHomeData(context, type: 'venue', page: 0, limit: _defaultPageSize),
//     ]);
//   }

//   // Get item by index from current list
//   dynamic getItemByIndex(int index) {
//     final list = getCurrentList();
//     if (index >= 0 && index < list.length) {
//       return list[index];
//     }
//     return null;
//   }

//   // Get member by ID
//   dynamic getMemberById(String id) {
//     try {
//       return _membersList.firstWhere((member) => member['_id'] == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<Map<String, dynamic>?> fetchMemberDetail(
//     BuildContext context, {
//     required String memberId,
//   }) async {
//     final token = AppConstant.token;
//     if (token.isEmpty || memberId.isEmpty) {
//       return null;
//     }

//     _isMemberDetailLoading = true;
//     notifyListeners();

//     try {
//       final response = await getData(
//         'feed/member_detail/$memberId',
//         context,
//         headers: {
//           'authorization': 'Bearer $token',
//         },
//       );

//       if (response != null && response['success'] == true) {
//         final data = response['data'];
//         if (data is Map<String, dynamic>) {
//           _memberDetail = data;
//           _memberDetailsModel = MemberDetailsModel.fromJson(data);
//           notifyListeners();
//           return _memberDetail;
//         }
//         _memberDetail = null;
//         _memberDetailsModel = null;
//         notifyListeners();
//       } else if (response != null) {
//         CommonHelper.handleInactiveUserRedirect(context, response);
//       }
//     } catch (e) {
//       log("fetchMemberDetail error: $e");
//       _memberDetail = null;
//       _memberDetailsModel = null;
//       notifyListeners();
//     } finally {
//       _isMemberDetailLoading = false;
//       notifyListeners();
//     }
//     return null;
//   }

//   // Get event by ID
//   dynamic getEventById(String id) {
//     try {
//       return _eventsList.firstWhere((event) => event['_id'] == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Get venue by ID
//   dynamic getVenueById(String id) {
//     try {
//       return _venuesList.firstWhere((venue) => venue['_id'] == id);
//     } catch (e) {
//       return null;
//     }
//   }

//   // Remove item from current list (for swipe actions)
//   void removeItemFromCurrentList(int index) {
//     final list = getCurrentList();
//     if (index >= 0 && index < list.length) {
//       switch (_currentType) {
//         case 'member':
//           _membersList.removeAt(index);
//           break;
//         case 'event':
//           _eventsList.removeAt(index);
//           break;
//         case 'venue':
//           _venuesList.removeAt(index);
//           break;
//       }
//       notifyListeners();
//     }
//   }

//   // Clear all data (useful for logout)
//   void clearAllData() {
//     // Cancel all ongoing requests
//     cancelAllRequests();

//     _membersList = [];
//     _eventsList = [];
//     _venuesList = [];
//     _currentType = 'member';
//     _isLoading = false;
//     _currentPages.updateAll((key, value) => 0);
//     _hasMorePages.updateAll((key, value) => true);
//     _isPaginationLoading.updateAll((key, value) => false);
//     _requestedPages.updateAll((key, value) => -1);
//     _notificationStatus = false;
//     notifyListeners();
//   }

//   // Get current list count
//   int getCurrentListCount() {
//     return getCurrentList().length;
//   }

//   // Check if current list is empty
//   bool isCurrentListEmpty() {
//     return getCurrentList().isEmpty;
//   }

//   // Like/Unlike actions
//   Future<bool> swipeUserAction(
//     BuildContext? context, {
//     required String targetUserId,
//     required String action, // right | left
//     bool allowRedirectOnFailure = true,
//   }) async {
//     final token = AppConstant.token;
//     if (token.isEmpty) {
//       return false;
//     }

//     final res = await postJsonData(
//       'feed/swipe_user',
//       {
//         'target_user_id': targetUserId,
//         'action': action,
//       },
//       context,
//       headers: {
//         'authorization': 'Bearer $token',
//       },
//     );

//     if (res != null && res['success'] == true) {
//       return true;
//     }
//     if (res != null && allowRedirectOnFailure && context != null) {
//       CommonHelper.handleInactiveUserRedirect(context, res);
//     }
//     return false;
//   }

//   Future<bool> eventLikeDislikeAction(
//     BuildContext? context, {
//     required String eventId,
//     required String action, // like | dislike
//     bool allowRedirectOnFailure = true,
//   }) async {
//     final token = AppConstant.token;
//     if (token.isEmpty) {
//       return false;
//     }

//     final res = await postJsonData(
//       'event/like_dislike',
//       {
//         'event_id': eventId,
//         'action': action,
//       },
//       context,
//       headers: {
//         'authorization': 'Bearer $token',
//       },
//     );

//     if (res != null && res['success'] == true) {
//       log("show action after 15 second ============>>>>$res");
//       return true;
//     }
//     if (res != null && allowRedirectOnFailure && context != null) {
//       CommonHelper.handleInactiveUserRedirect(context, res);
//     }
//     return false;
//   }

//   Future<bool> venueLikeDislikeAction(
//     BuildContext? context, {
//     required String venueId,
//     required String action, // like | dislike
//     bool allowRedirectOnFailure = true,
//   }) async {
//     final token = AppConstant.token;
//     if (token.isEmpty) {
//       return false;
//     }

//     final res = await postJsonData(
//       'venue/like_dislike',
//       {
//         'venue_id': venueId,
//         'action': action,
//       },
//       context,
//       headers: {
//         'authorization': 'Bearer $token',
//       },
//     );

//     if (res != null && res['success'] == true) {
//       return true;
//     }
//     if (res != null && allowRedirectOnFailure && context != null) {
//       CommonHelper.handleInactiveUserRedirect(context, res);
//     }
//     return false;
//   }

//   Future<void> likeItem(BuildContext context, String id, String type) async {
//     if (type == 'member') {
//       await swipeUserAction(
//         context,
//         targetUserId: id,
//         action: 'right',
//       );
//       return;
//     }
//     if (type == 'event') {
//       await eventLikeDislikeAction(
//         context,
//         eventId: id,
//         action: 'like',
//       );
//       return;
//     }
//     if (type == 'venue') {
//       await venueLikeDislikeAction(
//         context,
//         venueId: id,
//         action: 'like',
//       );
//       return;
//     }
//   }

//   Future<void> dislikeItem(BuildContext context, String id, String type) async {
//     if (type == 'member') {
//       await swipeUserAction(
//         context,
//         targetUserId: id,
//         action: 'left',
//       );
//       return;
//     }
//     if (type == 'event') {
//       await eventLikeDislikeAction(
//         context,
//         eventId: id,
//         action: 'dislike',
//       );
//       return;
//     }
//     if (type == 'venue') {
//       await venueLikeDislikeAction(
//         context,
//         venueId: id,
//         action: 'dislike',
//       );
//       return;
//     }
//   }
// }
