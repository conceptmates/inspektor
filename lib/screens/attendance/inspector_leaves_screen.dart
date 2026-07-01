import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/attendance_controllers.dart';
import '../../models/attendance_models.dart';
import '../../services/api/api_result.dart';
import '../../themes/attendance_colors.dart';
import 'leave_application_screen.dart';

/// The signed-in inspector's leave history. Reached from the attendance
/// tracker's app-bar "Leaves" button; lists requests with filter/apply/cancel.
class InspectorLeavesScreen extends ConsumerStatefulWidget {
  const InspectorLeavesScreen({super.key});

  @override
  ConsumerState<InspectorLeavesScreen> createState() =>
      _InspectorLeavesScreenState();
}

class _InspectorLeavesScreenState extends ConsumerState<InspectorLeavesScreen> {
  static const _statusFilters = ['all', 'pending', 'approved', 'rejected'];

  final _scrollController = ScrollController();
  final Set<Object> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      ref.read(inspectorLeavesControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _openApplyLeave() async {
    // The screen pops `true` on success; the controller refreshes itself after
    // a successful requestLeave, so no manual reload is needed here.
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(builder: (_) => const LeaveApplicationScreen()),
    );
  }

  Future<void> _cancel(InspectorLeave leave) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: Colors.white,
        title: const Text(
          'Cancel leave request?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
        content: Text(
          'Your pending request for '
          '${leave.leaveDate != null ? DateFormat('d MMM yyyy').format(leave.leaveDate!) : 'this date'} '
          'will be withdrawn.',
          style: const TextStyle(
            fontSize: 13,
            color: AttendanceColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep',
                style: TextStyle(color: AttendanceColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AttendanceColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final id = leave.id;
    if (id == null) return;

    setState(() => _busyIds.add(id));
    final result = await ref
        .read(inspectorLeavesControllerProvider.notifier)
        .cancelLeave(id);
    if (!mounted) return;
    setState(() => _busyIds.remove(id));

    switch (result) {
      case ApiSuccess():
        _toast('Leave request cancelled.', color: AttendanceColors.green);
      case ApiBadRequest(:final message) ||
            ApiUnauthorized(:final message) ||
            ApiForbidden(:final message) ||
            ApiNotFound(:final message) ||
            ApiClientError(:final message) ||
            ApiServerError(:final message) ||
            ApiNetworkError(:final message):
        _toast(message ?? 'Could not cancel.', color: AttendanceColors.red);
    }
  }

  void _toast(String msg, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Reveals a leave card's reason / admin note (kept off the card itself).
  void _showDetail({
    required String title,
    required String body,
    required IconData icon,
    required Color color,
    required Color bg,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AttendanceColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AttendanceColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                color: AttendanceColors.primary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inspectorLeavesControllerProvider);
    final hasItems = state.value?.items.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: AttendanceColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AttendanceColors.primary,
        title: const Text(
          'My Leaves',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _openApplyLeave,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Apply Leave'),
              style: TextButton.styleFrom(
                foregroundColor: AttendanceColors.accent,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              color: AttendanceColors.accent,
              onRefresh: () =>
                  ref.read(inspectorLeavesControllerProvider.notifier).refresh(),
              child: _buildBody(state),
            ),
          ),
        ],
      ),
      floatingActionButton: !hasItems
          ? null
          : FloatingActionButton.extended(
              onPressed: _openApplyLeave,
              backgroundColor: AttendanceColors.accent,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.event_available_rounded, size: 20),
              label: const Text('Apply Leave',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
    );
  }

  Widget _buildFilterBar() {
    final current =
        ref.watch(inspectorLeavesControllerProvider.notifier).filter;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: _statusFilters.map((s) {
          final isSel = s == current;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (s == current) return;
                ref
                    .read(inspectorLeavesControllerProvider.notifier)
                    .setFilter(s);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? AttendanceColors.accent : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isSel
                          ? AttendanceColors.accent
                          : AttendanceColors.border),
                ),
                child: Text(
                  s == 'all'
                      ? 'All'
                      : '${s[0].toUpperCase()}${s.substring(1)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSel ? Colors.white : AttendanceColors.primary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(AsyncValue<Paged<InspectorLeave>> state) {
    return state.when(
      loading: () => const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (err, _) => _buildScrollableMessage(
        icon: Icons.cloud_off_rounded,
        title: "Couldn't load leaves",
        subtitle: err.toString().replaceFirst('Exception: ', ''),
        action: _RetryButton(
          onTap: () =>
              ref.read(inspectorLeavesControllerProvider.notifier).refresh(),
        ),
      ),
      data: (paged) {
        final leaves = paged.items;
        if (leaves.isEmpty) {
          return _buildScrollableMessage(
            icon: Icons.beach_access_rounded,
            title: 'No leave requests yet',
            subtitle: 'Tap "Apply Leave" to request a day off.',
            action: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: ElevatedButton.icon(
                onPressed: _openApplyLeave,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Apply Leave'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AttendanceColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          );
        }
        final showLoader = paged.pagination.hasMore;
        return ListView.separated(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: leaves.length + (showLoader ? 1 : 0),
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            if (i >= leaves.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                ),
              );
            }
            return _buildLeaveCard(leaves[i]);
          },
        );
      },
    );
  }

  Widget _buildScrollableMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.16),
        Icon(icon, size: 56, color: const Color(0xFFCBD5E1)),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AttendanceColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        if (action != null) Center(child: action),
      ],
    );
  }

  Widget _buildLeaveCard(InspectorLeave leave) {
    final cfg = _statusConfig(leave.status);
    final reason = leave.reason ?? '';
    final adminNote = leave.adminNote ?? '';
    final busy = leave.id != null && _busyIds.contains(leave.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cfg.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(cfg.icon, size: 22, color: cfg.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.leaveDate != null
                          ? DateFormat('EEE, d MMM yyyy')
                              .format(leave.leaveDate!)
                          : 'Date unknown',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AttendanceColors.primary,
                      ),
                    ),
                    if (leave.createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Requested ${DateFormat('d MMM').format(leave.createdAt!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AttendanceColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusPill(label: cfg.label, color: cfg.color, bg: cfg.bg),
            ],
          ),
          if (reason.isNotEmpty || adminNote.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (reason.isNotEmpty)
                  _DetailChip(
                    icon: Icons.notes_rounded,
                    label: 'Reason',
                    color: AttendanceColors.accent,
                    bg: AttendanceColors.accentLight,
                    onTap: () => _showDetail(
                      title: 'Reason',
                      body: reason,
                      icon: Icons.notes_rounded,
                      color: AttendanceColors.accent,
                      bg: AttendanceColors.accentLight,
                    ),
                  ),
                if (adminNote.isNotEmpty)
                  _DetailChip(
                    icon: Icons.sticky_note_2_outlined,
                    label: 'Admin Note',
                    color: AttendanceColors.amber,
                    bg: AttendanceColors.amberLight,
                    onTap: () => _showDetail(
                      title: 'Admin Note',
                      body: adminNote,
                      icon: Icons.sticky_note_2_outlined,
                      color: AttendanceColors.amber,
                      bg: AttendanceColors.amberLight,
                    ),
                  ),
              ],
            ),
          ],
          if (leave.isPending) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: busy ? null : () => _cancel(leave),
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AttendanceColors.red),
                        ),
                      )
                    : const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancel Request'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AttendanceColors.red,
                  side: const BorderSide(color: AttendanceColors.redLight),
                  backgroundColor: AttendanceColors.redLight,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusCfg _statusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const _StatusCfg(
          label: 'Approved',
          color: AttendanceColors.green,
          bg: AttendanceColors.greenLight,
          icon: Icons.check_circle_rounded,
        );
      case 'rejected':
        return const _StatusCfg(
          label: 'Rejected',
          color: AttendanceColors.red,
          bg: AttendanceColors.redLight,
          icon: Icons.cancel_rounded,
        );
      default:
        return const _StatusCfg(
          label: 'Pending',
          color: AttendanceColors.amber,
          bg: AttendanceColors.amberLight,
          icon: Icons.hourglass_top_rounded,
        );
    }
  }
}

class _StatusCfg {
  const _StatusCfg({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 3),
            Icon(Icons.chevron_right_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Retry'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AttendanceColors.accent,
          side: const BorderSide(color: AttendanceColors.accent),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
      ),
    );
  }
}
