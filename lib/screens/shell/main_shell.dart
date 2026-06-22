import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../themes/app_palette.dart';

/// CarSpy bottom-nav shell. Two live tabs (Home, Reports) + two disabled
/// placeholders (Attendance, Work Assigned) for visual fidelity with the old
/// app. Profile is reached from the home top-app-bar, not the nav bar.
class MainShell extends StatelessWidget {
  const MainShell(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: navigationShell,
      bottomNavigationBar: _CarSpyBottomNavBar(
        selectedIndex: navigationShell.currentIndex,
        onSelect: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label, {this.enabled = true});
  final IconData icon;
  final String label;
  final bool enabled;
}

const _items = [
  _NavItem(Icons.home_rounded, 'HOME'),
  _NavItem(Icons.description_outlined, 'REPORTS'),
  _NavItem(Icons.calendar_today_outlined, 'ATTENDANCE', enabled: false),
  _NavItem(Icons.assignment_outlined, 'WORK ASSIGNED', enabled: false),
];

class _CarSpyBottomNavBar extends StatelessWidget {
  const _CarSpyBottomNavBar(
      {required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.w),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _items[i],
                    selected: selectedIndex == i,
                    onTap: _items[i].enabled ? () => onSelect(i) : null,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(
      {required this.item, required this.selected, required this.onTap});
  final _NavItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Color color = !item.enabled
        ? palette.disabledNav
        : selected
            ? palette.selectedNav
            : palette.unselectedNav;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: selected ? palette.iconPill : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22.sp, color: color),
            SizedBox(height: 4.w),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}
