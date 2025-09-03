
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData blackTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Colors.purpleAccent,
      background: const Color(0xFF000000),
      surface: const Color(0xFF1C1C1C),
      onBackground: Colors.white,
      onSurface: Colors.white,
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF000000),
  );
}
