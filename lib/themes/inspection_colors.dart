import 'package:flutter/material.dart';

/// Palette for the intrinsically-dark inspection capture flow (vehicle form,
/// inspection screen, camera HUD, success). Centralized here rather than
/// scattered — the dark capture flow is the documented dark-overlay exception
/// to the "use colorScheme in widgets" rule (architecture.md).
class InspectionColors {
  const InspectionColors._();

  // Surfaces
  static const Color scaffold = Color(0xFF121212); // vehicle form / dark bg
  static const Color surface = Color(0xFF1E1E1E); // cards / app bar
  static const Color fill = Color(0xFF2C2C2C); // field fill / dropdown menu
  static const Color black = Colors.black; // inspection scaffold + nav bar
  static const Color panel = Color(0xFF0D0D0D); // camera bottom control panel
  static const Color captureBg = Color(0xFF111111); // capture fallback/error
  static const Color sheetBg = Color(0xFF1C1C1E); // flag-issues sheet
  static const Color fieldCard = Colors.white; // non-media field card

  // Accents
  static const Color accent = Color(0xFF536DFE); // blueAccent.shade200
  static const Color navBlue = Color(0xFF448AFF); // progress + Next button
  static const Color shutterBlue = Color(0xFF4D9EFF); // accept / file / shutter
  static const Color refRed = Color(0xFFFF6B6B); // reference media border
  static const Color audioPink = Color(0xFFEC4899);
  static const Color flashAmber = Color(0xFFFFC107);
  static const Color recordRed = Colors.red;
  static const Color permissionBlue = Color(0xFF3B82F6);

  // Status
  static const Color approved = Color(0xFF22C55E);
  static const Color pending = Color(0xFFF59E0B);
  static const Color rejected = Color(0xFFEF4444);

  // Field-type badge colors (field card header)
  static const Color fieldImage = Color(0xFF4D9EFF);
  static const Color fieldVideo = Color(0xFFA855F7);
  static const Color fieldDropdown = Color(0xFFF97316);
  static const Color fieldFile = Color(0xFF22C55E);
  static const Color fieldAudio = Color(0xFFEC4899);

  // Gradients
  static const List<Color> headerGradient = [Color(0xFF1A73E8), Color(0xFF1557B0)];
  static const List<Color> startGradient = [Color(0xFF4CAF50), Color(0xFF45A049)];
  static const List<Color> successGradient = [Color(0xFF11998E), Color(0xFF38EF7D)];
  static const List<Color> homeButtonGradient = [Color(0xFF667EEA), Color(0xFF764BA2)];
}
