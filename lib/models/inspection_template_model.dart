import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_template_model.freezed.dart';
part 'inspection_template_model.g.dart';

/// Response of POST /dynamic-inspections/initialize — the dynamic-form engine.
@freezed
abstract class InspectionInitializationResponse
    with _$InspectionInitializationResponse {
  const factory InspectionInitializationResponse({
    @JsonKey(readValue: _readTemplateType) InspectionTemplate? templateType,
    @JsonKey(readValue: _readVehicleInfo) VehicleInfo? vehicleInfo,
    @Default(InspectionStructure()) InspectionStructure structure,
    // Resume payload: previously-saved answers + already-uploaded media URLs,
    // flattened to `fieldKey -> {value, remarks, image, multiImages, video,
    // audio, file}`. Read from BOTH `saved_sections` and a top-level `fields[]`
    // (the server carries resumed data in either shape across versions).
    @JsonKey(readValue: _readSaved, fromJson: _parseSavedFields)
    @Default(<String, Map<String, dynamic>>{})
    Map<String, Map<String, dynamic>> savedFields,
  }) = _InspectionInitializationResponse;

  factory InspectionInitializationResponse.fromJson(
          Map<String, dynamic> json) =>
      _$InspectionInitializationResponseFromJson(json);
}

@freezed
abstract class InspectionTemplate with _$InspectionTemplate {
  const factory InspectionTemplate({
    int? id,
    String? name,
    @JsonKey(name: 'display_name') String? displayName,
    String? description,
    @JsonKey(name: 'country_code') String? countryCode,
    @JsonKey(name: 'has_government_api') @Default(false) bool hasGovernmentApi,
    @JsonKey(name: 'government_api_type') String? governmentApiType,
  }) = _InspectionTemplate;

  factory InspectionTemplate.fromJson(Map<String, dynamic> json) =>
      _$InspectionTemplateFromJson(json);
}

@freezed
abstract class VehicleInfo with _$VehicleInfo {
  const factory VehicleInfo({
    String? brand,
    String? model,
    String? category,
    String? year,
    String? variant,
    @JsonKey(readValue: _readColour) String? colour,
    String? transmission,
  }) = _VehicleInfo;

  factory VehicleInfo.fromJson(Map<String, dynamic> json) =>
      _$VehicleInfoFromJson(json);
}

@freezed
abstract class InspectionStructure with _$InspectionStructure {
  const factory InspectionStructure({
    @Default(<InspectionSection>[]) List<InspectionSection> sections,
  }) = _InspectionStructure;

  factory InspectionStructure.fromJson(Map<String, dynamic> json) =>
      _$InspectionStructureFromJson(json);
}

@freezed
abstract class InspectionSection with _$InspectionSection {
  const factory InspectionSection({
    int? id,
    String? name,
    String? title,
    String? description,
    @Default(0) int order,
    @Default(<InspectionField>[]) List<InspectionField> fields,
  }) = _InspectionSection;

  factory InspectionSection.fromJson(Map<String, dynamic> json) =>
      _$InspectionSectionFromJson(json);
}

@freezed
abstract class InspectionField with _$InspectionField {
  const factory InspectionField({
    int? id,
    @JsonKey(name: 'field_id') String? fieldId,
    String? title,
    @JsonKey(name: 'field_type') @Default('text') String fieldType,
    @JsonKey(name: 'is_required') @Default(false) bool isRequired,
    @JsonKey(name: 'has_remarks') @Default(false) bool hasRemarks,
    @JsonKey(name: 'has_image') @Default(false) bool hasImage,
    @JsonKey(name: 'has_video') @Default(false) bool hasVideo,
    @JsonKey(name: 'has_file') @Default(false) bool hasFile,
    @JsonKey(name: 'has_multiple_images')
    @Default(false)
    bool hasMultipleImages,
    @Default(0) int order,
    Map<String, dynamic>? metadata,
    @Default(<DropdownOption>[]) List<DropdownOption> options,
    @JsonKey(name: 'reference_media')
    @Default(<ReferenceMedia>[])
    List<ReferenceMedia> referenceMedia,
    // Resume pre-fill (server's saved answer for this field). Empty on a fresh
    // initialize; populated by GET /{id}/resume so the merge can re-hydrate.
    @JsonKey(name: 'initial_value', fromJson: _asStr) String? initialValue,
    @JsonKey(name: 'initial_remarks', fromJson: _asStr) String? initialRemarks,
    @JsonKey(name: 'initial_image', fromJson: _mediaStr) String? initialImage,
    @JsonKey(name: 'initial_video', fromJson: _mediaStr) String? initialVideo,
    @JsonKey(name: 'initial_audio', fromJson: _mediaStr) String? initialAudio,
    @JsonKey(name: 'initial_file', fromJson: _mediaStr) String? initialFile,
    @JsonKey(name: 'initial_multi_images', fromJson: _mediaStrList)
    @Default(<String>[])
    List<String> initialMultiImages,
  }) = _InspectionField;

  factory InspectionField.fromJson(Map<String, dynamic> json) =>
      _$InspectionFieldFromJson(json);
}

@freezed
abstract class DropdownOption with _$DropdownOption {
  const factory DropdownOption({
    int? id,
    String? value,
    String? label,
    @JsonKey(name: 'color_name') String? colorName,
    @JsonKey(name: 'color_code') @Default('#000000') String colorCode,
    @Default(0) int order,
  }) = _DropdownOption;

