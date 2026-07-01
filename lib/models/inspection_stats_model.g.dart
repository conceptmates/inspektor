// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InspectionStats _$InspectionStatsFromJson(Map<String, dynamic> json) =>
    _InspectionStats(
      period: json['period'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
      totals: json['totals'] == null
          ? const InspectionStatsTotals()
          : InspectionStatsTotals.fromJson(
              json['totals'] as Map<String, dynamic>,
            ),
      buckets:
          (json['buckets'] as List<dynamic>?)
              ?.map(
                (e) =>
                    InspectionStatsBucket.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <InspectionStatsBucket>[],
    );

Map<String, dynamic> _$InspectionStatsToJson(_InspectionStats instance) =>
    <String, dynamic>{
      'period': instance.period,
      'from': instance.from,
      'to': instance.to,
      'totals': instance.totals.toJson(),
      'buckets': instance.buckets.map((e) => e.toJson()).toList(),
    };

_InspectionStatsTotals _$InspectionStatsTotalsFromJson(
  Map<String, dynamic> json,
) => _InspectionStatsTotals(
  total: (json['total'] as num?)?.toInt() ?? 0,
  approved: (json['approved'] as num?)?.toInt() ?? 0,
  pending: (json['pending'] as num?)?.toInt() ?? 0,
  rejected: (json['rejected'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$InspectionStatsTotalsToJson(
  _InspectionStatsTotals instance,
) => <String, dynamic>{
  'total': instance.total,
  'approved': instance.approved,
  'pending': instance.pending,
  'rejected': instance.rejected,
};

_InspectionStatsBucket _$InspectionStatsBucketFromJson(
  Map<String, dynamic> json,
) => _InspectionStatsBucket(
  bucket: json['bucket'] as String? ?? '',
  total: (json['total'] as num?)?.toInt() ?? 0,
  approved: (json['approved'] as num?)?.toInt() ?? 0,
  pending: (json['pending'] as num?)?.toInt() ?? 0,
  rejected: (json['rejected'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$InspectionStatsBucketToJson(
  _InspectionStatsBucket instance,
) => <String, dynamic>{
  'bucket': instance.bucket,
  'total': instance.total,
  'approved': instance.approved,
  'pending': instance.pending,
  'rejected': instance.rejected,
};
