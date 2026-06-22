import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_stats_model.freezed.dart';
part 'inspection_stats_model.g.dart';

/// Dashboard stats. The API nests period under `meta`, so build via [fromApi].
@freezed
abstract class InspectionStats with _$InspectionStats {
  const InspectionStats._();

  const factory InspectionStats({
    String? period,
    String? from,
    String? to,
    @Default(InspectionStatsTotals()) InspectionStatsTotals totals,
    @Default(<InspectionStatsBucket>[]) List<InspectionStatsBucket> buckets,
  }) = _InspectionStats;

  factory InspectionStats.fromJson(Map<String, dynamic> json) =>
      _$InspectionStatsFromJson(json);

  factory InspectionStats.fromApi(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map?)?.cast<String, dynamic>() ?? const {};
    return InspectionStats(
      period: meta['period']?.toString(),
      from: meta['from']?.toString(),
      to: meta['to']?.toString(),
      totals: InspectionStatsTotals.fromJson(
          (json['totals'] as Map?)?.cast<String, dynamic>() ?? const {}),
      buckets: ((json['buckets'] as List?) ?? const [])
          .map((e) => InspectionStatsBucket.fromJson(
              (e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }

  List<InspectionStatsBucket> get activeBuckets =>
      buckets.where((b) => b.total > 0).toList();
}

@freezed
abstract class InspectionStatsTotals with _$InspectionStatsTotals {
  const factory InspectionStatsTotals({
    @Default(0) int total,
    @Default(0) int approved,
    @Default(0) int pending,
    @Default(0) int rejected,
  }) = _InspectionStatsTotals;

  factory InspectionStatsTotals.fromJson(Map<String, dynamic> json) =>
      _$InspectionStatsTotalsFromJson(json);
}

@freezed
abstract class InspectionStatsBucket with _$InspectionStatsBucket {
  const factory InspectionStatsBucket({
    @Default('') String bucket,
    @Default(0) int total,
    @Default(0) int approved,
    @Default(0) int pending,
    @Default(0) int rejected,
  }) = _InspectionStatsBucket;

  factory InspectionStatsBucket.fromJson(Map<String, dynamic> json) =>
      _$InspectionStatsBucketFromJson(json);
}
