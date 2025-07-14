import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
  
  // Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve spring = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  
  // Scale values for micro-interactions
  static const double scaleDown = 0.95;
  static const double scaleUp = 1.05;
  static const double scaleNormal = 1.0;
  
  // Fade values
  static const double fadeIn = 1.0;
  static const double fadeOut = 0.0;
  static const double fadePartial = 0.5;
  
  // Slide offsets
  static const Offset slideUp = Offset(0, 1);
  static const Offset slideDown = Offset(0, -1);
  static const Offset slideLeft = Offset(-1, 0);
  static const Offset slideRight = Offset(1, 0);
  static const Offset slideNone = Offset.zero;
  
  // Common transition builders
  static Widget fadeTransition(Widget child, {Duration? duration}) {
    return AnimatedSwitcher(
      duration: duration ?? normal,
      child: child,
    );
  }
  
  static Widget scaleTransition(Widget child, {Duration? duration}) {
    return AnimatedScale(
      duration: duration ?? fast,
      scale: scaleNormal,
      child: child,
    );
  }
  
  static Widget slideTransition(Widget child, {required Offset offset, Duration? duration}) {
    return AnimatedSlide(
      duration: duration ?? normal,
      offset: offset,
      child: child,
    );
  }
  
  // Page transitions
  static PageRouteBuilder<T> createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  // Modal transitions
  static PageRouteBuilder<T> createModalRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}