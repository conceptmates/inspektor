import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/local_inspection.dart';

/// A locally-queued (offline-submitted) inspection awaiting upload: shows a
/// progress bar while syncing, media-pending count, and retry/delete actions.
/// Shared by the offline screen and the Reports "Pending" tab.
class PendingUploadCard extends StatelessWidget {
  const PendingUploadCard({
    super.key,
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
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
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

/// Shared confirm dialog before deleting an unsynced pending inspection.
Future<bool> confirmDeletePending(BuildContext context) async {
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
  return ok ?? false;
}
