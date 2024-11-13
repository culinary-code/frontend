import 'package:flutter/material.dart';
import 'package:frontend/theme/theme.dart';

class ThemeLoader {
  // Load the appropriate theme directly from the MaterialTheme class
  static ThemeData loadTheme(Brightness brightness) {
    // You can customize this logic based on how you want to load themes
    if (brightness == Brightness.light) {
      return MaterialTheme(TextTheme()).light(); // Use your light theme
    } else {
      return MaterialTheme(TextTheme()).dark(); // Use your dark theme
    }
  }
}
