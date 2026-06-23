import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

/// Immutable snapshot of the parameters used for a filter request.
/// Used to skip redundant network calls when nothing has changed.
class _SearchParams {
  final String cityId;
  final double latitude;
  final double longitude;
  final int radius;
  final String search;
  final String type;

  const _SearchParams({
    required this.cityId,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.search,
    required this.type,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _SearchParams &&
        other.cityId == cityId &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.radius == radius &&
        other.search == search &&
        other.type == type;
  }

  @override
  int get hashCode =>
      Object.hash(cityId, latitude, longitude, radius, search, type);
}

class SearchFilterController with ChangeNotifier {
  bool _isVenueLoading = false;
  bool _isEventLoading = false;

  List<Map<String, String>> _venueFeaturedList = [];
  List<Map<String, String>> _venueNearbyList = [];
  List<Map<String, String>> _venueRecommendedList = [];

  List<Map<String, String>> _eventFeaturedList = [];
  List<Map<String, String>> _eventNearbyList = [];
  List<Map<String, String>> _eventRecommendedList = [];

  /// Tracks the params from the last successful fetch to avoid re-fetching
  /// when the caller requests the same query again (e.g. on tab switch).
  _SearchParams? _lastVenueParams;
  _SearchParams? _lastEventParams;

  bool get isVenueLoading => _isVenueLoading;
  bool get isEventLoading => _isEventLoading;

  List<Map<String, String>> get venueFeaturedList => _venueFeaturedList;
  List<Map<String, String>> get venueNearbyList => _venueNearbyList;
  List<Map<String, String>> get venueRecommendedList => _venueRecommendedList;

  List<Map<String, String>> get eventFeaturedList => _eventFeaturedList;
  List<Map<String, String>> get eventNearbyList => _eventNearbyList;
  List<Map<String, String>> get eventRecommendedList => _eventRecommendedList;

  Future<void> fetchFilterEventsVenues(
      BuildContext context, {
        String cityId = '',
        required double latitude,
        required double longitude,
        required String type,
        int radius = 10,
        String search = '',
        bool forceRefresh = false,
      }) async {
    final params = _SearchParams(
      cityId: cityId.trim(),
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      search: search.trim(),
      type: type,
    );

    // FIX: When search is cleared (empty), always invalidate the cached params
    // so that clearing and re-searching the same term re-fetches from server
    // instead of being skipped by the dedup check below.
    if (params.search.isEmpty) {
      if (type == 'venue') {
        _lastVenueParams = null;
      } else {
        _lastEventParams = null;
      }
    }

    // Skip the network call when params are identical to the last fetch.
    if (!forceRefresh) {
      final lastParams = type == 'venue' ? _lastVenueParams : _lastEventParams;
      if (params == lastParams) return;
    }

    if (type == 'venue') {
      _isVenueLoading = true;
    } else {
      _isEventLoading = true;
    }
    notifyListeners();

    final token = AppConstant.token;

    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['authorization'] = 'Bearer $token';
    }

    final searchQuery = search.trim();
    final queryParameters = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'type': type,
      'radius': radius.toString(),
    };
    if (params.cityId.isNotEmpty) {
      queryParameters['city_id'] = params.cityId;
    }
    if (searchQuery.isNotEmpty) {
      queryParameters['search'] = searchQuery;
    } else {
      // Ensure no stale search key leaks through on clear
      queryParameters.remove('search');
    }
    final endpoint =
        'common/filter_events_venues?${Uri(queryParameters: queryParameters).query}';

    final response = await getData(
      endpoint,
      context,
      headers: headers.isEmpty ? null : headers,
    );

    if (response == null || response['success'] != true) {
      _clearType(type);
      _setLoading(type, false);
      notifyListeners();
      return;
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final featuredRaw = _toMapList(data['featured']);
    final nearbyRaw = _toMapList(data['nearby']);
    final recommendedRaw = _toMapList(data['recommended']);

    if (type == 'venue') {
      _venueFeaturedList = featuredRaw.map(_toFeaturedMap).toList();
      _venueNearbyList = nearbyRaw.map(_toNearbyMap).toList();
      _venueRecommendedList = recommendedRaw.map(_toRecommendedMap).toList();
      _lastVenueParams = params;
    } else {
      _eventFeaturedList = featuredRaw.map(_toFeaturedMap).toList();
      _eventNearbyList = nearbyRaw.map(_toNearbyMap).toList();
      _eventRecommendedList = recommendedRaw.map(_toRecommendedMap).toList();
      _lastEventParams = params;
    }

    _setLoading(type, false);
    notifyListeners();
  }

