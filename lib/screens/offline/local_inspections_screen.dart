import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controllers/offline_inspection_controller.dart';
import '../inspection/widgets/pending_upload_card.dart';

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
                return PendingUploadCard(
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
    if (await confirmDeletePending(context)) await notifier.delete(id);
  }
}
