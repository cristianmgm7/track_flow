import 'package:flutter/material.dart';

class AppShadows {
  // Shadow colors
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorDark = Color(0x33000000);
  static const Color shadowColorLight = Color(0x0D000000);
  
  // Elevation levels
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation3 = 3;
  static const double elevation4 = 4;
  static const double elevation6 = 6;
  static const double elevation8 = 8;
  static const double elevation12 = 12;
  static const double elevation16 = 16;
  static const double elevation24 = 24;
  
  // Predefined shadow styles
  static const List<BoxShadow> none = [];
  
  static const List<BoxShadow> small = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> large = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> extraLarge = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  // Card shadows
  static const List<BoxShadow> card = [
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // Button shadows
  static const List<BoxShadow> button = [
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> buttonPressed = [
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  // Modal shadows
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: shadowColorDark,
      offset: Offset(0, 8),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];
  
  // Bottom sheet shadows
  static const List<BoxShadow> bottomSheet = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, -2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // App bar shadows
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: shadowColorLight,
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];
  
  // Floating action button shadows
  static const List<BoxShadow> fab = [
    BoxShadow(
      color: shadowColor,
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
  
  // Custom shadow builder
  static List<BoxShadow> custom({
    required double blurRadius,
    required Offset offset,
    Color? color,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: color ?? shadowColor,
        offset: offset,
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      ),
    ];
  }
}