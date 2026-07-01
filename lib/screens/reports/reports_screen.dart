import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../controllers/inspection_lists_controller.dart';
import '../../controllers/offline_inspection_controller.dart';
import '../inspection/widgets/inspection_list.dart';
import '../inspection/widgets/pending_upload_card.dart';

/// My Reports: a completed-reports tab and a Pending tab (server drafts to
/// resume + locally-queued inspections awaiting upload). Mirrors the old app's
/// History / Pending split.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
          bottom: const TabBar(
            tabs: [Tab(text: 'Reports'), Tab(text: 'Pending')],
          ),
        ),
        body: const TabBarView(
          children: [_ReportsTab(), _PendingTab()],
        ),
      ),
    );
  }
}

/// Completed reports only — drafts live in the Pending tab (kept exclusive, as
/// the old app did) so the two never duplicate.
class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportsControllerProvider);
    final notifier = ref.read(reportsControllerProvider.notifier);
    final nonDraft = state.whenData((d) =>
        d.copyWith(items: d.items.where((i) => i.status != 'draft').toList()));
    return InspectionList(
      state: nonDraft,
      onRefresh: notifier.refresh,
      onLoadMore: notifier.loadMore,
      emptyMessage: 'You have no reports yet.',
    );
  }
}

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(offlineInspectionControllerProvider);
    final offlineNotifier = ref.read(offlineInspectionControllerProvider.notifier);
    final drafts = ref.watch(draftsControllerProvider);
    final draftsNotifier = ref.read(draftsControllerProvider.notifier);

    final children = <Widget>[];

    // 1) Local queue — inspections submitted offline, awaiting upload.
    if (offline.items.isNotEmpty) {
      children.add(_header(context, 'Awaiting upload'));
      for (final insp in offline.items) {
        children.add(Padding(
          padding: EdgeInsets.only(bottom: 12.w),
          child: PendingUploadCard(
            inspection: insp,
            busy: offline.submitting[insp.id] ?? false,
            onRetry: () => offlineNotifier.retry(insp),
            onDelete: () async {
              if (await confirmDeletePending(context)) {
                await offlineNotifier.delete(insp.id);
              }
            },
          ),
        ));
      }
      children.add(SizedBox(height: 8.w));
    }

    // 2) Server drafts — resume to continue (merges saved answers + media).
    children.add(_header(context, 'Drafts'));
    children.addAll(switch (drafts) {
      AsyncData(:final value) => value.items.isEmpty
          ? [_hint(context, 'No drafts to resume.')]
          : value.items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 12.w),
                child: InspectionHistoryCard(
                  item,
                  forceResume: true,
                  onResume: (it) => context.pushNamed(
                    RouteNames.inspection,
                    queryParameters: {'resumeId': it.id},
                  ),
                ),
              )),
      AsyncError(:final error) => [_hint(context, '$error')],
      _ => [
          Padding(
            padding: EdgeInsets.all(24.w),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ],
    });

    final isEmpty =
        offline.items.isEmpty && drafts.value?.items.isEmpty == true;

    return RefreshIndicator(
      onRefresh: () async {
        offlineNotifier.reload();
        await draftsNotifier.refresh();
      },
      child: isEmpty
          ? ListView(children: [
              SizedBox(height: 200.w),
              const Center(child: Text('Nothing pending.')),
            ])
          : ListView(padding: EdgeInsets.all(16.w), children: children),
    );
  }

  Widget _header(BuildContext context, String text) => Padding(
        padding: EdgeInsets.only(bottom: 8.w, top: 4.w),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      );

  Widget _hint(BuildContext context, String text) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24.w),
        child: Center(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center)),
      );
}
