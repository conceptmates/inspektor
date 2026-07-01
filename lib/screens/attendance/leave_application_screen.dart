import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/attendance_controllers.dart';
import '../../services/api/api_result.dart';
import '../../themes/attendance_colors.dart';

/// Lets an inspector request a single day of leave.
///
/// Submits one `leave_date` via the inspector leaves controller, then surfaces
/// the outcome (a warning dialog when the day has bookings an admin must
/// reassign, otherwise a success dialog). Pops `true` once the request lands so
/// the caller's list refreshes — the controller also refreshes itself.
class LeaveApplicationScreen extends ConsumerStatefulWidget {
  const LeaveApplicationScreen({super.key});

  @override
  ConsumerState<LeaveApplicationScreen> createState() =>
      _LeaveApplicationScreenState();
}

class _LeaveApplicationScreenState
    extends ConsumerState<LeaveApplicationScreen> {
  final _reasonController = TextEditingController();

  DateTime? _date;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> _pickDate() async {
    final initial = _date ?? _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(_today) ? _today : initial,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AttendanceColors.accent,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AttendanceColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => _date = picked);
  }

  Future<void> _submit() async {
    final date = _date;
    if (date == null) {
      _showError('Please select a leave date.');
      return;
    }

    final reason = _reasonController.text.trim();
    setState(() => _isSubmitting = true);

    final result = await ref
        .read(inspectorLeavesControllerProvider.notifier)
        .requestLeave(
          leaveDate: DateFormat('yyyy-MM-dd').format(date),
          reason: reason.isEmpty ? null : reason,
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case ApiSuccess(:final data):
        _showSuccess(warning: data.warning);
      case ApiBadRequest(:final message) ||
            ApiUnauthorized(:final message) ||
            ApiForbidden(:final message) ||
            ApiNotFound(:final message) ||
            ApiClientError(:final message) ||
            ApiServerError(:final message) ||
            ApiNetworkError(:final message):
        _showError(message ?? 'Could not submit request.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AttendanceColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  /// Success dialog. When [warning] is present the day had bookings an admin
  /// will need to reassign — shown as an amber notice — otherwise it's a plain
  /// green confirmation. Either way, "Done" pops back with `true`.
  void _showSuccess({String? warning}) {
    final hasWarning = warning != null && warning.isNotEmpty;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: hasWarning
                      ? AttendanceColors.amberLight
                      : AttendanceColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasWarning
                      ? Icons.info_outline_rounded
                      : Icons.check_rounded,
                  size: 32,
                  color: hasWarning
                      ? AttendanceColors.amber
                      : AttendanceColors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Leave Requested!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AttendanceColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your request is pending approval.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AttendanceColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (hasWarning) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AttendanceColors.amberLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 16, color: AttendanceColors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warning,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AttendanceColors.amber,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AttendanceColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AttendanceColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AttendanceColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Leave',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AttendanceColors.primary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Leave Date'),
          const SizedBox(height: 10),
          _buildDateCard(),
          const SizedBox(height: 16),
          _buildSectionHeader('Reason (optional)'),
          const SizedBox(height: 10),
          _buildReasonField(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AttendanceColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildDateCard() {
    final selected = _date != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AttendanceColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? AttendanceColors.accent.withValues(alpha: 0.3)
                      : AttendanceColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.event_rounded,
                          size: 13,
                          color: selected
                              ? AttendanceColors.accent
                              : AttendanceColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? AttendanceColors.accent
                              : AttendanceColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    selected
                        ? DateFormat('EEE, d MMM yyyy').format(_date!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected
                          ? AttendanceColors.primary
                          : AttendanceColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (selected) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AttendanceColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 15, color: AttendanceColors.accent),
                  SizedBox(width: 6),
                  Text(
                    '1 day of leave',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AttendanceColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _reasonController,
        maxLines: 5,
        maxLength: 500,
        style: const TextStyle(
            fontSize: 14, color: AttendanceColors.primary, height: 1.5),
        decoration: InputDecoration(
          hintText: 'Add a short reason for your leave…',
          hintStyle: const TextStyle(
              fontSize: 14, color: AttendanceColors.textSecondary),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AttendanceColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AttendanceColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AttendanceColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AttendanceColors.accent.withValues(alpha: 0.6),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Submit Request',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
