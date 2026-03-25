import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class InviteEventVenueListController extends ChangeNotifier {
  bool _isEventLoading = false;
  bool _isVenueLoading = false;
  bool _isEventLoadingMore = false;
  bool _isVenueLoadingMore = false;
  bool _isMembersLoading = false;
  bool _isMembersLoadingMore = false;

  List<Map<String, dynamic>> _eventItems = [];
  List<Map<String, dynamic>> _venueItems = [];
  List<Map<String, dynamic>> _memberItems = [];
  int _eventCurrentPage = 0;
  int _venueCurrentPage = 0;
  int _memberCurrentPage = 0;
  int _eventTotalPages = 0;
  int _venueTotalPages = 0;
  int _memberTotalPages = 0;
  int _eventTotalItems = 0;
  int _venueTotalItems = 0;
  int _memberTotalItems = 0;
  bool _hasMoreEvent = false;
  bool _hasMoreVenue = false;
  bool _hasMoreMember = false;

  bool get isEventLoading => _isEventLoading;
  bool get isVenueLoading => _isVenueLoading;
  bool get isEventLoadingMore => _isEventLoadingMore;
  bool get isVenueLoadingMore => _isVenueLoadingMore;
  bool get isMembersLoading => _isMembersLoading;
  bool get isMembersLoadingMore => _isMembersLoadingMore;
  List<Map<String, dynamic>> get eventItems => _eventItems;
  List<Map<String, dynamic>> get venueItems => _venueItems;
  List<Map<String, dynamic>> get memberItems => _memberItems;
  bool get hasMoreEvent => _hasMoreEvent;
  bool get hasMoreVenue => _hasMoreVenue;
  bool get hasMoreMember => _hasMoreMember;

  String _str(dynamic value) => (value ?? '').toString().trim();

  Future<void> fetchInitial(BuildContext context) async {
    await Future.wait([
      fetchList(context, type: 'event'),
      fetchList(context, type: 'venue'),
    ]);
  }

  Future<void> fetchList(
    BuildContext context, {
    required String type,
    int page = 0,
    int limit = 10,
    bool reset = true,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    if (type == 'event') {
      if (reset) {
        _isEventLoading = true;
        _eventItems = [];
        _eventCurrentPage = 0;
        _eventTotalPages = 0;
        _eventTotalItems = 0;
        _hasMoreEvent = false;
      } else {
        _isEventLoadingMore = true;
      }
    } else {
      if (reset) {
        _isVenueLoading = true;
        _venueItems = [];
        _venueCurrentPage = 0;
        _venueTotalPages = 0;
        _venueTotalItems = 0;
        _hasMoreVenue = false;
      } else {
        _isVenueLoadingMore = true;
      }
    }
    notifyListeners();

    try {
      final response = await getData(
        'common/get_event_venue_list?type=$type&page=$page&limit=$limit',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      final List<Map<String, dynamic>> parsed = [];
      if (response != null && response['success'] == true) {
        final data = response['data'];
        final rawItems = data is Map ? data['item'] : null;
        if (rawItems is List) {
          for (final item in rawItems) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            parsed.add({
              ...map,
              'id': _str(map['event_id'] ?? map['venue_id'] ?? map['_id']),
              'name': _str(
                map['event_name'] ?? map['venue_name'] ?? map['name'],
              ),
              'image': _str(
                map['event_image'] ?? map['venue_image'] ?? map['image'],
              ),
              'address': _str(map['address']),
              'time': _str(map['date'] ?? map['timing'] ?? map['time']),
              'date': _str(map['date']),
              'timing': _str(map['timing']),
              'categories': _categoryText(map['categories']),
            });
          }
        }
      }

      final totalItems = (response?['data']?['totalItems'] as num?)?.toInt() ?? parsed.length;
      final totalPages = (response?['data']?['totalPages'] as num?)?.toInt() ?? 1;
      final currentPage = (response?['data']?['currentPage'] as num?)?.toInt() ?? page;

      if (type == 'event') {
        if (reset) {
          _eventItems = parsed;
        } else {
          _eventItems.addAll(parsed);
        }
        _eventTotalItems = totalItems;
        _eventTotalPages = totalPages;
        _eventCurrentPage = currentPage;
        _hasMoreEvent = _eventItems.length < _eventTotalItems ||
            (_eventTotalPages > 0 && _eventCurrentPage < _eventTotalPages - 1);
      } else {
        if (reset) {
          _venueItems = parsed;
        } else {
          _venueItems.addAll(parsed);
        }
        _venueTotalItems = totalItems;
        _venueTotalPages = totalPages;
        _venueCurrentPage = currentPage;
        _hasMoreVenue = _venueItems.length < _venueTotalItems ||
            (_venueTotalPages > 0 && _venueCurrentPage < _venueTotalPages - 1);
      }
    } catch (_) {
      if (type == 'event') {
        if (reset) _eventItems = [];
      } else {
        if (reset) _venueItems = [];
      }
    } finally {
      if (type == 'event') {
        if (reset) {
          _isEventLoading = false;
        } else {
          _isEventLoadingMore = false;
        }
      } else {
        if (reset) {
          _isVenueLoading = false;
        } else {
          _isVenueLoadingMore = false;
        }
      }
      notifyListeners();
    }
  }

  String _categoryText(dynamic categoriesRaw) {
    if (categoriesRaw is! List) return '';
    final names = categoriesRaw
        .whereType<Map>()
        .map((e) => _str(e['category_name'] ?? e['name']))
        .where((e) => e.isNotEmpty)
        .toList();
    return names.join(', ');
  }

  Future<void> loadMoreEvents(BuildContext context, {int limit = 10}) async {
    if (_isEventLoadingMore || !_hasMoreEvent) return;
    await fetchList(
      context,
      type: 'event',
      page: _eventCurrentPage + 1,
      limit: limit,
      reset: false,
    );
  }

  Future<void> loadMoreVenues(BuildContext context, {int limit = 10}) async {
    if (_isVenueLoadingMore || !_hasMoreVenue) return;
    await fetchList(
      context,
      type: 'venue',
      page: _venueCurrentPage + 1,
      limit: limit,
      reset: false,
    );
  }

  Future<void> fetchMembers(
    BuildContext context, {
    int page = 0,
    int limit = 10,
    bool reset = true,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    if (reset) {
      _isMembersLoading = true;
      _memberItems = [];
      _memberCurrentPage = 0;
      _memberTotalPages = 0;
      _memberTotalItems = 0;
      _hasMoreMember = false;
    } else {
      _isMembersLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await getData(
        'common/get_all_members?page=$page&limit=$limit',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      final List<Map<String, dynamic>> parsed = [];
      if (response != null && response['success'] == true) {
        final data = response['data'];
        final rawItems = data is Map ? data['item'] : null;
        if (rawItems is List) {
          for (final item in rawItems) {
            if (item is! Map) continue;
            final map = Map<String, dynamic>.from(item);
            parsed.add({
              'id': _str(map['user_id'] ?? map['_id']),
              'full_name': _str(map['full_name']),
              'username': _str(map['username']),
              'profile_image': _str(map['profile_image']),
            });
          }
        }
      }
      final totalItems =
          (response?['data']?['totalItems'] as num?)?.toInt() ?? parsed.length;
      final totalPages =
          (response?['data']?['totalPages'] as num?)?.toInt() ?? 1;
      final currentPage =
          (response?['data']?['currentPage'] as num?)?.toInt() ?? page;

      if (reset) {
        _memberItems = parsed;
      } else {
        _memberItems.addAll(parsed);
      }
      _memberTotalItems = totalItems;
      _memberTotalPages = totalPages;
      _memberCurrentPage = currentPage;
      _hasMoreMember = _memberItems.length < _memberTotalItems ||
          (_memberTotalPages > 0 && _memberCurrentPage < _memberTotalPages - 1);
    } catch (_) {
      if (reset) _memberItems = [];
    } finally {
      if (reset) {
        _isMembersLoading = false;
      } else {
        _isMembersLoadingMore = false;
      }
      notifyListeners();
    }
  }

  Future<void> loadMoreMembers(BuildContext context, {int limit = 10}) async {
    if (_isMembersLoadingMore || !_hasMoreMember) return;
    await fetchMembers(
      context,
      page: _memberCurrentPage + 1,
      limit: limit,
      reset: false,
    );
  }
}
