// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/page_transition.dart';
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
        filteredGenres = controller.getGenresList.where((genre) {
          final name = _genreNameFrom(genre).toLowerCase();
          final category = (genre['category'] ?? '').toString().toLowerCase();
          return name.contains(query) || category.contains(query);
        }).toList();
      }
    });
  }

  String _genreIdFrom(dynamic genre) {
    return (genre['_id'] ?? genre['id'] ?? genre['genre_id'] ?? '').toString();
  }

  String _genreNameFrom(dynamic genre) {
    return (genre['genre_name'] ?? genre['name'] ?? '').toString();
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
              padding: EdgeInsets.only(
                bottom: 40 + MediaQuery.of(context).padding.bottom,
              ),
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

  // Curated gradient palette, all within the app's existing dark
  // purple/pink theme family so genre tiles feel native, not like a
  // random color picker. Picked deterministically per genre name so the
  // same genre always gets the same look across app restarts.
  static const List<List<Color>> _genreGradients = [
    [Color(0xFF3A1C71), Color(0xFFD76D77)],
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    [Color(0xFFEE0979), Color(0xFF8E2DE2)],
    [Color(0xFF641E82), Color(0xFFEE0979)],
    [Color(0xFF360033), Color(0xFF0B8793)],
    [Color(0xFFC33764), Color(0xFF1D2671)],
    [Color(0xFF7F00FF), Color(0xFFE100FF)],
    [Color(0xFF41295A), Color(0xFF2F0743)],
  ];

  List<Color> _gradientForGenre(String genreName) {
    if (genreName.trim().isEmpty) return _genreGradients.first;
    final hash = genreName.toLowerCase().codeUnits.fold<int>(
        0, (prev, unit) => (prev * 31 + unit) & 0x7fffffff);
    return _genreGradients[hash % _genreGradients.length];
  }

  // Best-effort icon match by keyword; falls back to a generic music note
  // for anything not explicitly listed (new genres added via admin panel
  // still get a sensible default instead of breaking).
  IconData _iconForGenre(String genreName) {
    final name = genreName.toLowerCase();
    if (name.contains('bollywood')) return Icons.theater_comedy_rounded;
    if (name.contains('hip hop') || name.contains('rap')) return Icons.mic_rounded;
    if (name.contains('r&b') || name.contains('rnb')) return Icons.favorite_rounded;
    if (name.contains('techno')) return Icons.bolt_rounded;
    if (name.contains('trance')) return Icons.auto_awesome_rounded;
    if (name.contains('psychedelic')) return Icons.blur_circular_rounded;
    if (name.contains('afrobeat')) return Icons.celebration_rounded;
    if (name.contains('reggaeton')) return Icons.music_note_rounded;
    if (name.contains('deep house')) return Icons.waves_rounded;
    if (name.contains('progressive')) return Icons.trending_up_rounded;
    if (name.contains('drum') || name.contains('bass')) return Icons.equalizer_rounded;
    if (name.contains('house')) return Icons.graphic_eq_rounded;
    if (name.contains('edm')) return Icons.electric_bolt_rounded;
    if (name.contains('rock')) return Icons.piano_rounded;
    if (name.contains('pop')) return Icons.star_rounded;
    if (name.contains('acoustic')) return Icons.piano_rounded;
    if (name.contains('commercial')) return Icons.trending_up_rounded;
    return Icons.music_note_rounded;
  }

  Widget _buildGenreCard(MusicGenresController controller, dynamic genre) {
    final size = MediaQuery.of(context).size;
    String genreId = _genreIdFrom(genre);
    String genreName = _genreNameFrom(genre);
    String genreCategory = (genre['category'] ?? '').toString();

    bool isSelected = controller.isGenreSelected(genreId);
    final gradientColors = _gradientForGenre(genreName);

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
                // Solid gradient background + genre icon, deterministic per
                // genre name - no photo, so nothing can ever look
                // mismatched or out of place.
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _iconForGenre(genreName),
                      size: 40,
                      color: Colors.white.withOpacity(0.35),
                    ),
                  ),
                ),

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

}