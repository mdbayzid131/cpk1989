import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;
  
  // Common colors
  static const Color primaryColor = Color(0xff9945FF);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // Premium Gold Gradient
  static const List<Color> goldGradientColors = [
    Color(0xFFAF7413),
    Color(0xFFC98C28),
    Color(0xFFE2B744),
    Color(0xFFFFED81),
    Color(0xFFE1C24E),
    Color(0xFFA06008),
  ];

  static const List<double> goldGradientStops = [
    0.0477,
    0.1933,
    0.3893,
    0.5054,
    0.6210,
    0.9074,
  ];

  static LinearGradient get goldGradient => const LinearGradient(
        colors: goldGradientColors,
        stops: goldGradientStops,
        begin: Alignment(-1.0, -0.165), // Simulates 99.37deg angle
        end: Alignment(1.0, 0.165),
      );
}
