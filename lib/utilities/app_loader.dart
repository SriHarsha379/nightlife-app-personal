import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_color.dart';

class ProgressHUD extends StatelessWidget {
  final Widget child;
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  //  final Animation<Color> valueColor;

  ProgressHUD({
    Key? key,
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.3,
    this.color = Colors.grey,
    //  this.valueColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
       SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.secondryColor(context),
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: AppColor.transparentColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    // ignore: deprecated_member_use
    List<Widget> widgetList = <Widget>[];
    widgetList.add(child);
    if (inAsyncCall) {
      final modal = new Stack(
        children: [
          new Opacity(
            opacity: opacity,
            child: ModalBarrier(dismissible: false, color: color),
          ),
          new Center(
              child: new CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
            AppColor.themeColor,
          ))),
        ],
      );
      widgetList.add(modal);
    }
    return Stack(
      children: widgetList,
    );
  }
}
