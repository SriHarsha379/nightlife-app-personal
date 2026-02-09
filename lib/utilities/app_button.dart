import 'package:flutter/material.dart';
import 'package:night_life/utilities/app_font.dart';
import '../utilities/app_color.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Function onPress;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 80 / 100,
        height: MediaQuery.of(context).size.height * 7 / 100,
        decoration: const BoxDecoration(
          color: AppColor.buttonColor,
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontFamily: AppFont.fontFamily,
              fontSize: 16),
        ),
      ),
    );
  }
}
