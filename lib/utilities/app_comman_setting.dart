import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_font.dart';

class SettingRow extends StatelessWidget {
  final String title;
  final String leadingIcon;
  // final String rightLeadingIcon;
  final Function onPress;

  const SettingRow({
    super.key,
    required this.title,
    required this.leadingIcon,
    // required this.rightLeadingIcon,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPress(),
      child: Container(
        width: MediaQuery.of(context).size.width * 90 / 100,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            // color: Color.fromARGB(255, 49, 51, 56),
            color: AppColor.profilesettignrowColor(context)),
            
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 7 / 100,
                  height: MediaQuery.of(context).size.width * 7 / 100,
                  alignment: Alignment.center,
                  child: Image.asset(
                    leadingIcon,
                    fit: BoxFit.cover,
                    color: AppColor.secondryColor(context),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 3 / 100,
                ),
                Text(
                  title,
                  style:  TextStyle(
                    color: AppColor.secondryColor(context),
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