  factory DropdownOption.fromJson(Map<String, dynamic> json) =>
      _$DropdownOptionFromJson(json);
}

@freezed
abstract class ReferenceMedia with _$ReferenceMedia {
  const factory ReferenceMedia({
    int? id,
    @JsonKey(readValue: _readMediaType) String? mediaType,
    @JsonKey(name: 'file_path') String? filePath,
    String? url,
    String? description,
    @Default(0) int order,
  }) = _ReferenceMedia;

  factory ReferenceMedia.fromJson(Map<String, dynamic> json) =>
      _$ReferenceMediaFromJson(json);
}

extension ReferenceImageUrls on InspectionInitializationResponse {
  /// Flat list of every image reference-media URL across all sections/fields,
  /// for warming the offline cache. Excludes non-image media (video/audio are
  /// streamed; links live on uncacheable third-party hosts).
  List<String> get referenceImageUrls => [
        for (final section in structure.sections)
          for (final field in section.fields)
            for (final media in field.referenceMedia)
              if ((media.url ?? '').isNotEmpty &&
                  (media.mediaType ?? '').toLowerCase() == 'image')
                media.url!,
      ];
}

// --- dual-key readers (API is inconsistent) ---
Object? _readTemplateType(Map json, String key) =>
    json['template_type'] ?? json['templateType'];
Object? _readVehicleInfo(Map json, String key) =>
    json['vehicle_info'] ?? json['vehicleInfo'];
Object? _readColour(Map json, String key) => json['colour'] ?? json['color'];
Object? _readMediaType(Map json, String key) =>
    json['media_type'] ?? json['type'];

// --- resume payload (saved_sections / fields[]) parsing ---

/// Combines the two server shapes that carry resumed answers into one list the
/// flattener can consume: `saved_sections` (sections or items) and a top-level
/// `fields[]` array (each with `initial_*`/`field_id`).
Object? _readSaved(Map json, String key) {
  final out = <dynamic>[];
  final ss = json['saved_sections'];
  if (ss is List) {
    out.addAll(ss);
  } else if (ss is Map) {
    out.addAll(ss.values);
  } else if (ss != null) {
    out.add(ss);
  }
  final f = json['fields'];
  if (f is List) out.addAll(f);
  return out.isEmpty ? null : out;
}

String? _asStr(Object? v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// A media value may be an object (`{url|path}`) or a plain string/path.
String? _mediaStr(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    final s = (v['url'] ?? v['path'])?.toString();
    return (s == null || s.isEmpty) ? null : s;
  }
  final s = v.toString();
  return s.isEmpty ? null : s;
}

List<String> _mediaStrList(Object? v) {
  if (v is! List) return const [];
  final out = <String>[];
  for (final e in v) {
    final s = _mediaStr(e);
    if (s != null && s.isNotEmpty) out.add(s);
  }
  return out;
}

/// Flattens the server's resumed answers into a flat
/// `fieldKey -> {value, remarks, image, multiImages, video, audio, file}` map.
/// Tolerant to shape: list of section objects, map keyed by section, a section's
/// `items` list/map, or already-flat item/`fields[]` records. Media may be
/// `{url|path}` objects or strings.
Map<String, Map<String, dynamic>> _parseSavedFields(Object? raw) {
  final out = <String, Map<String, dynamic>>{};
  if (raw == null) return out;

  void absorbItem(Object? item) {
    if (item is! Map) return;
    final key = (item['fieldId'] ??
            item['field_id'] ??
            item['uniqueId'] ??
            item['unique_id'] ??
            item['id'])
        ?.toString();
    if (key == null || key.isEmpty) return;
    out[key] = {
      'value': item['value'] ?? item['initial_value'] ?? item['initialValue'],
      'remarks':
          item['remarks'] ?? item['initial_remarks'] ?? item['initialRemarks'],
      'image': _mediaStr(item['imagePath'] ??
          item['image'] ??
          item['initial_image'] ??
          item['initialImage']),
      'multiImages': _mediaStrList(item['multiImages'] ??
          item['multi_images'] ??
          item['initial_multi_images'] ??
          item['initialMultiImages']),
      'video': _mediaStr(item['videoPath'] ??
          item['video'] ??
          item['initial_video'] ??
          item['initialVideo']),
      'audio': _mediaStr(item['audioPath'] ??
          item['audio'] ??
          item['initial_audio'] ??
          item['initialAudio']),
      'file': _mediaStr(item['filePath'] ??
          item['file'] ??
          item['initial_file'] ??
          item['initialFile']),
    };
  }

  void absorbItems(Object? items) {
    if (items is List) {
      for (final it in items) {
        absorbItem(it);
      }
    } else if (items is Map) {
      for (final it in items.values) {
        absorbItem(it);
      }
    }
  }

  void absorbSection(Object? section) {
    if (section is! Map) return;
    // A section wrapper carries an `items` list/map; otherwise treat the map as
    // a bare item (already-flat / fields[] record).
    if (section['items'] != null) {
      absorbItems(section['items']);
    } else {
      absorbItem(section);
    }
  }

  if (raw is List) {
    for (final s in raw) {
      absorbSection(s);
    }
  } else if (raw is Map) {
    for (final v in raw.values) {
      absorbSection(v);
    }
  }
  return out;
}
