import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../controllers/stats_controller.dart';
import '../../models/inspection_stats_model.dart';
import '../../services/local_inspection_service.dart';
import '../../themes/app_palette.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _chartTab = 0; // 0 = Daily, 1 = Monthly

  void _startInspection() {
    final colors = Theme.of(context).colorScheme;
    final local = ref.read(localInspectionServiceProvider);
    if (!local.hasFreshDraft()) {
      context.goNamed(RouteNames.vehicleDetails);
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Continue saved inspection?',
            style: TextStyle(
                color: colors.onSurface, fontWeight: FontWeight.w700)),
        content: Text(
          'You have an unfinished inspection. Continue where you left off, '
          'or start a new scan.',
          style: TextStyle(color: colors.onSurfaceVariant, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () {
              local.clearDraft();
              Navigator.pop(ctx);
              context.goNamed(RouteNames.vehicleDetails);
            },
            child: const Text('Start new'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.goNamed(RouteNames.inspection);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statsControllerProvider);
    final stats = statsAsync.value;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const _CarSpyTopAppBar(),
      body: RefreshIndicator(
        onRefresh: () => ref.read(statsControllerProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.w),
              _HeroSection(onInitializeScan: _startInspection),
              SizedBox(height: 28.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _InspectionChartCard(
                  daily: stats?.daily ?? const InspectionStats(),
                  monthly: stats?.monthly ?? const InspectionStats(),
                  loading: statsAsync.isLoading && stats == null,
                  tab: _chartTab,
                  onTab: (t) => setState(() => _chartTab = t),
                ),
              ),
              SizedBox(height: 24.w),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarSpyTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CarSpyTopAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = context.palette;
    return AppBar(
      toolbarHeight: 64,
      elevation: 1,
      scrolledUnderElevation: 1,
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      shadowColor: Colors.blueGrey.withValues(alpha: 0.1),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(left: 4.w),
        child: Row(
          children: [
            Icon(Icons.speed, color: palette.logo, size: 24.sp),
            SizedBox(width: 8.w),
            Text('CERTIFIDE',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: palette.logo,
                    letterSpacing: 1.2)),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: GestureDetector(
            onTap: () => context.pushNamed(RouteNames.profile),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration:
                  BoxDecoration(color: palette.iconPill, shape: BoxShape.circle),
              child: Icon(Icons.person_outline, color: palette.logo, size: 22.sp),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onInitializeScan});
  final VoidCallback onInitializeScan;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: SizedBox(
          height: 340.w,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/carspyHero.png', fit: BoxFit.cover),
              // Intrinsic dark scrim over the hero photo (decorative overlay).
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x22000000), Color(0xCC000000)],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                bottom: 28.w,
                left: 24.w,
                right: 24.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: colors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text('ADVANCED TECH',
                          style: TextStyle(
                              // light-on-dark accent over the hero image
                              color: const Color(0xFF60A5FA),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2)),
                    ),
                    SizedBox(height: 10.w),
                    Text('Start\nYour\nInspection.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            letterSpacing: -1)),
                    SizedBox(height: 8.w),
                    Text(
                      'Execute high-precision diagnostics and visual appraisals '
                      'through proprietary kinetic blueprint scanner.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.sp,
                          height: 1.5),
                    ),
                    SizedBox(height: 20.w),
                    ElevatedButton.icon(
                      onPressed: onInitializeScan,
                      icon: Icon(Icons.qr_code_scanner, size: 18.sp),
                      label: Text('Initialize Scan',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 14.w),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 8,
                        shadowColor: colors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InspectionChartCard extends StatelessWidget {
  const _InspectionChartCard({
    required this.daily,
    required this.monthly,
    required this.loading,
    required this.tab,
    required this.onTab,
  });

  final InspectionStats daily;
  final InspectionStats monthly;
  final bool loading;
  final int tab;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stats = tab == 0 ? daily : monthly;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspections',
                      style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                          letterSpacing: -0.3)),
                  SizedBox(height: 2.w),
                  Text(tab == 0 ? 'Last 7 days' : 'Last 6 months',
                      style: TextStyle(
                          fontSize: 12.sp, color: colors.onSurfaceVariant)),
                ],
              ),
              _SegTabs(tab: tab, onTab: onTab),
            ],
          ),
          SizedBox(height: 20.w),
          SizedBox(
            height: 180.w,
            child: loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : stats.activeBuckets.isEmpty
                    ? Center(
                        child: Text('No inspection data yet',
                            style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13.sp)))
                    : (tab == 0
                        ? _DailyBars(buckets: stats.buckets)
                        : _MonthlyLine(buckets: stats.buckets)),
          ),
          if (tab == 0 && stats.activeBuckets.isNotEmpty) ...[
            SizedBox(height: 12.w),
            const _Legend(),
          ],
          SizedBox(height: 20.w),
          Row(
            children: [
              _ChartStat(
                label: 'Today',
                value: daily.buckets.isNotEmpty ? daily.buckets.last.total : 0,
                icon: Icons.today_outlined,
                color: colors.primary,
              ),
              _ChartStat(
                label: tab == 0 ? 'This Month' : '6 Months',
                value: stats.totals.total,
                icon: Icons.bar_chart_rounded,
                color: context.palette.indigo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegTabs extends StatelessWidget {
  const _SegTabs({required this.tab, required this.onTab});
  final int tab;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget button(String label, int index) {
      final selected = tab == index;
      return GestureDetector(
        onTap: () => onTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.w),
          decoration: BoxDecoration(
            color: selected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2)),
                  ]
                : null,
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      selected ? colors.onSurface : colors.onSurfaceVariant)),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10.r)),
      child: Row(children: [button('Daily', 0), button('Monthly', 1)]),
    );
  }
}

