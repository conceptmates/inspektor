import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/inspection_lists_controller.dart';
import '../../../models/inspection_history_model.dart';
import '../../../themes/carspy_colors.dart';
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

  /// Status pill colour. Drafts share the amber "pending" tone, matching the
  /// old app's DRAFT badge.
  Color _statusColor() => switch (item.status.toLowerCase()) {
        'approved' => CarSpyColors.approved,
        'pending' => CarSpyColors.pending,
        'rejected' => CarSpyColors.rejected,
        'draft' => CarSpyColors.pending,
        _ => CarSpyColors.onSurfaceVariant,
      };

  /// Relative date matching the old app ("Today, 3:38 PM" / "Yesterday, …").
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today, ${DateFormat('h:mm a').format(date)}';
    if (d == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    }
    return DateFormat('MMM d, yyyy, h:mm a').format(date);
  }

  /// A labelled detail row; hidden when the server didn't populate the value
  /// (e.g. my-history omits variant/year) rather than rendering a bare "N/A".
  Widget _infoRow(String label, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: EdgeInsets.only(bottom: 2.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45)),
          ),
          Expanded(
            child: Text(value.toString(),
                style: TextStyle(fontSize: 12.5.sp, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  /// Opens the server-rendered report in the browser — brief loading dialog,
  /// then external launch; an error dialog on failure (old-app flow).
  Future<void> _launchReport(BuildContext context, String url) async {
    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final ok =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (navigator.canPop()) navigator.pop();
      if (!ok) throw Exception('Could not open the report.');
    } catch (_) {
      if (navigator.canPop()) navigator.pop();
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content:
              const Text("We couldn't open this report. Please try again."),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = item.vehicleInfo;
    final reg = v['registration_number']?.toString() ?? 'N/A';
    final reportUrl = item.links?['view'];
    final statusColor = _statusColor();
    final canView = reportUrl != null && reportUrl.isNotEmpty;
    final canResume =
        onResume != null && (forceResume || item.status == 'draft');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(13.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reg: $reg',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    item.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.4),
                  ),
                ),
              ],
            ),
            SizedBox(height: 7.w),
            _infoRow('Make & Model', v['make_model']),
            _infoRow('Variant', v['variant']),
            _infoRow('Year', v['manufacturing_year']),
            _infoRow('Date', _formatDate(item.date)),
            if (canView || canResume)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (canView)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(6.w),
                      onPressed: () => _launchReport(context, reportUrl),
                      icon: const Icon(Icons.visibility_outlined,
                          color: CarSpyColors.primary),
                    ),
                  if (canResume)
                    TextButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Resume'),
                      style: TextButton.styleFrom(
                          foregroundColor: CarSpyColors.pending),
                      onPressed: () => onResume!(item),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
