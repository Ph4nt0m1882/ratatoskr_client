import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme (Premium)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed:
        Colors.deepPurple, // Easily modifiable for Whitelabel
    scaffoldBackgroundColor: const Color(0xFFF5F5F7), // "Apple" style
  );

  // Dark Theme (Sublimated)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: Colors.deepPurple,
    scaffoldBackgroundColor: const Color(
      0xFF0D0D12,
    ), // Deep black, not dull gray
  );
}
