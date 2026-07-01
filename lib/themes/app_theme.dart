import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'carspy_colors.dart';

/// Light theme for the user-facing CarSpy screens. The inspection capture flow
/// hardcodes its own dark palette (faithful to the legacy app — the documented
/// dark-overlay exception in architecture.md).
class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: CarSpyColors.primary,
      primary: CarSpyColors.primary,
      surface: Colors.white,
    ).copyWith(
      onSurface: CarSpyColors.onSurface,
      onSurfaceVariant: CarSpyColors.onSurfaceVariant,
      outlineVariant: CarSpyColors.outlineVariant,
      error: CarSpyColors.rejected,
      surfaceContainerLow: CarSpyColors.surface, // card bg 0xFFF4F7FA
      surfaceContainerHighest: const Color(0xFFF1F5F9), // segmented-control bg
    );

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      extensions: const [AppPalette.light],
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: CarSpyColors.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: border(CarSpyColors.outlineVariant),
        enabledBorder: border(CarSpyColors.outlineVariant),
        focusedBorder: border(CarSpyColors.primary, 2),
        errorBorder: border(CarSpyColors.rejected),
        focusedErrorBorder: border(CarSpyColors.rejected, 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CarSpyColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: CarSpyColors.primary),
      ),
    );
  }
}
