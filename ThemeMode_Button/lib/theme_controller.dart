import 'package:flutter/material.dart';

/// A minimal theme controller that uses plain Dart state.
/// This is intentionally simple: toggle it from a StatefulWidget
/// using `setState` rather than a reactive/GetX controller.
class ThemeController {
  bool isDarkMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  ThemeController({
    this.isDarkMode = false,
    required this.lightTheme,
    required this.darkTheme,
  });

  void toggleTheme() => isDarkMode = !isDarkMode;

  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;
}
