import 'package:flutter/material.dart';

/// FadeRoute() - custom Navigation route for example, like MaterialPageRoute()
/// but used more smoother transition animation

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({Key key, @required this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
