// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../controller/city/city_preference.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';

class LocationFilterResult {
  final String cityId;
  final String cityName;
  final double latitude;
  final double longitude;
  final double radiusKm;

  const LocationFilterResult({
    required this.cityId,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });
}

class LocationFilterBottomSheet extends StatefulWidget {
  final String initialCityId;
  final String initialCityName;
  final double initialLatitude;
  final double initialLongitude;
  final double initialRadiusKm;

  const LocationFilterBottomSheet({
    super.key,
    required this.initialCityId,
    required this.initialCityName,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.initialRadiusKm,
  });

  @override
  State<LocationFilterBottomSheet> createState() =>
      _LocationFilterBottomSheetState();
}

class _LocationFilterBottomSheetState extends State<LocationFilterBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;

  List<Map<String, dynamic>> _allCities = [];
  bool _isCitiesLoading = false;
  bool _showAllCities = false;

  Map<String, dynamic>? _selectedCity;
  double _currentDistance = 15.0;

  @override
  void initState() {
    super.initState();
    _currentDistance = widget.initialRadiusKm.clamp(1.0, 60.0);
    _fetchCities();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCities() async {
    final cityController = context.read<CityPreferenceController>();
    setState(() {
      _isCitiesLoading = true;
    });

    if (cityController.getCityList.isEmpty) {
      await cityController.fetchCityList(context);
    }

    final cities = <Map<String, dynamic>>[];
    final rawList = cityController.getCityList.whereType<Map>();
    for (final item in rawList) {
      cities.add(Map<String, dynamic>.from(item));
    }

    Map<String, dynamic>? selected;
    if (cities.isNotEmpty) {
      final initialId = widget.initialCityId.trim();
      if (initialId.isNotEmpty) {
        for (final city in cities) {
          if (_cityId(city) == initialId) {
            selected = city;
            break;
          }
        }
      }
      selected ??= cities.firstWhere(
        (city) =>
            (city['city_name'] ?? '').toString().toLowerCase() ==
            widget.initialCityName.toLowerCase(),
        orElse: () => cities.first,
      );
    }

    if (selected == null) {
      selected = {
        'city_id': widget.initialCityId,
        'city_name': widget.initialCityName,
        'latitude': widget.initialLatitude,
        'longitude': widget.initialLongitude,
      };
    }

    if (!mounted) return;
    setState(() {
      _allCities = cities;
      _selectedCity = selected;
      _isCitiesLoading = false;
    });
    _moveCamera();
  }

  String _cityId(Map<String, dynamic>? city) {
    if (city == null) return '';
    return (city['_id'] ?? city['city_id'] ?? '').toString().trim();
  }

  List<Map<String, dynamic>> _filteredCities() {
    if (_searchController.text.trim().isEmpty) return _allCities;
    final q = _searchController.text.trim().toLowerCase();
    return _allCities.where((city) {
      final cityName = (city['city_name'] ?? '').toString().toLowerCase();
      return cityName.contains(q);
    }).toList();
  }

  double _toDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  double get _selectedLat =>
      _toDouble(_selectedCity?['latitude'], widget.initialLatitude);
  double get _selectedLng =>
      _toDouble(_selectedCity?['longitude'], widget.initialLongitude);
  String get _selectedCityName =>
      (_selectedCity?['city_name'] ?? widget.initialCityName).toString();
  String get _selectedCityId {
    final selectedId = _cityId(_selectedCity);
    if (selectedId.isNotEmpty) return selectedId;
    return widget.initialCityId.trim();
  }

  double _zoomForRadius(double radiusKm) {
    if (radiusKm <= 10) return 11.5;
    if (radiusKm <= 20) return 10.5;
    if (radiusKm <= 30) return 10.0;
    if (radiusKm <= 40) return 9.5;
    return 9.0;
  }

  void _moveCamera() {
    final controller = _mapController;
    if (controller == null) return;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_selectedLat, _selectedLng),
        _zoomForRadius(_currentDistance),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final filteredCities = _filteredCities();
    final visibleCities =
        _showAllCities ? filteredCities : filteredCities.take(6).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.005),
              Center(
                child: Container(
                  width: size.width * 0.15,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.025),
              Container(
                width: size.width * 0.95,
                height: size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColor.filledcolor(context),
                ),
                child: TextFormField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  cursorColor: AppColor.secondryColor(context),
                  style: TextStyle(color: AppColor.secondryColor(context)),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(
                        left: size.width * 0.04,
                        right: size.width * 0.02,
                      ),
                      child: Image.asset(
                        AppImage.searchIcon,
                        height: size.width * 0.04,
                        width: size.width * 0.04,
                        color: AppColor.filledText(context),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: size.width * 0.12,
                      minHeight: size.height * 0.06,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColor.borderColor),
                    ),
                    border: InputBorder.none,
                    hintText: AppLanguage.searchForaCityText[language],
                    hintStyle: AppConstant.textFilledStyle(context),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                      horizontal: size.width * 0.04,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                height: size.height * 0.25,
                width: size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_selectedLat, _selectedLng),
                      zoom: _zoomForRadius(_currentDistance),
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _moveCamera();
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected_city'),
                        position: LatLng(_selectedLat, _selectedLng),
                        infoWindow: InfoWindow(title: _selectedCityName),
                      ),
                    },
                    circles: {
                      Circle(
                        circleId: const CircleId('selected_radius'),
                        center: LatLng(_selectedLat, _selectedLng),
                        radius: _currentDistance * 1000,
                        fillColor: AppColor.pinkColor.withOpacity(0.2),
                        strokeColor: AppColor.pinkColor,
                        strokeWidth: 2,
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Location",
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColor.pinkColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              if (_isCitiesLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: visibleCities.map((city) {
                    final cityName = (city['city_name'] ?? '').toString();
                    final candidateId = _cityId(city);
                    final selected = candidateId.isNotEmpty
                        ? candidateId == _selectedCityId
                        : cityName.toLowerCase() ==
                            _selectedCityName.toLowerCase();
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCity = city;
                        });
                        _moveCamera();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: selected
                              ? AppColor.pinkColor.withOpacity(0.15)
                              : null,
                          border: Border.all(
                            color: selected
                                ? AppColor.pinkColor
                                : AppColor.textTapColor(context),
                          ),
                        ),
                        child: Text(
                          cityName,
                          style: const TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (filteredCities.length > 6)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllCities = !_showAllCities;
                      });
                    },
                    child: Text(_showAllCities ? "Show less" : "Show more"),
                  ),
              ],
              SizedBox(height: size.height * 0.02),
              Text(
                "Distance",
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColor.pinkColor,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColor.darkPurpleColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Text(
                        "Up to ${_currentDistance.toInt()} kilometres away",
                        style: const TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Slider(
                      value: _currentDistance,
                      min: 1,
                      max: 60,
                      activeColor: AppColor.pinkColor,
                      inactiveColor: AppColor.lightgreyColor,
                      onChanged: (value) {
                        setState(() {
                          _currentDistance = value;
                        });
                        _moveCamera();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "1km",
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "60km",
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.pinkColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      LocationFilterResult(
                       cityId: _selectedCityId,
                       cityName: _selectedCityName,
                       latitude: _selectedLat,
                       longitude: _selectedLng,
                        radiusKm: _currentDistance,
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }
}
