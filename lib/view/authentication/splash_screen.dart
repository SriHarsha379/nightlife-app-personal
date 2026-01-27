import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/welcomescreens/welcome_screen1.dart';

import '../../utilities/app_color.dart';
import '../../utilities/app_image.dart';

class Splash extends StatefulWidget {
  static String routeName = './Splash';

  Splash({super.key});

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      Duration(seconds: 3),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  WelcomeScreen1()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
 SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.transparentColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.transparentColor,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
      backgroundColor: AppColor.transparentColor,
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  WelcomeScreen1()),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
          AppImage.newGif,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.cover,
        ),
        ),
      ),
    );
  }
}
