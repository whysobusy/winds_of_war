import 'package:flutter/material.dart';
import 'package:winds_of_war/menu.dart';
import 'package:winds_of_war/winds_of_war.dart';

extension BuildContextExtensions on BuildContext {
  void backTo() {
    Navigator.of(this).pop();
  }

  Future goTo(Widget page) {
    return Navigator.push(
      this,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Container(
            color: Colors.black,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future exitToMenu(Widget page) {
    return Navigator.pushAndRemoveUntil(
      this,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return Container(
            color: Colors.black,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
      (Route<dynamic> route) => false,
    );
  }
}

