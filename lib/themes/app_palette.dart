import 'package:flutter/material.dart';

import 'carspy_colors.dart';

/// Per-app accent colors that don't map to a standard [ColorScheme] role
/// (inspection status colors, brand accents, nav states). Registered on the
/// theme; widgets read via `Theme.of(context).extension<AppPalette>()!` instead
/// of hardcoding colors (architecture.md).
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.indigo,
    required this.logo,
    required this.iconPill,
    required this.selectedNav,
    required this.disabledNav,
    required this.unselectedNav,
  });

  final Color approved;
  final Color pending;
  final Color rejected;
  final Color indigo;
  final Color logo;
  final Color iconPill;
  final Color selectedNav;
  final Color disabledNav;
  final Color unselectedNav;

  static const light = AppPalette(
    approved: CarSpyColors.approved,
    pending: CarSpyColors.pending,
    rejected: CarSpyColors.rejected,
    indigo: CarSpyColors.indigo,
    logo: CarSpyColors.logo,
    iconPill: CarSpyColors.iconPill,
    selectedNav: CarSpyColors.selectedTab,
    disabledNav: Color(0xFFE0E0E0),
    unselectedNav: Color(0xFFBDBDBD),
  );

  @override
  AppPalette copyWith({
    Color? approved,
    Color? pending,
    Color? rejected,
    Color? indigo,
    Color? logo,
    Color? iconPill,
    Color? selectedNav,
    Color? disabledNav,
    Color? unselectedNav,
  }) =>
      AppPalette(
        approved: approved ?? this.approved,
        pending: pending ?? this.pending,
        rejected: rejected ?? this.rejected,
        indigo: indigo ?? this.indigo,
        logo: logo ?? this.logo,
        iconPill: iconPill ?? this.iconPill,
        selectedNav: selectedNav ?? this.selectedNav,
        disabledNav: disabledNav ?? this.disabledNav,
        unselectedNav: unselectedNav ?? this.unselectedNav,
      );

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      approved: Color.lerp(approved, other.approved, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      rejected: Color.lerp(rejected, other.rejected, t)!,
      indigo: Color.lerp(indigo, other.indigo, t)!,
      logo: Color.lerp(logo, other.logo, t)!,
      iconPill: Color.lerp(iconPill, other.iconPill, t)!,
      selectedNav: Color.lerp(selectedNav, other.selectedNav, t)!,
      disabledNav: Color.lerp(disabledNav, other.disabledNav, t)!,
      unselectedNav: Color.lerp(unselectedNav, other.unselectedNav, t)!,
    );
  }
}

/// Sugar: `context.palette.approved`.
extension AppPaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
