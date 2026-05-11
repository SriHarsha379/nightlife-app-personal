import 'package:flutter/material.dart';
import 'package:night_life/utilities/app_color.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:provider/provider.dart';

import '../controller/city/city_preference.dart';

class CitySelectionBottomSheet extends StatefulWidget {
  final List<dynamic> cities; // API city list
  final String? selectedCityId;
  final Function(String cityId, String cityName) onCitySelected;

  const CitySelectionBottomSheet({
    Key? key,
    required this.cities,
    this.selectedCityId,
    required this.onCitySelected,
  }) : super(key: key);

  @override
  State<CitySelectionBottomSheet> createState() =>
      _CitySelectionBottomSheetState();
}

class _CitySelectionBottomSheetState extends State<CitySelectionBottomSheet> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredCities = [];

  @override
  void initState() {
    super.initState();
    filteredCities = widget.cities;
    searchController.addListener(_filterCities);
  }

  void _filterCities() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCities = widget.cities;
      } else {
        filteredCities = widget.cities.where((city) {
          String cityName = city['city_name']?.toString().toLowerCase() ?? '';
          return cityName.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.backgroundGradientcolor(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.greyLightColor(context).withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Select Your City',
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),

          // Search field
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              cursorColor: AppColor.secondryColor(context),
              decoration: InputDecoration(
                hintText: 'Search cities...',
                hintStyle: TextStyle(
                  color: AppColor.hinttextcolor(context),
                  fontFamily: AppFont.fontFamily,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColor.hinttextcolor(context),
                ),
                filled: true,
                fillColor: AppColor.textFieldColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.buttonColor
                        : AppColor.greyLightColor(context),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColor.buttonColor
                        : AppColor.greyLightColor(context),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColor.buttonColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontFamily: AppFont.fontFamily,
              ),
            ),
          ),

          // Cities List
          Expanded(
            child: Consumer<CityPreferenceController>(
              builder: (context, cityController, child) {
                if (filteredCities.isEmpty) {
                  return Center(
                    child: Text(
                      searchController.text.isEmpty
                          ? 'No cities available'
                          : 'No cities found',
                      style: TextStyle(
                        color: AppColor.greyLightColor(context),
                        fontFamily: AppFont.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    final cityId = city['_id'] ?? '';
                    final cityName = city['city_name'] ?? 'Unknown';
                    final cityImage = city['city_image'] ?? '';
                    // final userCount = city['user_count'] ?? 0;

                    final isSelected = cityId == widget.selectedCityId;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.buttonColor.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.buttonColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColor.filledcolor(context),
                            border: Border.all(
                              color: AppColor.borderColor,
                              width: 0.5,
                            ),
                          ),
                          child: cityImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    cityController.getCityImageUrl(cityImage),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to first letter if image fails
                                      return Center(
                                        child: Text(
                                          cityName.isNotEmpty
                                              ? cityName[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    cityName.isNotEmpty
                                        ? cityName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                        ),
                        title: Text(
                          cityName,
                          style: TextStyle(
                            color: isSelected
                                ? AppColor.buttonColor
                                : AppColor.secondryColor(context),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColor.buttonColor,
                                size: 24,
                              )
                            : null,
                        onTap: () {
                          widget.onCitySelected(cityId, cityName);
                          Navigator.pop(context);
                        },
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
