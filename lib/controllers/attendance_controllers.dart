import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/attendance_repository.dart';
import '../models/attendance_models.dart';
import '../models/pagination_data_model.dart';
import '../services/api/api_result.dart';

/// Generic paginated list state.
class Paged<T> {
  const Paged({
    this.items = const [],
    this.pagination = const PaginationData(),
    this.isLoadingMore = false,
  });
  final List<T> items;
  final PaginationData pagination;
  final bool isLoadingMore;

  Paged<T> copyWith({
    List<T>? items,
    PaginationData? pagination,
    bool? isLoadingMore,
  }) =>
      Paged(
        items: items ?? this.items,
        pagination: pagination ?? this.pagination,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      );
}

String _errMsg(ApiResult<Object?> r) => switch (r) {
      ApiNetworkError() => 'No connection. Check your network.',
      ApiUnauthorized() => 'Session expired. Please sign in again.',
      ApiForbidden() => 'You do not have access to this.',
      ApiBadRequest(:final message) ||
      ApiNotFound(:final message) ||
      ApiClientError(:final message) ||
      ApiServerError(:final message) =>
        message ?? 'Could not load. Please try again.',
      _ => 'Could not load. Please try again.',
    };

/// Reusable paginated AsyncNotifier (infinite scroll + pull-refresh).
abstract class PagedNotifier<T> extends AsyncNotifier<Paged<T>> {
  Future<ApiResult<({List<T> items, PaginationData pagination})>> fetchPage(
      int page);

  @override
  Future<Paged<T>> build() => _load(1);

  Future<Paged<T>> _load(int page) async {
    final res = await fetchPage(page);
    return switch (res) {
      ApiSuccess(:final data) =>
        Paged(items: data.items, pagination: data.pagination),
      _ => throw Exception(_errMsg(res)),
    };
  }

  Future<void> loadMore() async {
    final cur = state.value;
    if (cur == null || cur.isLoadingMore || !cur.pagination.hasMore) return;
    state = AsyncData(cur.copyWith(isLoadingMore: true));
    final res = await fetchPage(cur.pagination.currentPage + 1);
    if (!ref.mounted) return;
    switch (res) {
      case ApiSuccess(:final data):
        state = AsyncData(cur.copyWith(
          items: [...cur.items, ...data.items],
          pagination: data.pagination,
          isLoadingMore: false,
        ));
      case _:
        state = AsyncData(cur.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(1));
  }
}

// --- Inspector leaves -------------------------------------------------------

class InspectorLeavesController extends PagedNotifier<InspectorLeave> {
  String filter = 'all';

  @override
  Future<ApiResult<({List<InspectorLeave> items, PaginationData pagination})>>
      fetchPage(int page) {
    return ref.read(attendanceRepositoryProvider).getInspectorLeaves(
          page,
          status: filter == 'all' ? null : filter,
        );
  }

  void setFilter(String value) {
    if (filter == value) return;
    filter = value;
    ref.invalidateSelf();
  }

  Future<ApiResult<LeaveSubmitResult>> requestLeave({
    required String leaveDate,
    String? reason,
  }) async {
    final res = await ref
        .read(attendanceRepositoryProvider)
        .requestLeave(leaveDate: leaveDate, reason: reason);
    if (res is ApiSuccess) refresh();
    return res;
  }

  Future<ApiResult<bool>> cancelLeave(Object id) async {
    final res = await ref.read(attendanceRepositoryProvider).cancelLeave(id);
    if (res is ApiSuccess) refresh();
    return res;
  }
}

final inspectorLeavesControllerProvider =
    AsyncNotifierProvider<InspectorLeavesController, Paged<InspectorLeave>>(
        InspectorLeavesController.new);

// --- Admin leaves -----------------------------------------------------------

class AdminLeavesController extends PagedNotifier<LeaveRequest> {
  String filter = 'pending';

  @override
  Future<ApiResult<({List<LeaveRequest> items, PaginationData pagination})>>
      fetchPage(int page) {
    return ref.read(attendanceRepositoryProvider).getAdminLeaves(
          page,
          status: filter == 'all' ? null : filter,
        );
  }

  void setFilter(String value) {
    if (filter == value) return;
    filter = value;
    ref.invalidateSelf();
  }

  Future<ApiResult<LeaveDecision>> approve(Object id, String note) async {
    final res = await ref.read(attendanceRepositoryProvider).approveLeave(id, note);
    if (res is ApiSuccess) refresh();
    return res;
  }

  Future<ApiResult<LeaveDecision>> reject(Object id, String note) async {
    final res = await ref.read(attendanceRepositoryProvider).rejectLeave(id, note);
    if (res is ApiSuccess) refresh();
    return res;
  }
}

final adminLeavesControllerProvider =
    AsyncNotifierProvider<AdminLeavesController, Paged<LeaveRequest>>(
        AdminLeavesController.new);

// --- Admin attendance -------------------------------------------------------

class AdminAttendanceController extends PagedNotifier<AttendanceRecord> {
  String typeFilter = 'all';
  String? dateFilter;

  @override
  Future<ApiResult<({List<AttendanceRecord> items, PaginationData pagination})>>
      fetchPage(int page) {
    return ref.read(attendanceRepositoryProvider).getAdminAttendance(
          page,
          type: typeFilter == 'all' ? null : typeFilter,
          date: dateFilter,
        );
  }

  void setType(String value) {
    if (typeFilter == value) return;
    typeFilter = value;
    ref.invalidateSelf();
  }

  void setDate(String? value) {
    dateFilter = value;
    ref.invalidateSelf();
  }
}

final adminAttendanceControllerProvider =
    AsyncNotifierProvider<AdminAttendanceController, Paged<AttendanceRecord>>(
        AdminAttendanceController.new);
