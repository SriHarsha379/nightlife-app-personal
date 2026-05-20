import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class LikedBookedEventController extends ChangeNotifier {
  // ── Liked ──────────────────────────────────────────────────────────────────
  bool _isLikedEventsLoading = false;
  bool _isLikedLoadingMore = false;
  List<dynamic> _likedEvents = [];
  int _likedCurrentPage = 0;
  int _likedTotalPages = 0;
  int _likedTotalItems = 0;
  bool _hasMoreLiked = false;

  bool get isLikedEventsLoading => _isLikedEventsLoading;
  bool get isLikedLoadingMore => _isLikedLoadingMore;
  List<dynamic> get likedEvents => _likedEvents;
  bool get hasMoreLiked => _hasMoreLiked;

  // ── Booked / Upcoming ────────────────────────────────────────────────────
  bool _isBookedEventsLoading = false;
  List<dynamic> _upcomingEvents = [];

  bool get isBookedEventsLoading => _isBookedEventsLoading;
  List<dynamic> get upcomingEvents => _upcomingEvents;

  bool _isPastLoadingMore = false;
  bool _isPastFullyLoaded = false;
  List<dynamic> _pastBookings = [];
  int _pastTotalRecords = 0;
  bool _hasMorePast = false;

  bool get isPastLoadingMore => _isPastLoadingMore;
  List<dynamic> get pastBookings => _pastBookings;
  bool get hasMorePast => _hasMorePast;

  // ── Fetch (initial load) ───────────────────────────────────────────────────
  Future<void> fetchMyEvents(
    BuildContext context, {
    String type = 'liked',
    int page = 0,
    int limit = 10,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    if (type == 'liked') {
      _likedEvents = [];
      _likedCurrentPage = 0;
      _likedTotalItems = 0;
      _likedTotalPages = 0;
      _hasMoreLiked = false;
      _isLikedEventsLoading = true;
    } else {
      _upcomingEvents = [];
      _pastBookings = [];
      _pastTotalRecords = 0;
      _hasMorePast = false;
      _isPastLoadingMore = false;
      _isPastFullyLoaded = false;
      _isBookedEventsLoading = true;
    }
    notifyListeners();

    try {
      final response = await getData(
        'common/my_events?type=$type&page=$page&limit=$limit',
        context,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response != null && response['success'] == true) {
        if (type == 'liked') {
          _parseLikedResponse(response['data'], append: false);
        } else {
          await _parseBookedResponse(response['data'], context,
              initialLimit: limit);
        }
      }
    } catch (_) {
      // keep empty lists
    } finally {
      if (type == 'liked') {
        _isLikedEventsLoading = false;
      } else {
        _isBookedEventsLoading = false;
      }
      notifyListeners();
    }
  }

  // ── Load more liked event ─────────────────────────────────────────────────
  Future<void> loadMoreLiked(BuildContext context, {int limit = 10}) async {
    if (_isLikedLoadingMore || !hasMoreLiked) return;
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLikedLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _likedCurrentPage + 1;
      final response = await getData(
        'common/my_events?type=liked&page=$nextPage&limit=$limit',
        context,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response != null && response['success'] == true) {
        _parseLikedResponse(response['data'], append: true);
      }
    } catch (_) {
      // silently ignore
    } finally {
      _isLikedLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Load more past (fetch remaining all at once from page=0) ──────────────
  Future<void> loadMorePast(BuildContext context) async {
    if (_isPastLoadingMore || !_hasMorePast || _isPastFullyLoaded) return;
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isPastLoadingMore = true;
    notifyListeners();

    try {
      // Fetch with total_records as limit to get ALL past records at once
      final response = await getData(
        'common/my_events?type=booked&page=0&limit=$_pastTotalRecords',
        context,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response != null && response['success'] == true) {
        final past = response['data']['past'];
        final List<dynamic> allPast =
            past is List ? List<dynamic>.from(past) : [];

        // Replace with full list
        _pastBookings = allPast;
        _isPastFullyLoaded = true;
        _hasMorePast = false;

        debugPrint(
            '[MyEvents] past fully loaded: ${_pastBookings.length} / $_pastTotalRecords');
      } else {
        _hasMorePast = false;
      }
    } catch (_) {
      _hasMorePast = false;
    } finally {
      _isPastLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Parsers ────────────────────────────────────────────────────────────────

  void _parseLikedResponse(dynamic data, {required bool append}) {
    final items = data['item'];
    final List<dynamic> parsed = items is List ? List<dynamic>.from(items) : [];

    if (append) {
      _likedEvents.addAll(parsed);
    } else {
      _likedEvents = parsed;
    }

    _likedTotalItems = (data['totalItems'] as num?)?.toInt() ?? parsed.length;
    _likedTotalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
    _likedCurrentPage = (data['currentPage'] as num?)?.toInt() ?? 0;

    if (_likedTotalItems > 0) {
      _hasMoreLiked = _likedEvents.length < _likedTotalItems;
    } else if (_likedTotalPages > 0) {
      final isOneBased = _likedCurrentPage >= 1;
      _hasMoreLiked = isOneBased
          ? _likedCurrentPage < _likedTotalPages
          : _likedCurrentPage < _likedTotalPages - 1;
    } else {
      _hasMoreLiked = parsed.isNotEmpty;
    }
  }

  /// Initial load — page=0&limit=X

  Future<void> _parseBookedResponse(
    dynamic data,
    BuildContext context, {
    required int initialLimit,
  }) async {
    final upcoming = data['upcoming'];
    final past = data['past'];

    _upcomingEvents = upcoming is List ? List<dynamic>.from(upcoming) : [];
    _pastBookings = past is List ? List<dynamic>.from(past) : [];

    _pastTotalRecords = (data['total_records'] as num?)?.toInt() ?? 0;

    // has more if we got fewer past records than total
    _hasMorePast = _pastTotalRecords > _pastBookings.length;
    _isPastFullyLoaded = !_hasMorePast;

    debugPrint(
        '[MyEvents] initial past: ${_pastBookings.length} / $_pastTotalRecords  hasMore: $_hasMorePast');
  }
}
