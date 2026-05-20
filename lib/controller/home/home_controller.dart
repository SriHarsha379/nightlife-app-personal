import 'dart:developer';

import 'package:flutter/material.dart';
import 'member_details_model.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class HomeController with ChangeNotifier {
  static const int _defaultPageSize = 20;

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
  final Map<String, int> _currentPages = {'member': 0, 'event': 0, 'venue': 0};
  final Map<String, bool> _hasMorePages = {
    'member': true,
    'event': true,
    'venue': true,
  };
  final Map<String, bool> _isPaginationLoading = {
    'member': false,
    'event': false,
    'venue': false,
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
    int page = 0,
    int limit = _defaultPageSize,
    bool loadMore = false,
  }) async {
    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    if (!loadMore && _shouldShowLoading(type)) {
      _isLoading = true;
      notifyListeners();
    } else if (loadMore) {
      _setPaginationLoading(type, true);
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'feed/home_data?type=$type&page=$page&limit=$limit',
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
          _currentPages[_currentType] =
              page; // Use our page, not serverCurrentPage
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
        if (response != null) {
          // CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
      notifyListeners();
    } catch (e) {
      print("Exception in fetchHomeData for $type: $e");
      if (!loadMore) {
        _clearListByType(type);
      }
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
  void _updateListByType(String type, List<dynamic> list,
      {bool append = false}) {
    switch (type) {
      case 'member':
        _membersList = append ? [..._membersList, ...list] : list;
        break;
      case 'event':
        _eventsList = append ? [..._eventsList, ...list] : list;
        break;
      case 'venue':
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
      case 'member':
        _membersList = [];
        _currentPages['member'] = 0;
        _hasMorePages['member'] = true;
        break;
      case 'event':
        _eventsList = [];
        _currentPages['event'] = 0;
        _hasMorePages['event'] = true;
        break;
      case 'venue':
        _venuesList = [];
        _currentPages['venue'] = 0;
        _hasMorePages['venue'] = true;
        break;
    }
  }

  List<dynamic> _listByType(String type) {
    switch (type) {
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
      fetchHomeData(context, type: 'member', page: 0, limit: _defaultPageSize),
      fetchHomeData(context, type: 'event', page: 0, limit: _defaultPageSize),
      fetchHomeData(context, type: 'venue', page: 0, limit: _defaultPageSize),
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

  // Like/Unlike actions (you can implement API calls here)
  Future<bool> swipeUserAction(
    BuildContext? context, {
    required String targetUserId,
    required String action, // right | left
    bool allowRedirectOnFailure = true,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      return false;
    }

    final res = await postJsonData(
      'feed/swipe_user',
      {
        'target_user_id': targetUserId,
        'action': action,
      },
      context,
      headers: {
        'authorization': 'Bearer $token',
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

  Future<bool> eventLikeDislikeAction(
    BuildContext? context, {
    required String eventId,
    required String action, // like | dislike
    bool allowRedirectOnFailure = true,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      return false;
    }

    final res = await postJsonData(
      'event/like_dislike',
      {
        'event_id': eventId,
        'action': action,
      },
      context,
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (res != null && res['success'] == true) {
      log("show action after 15 second ============>>>>$res");

      return true;
    }
    if (res != null && allowRedirectOnFailure && context != null) {
      // CommonHelper.handleInactiveUserRedirect(context, res);
    }
    return false;
  }

  Future<bool> venueLikeDislikeAction(
    BuildContext? context, {
    required String venueId,
    required String action, // like | dislike
    bool allowRedirectOnFailure = true,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) {
      return false;
    }

    final res = await postJsonData(
      'venue/like_dislike',
      {
        'venue_id': venueId,
        'action': action,
      },
      context,
      headers: {
        'authorization': 'Bearer $token',
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

  Future<void> likeItem(BuildContext context, String id, String type) async {
    if (type == 'member') {
      await swipeUserAction(
        context,
        targetUserId: id,
        action: 'right',
      );
      return;
    }
    if (type == 'event') {
      await eventLikeDislikeAction(
        context,
        eventId: id,
        action: 'like',
      );
      return;
    }
    if (type == 'venue') {
      await venueLikeDislikeAction(
        context,
        venueId: id,
        action: 'like',
      );
      return;
    }
  }

  Future<void> dislikeItem(BuildContext context, String id, String type) async {
    if (type == 'member') {
      await swipeUserAction(
        context,
        targetUserId: id,
        action: 'left',
      );
      return;
    }
    if (type == 'event') {
      await eventLikeDislikeAction(
        context,
        eventId: id,
        action: 'dislike',
      );
      return;
    }
    if (type == 'venue') {
      await venueLikeDislikeAction(
        context,
        venueId: id,
        action: 'dislike',
      );
      return;
    }
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
