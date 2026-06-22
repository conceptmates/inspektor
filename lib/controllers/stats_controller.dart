import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/inspection_stats_model.dart';
import '../services/api/api_result.dart';

typedef DashboardStats = ({InspectionStats daily, InspectionStats monthly});

/// Home dashboard stats: daily (current month) + monthly (last 6 months).
/// Errors degrade to empty stats (show zeros) rather than blocking the home.
class StatsController extends AsyncNotifier<DashboardStats> {
  @override
  Future<DashboardStats> build() async {
    final repo = ref.read(inspectionRepositoryProvider);
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    final daily = await repo.getStats(
      from: fmt.format(DateTime(now.year, now.month, 1)),
      to: fmt.format(now),
    );
    final monthly = await repo.getStats(
      period: 'monthly',
      from: fmt.format(DateTime(now.year, now.month - 5, 1)),
      to: fmt.format(now),
    );

    return (daily: _value(daily), monthly: _value(monthly));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  static InspectionStats _value(ApiResult<InspectionStats> r) =>
      r is ApiSuccess<InspectionStats> ? r.data : const InspectionStats();
}

final statsControllerProvider =
    AsyncNotifierProvider<StatsController, DashboardStats>(StatsController.new);
