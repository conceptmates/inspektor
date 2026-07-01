import 'package:flutter/material.dart';

/// Light palette for the attendance + leaves screens (faithful to the legacy
/// attendance UI). Centralized — referenced by those screens instead of
/// scattered hex (architecture.md).
class AttendanceColors {
  const AttendanceColors._();

  static const Color primary = Color(0xFF0F172A);
  static const Color accent = Color(0xFF3B82F6);
  static const Color accentLight = Color(0xFFEFF6FF);
  static const Color surface = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color green = Color(0xFF10B981);
  static const Color greenLight = Color(0xFFECFDF5);
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFFFBEB);

  /// Avatar colors (hashed by name).
  static const List<Color> avatars = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];
}
