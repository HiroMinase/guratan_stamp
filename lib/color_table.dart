import 'package:flutter/material.dart';

// 色管理
class ColorTable {
  static const int _primaryWhiteValue = 0xFFFAFAFA;
  static const MaterialColor primaryWhiteColor = MaterialColor(
    _primaryWhiteValue,
    <int, Color>{
      50: Color(0xFFf2f3f9),
      100: Color(0xFFf2f4f9),
      200: Color(0xFFf2f5f9),
      300: Color(0xFFf2f6f9),
      400: Color(0xFFf2f7f9),
      500: Color(_primaryWhiteValue),
      600: Color(0xFFd7eaed),
      700: Color(0xFFbcdbe0),
      800: Color(0xFFa1cdd4),
      900: Color(0xFF87bec7),
    },
  );

  static const int _primaryBlackValue = 0xFF29383F;
  static const MaterialColor primaryBlackColor = MaterialColor(
    _primaryBlackValue,
    <int, Color>{
      50: Color(0xFF0285d3),
      100: Color(0xFF0279c0),
      200: Color(0xFF026dac),
      300: Color(0xFF016199),
      400: Color(0xFF015485),
      500: Color(_primaryBlackValue),
      600: Color(0xFF013c5f),
      700: Color(0xFF012f4b),
      800: Color(0xFF002338),
      900: Color(0xFF001724),
    },
  );

  static const int _primaryBlueValue = 0xFFCEE7F4;
  static const MaterialColor primaryBlueColor = MaterialColor(
    _primaryBlueValue,
    <int, Color>{
      50: Color(0xFF0285d3),
      100: Color(0xFF0279c0),
      200: Color(0xFF026dac),
      300: Color(0xFF016199),
      400: Color(0xFF015485),
      500: Color(_primaryBlueValue),
      600: Color(0xFF013c5f),
      700: Color(0xFF012f4b),
      800: Color(0xFF002338),
      900: Color(0xFF001724),
    },
  );
}