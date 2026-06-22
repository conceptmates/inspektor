import 'package:flutter/material.dart';

import '../utils/colors.dart';

/// Dark-only theme (faithful to old AppThemes.darkTheme). Material 3.
/// Widgets must use Theme.of(context).colorScheme — no hardcoded colors.
class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme {
    final scheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surfaceDark,
      error: AppColors.errorDark,
    );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.scaffoldDark,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        hintStyle: TextStyle(color: AppColors.hintDark),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border(AppColors.borderDark),
        enabledBorder: border(AppColors.borderDark),
        focusedBorder: border(AppColors.primary, 2),
        errorBorder: border(AppColors.errorDark),
        focusedErrorBorder: border(AppColors.errorDark, 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
    );
  }
}
