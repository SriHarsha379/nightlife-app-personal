import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'app_color.dart';
import 'app_font.dart';
import 'app_image.dart';

class AppHeader extends StatelessWidget {
  final String text;
  final List<Widget>? actionButtons;
  final Function()? onPress;

  const AppHeader({
    super.key,
    required this.text,
    this.onPress,
    this.actionButtons,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 14 / 100,
      decoration: BoxDecoration(
        color: AppColor.primaryColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.grayColor.withOpacity(0.4),
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: onPress ?? () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(5),
                child: Image.asset(
                  AppImage.backarrow,
                  color: AppColor.secondryColor,
                  width:MediaQuery.of(context).size.width* 5/100,
                  height: MediaQuery.of(context).size.height* 6/100,
                ),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width*0.5/100),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColor.secondryColor,
                ),
              ),
            ),
            if (actionButtons != null) ...actionButtons!,
          ],
        ),
      ),
    );
  }
}
class AppHeader1 extends StatelessWidget {
  final String text;
  final List<Widget>? actionButtons;
  final Function()? onPress;

  const AppHeader1({
    super.key,
    required this.text,
    this.onPress,
    this.actionButtons,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 100 / 100,
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onPress ?? () => Navigator.of(context).pop(),
            child: Container(
              height: MediaQuery.of(context).size.width * 14 / 100,
              width: MediaQuery.of(context).size.width * 98.8 / 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
               
                color: AppColor.secondryColor, // background color
                boxShadow: [
                  BoxShadow(
                    color: AppColor.grayColor.withOpacity(0.4), // shadow color
                    // spreadRadius: 1,
                    blurRadius: 2, // blur effect
                    offset: Offset(1, 1),
                  ),
                ],
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 3 / 100,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 5 / 100,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 5 / 100,
                      child: Image.asset(
                        AppImage.backarrow,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 1.5 / 100,
                  ),
                  Text(
                  text,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
       
        ],
      ),
    );
  }
}
