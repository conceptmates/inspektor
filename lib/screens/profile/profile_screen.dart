import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (ok ?? false) {
      // Redirect routes to /login once auth state clears.
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final initials = (user?.name ?? '?')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          SizedBox(height: 12.w),
          Center(
            child: CircleAvatar(
              radius: 44.r,
              backgroundColor: colors.primary,
              child: Text(initials.isEmpty ? '?' : initials,
                  style: TextStyle(
                      fontSize: 28.sp,
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 16.w),
          Center(
            child: Text(user?.name ?? 'Inspector',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          if (user?.email != null) ...[
            SizedBox(height: 4.w),
            Center(
              child: Text(user!.email!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colors.onSurfaceVariant)),
            ),
          ],
          if (user != null && user.roles.isNotEmpty) ...[
            SizedBox(height: 12.w),
            Center(
              child: Chip(label: Text(user.roles.join(', '))),
            ),
          ],
          SizedBox(height: 32.w),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: colors.error),
              title: Text('Log out', style: TextStyle(color: colors.error)),
              onTap: () => _confirmLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}
