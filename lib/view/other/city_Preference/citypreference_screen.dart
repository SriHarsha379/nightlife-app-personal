import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_header.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/city_Preference/additional_info.dart';
import 'package:night_life/view/bottom%20navigation/search_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';

class CityPreference extends StatefulWidget {
  const CityPreference({super.key});

  @override
  State<CityPreference> createState() => _CityPreferenceState();
}

class _CityPreferenceState extends State<CityPreference> {
  TextEditingController searchController = TextEditingController();

List<int> selectedIds = [];

   List cityList = [
    {
      'id': '1',
      'name': 'Mumbai',
      'image': './assets/icons/mumbai.png',
    },
    {
      'id': '2',
      'name': 'Delhi',
      'image': './assets/icons/delhi.png',
    },
    {
      'id': '3',
      'name': 'Bangalore',
      'image': './assets/icons/banglore.png',
    },
    {
      'id': '4',
      'name': 'Goa',
      'image': './assets/icons/goa.jpg',
    },
    {
      'id': '5',
      'name': 'Kolkata',
      'image': './assets/icons/kolkata.jpg',
    },
    {
      'id': '6',
      'name': 'Pune',
      'image': './assets/icons/pune.jpg',
    },
    {
      'id': '7',
      'name': 'Chennai',
      'image': './assets/icons/chennai.jpg',
    },
    {
      'id': '8',
      'name': 'Hyderabad',
      'image': './assets/icons/hydrabad_icon.jpg',
    },
  ];

  double _currentDistance = 80;
  bool _isBroadened = false;

  int selectedIndex = 1;
  int pronounsSelectedIndex = 1;
  int sexualitySelectedIndex = 1;

