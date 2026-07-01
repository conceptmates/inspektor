import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_controller.dart';
import 'admin_attendance_screen.dart';
import 'inspector_leaves_screen.dart';

/// Entry point for the attendance tab. Admins get the management view wired to
/// the admin leave/attendance API; inspectors get their leave history with an
/// "Attendance — coming soon" banner (the check-in/out tracker has no API yet).
class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin =
        ref.watch(authControllerProvider.select((s) => s.user?.isAdmin ?? false));
    if (isAdmin) return const AdminAttendanceScreen();
    return const InspectorLeavesScreen(showComingSoon: true);
  }
}
