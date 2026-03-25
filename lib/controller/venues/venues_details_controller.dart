import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';

class VenuesDetailsController with ChangeNotifier {
  Map<String, dynamic>? _venuesDetail;
  Map<String, dynamic>? get getVenuesDetail => _venuesDetail;
  bool _isVenuesDetailLoading = false;
  bool get isVenuesDetailLoading => _isVenuesDetailLoading;

  Map<String, dynamic>? _venueSlots;
  Map<String, dynamic>? get getVenueSlots => _venueSlots;
  bool _isSlotsLoading = false;
  bool get isSlotsLoading => _isSlotsLoading;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  // Fetch venue details from API
  Future<Map<String, dynamic>?> fetchVenuesDetail(
    BuildContext context, {
    required String venueId,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty || venueId.isEmpty) {
      return null;
    }

    _isVenuesDetailLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'venue/venue_detail/$venueId',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          _venuesDetail = data;
          _isVenuesDetailLoading = false;
          notifyListeners();
          return _venuesDetail;
        }
        _venuesDetail = null;
        _isVenuesDetailLoading = false;
        notifyListeners();
      } else if (response != null) {
        // CommonHelper.handleInactiveUserRedirect(context, response);
        _isVenuesDetailLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print("Exception in fetchVenuesDetail: $e");
      _isVenuesDetailLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Fetch venue booking slots from API
  Future<Map<String, dynamic>?> fetchVenueSlots(
    BuildContext context, {
    required String venueId,
    required String date, // (e.g., 2026-02-11)
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty || venueId.isEmpty || date.isEmpty) {
      return null;
    }

    _isSlotsLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'booking/get_venue_slots?date=$date&venue_id=$venueId',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          _venueSlots = data;
          _isSlotsLoading = false;
          notifyListeners();
          return _venueSlots;
        }
        _venueSlots = null;
        _isSlotsLoading = false;
        notifyListeners();
      } else if (response != null) {
        // CommonHelper.handleInactiveUserRedirect(context, response);
        _isSlotsLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print("Exception in fetchVenueSlots: $e");
      _isSlotsLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Get image URL
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${AppConfigProvider.imageUrl}$imagePath';
  }

  // Clear all data (useful for logout)
  void clearData() {
    _venuesDetail = null;
    _venueSlots = null;
    _isLoading = false;
    _isVenuesDetailLoading = false;
    _isSlotsLoading = false;
    notifyListeners();
  }
}
