import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/splash_screen.dart';
import 'package:provider/provider.dart';
import 'controller/city_preference.dart';
import 'provider/darkmode_provider.dart';
import 'provider/post_api_provider.dart';
import 'utilities/app_color.dart';
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
                ChangeNotifierProvider(create: (_) => CityPreferenceController()),

      ],
      child: MaterialApp(
        title: "Hii",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: AppFont.fontFamily,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColor.themeColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ),

        // themeMode: themeProvider.themeMode, //

        // routes: routes,
        home: Splash(),
      ),
    );
  }
}