  @override
  Widget build(BuildContext context) {
   
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            // backgroundColor: AppColor.primaryColor,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AppButton(
                text: '${AppLanguage.continueText[language]}',
                onPress: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: AdditionalInfoScreen(),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            ),
            body: Container(
              height: size.height * 100 / 100,
              width: size.width * 100 / 100,
              decoration:
                  BoxDecoration(gradient: AppColor.backgroundGradientcolor),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 5 / 100,
                  ),
                  Container(
                    width: size.width * 90 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                              color: AppColor.secondryColor,
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
                              color: AppColor.secondryColor),
                        ),
                        Container(
                          height: size.width * 5 / 100,
                          width: size.width * 5 / 100,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 2 / 100,
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            width: size.width * 90 / 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height * 2 / 100,
                                ),
                                Text(
                                  AppLanguage.whereDoYouGoOutText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.secondryColor),
                                ),
                                SizedBox(
                                  height: size.height * 2.5 / 100,
                                ),
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
                                    textAlignVertical: TextAlignVertical.center,
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
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColor.borderColor,
                                          width: 0,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColor.borderColor,
                                          width: 0,
                                        ),
                                      ),
                                      border: InputBorder.none,
                                      hintText: AppLanguage
                                          .searchForaCityText[language],
                                      hintStyle: AppConstant.textFilledStyle,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: size.height * 2 / 100,
                                        horizontal: size.width * 4 / 100,
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 3.5 / 100,
                                ),
                                Container(
                                  width: size.width * 0.9,
                                  height: size.height * 0.28,
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
                                        vertical: 5, horizontal: 20),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppLanguage
                                                .popularCitiesText[language],
                                            style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.secondryColor),
                                          ),
                                          SizedBox(
                                            height: size.height * 1.5 / 100,
                                          ),
                                Wrap(
              spacing: size.width * 5 / 100,
              runSpacing: size.height * 2 / 100,
              children: List.generate(cityList.length, (index) {
                int id = int.parse(cityList[index]['id']);   // Keep int conversion
            
                bool isSelected = selectedIds.contains(id);  // matches type int
            
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
            selectedIds.remove(id);              // remove int
                      } else {
            if (selectedIds.length < 5) {
              selectedIds.add(id);               // add int
            } else {}
                      }
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
            height: size.width * 14 / 100,
            width: size.width * 14 / 100,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColor.filledcolor
                  : AppColor.filledcolor,
              border: Border.all(
                color: isSelected
                    ? AppColor.buttonColor
                    : AppColor.borderColor,
                width: 1,
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage(
                  cityList[index]['image']!,
                ),
                fit: BoxFit.cover,
              ),
            ),
                      ),
                      SizedBox(height: size.height * 1 / 100),
                      Text(
            cityList[index]['name']!,
            style: TextStyle(
              fontFamily: AppFont.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColor.secondryColor,
            ),
                      ),
                    ],
                  ),
                );
              }),
            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 2 / 100,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: size.width * 90 / 100,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              AppLanguage.mapViewText[language],
                              style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor),
                            ),
                          ),
                          SizedBox(
                            height: size.height * 2.5 / 100,
                          ),
                          Stack(
                            children: [
                              Container(
                                height: size.height * 45 / 100,
                                width: size.width * 100 / 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColor.darkPurpleColor,
                                      width: 2),
                                  image: DecorationImage(
                                      image: AssetImage(AppImage.mapImageIcon),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                // right: 1,
                                left: 105,
                                bottom: 15,
                                child: GestureDetector(
                                  child: Container(
                                    height: size.height * 3.5 / 100,
                                    width: size.width * 45 / 100,
                                    decoration: BoxDecoration(
                                      color: AppColor.backgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          AppImage.pinLocationicon,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              4 /
                                              100,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              2 /
                                              100,
                                          color: AppColor.secondryColor,
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1.5 /
                                                100),
                                        Text(
                                          AppLanguage
                                              .currentLocationText[language],
                                          style: TextStyle(
                                            color: AppColor.secondryColor,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w300,
                                            fontFamily: AppFont.fontFamily,
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1 /
                                                100),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Divider(
                          //   thickness: 4,
                          //   color: AppColor.darkPurpleColor,
                          // ),
            
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16),
            
                                Text(
                                  AppLanguage.distanceText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColor.secondryColor,
                                  ),
                                ),
            
                                SizedBox(height: 14), // instead of size
            
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: AppColor.darkPurpleColor,
                                      width: 1,
                                    ),
                                    color: Colors.transparent,
                                  ),
                                  padding: const EdgeInsets.only(right: 6),
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
                                        padding: EdgeInsets.only(left: 18),
                                        child: Text(
                                          "Upto ${_currentDistance.toInt()} kilometres away",
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: AppColor.secondryColor,
                                          ),
                                        ),
                                      ),
                                      SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 4.0,
                                          overlayShape: RoundSliderOverlayShape(
                                              overlayRadius: 20),
                                          thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 10),
                                        ),
                                        child: Slider(
                                          value: _currentDistance,
                                          min: 1,
                                          max: 100,
                                          activeColor: AppColor.pinkColor,
                                          inactiveColor:
                                              AppColor.lightgreyColor,
                                          onChanged: (value) {
                                            setState(() {
                                              _currentDistance = value;
                                            });
                                          },
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 19.0),
                                            child: Text(
                                              "1km",
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                color: AppColor.secondryColor,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 17.0),
                                            child: Text(
                                              "60km",
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                color: AppColor.secondryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 19.0),
                                              child: Text(
                                                "Broaden the vibe zone...",
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: AppColor
                                                      .greygreyLightColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 5.0),
                                            child: Transform.scale(
                                              scale: 0.72,
                                              child: Switch(
                                                value: _isBroadened,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _isBroadened = value;
                                                  });
                                                },
                                                activeColor: AppColor.pinkColor,
                                                inactiveTrackColor:
                                                    AppColor.secondryColor,
                                                inactiveThumbColor:
                                                    AppColor.secondryColor,
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
                          SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  15 /
                                  100),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

class AboutRow extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const AboutRow({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.07,
        decoration: BoxDecoration(
          color: AppColor.themeColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 0.3,
            color: AppColor.pinkColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.05),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondryColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.05),
              child: Container(
                height: size.height * 0.03,
                width: size.height * 0.03,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColor.pinkColor
                        : AppColor.lightgreyColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    height: size.height * 0.015,
                    width: size.height * 0.015,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? AppColor.pinkColor : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
