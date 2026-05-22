import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/authentication/signup.dart';
import 'package:night_life/view/other/city_Preference/additional_info.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../controller/city/city_preference.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_snack_bar_toast_message.dart';

class CityPreference extends StatefulWidget {
  const CityPreference({super.key});

  @override
  State<CityPreference> createState() => _CityPreferenceState();
}

class _CityPreferenceState extends State<CityPreference> {
  TextEditingController searchController = TextEditingController();
  DateTime? lastPressed;
  GoogleMapController? mapController;
  Set<Circle> circles = {};
  Set<Marker> markers = {};

  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CityPreferenceController>(context, listen: false)
          .fetchCityList(context);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  List<dynamic> _getFilteredCities(List<dynamic> cities) {
    if (searchController.text.isEmpty) {
      return cities;
    }
    return cities.where((city) {
      String cityName = city['city_name']?.toString().toLowerCase() ?? '';
      return cityName.contains(searchController.text.toLowerCase());
    }).toList();
  }

  double _getZoomLevel(double radiusInKm) {
    if (radiusInKm <= 10) return 11.5;
    if (radiusInKm <= 20) return 10.5;
    if (radiusInKm <= 30) return 10.0;
    if (radiusInKm <= 40) return 9.5;
    return 9.0;
  }

  void _updateMapCircles(CityPreferenceController controller) {
    if (controller.getCurrentConfigCity == null) return;
    if (!_isMapReady) return;

    final currentCity = controller.getCurrentConfigCity!;
    final lat = controller.getCityLatitude(currentCity);
    final lng = controller.getCityLongitude(currentCity);
    final cityName = currentCity['city_name'] ?? '';

    setState(() {
      circles = {
        Circle(
          circleId: const CircleId('radius'),
          center: LatLng(lat, lng),
          radius: controller.getCurrentDistance * 1000,
          fillColor: AppColor.pinkColor.withOpacity(0.2),
          strokeColor: AppColor.pinkColor,
          strokeWidth: 2,
        ),
      };

      markers = {
        Marker(
          markerId: const MarkerId('city_center'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: cityName,
            snippet: '${controller.getCurrentDistance.toInt()} km radius',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      };
    });
  }

  void _moveCameraToLocation(LatLng location, double radiusInKm) {
    if (mapController == null || !_isMapReady) {
      print("Map not ready yet");
      return;
    }

    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          location,
          _getZoomLevel(radiusInKm),
        ),
      );
    } catch (e) {
      print("Error animating camera: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final cardColor = AppColor.pastbookeventcontainercolor(context);
    const cityChipRadius = 24.0;
    const mapCardRadius = 18.0;
    return Consumer<CityPreferenceController>(
      builder: (context, controller, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            final now = DateTime.now();
            const maxDuration = Duration(seconds: 2);
            final isWarning = lastPressed == null ||
                now.difference(lastPressed!) > maxDuration;

            if (isWarning) {
              lastPressed = now;
              SnackBarToastMessage.showSnackBar(
                  context, AppLanguage.pressAgainExitText[language]);
            } else {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            }
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  isDark ? Brightness.dark : Brightness.light, // iOS
            ),
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Scaffold(
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                floatingActionButton: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: AppButton(
                    text: controller.allCitiesConfigured
                        ? AppLanguage.continueText[language]
                        : "Next",
                    onPress: () {
                      if (controller.getSelectedCities.isEmpty) {
                        SnackBarToastMessage.showSnackBar(
                          context,
                          "Please select at least one city",
                        );
                        return;
                      }

                      if (!controller.allCitiesConfigured) {
                        controller.moveToNextCity();

                        if (controller.getCurrentConfigCity != null) {
                          final nextCity = controller.getCurrentConfigCity!;
                          final lat = controller.getCityLatitude(nextCity);
                          final lng = controller.getCityLongitude(nextCity);

                          Future.delayed(const Duration(milliseconds: 300), () {
                            _moveCameraToLocation(
                              LatLng(lat, lng),
                              controller.getCurrentDistance,
                            );
                            _updateMapCircles(controller);
                          });
                        }
                        return;
                      }

                      // ✅ Prepare city data in required format
                      final cityRadiusData = controller.getAllCityRadiusData();
                      List<Map<String, dynamic>> preferredCities =
                          cityRadiusData.map((city) {
                        return {
                          "city_id": city['city_id'],
                          "latitude": city['latitude'],
                          "longitude": city['longitude'],
                          "radius": city['radius'].toInt(),
                        };
                      }).toList();

                      print("✅ Preferred Cities Data: $preferredCities");

                      // ✅ Navigate to AdditionalInfo with city data
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: AdditionalInfoScreen(
                            preferredCities: preferredCities,
                          ),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                ),
                body: Container(
                  height: size.height * 100 / 100,
                  width: size.width * 100 / 100,
                  decoration: BoxDecoration(
                      gradient: AppColor.backgroundGradientcolor(context)),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 5 / 100),

                      // Header
                      SizedBox(
                        width: size.width * 90 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignUp()));
                              },
                              child: Image.asset(
                                  color: AppColor.secondryColor(context),
                                  height: size.width * 5 / 100,
                                  width: size.width * 5 / 100,
                                  AppImage.backArrowIcon),
                            ),
                            Text(
                              AppLanguage.cityPreferenceText[language],
                              style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppColor.secondryColor(context)),
                            ),
                            SizedBox(
                              height: size.width * 5 / 100,
                              width: size.width * 5 / 100,
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 2 / 100),

                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                width: size.width * 90 / 100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: size.height * 2 / 100),

