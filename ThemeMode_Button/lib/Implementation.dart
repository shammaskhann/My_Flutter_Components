import 'package:flutter/material.dart';
import 'theme_button.dart';

/// Simple stateless wrapper for the `ThemeButton` that takes
/// `isDark` and `onToggle` from a parent widget which manages state
/// with `setState`.
class ThemeButtonSimple extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const ThemeButtonSimple({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeButton(isDark: isDark, onToggle: onToggle);
  }
}
