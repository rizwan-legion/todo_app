// theme_config.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData blackTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark, // ✅ Force dark mode
    colorScheme: ColorScheme.dark(
      primary: Colors.purpleAccent,
      background: const Color(0xFF000000), // Pure black
      surface: const Color(0xFF1C1C1C),   // Light black for cards/containers
      onBackground: Colors.white,
      onSurface: Colors.white,
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF000000), // Always black
  );
}
