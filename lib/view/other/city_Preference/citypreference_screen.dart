import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/authentication/signup.dart';
import 'package:night_life/view/other/city_Preference/additional_info.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../controller/city_preference.dart';
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

  // ADD THIS: Map ready flag
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    // Fetch city list when screen loads
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

  // Filter cities based on search
  List<dynamic> _getFilteredCities(List<dynamic> cities) {
    if (searchController.text.isEmpty) {
      return cities;
    }
    return cities.where((city) {
      String cityName = city['city_name']?.toString().toLowerCase() ?? '';
      return cityName.contains(searchController.text.toLowerCase());
    }).toList();
  }

  // UPDATED: Update map circles with safety checks
  void _updateMapCircles(CityPreferenceController controller) {
    if (controller.getCurrentConfigCity == null) return;
    if (!_isMapReady) return; // Safety check

    final currentCity = controller.getCurrentConfigCity!;
    final lat = controller.getCityLatitude(currentCity);
    final lng = controller.getCityLongitude(currentCity);

    setState(() {
      circles = {
        Circle(
          circleId: const CircleId('radius'),
          center: LatLng(lat, lng),
          radius: controller.getCurrentDistance * 1000, // Convert km to meters
          fillColor: AppColor.pinkColor.withOpacity(0.2),
          strokeColor: AppColor.pinkColor,
          strokeWidth: 2,
        ),
      };
    });
  }

  // ADD THIS: Safe camera movement method
  void _moveCameraToLocation(LatLng location) {
    if (mapController == null || !_isMapReady) {
      print("Map not ready yet");
      return;
    }

    try {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(location, 12.0),
      );
    } catch (e) {
      print("Error animating camera: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
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
                      // Check if at least one city is selected
                      if (controller.getSelectedCities.isEmpty) {
                        SnackBarToastMessage.showSnackBar(
                          context,
                          "Please select at least one city",
                        );
                        return;
                      }

                      // If not all cities configured, move to next city
                      if (!controller.allCitiesConfigured) {
                        controller.moveToNextCity();

                        // UPDATED: Safe camera update with delay
                        if (controller.getCurrentConfigCity != null) {
                          final nextCity = controller.getCurrentConfigCity!;
                          final lat = controller.getCityLatitude(nextCity);
                          final lng = controller.getCityLongitude(nextCity);

                          // Use delay to ensure map is ready
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _moveCameraToLocation(LatLng(lat, lng));
                            _updateMapCircles(controller);
                          });
                        }
                        return;
                      }

                      // All cities configured, get data and navigate
                      Map<String, dynamic> data =
                          controller.getDataForNextScreen();

                      print("Data to pass: $data");

                      // Navigate to next screen
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const AdditionalInfoScreen(),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                  ),
                ),
                body: Container(
                  height: size.height * 100 / 100,
                  width: size.width * 100 / 100,
                  decoration: const BoxDecoration(
                      gradient: AppColor.backgroundGradientcolor),
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
                                  color: AppColor.secondryColor,
                                  height: size.width * 5 / 100,
                                  width: size.width * 5 / 100,
                                  AppImage.backArrowIcon),
                            ),
                            Text(
                              AppLanguage.cityPreferenceText[language],
                              style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: AppColor.secondryColor),
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
                                            style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.secondryColor,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: " (Max 4)",
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.secondryColor,
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
                                        color: AppColor.filledcolor,
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
                                        cursorColor: AppColor.secondryColor,
                                        style: const TextStyle(
                                            color: AppColor.secondryColor),
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
                                              color: AppColor.filledText,
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
                                              AppConstant.textFilledStyle,
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
                                        minHeight: size.height * 0.28,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColor.themeColor,
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          width: 0.3,
                                          color: AppColor.pinkColor,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLanguage
                                                  .popularCitiesText[language],
                                              style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColor.secondryColor),
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
                                                            style:
                                                                const TextStyle(
                                                              fontFamily: AppFont
                                                                  .fontFamily,
                                                              fontSize: 14,
                                                              color: AppColor
                                                                  .greygreyLightColor,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Wrap(
                                                        spacing: size.width *
                                                            5 /
                                                            100,
                                                        runSpacing:
                                                            size.height *
                                                                2 /
                                                                100,
                                                        children:
                                                            _getFilteredCities(
                                                                    controller
                                                                        .getCityList)
                                                                .map((city) {
                                                          String cityId =
                                                              city['_id'] ?? '';
                                                          String cityName =
                                                              city['city_name'] ??
                                                                  'Unknown';
                                                          String cityImage =
                                                              city['image'] ??
                                                                  '';

                                                          bool isSelected =
                                                              controller
                                                                  .isCitySelected(
                                                                      cityId);

                                                          return GestureDetector(
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

                                                              // UPDATED: Safe camera movement with delay
                                                              if (controller
                                                                  .getSelectedCities
                                                                  .isNotEmpty) {
                                                                controller
                                                                    .resetCityConfiguration();

                                                                // Wait before moving camera
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
                                                                            lng));
                                                                    _updateMapCircles(
                                                                        controller);
                                                                  }
                                                                });
                                                              }
                                                            },
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Container(
                                                                  height:
                                                                      size.width *
                                                                          14 /
                                                                          100,
                                                                  width:
                                                                      size.width *
                                                                          14 /
                                                                          100,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: AppColor
                                                                        .filledcolor,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: isSelected
                                                                          ? AppColor
                                                                              .buttonColor
                                                                          : AppColor
                                                                              .borderColor,
                                                                      width: 2,
                                                                    ),
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    image: cityImage
                                                                            .isNotEmpty
                                                                        ? DecorationImage(
                                                                            image:
                                                                                NetworkImage(
                                                                              controller.getCityImageUrl(cityImage),
                                                                            ),
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            onError:
                                                                                (exception, stackTrace) {
                                                                              print("Image load error: $exception");
                                                                            },
                                                                          )
                                                                        : null,
                                                                  ),
                                                                  child: cityImage
                                                                          .isEmpty
                                                                      ? Center(
                                                                          child:
                                                                              Text(
                                                                            cityName.isNotEmpty
                                                                                ? cityName[0].toUpperCase()
                                                                                : '?',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontFamily: AppFont.fontFamily,
                                                                              fontSize: 24,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: AppColor.secondryColor,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : null,
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        1 /
                                                                        100),
                                                                Text(
                                                                  cityName,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontFamily:
                                                                        AppFont
                                                                            .fontFamily,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: AppColor
                                                                        .secondryColor,
                                                                  ),
                                                                ),
                                                              ],
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

                              // Map View Section - Only show if cities are selected
                              if (controller.getSelectedCities.isNotEmpty &&
                                  controller.getCurrentConfigCity != null) ...[
                                Container(
                                  width: size.width * 90 / 100,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "${AppLanguage.mapViewText[language]} - ${controller.getCurrentConfigCity!['city_name']} (${controller.getCurrentCityIndex + 1}/${controller.getSelectedCities.length})",
                                    style: const TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.secondryColor),
                                  ),
                                ),

                                SizedBox(height: size.height * 2.5 / 100),

                                // UPDATED: Google Map Container with proper initialization
                                Container(
                                  height: size.height * 45 / 100,
                                  width: size.width * 100 / 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColor.darkPurpleColor,
                                        width: 2),
                                  ),
                                  child: GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(
                                        controller.getCityLatitude(
                                            controller.getCurrentConfigCity!),
                                        controller.getCityLongitude(
                                            controller.getCurrentConfigCity!),
                                      ),
                                      zoom: 12.0,
                                    ),
                                    circles: circles,
                                    onMapCreated:
                                        (GoogleMapController gController) {
                                      print("Map created callback");
                                      mapController = gController;

                                      // Wait for map to be fully initialized
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
                                        style: const TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.secondryColor,
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
                                                "Upto ${controller.getCurrentDistance.toInt()} kilometres away",
                                                style: const TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                  color: AppColor.secondryColor,
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
                                                },
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
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
                                                          .secondryColor,
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
                                                          .secondryColor,
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
                                                const Expanded(
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
                                                        color: AppColor
                                                            .greygreyLightColor,
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
                                                      },
                                                      activeColor:
                                                          AppColor.pinkColor,
                                                      inactiveTrackColor:
                                                          AppColor
                                                              .secondryColor,
                                                      inactiveThumbColor:
                                                          AppColor.pinkColor,
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

                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      20 /
                                      100),
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
