import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../controllers/attendance_controllers.dart';
import '../../models/attendance_models.dart';
import '../../services/api/api_result.dart';
import '../../themes/attendance_colors.dart';

/// Admin-facing management view wired to the new Riverpod controllers:
///  • [adminLeavesControllerProvider]     — review/approve/reject leave requests
///  • [adminAttendanceControllerProvider] — browse attendance records
class AdminAttendanceScreen extends ConsumerStatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  ConsumerState<AdminAttendanceScreen> createState() =>
      _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends ConsumerState<AdminAttendanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AttendanceColors.surface,
      appBar: AppBar(
        backgroundColor: AttendanceColors.cardBg,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16.w,
        title: Text(
          'Attendance & Leaves',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Container(
            color: AttendanceColors.cardBg,
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AttendanceColors.accent,
              unselectedLabelColor: AttendanceColors.textSecondary,
              indicatorColor: AttendanceColors.accent,
              indicatorWeight: 2.5,
              labelStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
                  TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Leave Requests'),
                Tab(text: 'Attendance'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LeavesTab(),
          _AttendanceTab(),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Leaves tab ───────────────────────────────

class _LeavesTab extends ConsumerStatefulWidget {
  const _LeavesTab();

  @override
  ConsumerState<_LeavesTab> createState() => _LeavesTabState();
}

class _LeavesTabState extends ConsumerState<_LeavesTab>
    with AutomaticKeepAliveClientMixin {
  static const _statusFilters = ['all', 'pending', 'approved', 'rejected'];

  final _scrollController = ScrollController();
  final Set<Object> _busyIds = {};

  @override
  bool get wantKeepAlive => true;

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
        _scrollController.position.maxScrollExtent - 240.h) {
      ref.read(adminLeavesControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _decide(LeaveRequest leave, {required bool approve}) async {
    final note = await _AdminNoteSheet.show(
      context,
      approve: approve,
      inspectorName: leave.inspectorName,
    );
    if (note == null || !mounted) return; // cancelled

    final id = leave.id;
    if (id == null) return;

    setState(() => _busyIds.add(id));
    final notifier = ref.read(adminLeavesControllerProvider.notifier);
    final result = approve
        ? await notifier.approve(id, note)
        : await notifier.reject(id, note);
    if (!mounted) return;
    setState(() => _busyIds.remove(id));

    switch (result) {
      case ApiSuccess(:final data):
        if (approve && data.conflictingBookings.isNotEmpty) {
          await _showConflicts(data.conflictingBookings);
        } else {
          _toast(
            'Leave ${approve ? 'approved' : 'rejected'}.',
            color: approve ? AttendanceColors.green : AttendanceColors.amber,
          );
        }
      case _:
        _toast(_errorText(result), color: AttendanceColors.red);
    }
  }

  Future<void> _showConflicts(List<String> orders) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        backgroundColor: AttendanceColors.cardBg,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AttendanceColors.amberLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.warning_amber_rounded,
                  size: 20.sp, color: AttendanceColors.amber),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text('Bookings to Reassign',
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AttendanceColors.primary)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave approved. The inspector has bookings on these dates that '
              'need reassigning:',
              style: TextStyle(
                  fontSize: 13.sp,
                  color: AttendanceColors.textSecondary,
                  height: 1.5),
            ),
            SizedBox(height: 14.h),
            ...orders.map(
              (o) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        size: 16.sp, color: AttendanceColors.accent),
                    SizedBox(width: 8.w),
                    Text(o,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AttendanceColors.primary)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AttendanceColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg, {required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(adminLeavesControllerProvider);
    final notifier = ref.read(adminLeavesControllerProvider.notifier);

    return Column(
      children: [
        _FilterChipsBar(
          options: _statusFilters,
          selected: notifier.filter,
          labelOf: (s) => s == 'all' ? 'All' : _capitalize(s),
          onSelected: notifier.setFilter,
        ),
        Expanded(
          child: RefreshIndicator(
            color: AttendanceColors.accent,
            onRefresh: notifier.refresh,
            child: switch (state) {
              AsyncData(:final value) => _buildList(value),
              AsyncError(:final error) => _ErrorState(
                  message: error.toString().replaceFirst('Exception: ', ''),
                  onRetry: notifier.refresh,
                ),
              _ => const _CenteredLoader(),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList(Paged<LeaveRequest> paged) {
    final leaves = paged.items;
    if (leaves.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_available_rounded,
        title: 'No leave requests',
        subtitle: 'Requests matching this filter will appear here.',
      );
    }
    final hasMore = paged.pagination.hasMore;
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      itemCount: leaves.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, i) {
        if (i >= leaves.length) return const _ListFooterLoader();
        final leave = leaves[i];
        return _LeaveCard(
          leave: leave,
          busy: leave.id != null && _busyIds.contains(leave.id),
          onApprove: () => _decide(leave, approve: true),
          onReject: () => _decide(leave, approve: false),
        );
      },
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

String _errorText(ApiResult<Object?> r) => switch (r) {
      ApiNetworkError() => 'No connection. Check your network.',
      ApiUnauthorized() => 'Session expired. Please sign in again.',
      ApiForbidden() => 'You do not have access to this.',
      ApiBadRequest(:final message) ||
      ApiNotFound(:final message) ||
      ApiClientError(:final message) ||
      ApiServerError(:final message) =>
        message ?? 'Action failed',
      _ => 'Action failed',
    };

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.leave,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  final LeaveRequest leave;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AttendanceColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: leave.inspectorName),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.inspectorName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AttendanceColors.primary,
                      ),
                    ),
                    if ((leave.inspectorEmail ?? '').isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        leave.inspectorEmail!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.sp,
                            color: AttendanceColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              _StatusPill(status: leave.status),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AttendanceColors.accentLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: AttendanceColors.cardBg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.event_rounded,
                      size: 20.sp, color: AttendanceColors.accent),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave date',
                        style: TextStyle(
                            fontSize: 11.sp,
                            color: AttendanceColors.textSecondary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        leave.leaveDate != null
                            ? DateFormat('EEE, d MMM yyyy')
                                .format(leave.leaveDate!)
                            : 'Date not set',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AttendanceColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_relativeLabel(leave.leaveDate) != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AttendanceColors.cardBg,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      _relativeLabel(leave.leaveDate)!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AttendanceColors.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if ((leave.reason ?? '').isNotEmpty ||
              (leave.adminNote ?? '').isNotEmpty) ...[
            SizedBox(height: 10.h),
            _CollapsibleDetails(
              reason: (leave.reason ?? '').isNotEmpty ? leave.reason : null,
              adminNote:
                  (leave.adminNote ?? '').isNotEmpty ? leave.adminNote : null,
            ),
          ],
          if (leave.conflictingBookings.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AttendanceColors.redLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 14.sp, color: AttendanceColors.red),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      '${leave.conflictingBookings.length} booking(s) to '
                      'reassign: ${leave.conflictingBookings.join(', ')}',
                      style: TextStyle(
                          fontSize: 12.sp, color: AttendanceColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (leave.isPending) ...[
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    color: AttendanceColors.red,
                    bg: AttendanceColors.redLight,
                    busy: busy,
                    onTap: onReject,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    label: 'Approve',
                    icon: Icons.check_rounded,
                    color: Colors.white,
                    bg: AttendanceColors.green,
                    filled: true,
                    busy: busy,
                    onTap: onApprove,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// A short, human-friendly hint of how far away the leave date is.
  String? _relativeLabel(DateTime? date) {
    if (date == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1) return 'In $diff days';
    return '${-diff} days ago';
  }
}

/// Compact, single collapsible row holding both the reason and the admin note.
class _CollapsibleDetails extends StatefulWidget {
  const _CollapsibleDetails({this.reason, this.adminNote});

  final String? reason;
  final String? adminNote;

  @override
  State<_CollapsibleDetails> createState() => _CollapsibleDetailsState();
}

class _CollapsibleDetailsState extends State<_CollapsibleDetails> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasReason = widget.reason != null;
    final hasNote = widget.adminNote != null;
    final previewLabel = hasReason ? 'Reason' : 'Admin note';
    final previewText = hasReason ? widget.reason! : widget.adminNote!;
    final previewColor =
        hasReason ? AttendanceColors.textSecondary : AttendanceColors.amber;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      behavior: HitTestBehavior.opaque,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AttendanceColors.surface,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                      hasReason
                          ? Icons.notes_rounded
                          : Icons.sticky_note_2_outlined,
                      size: 13.sp,
                      color: previewColor),
                  SizedBox(width: 5.w),
                  Text(
                    '$previewLabel:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: previewColor,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      previewText,
                      maxLines: 1,
                      overflow:
                          _expanded ? TextOverflow.clip : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: _expanded
                            ? Colors.transparent
                            : AttendanceColors.primary,
                        height: 1.3,
                      ),
                    ),
                  ),
                  if (!_expanded && hasReason && hasNote) ...[
                    SizedBox(width: 4.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AttendanceColors.amberLight,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'note',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AttendanceColors.amber,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(width: 2.w),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 18.sp, color: previewColor),
                  ),
                ],
              ),
              if (_expanded) ...[
                if (hasReason)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      widget.reason!,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: AttendanceColors.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                if (hasNote) ...[
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: AttendanceColors.amberLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.sticky_note_2_outlined,
                            size: 13.sp, color: AttendanceColors.amber),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Admin note: ',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AttendanceColors.amber,
                                  ),
                                ),
                                TextSpan(
                                  text: widget.adminNote!,
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    color: AttendanceColors.amber,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── Attendance tab ─────────────────────────────

class _AttendanceTab extends ConsumerStatefulWidget {
  const _AttendanceTab();

  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab>
    with AutomaticKeepAliveClientMixin {
  static const _typeFilters = ['all', 'available', 'working'];

  final _scrollController = ScrollController();
  DateTime? _date;

  @override
  bool get wantKeepAlive => true;

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
        _scrollController.position.maxScrollExtent - 240.h) {
      ref.read(adminAttendanceControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AttendanceColors.accent,
            onPrimary: Colors.white,
            surface: AttendanceColors.cardBg,
            onSurface: AttendanceColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    ref
        .read(adminAttendanceControllerProvider.notifier)
        .setDate(DateFormat('yyyy-MM-dd').format(picked));
  }

  void _clearDate() {
    setState(() => _date = null);
    ref.read(adminAttendanceControllerProvider.notifier).setDate(null);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(adminAttendanceControllerProvider);
    final notifier = ref.read(adminAttendanceControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Row(
            children: [
              Expanded(
                child: _FilterChipsBar(
                  padding: EdgeInsets.zero,
                  options: _typeFilters,
                  selected: notifier.typeFilter,
                  labelOf: (s) => s == 'all' ? 'All' : _capitalize(s),
                  onSelected: notifier.setType,
                ),
              ),
              SizedBox(width: 8.w),
              _DateFilterButton(
                date: _date,
                onPick: _pickDate,
                onClear: _date == null ? null : _clearDate,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AttendanceColors.accent,
            onRefresh: notifier.refresh,
            child: switch (state) {
              AsyncData(:final value) => _buildList(value),
              AsyncError(:final error) => _ErrorState(
                  message: error.toString().replaceFirst('Exception: ', ''),
                  onRetry: notifier.refresh,
                ),
              _ => const _CenteredLoader(),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildList(Paged<AttendanceRecord> paged) {
    final records = paged.items;
    if (records.isEmpty) {
      return const _EmptyState(
        icon: Icons.fact_check_outlined,
        title: 'No attendance records',
        subtitle: 'Records matching these filters will appear here.',
      );
    }
    final hasMore = paged.pagination.hasMore;
    return ListView.separated(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      itemCount: records.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, i) {
        if (i >= records.length) return const _ListFooterLoader();
        return _AttendanceCard(record: records[i]);
      },
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final working = record.isWorking;
    final typeColor = working ? AttendanceColors.accent : AttendanceColors.green;
    final typeBg =
        working ? AttendanceColors.accentLight : AttendanceColors.greenLight;

    return Container(
      decoration: BoxDecoration(
        color: AttendanceColors.cardBg,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: record.inspectorName),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.inspectorName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AttendanceColors.primary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      record.date != null
                          ? DateFormat('EEE, d MMM yyyy').format(record.date!)
                          : 'Date unknown',
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: AttendanceColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _Tag(
                label: working ? 'Working' : 'Available',
                color: typeColor,
                bg: typeBg,
                icon: working
                    ? Icons.work_outline_rounded
                    : Icons.event_available_rounded,
              ),
            ],
          ),
          if (working || record.checkIn != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AttendanceColors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MetricCell(
                      icon: Icons.login_rounded,
                      color: AttendanceColors.green,
                      label: 'Check In',
                      value: _time(record.checkIn),
                    ),
                  ),
                  _divider(),
                  Expanded(
                    child: _MetricCell(
                      icon: Icons.logout_rounded,
                      color: AttendanceColors.red,
                      label: 'Check Out',
                      value: _time(record.checkOut),
                    ),
                  ),
                  _divider(),
                  Expanded(
                    child: _MetricCell(
                      icon: Icons.timer_outlined,
                      color: AttendanceColors.accent,
                      label: 'Duration',
                      value: _durationText(record.duration),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (record.hasLocation) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(Icons.location_on_rounded,
                    size: 14.sp, color: AttendanceColors.amber),
                SizedBox(width: 6.w),
                Text(
                  '${record.latitude!.toStringAsFixed(5)}, '
                  '${record.longitude!.toStringAsFixed(5)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AttendanceColors.amber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 30.h,
        color: AttendanceColors.border,
        margin: EdgeInsets.symmetric(horizontal: 8.w),
      );

  String _time(DateTime? dt) =>
      dt == null ? '--:--' : DateFormat('hh:mm a').format(dt);

  String _durationText(Duration? d) =>
      d == null ? '--' : '${d.inHours}h ${d.inMinutes.remainder(60)}m';
}

// ─────────────────────────── Shared sub-widgets ───────────────────────────

class _FilterChipsBar extends StatelessWidget {
  const _FilterChipsBar({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.padding,
  });

  final List<String> options;
  final String selected;
  final String Function(String) labelOf;
  final ValueChanged<String> onSelected;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: options.map((o) {
          final isSel = o == selected;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => onSelected(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSel
                      ? AttendanceColors.accent
                      : AttendanceColors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                      color: isSel
                          ? AttendanceColors.accent
                          : AttendanceColors.border),
                ),
                child: Text(
                  labelOf(o),
                  style: TextStyle(
                    fontSize: 13.sp,
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
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final active = date != null;
    return GestureDetector(
      onTap: active ? onClear : onPick,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? AttendanceColors.accentLight : AttendanceColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: active ? AttendanceColors.accent : AttendanceColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? Icons.close_rounded : Icons.calendar_today_rounded,
                size: 14.sp,
                color: active
                    ? AttendanceColors.accent
                    : AttendanceColors.textSecondary),
            SizedBox(width: 6.w),
            Text(
              active ? DateFormat('d MMM').format(date!) : 'Date',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: active
                    ? AttendanceColors.accent
                    : AttendanceColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final color = _colorFor(name);
    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static Color _colorFor(String name) {
    if (name.isEmpty) return AttendanceColors.avatars.first;
    return AttendanceColors
        .avatars[name.codeUnitAt(0) % AttendanceColors.avatars.length];
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    late Color color;
    late Color bg;
    late IconData icon;
    switch (s) {
      case 'approved':
        color = AttendanceColors.green;
        bg = AttendanceColors.greenLight;
        icon = Icons.check_circle_rounded;
      case 'rejected':
        color = AttendanceColors.red;
        bg = AttendanceColors.redLight;
        icon = Icons.cancel_rounded;
      default:
        color = AttendanceColors.amber;
        bg = AttendanceColors.amberLight;
        icon = Icons.hourglass_top_rounded;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            s.isEmpty ? 'Pending' : '${s[0].toUpperCase()}${s.substring(1)}',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 15.sp, color: color),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: TextStyle(
              fontSize: 10.sp, color: AttendanceColors.textSecondary),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
    this.filled = false,
    this.busy = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final bool filled;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: busy
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      filled ? Colors.white : color,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 16.sp, color: color),
                    SizedBox(width: 6.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ListFooterLoader extends StatelessWidget {
  const _ListFooterLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: const CircularProgressIndicator(strokeWidth: 2.2),
        ),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 30.w,
        height: 30.w,
        child: const CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Icon(icon, size: 56.sp, color: const Color(0xFFCBD5E1)),
        SizedBox(height: 16.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp,
                color: AttendanceColors.textSecondary,
                height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.16),
        Icon(Icons.cloud_off_rounded, size: 56.sp, color: const Color(0xFFCBD5E1)),
        SizedBox(height: 16.h),
        Text(
          "Couldn't load data",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13.sp,
                color: AttendanceColors.textSecondary,
                height: 1.5),
          ),
        ),
        SizedBox(height: 18.h),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh_rounded, size: 18.sp),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AttendanceColors.accent,
              side: const BorderSide(color: AttendanceColors.accent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet that confirms an approve/reject and collects an optional
/// admin note. Returns the note string (possibly empty) on confirm, or
/// `null` if the admin cancelled.
class _AdminNoteSheet extends StatefulWidget {
  const _AdminNoteSheet({required this.approve, required this.inspectorName});

  final bool approve;
  final String inspectorName;

  static Future<String?> show(
    BuildContext context, {
    required bool approve,
    required String inspectorName,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _AdminNoteSheet(approve: approve, inspectorName: inspectorName),
    );
  }

  @override
  State<_AdminNoteSheet> createState() => _AdminNoteSheetState();
}

class _AdminNoteSheetState extends State<_AdminNoteSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final approve = widget.approve;
    final accent = approve ? AttendanceColors.green : AttendanceColors.red;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AttendanceColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AttendanceColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    approve ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: accent,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        approve ? 'Approve Leave' : 'Reject Leave',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: AttendanceColors.primary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'For ${widget.inspectorName}',
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: AttendanceColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              'Note (optional)',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AttendanceColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _controller,
              maxLines: 3,
              maxLength: 250,
              style: TextStyle(fontSize: 14.sp, color: AttendanceColors.primary),
              decoration: InputDecoration(
                hintText: approve
                    ? 'Add a note for the inspector…'
                    : 'Reason for rejection…',
                hintStyle: TextStyle(
                    fontSize: 14.sp, color: AttendanceColors.textSecondary),
                filled: true,
                fillColor: AttendanceColors.surface,
                contentPadding: EdgeInsets.all(14.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AttendanceColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AttendanceColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: accent, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AttendanceColors.textSecondary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, _controller.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      approve ? 'Approve' : 'Reject',
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
