// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_inspection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocalInspection _$LocalInspectionFromJson(
  Map<String, dynamic> json,
) => _LocalInspection(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  status:
      $enumDecodeNullable(_$LocalStatusEnumMap, json['status']) ??
      LocalStatus.draft,
  isCompleted: json['isCompleted'] as bool? ?? false,
  inspectionId: (json['inspectionId'] as num?)?.toInt(),
  currentSection: (json['currentSection'] as num?)?.toInt() ?? 0,
  vehicleDetails: json['vehicleDetails'] as Map<String, dynamic>?,
  inspectionTemplate: json['inspectionTemplate'] as Map<String, dynamic>?,
  itemValues:
      (json['itemValues'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  itemRemarks:
      (json['itemRemarks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  textFieldValues:
      (json['textFieldValues'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  itemImages:
      (json['itemImages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  itemVideos:
      (json['itemVideos'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  itemAudios:
      (json['itemAudios'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  itemFiles:
      (json['itemFiles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  itemMultiImages:
      (json['itemMultiImages'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const <String, List<String>>{},
  itemFlaggedIssues:
      (json['itemFlaggedIssues'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const <String, List<String>>{},
  submissionData: json['submissionData'] as Map<String, dynamic>?,
  pendingMedia:
      (json['pendingMedia'] as List<dynamic>?)
          ?.map((e) => PendingMedia.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PendingMedia>[],
);

Map<String, dynamic> _$LocalInspectionToJson(_LocalInspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'status': _$LocalStatusEnumMap[instance.status]!,
      'isCompleted': instance.isCompleted,
      'inspectionId': instance.inspectionId,
      'currentSection': instance.currentSection,
      'vehicleDetails': instance.vehicleDetails,
      'inspectionTemplate': instance.inspectionTemplate,
      'itemValues': instance.itemValues,
      'itemRemarks': instance.itemRemarks,
      'textFieldValues': instance.textFieldValues,
      'itemImages': instance.itemImages,
      'itemVideos': instance.itemVideos,
      'itemAudios': instance.itemAudios,
      'itemFiles': instance.itemFiles,
      'itemMultiImages': instance.itemMultiImages,
      'itemFlaggedIssues': instance.itemFlaggedIssues,
      'submissionData': instance.submissionData,
      'pendingMedia': instance.pendingMedia.map((e) => e.toJson()).toList(),
    };

const _$LocalStatusEnumMap = {
  LocalStatus.draft: 'draft',
  LocalStatus.pending: 'pending',
  LocalStatus.submitted: 'submitted',
};

_PendingMedia _$PendingMediaFromJson(Map<String, dynamic> json) =>
    _PendingMedia(
      localPath: json['localPath'] as String,
      section: json['section'] as String,
      itemId: json['itemId'] as String,
      kind: json['kind'] as String? ?? 'image',
    );

Map<String, dynamic> _$PendingMediaToJson(_PendingMedia instance) =>
    <String, dynamic>{
      'localPath': instance.localPath,
      'section': instance.section,
      'itemId': instance.itemId,
      'kind': instance.kind,
    };
