// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:night_life/view/other/city_Preference/event_preference.dart';
import '../../../controller/genres/music_genres_controller.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class MusicGenresScreen extends StatefulWidget {
  static String routeName = './MusicGenresScreen';
  const MusicGenresScreen({super.key});
  @override
  State<MusicGenresScreen> createState() => _MusicGenresScreenState();
}

class _MusicGenresScreenState extends State<MusicGenresScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> filteredGenres = [];

  @override
  void initState() {
    super.initState();

    // Fetch genres data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MusicGenresController>(context, listen: false)
          .fetchGenresData(context);
    });

    // Add search listener
    searchController.addListener(_filterGenres);
  }

  void _filterGenres() {
    final controller =
        Provider.of<MusicGenresController>(context, listen: false);
    final query = searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredGenres = controller.getGenresList;
      } else {
        filteredGenres = controller.getGenresList
            .where((genre) =>
                genre['name'].toString().toLowerCase().contains(query))
            .toList();
        filteredGenres = controller.getGenresList
            .where((genre) =>
                genre['category'].toString().toLowerCase().contains(query))
            .toList();
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
    final size = MediaQuery.of(context).size;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer<MusicGenresController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AppButton(
                text: '${AppLanguage.continueText[language]}',
                onPress: () {
                  // Get selected genres as comma-separated string
                  String selectedGenres = controller.getSelectedGenresString();

                  if (selectedGenres.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please select at least one genre"),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Navigate to next screen with selected genres
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: EventPreference(
                        selectedGenres: selectedGenres,
                        customGenre: searchController.text,
                      ),
                      duration: const Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            );
          },
        ),
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          child: Consumer<MusicGenresController>(
            builder: (context, controller, child) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 3 / 100),

                    // Header
                    SizedBox(
                      width: size.width * 90 / 100,
                      height: size.height * 8 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SizedBox(
                              width: size.width * 4 / 100,
                              child: SizedBox(
                                height: size.height * 5 / 100,
                                child: Image.asset(
                                  AppImage.backArrowIcon,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 80 / 100,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLanguage.musicGenres[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subtitle
                    SizedBox(
                      width: size.width * 80 / 100,
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          AppLanguage.pickUpgenreText[language],
                          style: TextStyle(
                            fontFamily: AppFont.plusJakartaSansFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    // Selection counter
                    SizedBox(
                      width: size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: size.width * 2 / 100),
                              Image.asset(
                                AppImage.fireIcon,
                                height: size.width * 4 / 100,
                                width: size.width * 4 / 100,
                              ),
                              SizedBox(width: size.width * 2 / 100),
                              Text(
                                AppLanguage.topPicksforText[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${controller.selectedCount}/${controller.maxSelection}',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.buttonColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    // Loading or Genres Grid
                    if (controller.getIsLoading)
                      SizedBox(
                        height: size.height * 40 / 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.buttonColor,
                          ),
                        ),
                      )
                    else if (controller.getGenresList.isEmpty)
                      SizedBox(
                        height: size.height * 40 / 100,
                        child: Center(
                          child: Text(
                            'No genres available',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      )
                    else
                      _buildGenresGrid(controller),

                    SizedBox(height: size.height * 2 / 100),

                    // Search section
                    SizedBox(
                      width: size.width * 90 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.otherGenretexts[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    // Search field
                    Container(
                      width: size.width * 90 / 100,
                      height: size.height * 6 / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColor.filledcolor(context),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 1),
                            spreadRadius: 0,
                            blurRadius: 0,
                            color: AppColor.transparentColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: searchController,
                        cursorColor: AppColor.secondryColor(context),
                        style:
                            TextStyle(color: AppColor.secondryColor(context)),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                              left: size.width * 4 / 100,
                              right: size.width * 2 / 100,
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: size.width * 2 / 100,
                            minHeight: size.height * 6 / 100,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColor.borderColor,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColor.borderColor,
                              width: 2,
                            ),
                          ),
                          border: InputBorder.none,
                          hintText:
                              AppLanguage.typeYourfavouritegenreText[language],
                          hintStyle: AppConstant.textFilledStyle1(context),
                          contentPadding: EdgeInsets.only(
                            right: size.width * 4 / 100,
                          ),
                        ),
                      ),
                    ),

                    // // Filtered results
                    // if (searchController.text.isNotEmpty)
                    //   _buildFilteredResults(controller),

                    SizedBox(height: size.height * 20 / 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGenresGrid(MusicGenresController controller) {
    final size = MediaQuery.of(context).size;
    List<dynamic> genres = controller.getGenresList;

    // Create pairs for 2-column layout
    List<List<dynamic>> genrePairs = [];
    for (int i = 0; i < genres.length; i += 2) {
      if (i + 1 < genres.length) {
        genrePairs.add([genres[i], genres[i + 1]]);
      } else {
        genrePairs.add([genres[i]]);
      }
    }

    return Column(
      children: List.generate(genrePairs.length, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          child: Row(
            children: [
              // First genre in pair
              Expanded(
                child: _buildGenreCard(
                  controller,
                  genrePairs[index][0],
                ),
              ),

              // Second genre in pair (if exists)
              if (genrePairs[index].length > 1)
                Expanded(
                  child: _buildGenreCard(
                    controller,
                    genrePairs[index][1],
                  ),
                )
              else
                Expanded(child: SizedBox()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGenreCard(MusicGenresController controller, dynamic genre) {
    final size = MediaQuery.of(context).size;
    String genreId = genre['_id'] ?? '';
    String genreName = genre['name'] ?? '';
    String genreCategory = genre['category'] ?? '';

    String? imageUrl = genre['image'];
    bool isSelected = controller.isGenreSelected(genreId);

    return GestureDetector(
      onTap: () {
        if (!isSelected &&
            controller.selectedCount >= controller.maxSelection) {
          SnackBarToastMessage.info(
              context, "Max ${controller.maxSelection} selections allowed");
        } else {
          controller.toggleGenreSelection(genreId);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          height: size.height * 18 / 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColor.buttonColor : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Genre image or placeholder
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    controller.getGenreImageUrl(imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(genreName);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColor.buttonColor,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  )
                else
                  _buildPlaceholder(genreName),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),

                // Genre name
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        genreName,
                        style: TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        genreCategory,
                        style: TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Selection checkmark
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColor.buttonColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String genreName) {
    return Container(
      color: AppColor.filledcolor(context),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 48,
          color: AppColor.secondryColor(context).withOpacity(0.3),
        ),
      ),
    );
  }
}
