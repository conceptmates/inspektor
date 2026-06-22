import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/stats_controller.dart';
import '../../models/inspection_stats_model.dart';
import '../../services/local_inspection_service.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _startInspection(BuildContext context, WidgetRef ref) {
    final local = ref.read(localInspectionServiceProvider);
    if (local.hasFreshDraft()) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Resume inspection?'),
          content: const Text(
              'You have an unfinished inspection. Resume it or start new?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                ctx.goNamed(RouteNames.inspection);
              },
              child: const Text('Resume'),
            ),
            TextButton(
              onPressed: () {
                local.clearDraft();
                Navigator.pop(ctx);
                ctx.goNamed(RouteNames.vehicleDetails);
              },
              child: const Text('Start New'),
            ),
          ],
        ),
      );
    } else {
      context.goNamed(RouteNames.vehicleDetails);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final name = ref.watch(authControllerProvider.select((s) => s.user?.name));
    final statsAsync = ref.watch(statsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(name == null ? 'Certifide Inspektor' : 'Hi, $name'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(statsControllerProvider.notifier).refresh(),
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _StartInspectionCard(onStart: () => _startInspection(context, ref)),
            SizedBox(height: 20.w),
            Text('Overview', style: theme.textTheme.titleMedium),
            SizedBox(height: 12.w),
            switch (statsAsync) {
              AsyncData(:final value) => _StatsSection(stats: value),
              AsyncError(:final error) => Padding(
                  padding: EdgeInsets.only(top: 40.w),
                  child: ErrorDisplayWidget(
                    message: 'Could not load stats.\n$error',
                    onRetry: () =>
                        ref.read(statsControllerProvider.notifier).refresh(),
                  ),
                ),
              _ => Padding(
                  padding: EdgeInsets.only(top: 40.w),
                  child: const LoadingWidget(),
                ),
            },
          ],
        ),
      ),
    );
  }
}

class _StartInspectionCard extends StatelessWidget {
  const _StartInspectionCard({required this.onStart});
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primary,
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              Icon(Icons.document_scanner_outlined,
                  size: 40.sp, color: colors.onPrimary),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Start Inspection',
                        style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimary)),
                    SizedBox(height: 4.w),
                    Text('Begin a new vehicle inspection',
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: colors.onPrimary.withValues(alpha: 0.85))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 16.sp, color: colors.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final t = stats.daily.totals;
    return Column(
      children: [
        Row(
          children: [
            _StatCard(label: 'Total', value: t.total, color: Colors.blue),
            _StatCard(label: 'Approved', value: t.approved, color: Colors.green),
          ],
        ),
        SizedBox(height: 12.w),
        Row(
          children: [
            _StatCard(label: 'Pending', value: t.pending, color: Colors.orange),
            _StatCard(label: 'Rejected', value: t.rejected, color: Colors.red),
          ],
        ),
        if (stats.monthly.activeBuckets.isNotEmpty) ...[
          SizedBox(height: 24.w),
          Text('Last 6 months',
              style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 12.w),
          SizedBox(height: 180.w, child: _MonthlyChart(stats.monthly)),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: color, fontWeight: FontWeight.bold)),
              SizedBox(height: 4.w),
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart(this.stats);
  final InspectionStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final buckets = stats.buckets;
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: buckets[i].total.toDouble(),
                color: colors.primary,
                width: 14,
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
        ],
      ),
    );
  }
}
