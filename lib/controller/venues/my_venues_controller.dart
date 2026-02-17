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

  // ── Reserved ───────────────────────────────────────────────────────────────
  bool _isReservedVenuesLoading = false;
  bool _isReservedLoadingMore = false;
  List<dynamic> _upcomingReservations = [];
  List<dynamic> _pastReservations = [];
  int _reservedCurrentPage = 1;
  int _reservedTotalPages = 0;

  bool get isReservedVenuesLoading => _isReservedVenuesLoading;
  bool get isReservedLoadingMore => _isReservedLoadingMore;
  List<dynamic> get upcomingReservations => _upcomingReservations;
  List<dynamic> get pastReservations => _pastReservations;
  bool get hasMoreReserved => _reservedCurrentPage < _reservedTotalPages;

  // ── Fetch liked venues (initial load) ─────────────────────────────────────
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
      _reservedCurrentPage = 1;
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
          _parseReservedResponse(response['data'], append: false);
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

  // ── Load more reserved (upcoming) ─────────────────────────────────────────
  Future<void> loadMoreReserved(BuildContext context, {int limit = 10}) async {
    if (_isReservedLoadingMore || !hasMoreReserved) return;
    final token = AppConstant.token;
    if (token.isEmpty) return;

    _isReservedLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _reservedCurrentPage + 1;
      final response = await getData(
        'common/my_venues?type=reserved&page=$nextPage&limit=$limit',
        context,
        headers: {'authorization': 'Bearer $token'},
      );

      if (response != null && response['success'] == true) {
        _parseReservedResponse(response['data'], append: true);
      }
    } catch (_) {
      // silently ignore
    } finally {
      _isReservedLoadingMore = false;
      notifyListeners();
    }
  }

  // ── Parsers ────────────────────────────────────────────────────────────────

  void _parseLikedResponse(dynamic data, {required bool append}) {
    // Response shape: { totalItems, item: [...], totalPages, currentPage }
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

    // Handle both 0-based and 1-based backends safely.
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

  void _parseReservedResponse(dynamic data, {required bool append}) {
    final upcoming = data['upcoming'];
    final past = data['past'];

    final List<dynamic> parsedUpcoming =
        upcoming is List ? List<dynamic>.from(upcoming) : [];
    final List<dynamic> parsedPast =
        past is List ? List<dynamic>.from(past) : [];

    if (append) {
      _upcomingReservations.addAll(parsedUpcoming);
      _pastReservations.addAll(parsedPast);
    } else {
      _upcomingReservations = parsedUpcoming;
      _pastReservations = parsedPast;
    }

    _reservedTotalPages = (data['total_pages'] as num?)?.toInt() ?? 0;
    _reservedCurrentPage = (data['current_page'] as num?)?.toInt() ?? 1;
  }
}
