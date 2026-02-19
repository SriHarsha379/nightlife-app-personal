import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/controller/venues/my_venues_controller.dart';
import 'package:night_life/view/authentication/splash_screen.dart';
import 'package:provider/provider.dart';
import 'controller/book_venue/book_venue_details_controller.dart';
import 'controller/city/city_preference.dart';
import 'controller/book_venue/book_venue_controller.dart';
import 'controller/event_preference/event_preference_controller.dart';
import 'controller/genres/music_genres_controller.dart';
import 'controller/home/home_controller.dart';
import 'controller/members/members_controller.dart';
import 'controller/my_profile/get_my_profile.dart';
import 'controller/my_profile/get_my_swipe_profile_controller.dart';
import 'controller/my_profile/my_visibility_controller.dart';
import 'controller/search/search_filter_controller.dart';
import 'controller/support/faq_controller.dart';
import 'controller/venues/venues_details_controller.dart';
import 'controller/vibe_check/vibe_check_controller.dart';
import 'controller/vibe_preference/vibe_prefernce_controller.dart';
import 'provider/darkmode_provider.dart';
import 'provider/post_api_provider.dart';
import 'provider/user_controller.dart';
import 'utilities/app_font.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PostApiProvider()),
        ChangeNotifierProvider(create: (_) => VibeCheckController()),
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => CityPreferenceController()),
        ChangeNotifierProvider(create: (_) => MusicGenresController()),
        ChangeNotifierProvider(create: (_) => EventPreferenceController()),
        ChangeNotifierProvider(create: (_) => VibePreferenceController()),
        ChangeNotifierProvider(create: (_) => VibeCheckController()),
        ChangeNotifierProvider(create: (_) => HomeController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => GetMySwipeProfileController()),
        ChangeNotifierProvider(create: (_) => MyVisibilityController()),
        ChangeNotifierProvider(create: (_) => FaqController()),
        ChangeNotifierProvider(create: (_) => MembersController()),
        ChangeNotifierProvider(create: (_) => VenuesDetailsController()),
        ChangeNotifierProvider(create: (_) => BookVenueController()),
        ChangeNotifierProvider(create: (_) => MyVenuesController()),
        ChangeNotifierProvider(create: (_) => VenuesBookingDetailsController()),
        ChangeNotifierProvider(create: (_) => SearchFilterController()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: "Night Life",
            debugShowCheckedModeBanner: false,

            // Theme Mode - Switches between dark, light, and system
            themeMode: themeProvider.themeMode,

            // Dark Theme Configuration
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              fontFamily: AppFont.fontFamily,

              // Color Scheme for Dark Mode
              colorScheme: const ColorScheme.dark(
                primary: Color(0xffFF1CC0), // Pink accent
                secondary: Colors.white,
                surface: Color(0xff171217),
                background: Colors.black,
                onPrimary: Colors.white,
                onSecondary: Colors.black,
                onSurface: Colors.white,
                onBackground: Colors.white,
              ),

              // Scaffold
              scaffoldBackgroundColor: Colors.black,

              // AppBar
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),

              // Card
              cardTheme: CardTheme(
                color: const Color(0xff171217),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Input Fields
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xff0f0616),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xffFF1CC0),
                    width: 1,
                  ),
                ),
                hintStyle: const TextStyle(
                  color: Color(0xffb8b7bd),
                ),
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
              ),

              // Text Theme
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                displayMedium: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                displaySmall: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                headlineLarge: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                headlineMedium: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                headlineSmall: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                titleLarge: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                titleMedium: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                titleSmall: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                bodyLarge: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                bodyMedium: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                bodySmall: TextStyle(
                  color: Color(0xffB09CBA),
                  fontFamily: AppFont.fontFamily,
                ),
                labelLarge: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                labelMedium: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFont.fontFamily,
                ),
                labelSmall: TextStyle(
                  color: Color(0xffB09CBA),
                  fontFamily: AppFont.fontFamily,
                ),
              ),

              // Icon Theme
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),

              // Divider
              dividerTheme: const DividerThemeData(
                color: Color(0xff333333),
                thickness: 1,
              ),

              // Bottom Navigation Bar
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.black,
                selectedItemColor: Color(0xffFF1CC0),
                unselectedItemColor: Color(0xffB09CBA),
              ),
            ),

            // Light Theme Configuration
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              fontFamily: AppFont.fontFamily,

              // Color Scheme for Light Mode
              colorScheme: const ColorScheme.light(
                primary: Color(0xffFF1CC0), // Pink accent
                secondary: Colors.black,
                surface: Colors.white,
                background: Color(0xFFF5F5F5),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.black,
                onBackground: Colors.black,
              ),

              // Scaffold
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),

              // AppBar
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF5F5F5),
                foregroundColor: Colors.black,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
              ),

              // Card
              cardTheme: CardTheme(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              // Input Fields
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xffFF1CC0),
                    width: 1,
                  ),
                ),
                hintStyle: const TextStyle(
                  color: Color(0xff999999),
                ),
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
              ),

              // Text Theme
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                displayMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                displaySmall: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                headlineLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                headlineMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                headlineSmall: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                titleLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                titleMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                titleSmall: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                bodyLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                bodyMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                bodySmall: TextStyle(
                  color: Color(0xff666666),
                  fontFamily: AppFont.fontFamily,
                ),
                labelLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                labelMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: AppFont.fontFamily,
                ),
                labelSmall: TextStyle(
                  color: Color(0xff666666),
                  fontFamily: AppFont.fontFamily,
                ),
              ),

              // Icon Theme
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),

              // Divider
              dividerTheme: const DividerThemeData(
                color: Color(0xFFE0E0E0),
                thickness: 1,
              ),

              // Bottom Navigation Bar
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xffFF1CC0),
                unselectedItemColor: Color(0xff666666),
              ),
            ),

            // Home Screen
            home: Splash(),
          );
        },
      ),
    );
  }
}
