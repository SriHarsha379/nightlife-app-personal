import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';

class CityPreferenceController with ChangeNotifier {
  List<dynamic> _cityList = [];
  List<dynamic> get getCityList => _cityList;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  // Selected cities data
  List<Map<String, dynamic>> _selectedCities = [];
  List<Map<String, dynamic>> get getSelectedCities => _selectedCities;

  // Current city index for map view (which city is being configured)
  int _currentCityIndex = 0;
  int get getCurrentCityIndex => _currentCityIndex;

  // Store radius and broadened status for each selected city
  Map<String, Map<String, dynamic>> _cityRadiusData = {};
  Map<String, Map<String, dynamic>> get getCityRadiusData => _cityRadiusData;

  // Current working values (for the city being configured)
  double _currentDistance = 1.0;
  bool _isBroadened = false;

  double get getCurrentDistance => _currentDistance;
  bool get getIsBroadened => _isBroadened;

  // Get current city being configured
  Map<String, dynamic>? get getCurrentConfigCity {
    if (_selectedCities.isEmpty ||
        _currentCityIndex >= _selectedCities.length) {
      return null;
    }
    return _selectedCities[_currentCityIndex];
  }

  // Check if all selected cities have been configured
  bool get allCitiesConfigured {
    if (_selectedCities.isEmpty) return false;
    return _currentCityIndex >= _selectedCities.length;
  }

  // Move to next city for configuration
  void moveToNextCity() {
    // Save current city's radius data
    if (getCurrentConfigCity != null) {
      String cityId = getCurrentConfigCity!['_id'];
      _cityRadiusData[cityId] = {
        'city_id': cityId,
        'city_name': getCurrentConfigCity!['city_name'],
        'latitude': getCurrentConfigCity!['latitude'] ?? 0.0,
        'longitude': getCurrentConfigCity!['longitude'] ?? 0.0,
        'radius': _currentDistance,
        'is_broadened': _isBroadened,
      };
    }

    _currentCityIndex++;

    // Load next city's saved data or reset to defaults
    if (!allCitiesConfigured) {
      String nextCityId = _selectedCities[_currentCityIndex]['_id'];
      if (_cityRadiusData.containsKey(nextCityId)) {
        _currentDistance = _cityRadiusData[nextCityId]!['radius'];
        _isBroadened = _cityRadiusData[nextCityId]!['is_broadened'];
      } else {
        _currentDistance = 1.0;
        _isBroadened = false;
      }
    }

    notifyListeners();
  }

  // Reset city configuration (when going back)
  void resetCityConfiguration() {
    _currentCityIndex = 0;
    _cityRadiusData.clear();
    _currentDistance = 1.0;
    _isBroadened = false;
    notifyListeners();
  }

  // Update distance
// Update distance
  void updateDistance(double distance) {
    _currentDistance = distance;

    if (distance >= 60.0) {
      _isBroadened = true;
    } else if (distance < 60.0) {
      _isBroadened = false;
    }

    notifyListeners();
  }

  // Toggle broadened - when toggled, set distance to max
  void toggleBroadened(bool value) {
    _isBroadened = value;
    if (value) {
      _currentDistance = 60.0; // Set to maximum when broadened
    }
    notifyListeners();
  }

  // Fetch city list from API
  Future<void> fetchCityList(BuildContext context) async {
    // String token =
    //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NzQ4NmE1MWVlOWE5NGM3NGVkZTFkNCIsImlhdCI6MTc2OTU5NDk0NiwiZXhwIjoxNzcyMTg2OTQ2fQ.hA61WV_g0cXiKCs5saXoEeFWa38q_1BO7GwTucHUWMw";

    // Map<String, String> headers = {
    //   'Authorization': 'Bearer $token',
    // };

    if (_cityList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'auth/popular_cities',
        context,
        // headers: headers,
      );

      print("API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'] is List) {
          _cityList = response['data'];
          print("City List: $_cityList");
        } else {
          _cityList = [];
          print("No city data found");
        }

        notifyListeners();
      } else {
        _cityList = [];
        if (response != null) {
          // CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchCityList: $e");
      _cityList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle city selection (max 4)
  void toggleCitySelection(Map<String, dynamic> city) {
    int index = _selectedCities.indexWhere((c) => c['_id'] == city['_id']);

    if (index != -1) {
      // City already selected, remove it
      String cityId = _selectedCities[index]['_id'];
      _selectedCities.removeAt(index);
      _cityRadiusData.remove(cityId); // Remove radius data too

      // Reset configuration if removing affects current index
      if (_currentCityIndex >= _selectedCities.length) {
        _currentCityIndex =
            _selectedCities.isEmpty ? 0 : _selectedCities.length - 1;
      }
    } else {
      // City not selected, add if less than 4
      if (_selectedCities.length < 4) {
        _selectedCities.add(city);
      } else {
        print("Maximum 4 cities can be selected");
      }
    }

    notifyListeners();
  }

  // Check if a city is selected
  bool isCitySelected(String cityId) {
    return _selectedCities.any((city) => city['_id'] == cityId);
  }

  // Get selected city IDs
  List<String> getSelectedCityIds() {
    return _selectedCities.map((city) => city['_id'].toString()).toList();
  }

  // Get selected city names
  List<String> getSelectedCityNames() {
    return _selectedCities.map((city) => city['city_name'].toString()).toList();
  }

  // Get city image URL
  String getCityImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${AppConfigProvider.imageUrl}$imagePath';
  }

  // Get all configured city radius data as a list
  List<Map<String, dynamic>> getAllCityRadiusData() {
    List<Map<String, dynamic>> result = [];

    for (var city in _selectedCities) {
      String cityId = city['_id'];
      if (_cityRadiusData.containsKey(cityId)) {
        result.add(_cityRadiusData[cityId]!);
      }
    }

    return result;
  }

  // Prepare data for next screen
  Map<String, dynamic> getDataForNextScreen() {
    // Save current city's data before preparing final data
    if (getCurrentConfigCity != null && !allCitiesConfigured) {
      String cityId = getCurrentConfigCity!['_id'];
      _cityRadiusData[cityId] = {
        'city_id': cityId,
        'city_name': getCurrentConfigCity!['city_name'],
        'latitude': getCurrentConfigCity!['latitude'] ?? 0.0,
        'longitude': getCurrentConfigCity!['longitude'] ?? 0.0,
        'radius': _currentDistance,
        'is_broadened': _isBroadened,
      };
    }

    return {
      'selected_cities': _selectedCities,
      'selected_city_ids': getSelectedCityIds(),
      'selected_city_names': getSelectedCityNames(),
      'city_radius_data':
          getAllCityRadiusData(), // List of all cities with their radius data
    };
  }

  // Clear all selections
  void clearSelections() {
    _selectedCities.clear();
    _cityRadiusData.clear();
    _currentCityIndex = 0;
    _currentDistance = 1.0;
    _isBroadened = false;
    notifyListeners();
  }

  // Clear all data (useful for logout)
  void clearData() {
    _cityList = [];
    _selectedCities = [];
    _cityRadiusData = {};
    _currentCityIndex = 0;
    _currentDistance = 1.0;
    _isBroadened = false;
    _isLoading = false;
    notifyListeners();
  }

  // Get user count for a city
  int getCityUserCount(Map<String, dynamic> city) {
    return city['user_count'] ?? 0;
  }

  // Get latitude and longitude for a city
  double getCityLatitude(Map<String, dynamic> city) {
    return city['latitude']?.toDouble() ?? 0.0;
  }

  double getCityLongitude(Map<String, dynamic> city) {
    return city['longitude']?.toDouble() ?? 0.0;
  }
}
