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

// --- dual-key readers (API is inconsistent) ---
Object? _readTemplateType(Map json, String key) =>
    json['template_type'] ?? json['templateType'];
Object? _readVehicleInfo(Map json, String key) =>
    json['vehicle_info'] ?? json['vehicleInfo'];
Object? _readColour(Map json, String key) => json['colour'] ?? json['color'];
Object? _readMediaType(Map json, String key) =>
    json['media_type'] ?? json['type'];
