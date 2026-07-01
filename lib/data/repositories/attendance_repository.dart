import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/attendance_models.dart';
import '../../models/pagination_data_model.dart';
import '../../services/api/api_result.dart';
import '../../services/api/api_wrapper.dart';
import '../../services/api_list.dart';
import '../../services/dio_client.dart';

typedef LeavePage = ({List<InspectorLeave> items, PaginationData pagination});
typedef AdminLeavePage = ({List<LeaveRequest> items, PaginationData pagination});
typedef AttendancePage = ({
  List<AttendanceRecord> items,
  PaginationData pagination,
});
typedef LeaveSubmitResult = ({InspectorLeave? leave, String? warning});
typedef LeaveDecision = ({List<String> conflictingBookings});

/// Attendance + leave domain ops. Role-gated server-side (admin vs inspector).
class AttendanceRepository {
  AttendanceRepository(this._api);
  final ApiWrapper _api;

  // --- Inspector ---

  Future<ApiResult<LeavePage>> getInspectorLeaves(int page, {String? status}) async {
    final res = await _api.get<Map<String, dynamic>>(
      APIList.inspectorLeaves,
      query: {'page': page, 'per_page': 15, 'status': ?status},
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    return ApiSuccess((
      items: _list(res.data, 'leaves')
          .map((e) => InspectorLeave.fromApi(_m(e)))
          .toList(),
      pagination: _pagination(res.data),
    ));
  }

  Future<ApiResult<LeaveSubmitResult>> requestLeave({
    required String leaveDate,
    String? reason,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      APIList.inspectorLeaves,
      body: {'leave_date': leaveDate, 'reason': ?reason},
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    final data = res.data['data'];
    return ApiSuccess((
      leave: data is Map ? InspectorLeave.fromApi(_m(data)) : null,
      warning: res.data['warning']?.toString(),
    ));
  }

  Future<ApiResult<bool>> cancelLeave(Object id) async {
    final res = await _api.delete<Map<String, dynamic>>(
      APIList.cancelLeave(id),
      fromJson: _asMap,
    );
    return res is ApiSuccess ? const ApiSuccess(true) : castApiError(res);
  }

  // --- Admin ---

  Future<ApiResult<AdminLeavePage>> getAdminLeaves(
    int page, {
    int? inspectorId,
    String? status,
    String? date,
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      APIList.adminLeaves,
      query: {
        'page': page,
        'per_page': 20,
        'inspector_id': ?inspectorId,
        'status': ?status,
        'date': ?date,
      },
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    return ApiSuccess((
      items: _list(res.data, 'leaves')
          .map((e) => LeaveRequest.fromApi(_m(e)))
          .toList(),
      pagination: _pagination(res.data),
    ));
  }

  Future<ApiResult<LeaveDecision>> approveLeave(Object id, String note) =>
      _decideLeave(APIList.approveLeave(id), note);

  Future<ApiResult<LeaveDecision>> rejectLeave(Object id, String note) =>
      _decideLeave(APIList.rejectLeave(id), note);

  Future<ApiResult<LeaveDecision>> _decideLeave(String path, String note) async {
    final res = await _api.post<Map<String, dynamic>>(
      path,
      body: {if (note.trim().isNotEmpty) 'admin_note': note.trim()},
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    return ApiSuccess((
      conflictingBookings: (res.data['conflicting_bookings'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    ));
  }

  Future<ApiResult<AttendancePage>> getAdminAttendance(
    int page, {
    int? inspectorId,
    String? date,
    String? month,
    String? type,
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      APIList.adminAttendance,
      query: {
        'page': page,
        'per_page': 30,
        'inspector_id': ?inspectorId,
        'date': ?date,
        'month': ?month,
        'type': ?type,
      },
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    return ApiSuccess((
      items: _list(res.data, 'attendance')
          .map((e) => AttendanceRecord.fromApi(_m(e)))
          .toList(),
      pagination: _pagination(res.data),
    ));
  }

  // --- tolerant envelope parsing ---

  static Map<String, dynamic> _asMap(dynamic d) =>
      (d as Map).cast<String, dynamic>();
  static Map<String, dynamic> _m(dynamic e) => (e as Map).cast<String, dynamic>();

  List<dynamic> _list(Map<String, dynamic> body, String key) {
    final data = body['data'];
    if (data is List) return data;
    if (data is Map) {
      final v = data[key] ?? data['data'] ?? data['items'];
      if (v is List) return v;
    }
    final top = body[key];
    return top is List ? top : const [];
  }

  PaginationData _pagination(Map<String, dynamic> body) {
    final data = body['data'];
    final p = (data is Map ? data['pagination'] : null) ??
        body['pagination'] ??
        body['meta'];
    if (p is Map) return PaginationData.fromJson(p.cast<String, dynamic>());
    final src = (data is Map ? data : body);
    if (src['current_page'] != null) {
      return PaginationData.fromJson(src.cast<String, dynamic>());
    }
    return const PaginationData();
  }
}

final attendanceRepositoryProvider = Provider<AttendanceRepository>(
  (ref) => AttendanceRepository(ref.read(apiWrapperProvider)),
);
