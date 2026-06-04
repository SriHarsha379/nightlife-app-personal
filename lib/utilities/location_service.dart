import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Position? _lastPosition;

  static Position? get lastPosition => _lastPosition;

  static Future<Position?> requestAndGetLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('📍 Location services are disabled on device');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('📍 Location permission denied by user');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('📍 Location permission permanently denied');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastPosition = position;
      debugPrint('📍 Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('📍 Location error: $e');
      return null;
    }
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  static double? get latitude => _lastPosition?.latitude;
  static double? get longitude => _lastPosition?.longitude;
}
