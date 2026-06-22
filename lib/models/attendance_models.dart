import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_models.freezed.dart';

/// Attendance/leave DTOs. Built from tolerant `fromApi` parsers (the backend
/// envelope nests under `inspector`/`data` or is flat) — no toJson needed.

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

int? _int(dynamic v) =>
    v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}'));

String? _nullableStr(dynamic v) {
  final s = v?.toString().trim();
  if (s == null || s.isEmpty || s == 'null' || s == 'none') return null;
  return s;
}

String? _nested(Map<String, dynamic> j, String parent, String child) =>
    (j[parent] is Map ? (j[parent] as Map)[child] : null)?.toString();

@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const AttendanceRecord._();

  const factory AttendanceRecord({
    int? id,
    int? inspectorId,
    @Default('Inspector') String inspectorName,
    String? inspectorEmail,
    @Default('available') String type,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    double? latitude,
    double? longitude,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromApi(Map<String, dynamic> j) => AttendanceRecord(
        id: _int(j['id']),
        inspectorId: _int(j['inspector_id'] ?? _nested(j, 'inspector', 'id')),
        inspectorName: _nested(j, 'inspector', 'name') ??
            _nullableStr(j['inspector_name']) ??
            _nullableStr(j['name']) ??
            'Inspector',
        inspectorEmail: _nested(j, 'inspector', 'email') ??
            _nullableStr(j['inspector_email']) ??
            _nullableStr(j['email']),
        type: (j['type'] ?? 'available').toString(),
        date: _date(j['date'] ?? j['created_at']),
        checkIn: _date(j['check_in'] ?? j['checked_in_at'] ?? j['start_time']),
        checkOut:
            _date(j['check_out'] ?? j['checked_out_at'] ?? j['end_time']),
        latitude: (j['latitude'] ?? j['lat']) is num
            ? (j['latitude'] ?? j['lat']).toDouble()
            : null,
        longitude: (j['longitude'] ?? j['lng']) is num
            ? (j['longitude'] ?? j['lng']).toDouble()
            : null,
      );

  bool get isWorking => type == 'working';
  bool get isAvailable => !isWorking;
  bool get hasLocation => latitude != null && longitude != null;
  Duration? get duration {
    if (checkIn == null || checkOut == null) return null;
    final d = checkOut!.difference(checkIn!);
    return d.isNegative ? null : d;
  }
}

@freezed
abstract class InspectorLeave with _$InspectorLeave {
  const InspectorLeave._();

  const factory InspectorLeave({
    int? id,
    DateTime? leaveDate,
    String? reason,
    @Default('pending') String status,
    String? adminNote,
    DateTime? reviewedAt,
    String? reviewedBy,
    DateTime? createdAt,
  }) = _InspectorLeave;

  factory InspectorLeave.fromApi(Map<String, dynamic> j) => InspectorLeave(
        id: _int(j['id']),
        leaveDate: _date(j['leave_date'] ?? j['date']),
        reason: _nullableStr(j['reason']),
        status: (j['status'] ?? 'pending').toString(),
        adminNote: _nullableStr(j['admin_note']),
        reviewedAt: _date(j['reviewed_at']),
        reviewedBy: j['reviewed_by'] is Map
            ? _nested(j, 'reviewed_by', 'name') ?? _nested(j, 'reviewed_by', 'id')
            : _nullableStr(j['reviewed_by']),
        createdAt: _date(j['created_at']),
      );

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}

@freezed
abstract class LeaveRequest with _$LeaveRequest {
  const LeaveRequest._();

  const factory LeaveRequest({
    int? id,
    int? inspectorId,
    @Default('Inspector') String inspectorName,
    String? inspectorEmail,
    @Default('pending') String status,
    DateTime? leaveDate,
    String? reason,
    String? adminNote,
    DateTime? createdAt,
    @Default(<String>[]) List<String> conflictingBookings,
  }) = _LeaveRequest;

  factory LeaveRequest.fromApi(Map<String, dynamic> j) => LeaveRequest(
        id: _int(j['id']),
        inspectorId: _int(j['inspector_id'] ?? _nested(j, 'inspector', 'id')),
        inspectorName: _nested(j, 'inspector', 'name') ??
            _nullableStr(j['inspector_name']) ??
            _nullableStr(j['name']) ??
            'Inspector',
        inspectorEmail: _nested(j, 'inspector', 'email') ??
            _nullableStr(j['inspector_email']) ??
            _nullableStr(j['email']),
        status: (j['status'] ?? 'pending').toString(),
        leaveDate: _date(j['leave_date'] ??
            j['date'] ??
            j['from_date'] ??
            j['start_date']),
        reason: _nullableStr(j['reason'] ?? j['note']),
        adminNote: _nullableStr(j['admin_note']),
        createdAt: _date(j['created_at']),
        conflictingBookings: (j['conflicting_bookings'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
      );

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
