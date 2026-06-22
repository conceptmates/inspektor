import 'package:flutter/material.dart';

/// Light palette for the user-facing CarSpy screens (home, reports, nav).
/// Matches the legacy CarSpy UI exactly. The inspection capture flow uses its
/// own dark tokens (see inspection screen).
class CarSpyColors {
  const CarSpyColors._();

  static const Color primary = Color(0xFF0052CC);
  static const Color onSurface = Color(0xFF172B4D);
  static const Color surface = Color(0xFFF4F7FA);
  static const Color onSurfaceVariant = Color(0xFF44546F);
  static const Color outlineVariant = Color(0xFFD1D5DB);

  // Top bar / accents
  static const Color logo = Color(0xFF1E40AF);
  static const Color iconPill = Color(0xFFEFF6FF);
  static const Color selectedTab = Color(0xFF1D4ED8);

  // Chart status
  static const Color approved = Color(0xFF22C55E);
  static const Color pending = Color(0xFFF59E0B);
  static const Color rejected = Color(0xFFEF4444);
  static const Color indigo = Color(0xFF6366F1);
}
