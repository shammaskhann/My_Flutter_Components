import 'package:flutter/material.dart';

/// ThemeSwitcher provides a small, reusable component that manages
/// the app's theme mode using plain `setState` and exposes a
/// builder so any UI can access `isDark` and `toggle`.
class ThemeSwitcher extends StatefulWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final Widget Function(BuildContext context, bool isDark, VoidCallback toggle)
  builder;

  const ThemeSwitcher({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
    required this.builder,
  });

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  bool _isDark = false;

  void _toggle() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: widget.lightTheme,
      darkTheme: widget.darkTheme,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => widget.builder(context, _isDark, _toggle),
      ),
    );
  }
}