                                    // Title
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: AppLanguage
                                                    .selectYourPrefferedCityText[
                                                language],
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                          TextSpan(
                                            text: " (Max 4)",
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: size.height * 2 / 100),

                                    // Search Field
                                    Container(
                                      width: size.width * 95 / 100,
                                      height: size.height * 6 / 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: AppColor.filledcolor(context),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 1),
                                            spreadRadius: 0,
                                            blurRadius: 0,
                                            color: AppColor.transparentColor
                                                .withOpacity(0.1),
                                          ),
                                        ],
                                      ),
                                      child: TextFormField(
                                        controller: searchController,
                                        cursorColor:
                                            AppColor.secondryColor(context),
                                        style: TextStyle(
                                            color: AppColor.secondryColor(
                                                context)),
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.only(
                                              left: size.width * 4 / 100,
                                              right: size.width * 2 / 100,
                                            ),
                                            child: Image.asset(
                                              AppImage.searchIcon,
                                              height: size.width * 4 / 100,
                                              width: size.width * 4 / 100,
                                              color:
                                                  AppColor.filledText(context),
                                            ),
                                          ),
                                          prefixIconConstraints: BoxConstraints(
                                            minWidth: size.width * 12 / 100,
                                            minHeight: size.height * 6 / 100,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: AppColor.borderColor,
                                              width: 0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: AppColor.borderColor,
                                              width: 0,
                                            ),
                                          ),
                                          border: InputBorder.none,
                                          hintText: AppLanguage
                                              .searchForaCityText[language],
                                          hintStyle:
                                              AppConstant.textFilledStyle(
                                                  context),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: size.height * 2 / 100,
                                            horizontal: size.width * 4 / 100,
                                          ),
                                          isDense: true,
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: size.height * 3.5 / 100),

                                    // Popular Cities Container
                                    Container(
                                      width: size.width * 0.9,
                                      constraints: BoxConstraints(
                                        minHeight: size.height * 0.24,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          width: 0.7,
                                          color: AppColor.pinkColor,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 18),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  AppLanguage.popularCitiesText[
                                                      language],
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor
                                                        .secondryColor(context),
                                                  ),
                                                ),
                                                Text(
                                                  "${controller.getSelectedCities.length}/4",
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColor
                                                        .pinkColor
                                                        .withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    size.height * 1.5 / 100),

                                            // Loading or City List
                                            controller.getIsLoading
                                                ? const Center(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(20.0),
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            AppColor.pinkColor,
                                                      ),
                                                    ),
                                                  )
                                                : _getFilteredCities(controller
                                                            .getCityList)
                                                        .isEmpty
                                                    ? Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Text(
                                                            searchController
                                                                    .text
                                                                    .isNotEmpty
                                                                ? "No cities found"
                                                                : "No cities available",
                                                            style: TextStyle(
                                                                fontFamily: AppFont
                                                                    .fontFamily,
                                                                fontSize: 14,
                                                                color: AppColor
                                                                    .secondryColor(
                                                                        context)),
                                                          ),
                                                        ),
                                                      )
                                                    : Wrap(
                                                        spacing:
                                                           size.width * 2 / 100,
                                                        runSpacing:
                                                           size.height *
                                                               1.2 /
                                                               100,
                                                        children: _getFilteredCities(
                                                               controller
                                                                   .getCityList)
                                                           .map((city) {
                                                          String cityId =
                                                              city['_id'] ?? '';
                                                          String cityName =
                                                              city['city_name'] ??
                                                                  'Unknown';

                                                          bool isSelected =
                                                              controller
                                                                  .isCitySelected(
                                                                      cityId);

                                                          return InkWell(
                                                            borderRadius: BorderRadius
                                                                .circular(
                                                                    cityChipRadius),
                                                            onTap: () {
                                                              if (!isSelected &&
                                                                  controller
                                                                          .getSelectedCities
                                                                          .length >=
                                                                      4) {
                                                                SnackBarToastMessage
                                                                    .showSnackBar(
                                                                  context,
                                                                  "Maximum 4 cities can be selected",
                                                                );
                                                                return;
                                                              }
                                                              controller
                                                                  .toggleCitySelection(
                                                                      city);

                                                              if (controller
                                                                  .getSelectedCities
                                                                  .isNotEmpty) {
                                                                controller
                                                                    .resetCityConfiguration();

                                                                Future.delayed(
                                                                    const Duration(
                                                                        milliseconds:
                                                                            300),
                                                                    () {
                                                                  if (_isMapReady) {
                                                                    final firstCity =
                                                                        controller
                                                                            .getSelectedCities[0];
                                                                    final lat =
                                                                        controller
                                                                            .getCityLatitude(firstCity);
                                                                    final lng =
                                                                        controller
                                                                            .getCityLongitude(firstCity);

                                                                    _moveCameraToLocation(
                                                                      LatLng(
                                                                          lat,
                                                                          lng),
                                                                      controller
                                                                          .getCurrentDistance,
                                                                    );
                                                                    _updateMapCircles(
                                                                        controller);
                                                                  }
                                                                });
                                                              }
                                                            },
                                                            child: AnimatedContainer(
                                                             duration:
                                                                 const Duration(
                                                                     milliseconds:
                                                                         180),
                                                             padding:
                                                                 const EdgeInsets
                                                                     .symmetric(
                                                                     horizontal:
                                                                         14,
                                                                     vertical:
                                                                         9),
                                                             decoration:
                                                                 BoxDecoration(
                                                               borderRadius:
                                                                   BorderRadius
                                                                       .circular(
                                                                           cityChipRadius),
                                                               color: isSelected
                                                                   ? AppColor
                                                                       .pinkColor
                                                                       .withOpacity(
                                                                           0.18)
                                                                   : AppColor
                                                                       .filledcolor(
                                                                           context),
                                                               border:
                                                                   Border.all(
                                                                 color: isSelected
                                                                     ? AppColor
                                                                         .pinkColor
                                                                     : AppColor
                                                                         .borderColor
                                                                         .withOpacity(
                                                                             0.55),
                                                                 width: 1.1,
                                                               ),
                                                             ),
                                                             child: Row(
                                                               mainAxisSize:
                                                                   MainAxisSize
                                                                       .min,
                                                               children: [
                                                                 Text(
                                                                   cityName,
                                                                   style:
                                                                       TextStyle(
                                                                     fontFamily:
                                                                         AppFont
                                                                             .fontFamily,
                                                                     fontSize:
                                                                         13,
                                                                     fontWeight:
                                                                         FontWeight
                                                                             .w500,
                                                                     color: isSelected
                                                                         ? AppColor
                                                                             .pinkColor
                                                                         : AppColor
                                                                             .secondryColor(context),
                                                                   ),
                                                                 ),
                                                                 if (isSelected)
                                                                   const Padding(
                                                                     padding: EdgeInsets
                                                                         .only(
                                                                         left:
                                                                             6),
                                                                     child:
                                                                         Icon(
                                                                       Icons
                                                                           .check_circle,
                                                                       size:
                                                                           16,
                                                                       color: AppColor
                                                                           .pinkColor,
                                                                     ),
                                                                   ),
                                                               ],
                                                             ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: size.height * 2 / 100),
                                  ],
                                ),
                              ),

                              SizedBox(height: size.height * 4 / 100),

                              // Map View Section
                              if (controller.getSelectedCities.isNotEmpty &&
                                  controller.getCurrentConfigCity != null) ...[
                                Container(
                                  width: size.width * 90 / 100,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "${AppLanguage.mapViewText[language]} - ${controller.getCurrentConfigCity!['city_name']} (${controller.getCurrentCityIndex + 1}/${controller.getSelectedCities.length})",
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),

                                SizedBox(height: size.height * 2.5 / 100),

                                Container(
                                 height: size.height * 38 / 100,
                                 width: size.width * 90 / 100,
                                   decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(
                                       mapCardRadius),
                                   border: Border.all(
                                       color: AppColor.darkPurpleColor,
                                       width: 1.5),
                                 ),
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(
                                       mapCardRadius),
                                   child: GoogleMap(
                                     initialCameraPosition: CameraPosition(
                                       target: LatLng(
                                         controller.getCityLatitude(
                                             controller.getCurrentConfigCity!),
                                         controller.getCityLongitude(
                                             controller.getCurrentConfigCity!),
                                       ),
                                       zoom: _getZoomLevel(
                                           controller.getCurrentDistance),
                                     ),
                                     circles: circles,
                                     markers: markers,
                                     onMapCreated:
                                         (GoogleMapController gController) {
                                       print("Map created callback");
                                       mapController = gController;

                                       Future.delayed(
                                           const Duration(milliseconds: 500),
                                           () {
                                         print("Map is now ready");
                                         setState(() {
                                           _isMapReady = true;
                                         });
                                         _updateMapCircles(controller);
                                       });
                                     },
                                     myLocationButtonEnabled: false,
                                     zoomControlsEnabled: false,
                                     mapToolbarEnabled: false,
                                     scrollGesturesEnabled: true,
                                     zoomGesturesEnabled: true,
                                     tiltGesturesEnabled: true,
                                     rotateGesturesEnabled: true,
                                   ),
                                 ),
                                ),

                                // Distance Section
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size.height * 4 / 100),
                                      Text(
                                        AppLanguage.distanceText[language],
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                            color: AppColor.darkPurpleColor,
                                            width: 1,
                                          ),
                                          color: Colors.transparent,
                                        ),
                                        padding:
                                            const EdgeInsets.only(right: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    1 /
                                                    100),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 18),
                                              child: Text(
                                                "Up to ${controller.getCurrentDistance.toInt()} kilometres away",
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  color: AppColor.secondryColor(
                                                      context),
                                                ),
                                              ),
                                            ),
                                            SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                trackHeight: 4.0,
                                                overlayShape:
                                                    const RoundSliderOverlayShape(
                                                        overlayRadius: 20),
                                                thumbShape:
                                                    const RoundSliderThumbShape(
                                                        enabledThumbRadius: 10),
                                              ),
                                              child: Slider(
                                                value: controller
                                                    .getCurrentDistance,
                                                min: 1.0,
                                                max: 60.0,
                                                activeColor: AppColor.pinkColor,
                                                inactiveColor:
                                                    AppColor.lightgreyColor,
                                                onChanged: (value) {
                                                  controller
                                                      .updateDistance(value);
                                                  _updateMapCircles(controller);

                                                  if (_isMapReady) {
                                                    final currentCity = controller
                                                        .getCurrentConfigCity!;
                                                    final lat = controller
                                                        .getCityLatitude(
                                                            currentCity);
                                                    final lng = controller
                                                        .getCityLongitude(
                                                            currentCity);
                                                    _moveCameraToLocation(
                                                      LatLng(lat, lng),
                                                      value,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 19.0),
                                                  child: Text(
                                                    "1km",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 10,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 17.0),
                                                  child: Text(
                                                    "60km",
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 10,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 19.0),
                                                    child: Text(
                                                      "Broaden the vibe zone...",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13,
                                                        color: isDark
                                                            ? AppColor
                                                                .greygreyLightColor
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 5.0),
                                                  child: Transform.scale(
                                                    scale: 0.72,
                                                    child: Switch(
                                                      value: controller
                                                          .getIsBroadened,
                                                      onChanged: (value) {
                                                        controller
                                                            .toggleBroadened(
                                                                value);
                                                        _updateMapCircles(
                                                            controller);

                                                        if (_isMapReady) {
                                                          final currentCity =
                                                              controller
                                                                  .getCurrentConfigCity!;
                                                          final lat = controller
                                                              .getCityLatitude(
                                                                  currentCity);
                                                          final lng = controller
                                                              .getCityLongitude(
                                                                  currentCity);
                                                          _moveCameraToLocation(
                                                            LatLng(lat, lng),
                                                            controller
                                                                .getCurrentDistance,
                                                          );
                                                        }
                                                      },
                                                      activeColor: Colors.white,
                                                      activeTrackColor:
                                                          AppColor.pinkColor,
                                                      inactiveThumbColor:
                                                          Colors.white,
                                                      inactiveTrackColor: isDark
                                                          ? const Color(
                                                              0xFF6E6E6E)
                                                          : const Color(
                                                              0xFFBDBDBD),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              SizedBox(height: size.height * 14 / 100),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
