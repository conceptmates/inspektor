import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/inspection_lists_controller.dart';
import '../../../models/inspection_history_model.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';

/// Dumb paginated list of inspections (pull-refresh + infinite scroll + status
/// chips + open-report). Reused by Reports and History.
class InspectionList extends StatelessWidget {
  const InspectionList({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onLoadMore,
    this.emptyMessage = 'No inspections yet.',
    this.onResume,
  });

  final AsyncValue<PaginatedInspections> state;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final String emptyMessage;

  /// When provided, draft rows show a "Resume" action (server-side resume).
  final void Function(InspectionHistory item)? onResume;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AsyncData(:final value) => _list(context, value),
      AsyncError(:final error) =>
        ErrorDisplayWidget(message: '$error', onRetry: onRefresh),
      _ => const LoadingWidget(),
    };
  }

  Widget _list(BuildContext context, PaginatedInspections data) {
    if (data.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: 200.w),
            Center(child: Text(emptyMessage)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (n) {
          if (n.metrics.extentAfter < 200 && data.pagination.hasMore) {
            onLoadMore();
          }
          return false;
        },
        child: ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: data.items.length + (data.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: 12.w),
          itemBuilder: (context, i) {
            if (i >= data.items.length) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return InspectionHistoryCard(data.items[i], onResume: onResume);
          },
        ),
      ),
    );
  }
}

/// One inspection row (status chip + report link, or Resume on draft rows).
/// Public so the Reports "Pending" tab can render server drafts identically.
class InspectionHistoryCard extends StatelessWidget {
  const InspectionHistoryCard(this.item,
      {super.key, this.onResume, this.forceResume = false});
  final InspectionHistory item;
  final void Function(InspectionHistory item)? onResume;

  /// Show Resume regardless of [item.status] — used by the Pending tab, whose
  /// rows are fetched via `?status=draft` so are known to be resumable even if
  /// the API labels them differently.
  final bool forceResume;

  Color _statusColor(BuildContext context) => switch (item.status) {
        'approved' => Colors.green,
        'pending' => Colors.orange,
        'rejected' => Colors.red,
        _ => Theme.of(context).colorScheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = item.vehicleInfo;
    final reg = v['registration_number']?.toString() ?? 'Inspection';
    final makeModel = v['make_model']?.toString() ?? '';
    final reportUrl = item.links?['view'];
    final canResume = onResume != null && (forceResume || item.status == 'draft');

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(reg,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(item.status,
                      style: TextStyle(
                          color: _statusColor(context), fontSize: 12.sp)),
                ),
              ],
            ),
            if (makeModel.isNotEmpty) ...[
              SizedBox(height: 4.w),
              Text(makeModel, style: theme.textTheme.bodyMedium),
            ],
            SizedBox(height: 8.w),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 14.sp, color: theme.colorScheme.onSurfaceVariant),
                SizedBox(width: 4.w),
                Text(item.inspectorName, style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(DateFormat('dd MMM yyyy').format(item.date),
                    style: theme.textTheme.bodySmall),
              ],
            ),
            if (canResume) ...[
              SizedBox(height: 8.w),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: const Text('Resume'),
                  onPressed: () => onResume!(item),
                ),
              ),
            ] else if (reportUrl != null) ...[
              SizedBox(height: 8.w),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('View report'),
                  onPressed: () => launchUrl(Uri.parse(reportUrl),
                      mode: LaunchMode.externalApplication),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
