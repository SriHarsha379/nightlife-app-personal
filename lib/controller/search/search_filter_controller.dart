import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class SearchFilterController with ChangeNotifier {
  bool _isVenueLoading = false;
  bool _isEventLoading = false;

  List<Map<String, String>> _venueFeaturedList = [];
  List<Map<String, String>> _venueNearbyList = [];
  List<Map<String, String>> _venueRecommendedList = [];

  List<Map<String, String>> _eventFeaturedList = [];
  List<Map<String, String>> _eventNearbyList = [];
  List<Map<String, String>> _eventRecommendedList = [];

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
    required double latitude,
    required double longitude,
    required String type,
    int radius = 10,
    String search = '',
  }) async {
    if (type == 'venue') {
      _isVenueLoading = true;
    } else {
      _isEventLoading = true;
    }
    notifyListeners();

    // final token = AppConstant.token;
    final token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5ODZkNDlhYzc2NjMyNjNkMWQ0OTc1MiIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc3MDQ0NDE5MywiZXhwIjoxNzczMDM2MTkzfQ.K79Th_-_o7nt3MHLLuoFJK4j-EYxjcARUzY4IcTuhnc";

    final headers = <String, String>{};
    if (token.isNotEmpty) {
      headers['authorization'] = 'Bearer $token';
    }

    final searchQuery = search.trim();
    final encodedSearch = Uri.encodeQueryComponent(searchQuery);
    final endpoint = searchQuery.isEmpty
        ? 'common/filter_events_venues?latitude=$latitude&longitude=$longitude&type=$type&radius=$radius'
        : 'common/filter_events_venues?search=$encodedSearch&latitude=$latitude&longitude=$longitude&type=$type&radius=$radius';

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
    } else {
      _eventFeaturedList = featuredRaw.map(_toFeaturedMap).toList();
      _eventNearbyList = nearbyRaw.map(_toNearbyMap).toList();
      _eventRecommendedList = recommendedRaw.map(_toRecommendedMap).toList();
    }

    _setLoading(type, false);
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
    final categoryName =
        _firstCategoryName(item['category_ids'] ?? item['categories']);
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

  String _firstCategoryName(dynamic categories) {
    if (categories is! List || categories.isEmpty) return '';
    final first = categories.first;
    if (first is! Map) return '';
    return _readString(first['category_name']);
  }

  String _locationLabel(String distance, String location) {
    if (distance.isEmpty) return location;
    if (location.isEmpty) return distance;
    return '$distance | $location';
  }
}
