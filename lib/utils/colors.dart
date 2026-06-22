import 'package:flutter/material.dart';

/// Raw colors — use ONLY when building ThemeData (app_theme.dart).
/// In widgets use Theme.of(context).colorScheme. Dark-only app.
class AppColors {
  const AppColors._();

  // Dark surfaces (from old AppThemes.darkTheme)
  static const Color scaffoldDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color inputFillDark = Color(0xFF2C2C2C);

  // Accents
  static final Color primary = Colors.blueAccent.shade200;
  static final Color errorDark = Colors.red.shade400;
  static final Color borderDark = Colors.grey.shade700;
  static final Color hintDark = Colors.grey.shade500;
}
