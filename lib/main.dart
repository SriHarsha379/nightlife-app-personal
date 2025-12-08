import 'package:flutter/material.dart';
// import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/view/authentication/splash_screen.dart';
import 'package:provider/provider.dart';

import 'provider/darkmode_provider.dart';
import 'utilities/app_color.dart';
import 'utilities/app_font.dart';
import 'utilities/app_language.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
        return MaterialApp(
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

          themeMode: themeProvider.themeMode, // 👈 Controlled Globally

          // routes: routes,
          home: Splash(),
        );
      }),
    );
  }
}
