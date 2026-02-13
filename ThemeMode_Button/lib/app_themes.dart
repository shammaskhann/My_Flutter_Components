import 'package:flutter/material.dart';

const Color kprimaryColor = Color(0xFF6200EE);
const Color kWhiteColor = Colors.white;
const TextStyle appbarStyle = TextStyle(
  color: kWhiteColor,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);

final ThemeData lightThemeData = ThemeData(
  brightness: Brightness.light,
  primaryColor: kprimaryColor,
  scaffoldBackgroundColor: kWhiteColor,
  appBarTheme: AppBarTheme(
    backgroundColor: kprimaryColor,
    titleTextStyle: appbarStyle,
    iconTheme: const IconThemeData(color: kWhiteColor),
    elevation: 0,
  ),
  // ... rest of your light theme configuration
);

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kprimaryColor,
  scaffoldBackgroundColor: const Color.fromARGB(255, 28, 27, 27),
  // ... rest of your dark theme configuration
);
