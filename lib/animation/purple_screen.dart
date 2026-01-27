import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../utilities/app_color.dart';

class PurpleScreen extends StatefulWidget {
  static String routeName = './PurpleScreen';

  final Widget nextScreen;

  const PurpleScreen({super.key, required this.nextScreen});

  @override
  State<PurpleScreen> createState() => _PurpleScreenState();
}

class _PurpleScreenState extends State<PurpleScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => widget.nextScreen));
      // Navigator.pushReplacement(
      //   context,
      //   PageTransition(
      //     type: PageTransitionType.topToBottom,
      //     child: widget.nextScreen,
      //     duration: const Duration(milliseconds: 500),
      //   ),
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: AppColor.purpleScreenColor,
            // borderRadius: BorderRadius.only(
            //   topLeft: Radius.circular(50),
            //   topRight: Radius.circular(50),
            // ),
          ),
        ),
      ),
    );
  }
}
