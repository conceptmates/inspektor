import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../controllers/offline_inspection_controller.dart';
import '../../models/local_inspection.dart';

class LocalInspectionsScreen extends ConsumerWidget {
  const LocalInspectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(offlineInspectionControllerProvider);
    final notifier = ref.read(offlineInspectionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Uploads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync now',
            onPressed: notifier.syncAll,
          ),
        ],
      ),
      body: state.items.isEmpty
          ? const Center(child: Text('No pending inspections.'))
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => SizedBox(height: 12.w),
              itemBuilder: (context, i) {
                final insp = state.items[i];
                final busy = state.submitting[insp.id] ?? false;
                return _PendingCard(
                  inspection: insp,
                  busy: busy,
                  onRetry: () => notifier.retry(insp),
                  onDelete: () => _confirmDelete(context, notifier, insp.id),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context,
      OfflineInspectionController notifier, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete pending inspection?'),
        content: const Text('This unsynced inspection will be removed.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok ?? false) await notifier.delete(id);
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.inspection,
    required this.busy,
    required this.onRetry,
    required this.onDelete,
  });

  final LocalInspection inspection;
  final bool busy;
  final VoidCallback onRetry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reg = inspection.vehicleDetails?['registration_number']?.toString() ??
        inspection.vehicleDetails?['model']?.toString() ??
        'Inspection ${inspection.id.substring(0, 6)}';
    return Card(
      child: Column(
        children: [
          if (busy) const LinearProgressIndicator(),
          ListTile(
            title: Text(reg),
            subtitle: Text(
              'Saved ${DateFormat('dd MMM, HH:mm').format(inspection.createdAt)}'
              '${inspection.hasPendingMedia ? ' • ${inspection.pendingMedia.length} media pending' : ''}',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.upload),
                  tooltip: 'Retry upload',
                  onPressed: busy ? null : onRetry,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: theme.colorScheme.error),
                  onPressed: busy ? null : onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
