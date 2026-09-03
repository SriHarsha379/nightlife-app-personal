import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../provider/darkmode_provider.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_config_provider.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_header.dart';
import '../../../../utilities/app_language.dart';
import '../../../../utilities/page_transition.dart';
import 'venuepages.dart';

/// Plots the currently-loaded venues on a map, one pin each. Was
/// completely missing — "Venues – map is missing" in the client's list —
/// venues could only ever be browsed as a swipe deck, with no way to see
/// where they actually are relative to each other or to the user.
///
/// Takes an already-fetched venue list (from HomeController.getVenuesList,
/// the same data source the swipe deck uses) rather than re-fetching, so
/// this is guaranteed to show exactly what the person was just browsing —
/// no separate endpoint, no risk of a mismatched/paginated subset.
class VenuesMapScreen extends StatefulWidget {
  static String routeName = './VenuesMapScreen';
  final List<dynamic> venues;
  final double? userLatitude;
  final double? userLongitude;

  const VenuesMapScreen({
    super.key,
    required this.venues,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<VenuesMapScreen> createState() => _VenuesMapScreenState();
}

class _VenuesMapScreenState extends State<VenuesMapScreen> {
  GoogleMapController? _mapController;
  Map<String, dynamic>? _selectedVenue;

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  List<Map<String, dynamic>> get _plottableVenues {
    return widget.venues
        .whereType<Map>()
        .map((v) => Map<String, dynamic>.from(v))
    // Ad items and anything missing real coordinates can't be
    // plotted — silently skipped rather than crashing the map.
        .where((v) =>
    v['type'] != 'ad' &&
        _asDouble(v['latitude']) != null &&
        _asDouble(v['longitude']) != null)
        .toList();
  }

  Set<Marker> _buildMarkers() {
    return _plottableVenues.map((venue) {
      final lat = _asDouble(venue['latitude'])!;
      final lng = _asDouble(venue['longitude'])!;
      final id = (venue['_id'] ?? venue['venue_name'] ?? '').toString();
      return Marker(
        markerId: MarkerId(id),
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        onTap: () => setState(() => _selectedVenue = venue),
      );
    }).toSet();
  }

  LatLng get _initialCenter {
    if (widget.userLatitude != null && widget.userLongitude != null) {
      return LatLng(widget.userLatitude!, widget.userLongitude!);
    }
    final plottable = _plottableVenues;
    if (plottable.isNotEmpty) {
      return LatLng(
        _asDouble(plottable.first['latitude'])!,
        _asDouble(plottable.first['longitude'])!,
      );
    }
    return const LatLng(22.9734, 78.6569); // Center of India — safe fallback
  }

  String _imageUrl(dynamic path) {
    final value = (path ?? '').toString();
    if (value.isEmpty) return '';
    return value.startsWith('http') ? value : '${AppConfigProvider.imageUrl}$value';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final markers = _buildMarkers();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColor.primaryColor(context),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              text: AppLanguage.venuesText[language],
              onPress: () => Navigator.pop(context),
            ),
            Expanded(
              child: markers.isEmpty
                  ? Center(
                child: Text(
                  "No venues with a location to show right now.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColor.secondryColor(context).withOpacity(0.6),
                    fontFamily: AppFont.fontFamily,
                    fontSize: 14,
                  ),
                ),
              )
                  : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialCenter,
                      zoom: 12,
                    ),
                    markers: markers,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) => _mapController = controller,
                    onTap: (_) => setState(() => _selectedVenue = null),
                  ),
                  if (_selectedVenue != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: GestureDetector(
                        onTap: () {
                          final venueId = (_selectedVenue!['_id'] ?? '').toString();
                          if (venueId.isEmpty) return;
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: VenuePages(venueId: venueId),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor(context),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageUrl(_selectedVenue!['venue_image']),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColor.filledcolor(context),
                                    child: Icon(Icons.location_city,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (_selectedVenue!['venue_name'] ?? '').toString(),
                                      style: TextStyle(
                                        color: AppColor.secondryColor(context),
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_selectedVenue!['address'] != null)
                                      Text(
                                        (_selectedVenue!['address'] ?? '').toString(),
                                        style: TextStyle(
                                          color: AppColor.secondryColor(context)
                                              .withOpacity(0.6),
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: AppColor.secondryColor(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}