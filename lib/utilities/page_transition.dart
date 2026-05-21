import 'package:flutter/material.dart';

/// Minimal local replacement for the external page_transition package.
enum PageTransitionType {
  fade,
  rightToLeft,
  rightToLeftWithFade,
  bottomToTop,
  topToBottom,
}

class PageTransition<T> extends PageRouteBuilder<T> {
  PageTransition({
    required this.type,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    RouteSettings? settings,
  }) : super(
         settings: settings,
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, routeChild) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeInOut,
           );

           switch (type) {
             case PageTransitionType.fade:
               return FadeTransition(opacity: curvedAnimation, child: routeChild);
             case PageTransitionType.rightToLeft:
               return _buildSlideTransition(
                 routeChild,
                 curvedAnimation,
                 const Offset(1, 0),
               );
             case PageTransitionType.rightToLeftWithFade:
               return FadeTransition(
                 opacity: curvedAnimation,
                 child: _buildSlideTransition(
                   routeChild,
                   curvedAnimation,
                   const Offset(1, 0),
                 ),
               );
             case PageTransitionType.bottomToTop:
               return _buildSlideTransition(
                 routeChild,
                 curvedAnimation,
                 const Offset(0, 1),
               );
             case PageTransitionType.topToBottom:
               return _buildSlideTransition(
                 routeChild,
                 curvedAnimation,
                 const Offset(0, -1),
               );
           }
         },
       );

  final PageTransitionType type;
  final Widget child;
  final Duration duration;

  static Widget _buildSlideTransition(
    Widget child,
    Animation<double> animation,
    Offset begin,
  ) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(animation),
      child: child,
    );
  }
}
