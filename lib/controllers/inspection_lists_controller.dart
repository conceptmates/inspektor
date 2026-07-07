import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/inspection_history_model.dart';
import '../models/pagination_data_model.dart';
import '../services/api/api_result.dart';

part 'inspection_lists_controller.freezed.dart';

@freezed
abstract class PaginatedInspections with _$PaginatedInspections {
  const factory PaginatedInspections({
    @Default(<InspectionHistory>[]) List<InspectionHistory> items,
    @Default(PaginationData()) PaginationData pagination,
    @Default(false) bool isLoadingMore,
  }) = _PaginatedInspections;
}

/// Shared paginated-list controller (infinite scroll + pull-refresh).
/// First-load failure surfaces as AsyncError (UI shows retry).
abstract class PaginatedInspectionsController
    extends AsyncNotifier<PaginatedInspections> {
  Future<ApiResult<HistoryPage>> fetchPage(int page);

  @override
  Future<PaginatedInspections> build() => _load(1);

  Future<PaginatedInspections> _load(int page) async {
    final res = await fetchPage(page);
    return switch (res) {
      ApiSuccess(:final data) =>
        PaginatedInspections(items: data.items, pagination: data.pagination),
      ApiUnauthorized(:final message) ||
      ApiBadRequest(:final message) ||
      ApiForbidden(:final message) ||
      ApiNotFound(:final message) ||
      ApiClientError(:final message) ||
      ApiServerError(:final message) ||
      ApiNetworkError(:final message) =>
        throw Exception(message ?? 'Failed to load'),
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

/// GET /dynamic-inspections — full history.
class HistoryController extends PaginatedInspectionsController {
  @override
  Future<ApiResult<HistoryPage>> fetchPage(int page) =>
      ref.read(inspectionRepositoryProvider).getHistory(page);
}

/// GET /dynamic-inspections/my-history — current inspector's reports.
class ReportsController extends PaginatedInspectionsController {
  @override
  Future<ApiResult<HistoryPage>> fetchPage(int page) =>
      ref.read(inspectionRepositoryProvider).getMyHistory(page);
}

/// GET /dynamic-inspections/my-history?status=draft — resumable server drafts
/// (the Pending tab). Drafts are served only by this filter.
class DraftsController extends PaginatedInspectionsController {
  @override
  Future<ApiResult<HistoryPage>> fetchPage(int page) async {
    final res = await ref
        .read(inspectionRepositoryProvider)
        .getMyHistory(page, status: 'draft');
    // Reverse chronological — newest drafts first.
    if (res is ApiSuccess<HistoryPage>) {
      final sorted = [...res.data.items]
        ..sort((a, b) => b.date.compareTo(a.date));
      return ApiSuccess((items: sorted, pagination: res.data.pagination));
    }
    return res;
  }
}

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, PaginatedInspections>(
        HistoryController.new);

final reportsControllerProvider =
    AsyncNotifierProvider<ReportsController, PaginatedInspections>(
        ReportsController.new);

final draftsControllerProvider =
    AsyncNotifierProvider<DraftsController, PaginatedInspections>(
        DraftsController.new);
