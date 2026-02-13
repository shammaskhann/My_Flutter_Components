import 'package:flutter/material.dart';
import 'app_themes.dart';
import 'theme_switcher.dart';
import 'Implementation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(
      lightTheme: lightThemeData,
      darkTheme: darkThemeData,
      builder: (context, isDark, toggle) {
        return Scaffold(
          body: Center(
            child: ThemeButtonSimple(isDark: isDark, onToggle: toggle),
          ),
        );
      },
    );
  }
}