  /// Clears all results and invalidates cached params so the next call
  /// forces a fresh fetch (e.g. when the user changes their city).
  void clearAll() {
    _venueFeaturedList = [];
    _venueNearbyList = [];
    _venueRecommendedList = [];
    _eventFeaturedList = [];
    _eventNearbyList = [];
    _eventRecommendedList = [];
    _lastVenueParams = null;
    _lastEventParams = null;
    notifyListeners();
  }

  void _setLoading(String type, bool value) {
    if (type == 'venue') {
      _isVenueLoading = value;
    } else {
      _isEventLoading = value;
    }
  }

  void _clearType(String type) {
    if (type == 'venue') {
      _venueFeaturedList = [];
      _venueNearbyList = [];
      _venueRecommendedList = [];
      return;
    }
    _eventFeaturedList = [];
    _eventNearbyList = [];
    _eventRecommendedList = [];
  }

  List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (value is! List) return <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Map<String, String> _toFeaturedMap(Map<String, dynamic> item) {
    final tags = item['tags'];
    final categories =
    _categoryNames(item['category_ids'] ?? item['categories']);
    final categoryName = categories.isNotEmpty ? categories.first : '';
    final subtitle = tags is List && tags.isNotEmpty
        ? _readString(tags.first)
        : categoryName.isNotEmpty
        ? categoryName
        : _readString(item['location']);

    return {
      'id': _readString(
          item['id'] ?? item['event_id'] ?? item['venue_id'] ?? item['_id']),
      'image': _readString(
          item['image'] ?? item['venue_image'] ?? item['event_image']),
      'title':
      _readString(item['name'] ?? item['venue_name'] ?? item['event_name']),
      'subtitle': subtitle,
      'event_date': _readString(item['event_date']),
      'categories': categories.join('||'),
      'location': _readString(item['location'] ?? item['address']),
    };
  }

  Map<String, String> _toNearbyMap(Map<String, dynamic> item) {
    return {
      'id': _readString(
          item['id'] ?? item['event_id'] ?? item['venue_id'] ?? item['_id']),
      'image': _readString(
          item['image'] ?? item['venue_image'] ?? item['event_image']),
      'title':
      _readString(item['name'] ?? item['venue_name'] ?? item['event_name']),
      'distance': _distance(item['distance_km']),
      'location': _readString(item['location'] ?? item['address']),
    };
  }

  Map<String, String> _toRecommendedMap(Map<String, dynamic> item) {
    final distance = _distance(item['distance_km']);
    final location = _readString(item['location'] ?? item['address']);
    return {
      'id': _readString(
          item['id'] ?? item['event_id'] ?? item['venue_id'] ?? item['_id']),
      'image': _readString(
          item['image'] ?? item['venue_image'] ?? item['event_image']),
      'title':
      _readString(item['name'] ?? item['venue_name'] ?? item['event_name']),
      'location': _locationLabel(distance, location),
      'distance': distance,
    };
  }

  String _readString(dynamic value) => value?.toString().trim() ?? '';

  String _distance(dynamic value) {
    if (value == null) return '';
    final number = double.tryParse(value.toString());
    if (number == null) return '';
    return '${number.toStringAsFixed(1)} km';
  }

  List<String> _categoryNames(dynamic categories) {
    if (categories is! List || categories.isEmpty) return <String>[];
    return categories
        .whereType<Map>()
        .map((category) {
      return _readString(category['category_name']);
    })
        .where((name) => name.isNotEmpty)
        .toList();
  }

  String _locationLabel(String distance, String location) {
    if (distance.isEmpty) return location;
    if (location.isEmpty) return distance;
    return '$distance | $location';
  }
}