class _DailyBars extends StatelessWidget {
  const _DailyBars({required this.buckets});
  final List<InspectionStatsBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = context.palette;
    final rawMax = buckets.fold<int>(0, (m, b) => b.total > m ? b.total : m);
    final maxY = (rawMax < 4 ? 4 : rawMax + 2).toDouble();
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
              color: colors.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true, reservedSize: 30, interval: maxY / 4)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= buckets.length) return const SizedBox.shrink();
                final b = buckets[i].bucket;
                final day = b.length >= 10 ? b.substring(8, 10) : b;
                return Padding(
                    padding: EdgeInsets.only(top: 4.w),
                    child: Text(day, style: TextStyle(fontSize: 11.sp)));
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: buckets[i].total.toDouble(),
                color: Colors.transparent,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                rodStackItems: [
                  BarChartRodStackItem(
                      0, buckets[i].approved.toDouble(), palette.approved),
                  BarChartRodStackItem(
                      buckets[i].approved.toDouble(),
                      (buckets[i].approved + buckets[i].pending).toDouble(),
                      palette.pending),
                  BarChartRodStackItem(
                      (buckets[i].approved + buckets[i].pending).toDouble(),
                      buckets[i].total.toDouble(),
                      palette.rejected),
                ],
              ),
            ]),
        ],
      ),
    );
  }
}

class _MonthlyLine extends StatelessWidget {
  const _MonthlyLine({required this.buckets});
  final List<InspectionStatsBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rawMax = buckets.fold<int>(0, (m, b) => b.total > m ? b.total : m);
    final maxY = (rawMax < 4 ? 4 : rawMax + 2).toDouble();
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (buckets.length - 1).toDouble().clamp(0, double.infinity),
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
              color: colors.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: colors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.primary.withValues(alpha: 0.18),
                  colors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
            spots: [
              for (var i = 0; i < buckets.length; i++)
                FlSpot(i.toDouble(), buckets[i].total.toDouble()),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final palette = context.palette;
    Widget item(String label, Color color) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: 5.w),
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp, color: colors.onSurfaceVariant)),
          ],
        );
    return Row(
      children: [
        item('Approved', palette.approved),
        SizedBox(width: 12.w),
        item('Pending', palette.pending),
        SizedBox(width: 12.w),
        item('Rejected', palette.rejected),
      ],
    );
  }
}

class _ChartStat extends StatelessWidget {
  const _ChartStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r)),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                      letterSpacing: -0.3)),
              Text(label,
                  style: TextStyle(
                      fontSize: 12.sp, color: colors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
