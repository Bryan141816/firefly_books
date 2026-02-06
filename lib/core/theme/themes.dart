import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        primary: Color(0xFF84a8f0),
        onPrimary: Colors.black,
        secondary: Color(0xFFE0E4EB),
        onSecondary: Colors.black,
        error: Colors.red,
        onError: Colors.white,
        surface: Color(0xFFF0F1F5),
        onSurface: Colors.black,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        primary: Color(0xFF84a8f0),
        onPrimary: Colors.black,
        secondary: Color(0xff1b1d1f),
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: Color(0xFF21262b),
        onSurface: Colors.white,
        brightness: Brightness.dark,
      ),
    );
  }
}
