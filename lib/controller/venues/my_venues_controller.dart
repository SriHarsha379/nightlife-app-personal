import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class MyVenuesController with ChangeNotifier {
  // ── Liked ──────────────────────────────────────────────────────────────────
  bool _isLikedVenuesLoading = false;
  bool _isLikedLoadingMore = false;
  List<dynamic> _likedVenues = [];
  int _likedCurrentPage = 0;
  int _likedTotalPages = 0;
  int _likedTotalItems = 0;
  bool _hasMoreLiked = false;

  bool get isLikedVenuesLoading => _isLikedVenuesLoading;
  bool get isLikedLoadingMore => _isLikedLoadingMore;
  List<dynamic> get likedVenues => _likedVenues;
  bool get hasMoreLiked => _hasMoreLiked;

  // ── Reserved / Upcoming ────────────────────────────────────────────────────
  bool _isReservedVenuesLoading = false;
  List<dynamic> _upcomingReservations = [];

  bool get isReservedVenuesLoading => _isReservedVenuesLoading;
  List<dynamic> get upcomingReservations => _upcomingReservations;


  bool _isPastLoadingMore = false;
  bool _isPastFullyLoaded = false;
  List<dynamic> _pastReservations = [];
  int _pastTotalRecords = 0;
  bool _hasMorePast = false;

  bool get isPastLoadingMore => _isPastLoadingMore;
  List<dynamic> get pastReservations => _pastReservations;
  bool get hasMorePast => _hasMorePast;

  // ── Fetch (initial load) ───────────────────────────────────────────────────
  Future<void> fetchMyVenues(
    BuildContext context, {
    String type = 'liked',
    int page = 0,
    int limit = 10,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;

    if (type == 'liked') {
      _likedVenues = [];
      _likedCurrentPage = 0;
      _likedTotalItems = 0;
      _likedTotalPages = 0;
      _hasMoreLiked = false;
      _isLikedVenuesLoading = true;
    } else {
      _upcomingReservations = [];
      _pastReservations = [];
      _pastTotalRecords = 0;
      _hasMorePast = false;
      _isPastLoadingMore = false;
      _isPastFullyLoaded = false;
      _isReservedVenuesLoading = true;
    }
    notifyListeners();

    try {
      final response = await getData(
        'common/my_venues?type=$type&page=$page&limit=$limit',
        context,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response != null && response['success'] == true) {
        if (type == 'liked') {
          _parseLikedResponse(response['data'], append: false);
        } else {
          await _parseReservedResponse(response['data'], context,
              initialLimit: limit);
        }
      }
    } catch (_) {
      // keep empty lists
    } finally {
      if (type == 'liked') {
        _isLikedVenuesLoading = false;
      } else {
        _isReservedVenuesLoading = false;
      }
      notifyListeners();
    }
  }

  // ── Load more liked venues ─────────────────────────────────────────────────
  Future<void> loadMoreLiked(BuildContext context, {int limit = 10}) async {
    if (_isLikedLoadingMore || !hasMoreLiked) return;
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isLikedLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _likedCurrentPage + 1;
      final response = await getData(
        'common/my_venues?type=liked&page=$nextPage&limit=$limit',
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
      // Backend: past sirf page=0 pe aata hai
      // Fetch with total_records as limit to get ALL past records at once
      final response = await getData(
        'common/my_venues?type=reserved&page=0&limit=$_pastTotalRecords',
        context,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response != null && response['success'] == true) {
        final past = response['data']['past'];
        final List<dynamic> allPast =
            past is List ? List<dynamic>.from(past) : [];

        // Replace with full list
        _pastReservations = allPast;
        _isPastFullyLoaded = true;
        _hasMorePast = false;

        debugPrint(
            '[MyVenues] past fully loaded: ${_pastReservations.length} / $_pastTotalRecords');
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
      _likedVenues.addAll(parsed);
    } else {
      _likedVenues = parsed;
    }

    _likedTotalItems = (data['totalItems'] as num?)?.toInt() ?? parsed.length;
    _likedTotalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
    _likedCurrentPage = (data['currentPage'] as num?)?.toInt() ?? 0;

    if (_likedTotalItems > 0) {
      _hasMoreLiked = _likedVenues.length < _likedTotalItems;
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
  /// Past ke pehle X records milte hain + total_records pata chalta hai
  /// Agar total_records > loaded past → hasMorePast = true
  Future<void> _parseReservedResponse(
    dynamic data,
    BuildContext context, {
    required int initialLimit,
  }) async {
    final upcoming = data['upcoming'];
    final past = data['past'];

    _upcomingReservations =
        upcoming is List ? List<dynamic>.from(upcoming) : [];
    _pastReservations = past is List ? List<dynamic>.from(past) : [];

    _pastTotalRecords = (data['total_records'] as num?)?.toInt() ?? 0;

    // has more if we got fewer past records than total
    _hasMorePast = _pastTotalRecords > _pastReservations.length;
    _isPastFullyLoaded = !_hasMorePast;

    debugPrint(
        '[MyVenues] initial past: ${_pastReservations.length} / $_pastTotalRecords  hasMore: $_hasMorePast');
  }
}
