// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InspectionInitializationResponse _$InspectionInitializationResponseFromJson(
  Map<String, dynamic> json,
) => _InspectionInitializationResponse(
  templateType: _readTemplateType(json, 'templateType') == null
      ? null
      : InspectionTemplate.fromJson(
          _readTemplateType(json, 'templateType') as Map<String, dynamic>,
        ),
  vehicleInfo: _readVehicleInfo(json, 'vehicleInfo') == null
      ? null
      : VehicleInfo.fromJson(
          _readVehicleInfo(json, 'vehicleInfo') as Map<String, dynamic>,
        ),
  structure: json['structure'] == null
      ? const InspectionStructure()
      : InspectionStructure.fromJson(json['structure'] as Map<String, dynamic>),
  savedFields: _readSaved(json, 'savedFields') == null
      ? const <String, Map<String, dynamic>>{}
      : _parseSavedFields(_readSaved(json, 'savedFields')),
);

Map<String, dynamic> _$InspectionInitializationResponseToJson(
  _InspectionInitializationResponse instance,
) => <String, dynamic>{
  'templateType': instance.templateType?.toJson(),
  'vehicleInfo': instance.vehicleInfo?.toJson(),
  'structure': instance.structure.toJson(),
  'savedFields': instance.savedFields,
};

_InspectionTemplate _$InspectionTemplateFromJson(Map<String, dynamic> json) =>
    _InspectionTemplate(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      displayName: json['display_name'] as String?,
      description: json['description'] as String?,
      countryCode: json['country_code'] as String?,
      hasGovernmentApi: json['has_government_api'] as bool? ?? false,
      governmentApiType: json['government_api_type'] as String?,
    );

Map<String, dynamic> _$InspectionTemplateToJson(_InspectionTemplate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'display_name': instance.displayName,
      'description': instance.description,
      'country_code': instance.countryCode,
      'has_government_api': instance.hasGovernmentApi,
      'government_api_type': instance.governmentApiType,
    };

_VehicleInfo _$VehicleInfoFromJson(Map<String, dynamic> json) => _VehicleInfo(
  brand: json['brand'] as String?,
  model: json['model'] as String?,
  category: json['category'] as String?,
  year: json['year'] as String?,
  variant: json['variant'] as String?,
  colour: _readColour(json, 'colour') as String?,
  transmission: json['transmission'] as String?,
);

Map<String, dynamic> _$VehicleInfoToJson(_VehicleInfo instance) =>
    <String, dynamic>{
      'brand': instance.brand,
      'model': instance.model,
      'category': instance.category,
      'year': instance.year,
      'variant': instance.variant,
      'colour': instance.colour,
      'transmission': instance.transmission,
    };

_InspectionStructure _$InspectionStructureFromJson(Map<String, dynamic> json) =>
    _InspectionStructure(
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map(
                (e) => InspectionSection.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <InspectionSection>[],
    );

Map<String, dynamic> _$InspectionStructureToJson(
  _InspectionStructure instance,
) => <String, dynamic>{
  'sections': instance.sections.map((e) => e.toJson()).toList(),
};

_InspectionSection _$InspectionSectionFromJson(Map<String, dynamic> json) =>
    _InspectionSection(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map((e) => InspectionField.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <InspectionField>[],
    );

Map<String, dynamic> _$InspectionSectionToJson(_InspectionSection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'description': instance.description,
      'order': instance.order,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
    };

_InspectionField _$InspectionFieldFromJson(Map<String, dynamic> json) =>
    _InspectionField(
      id: (json['id'] as num?)?.toInt(),
      fieldId: json['field_id'] as String?,
      title: json['title'] as String?,
      fieldType: json['field_type'] as String? ?? 'text',
      isRequired: json['is_required'] as bool? ?? false,
      hasRemarks: json['has_remarks'] as bool? ?? false,
      hasImage: json['has_image'] as bool? ?? false,
      hasVideo: json['has_video'] as bool? ?? false,
      hasFile: json['has_file'] as bool? ?? false,
      hasMultipleImages: json['has_multiple_images'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => DropdownOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <DropdownOption>[],
      referenceMedia:
          (json['reference_media'] as List<dynamic>?)
              ?.map((e) => ReferenceMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ReferenceMedia>[],
      initialValue: _asStr(json['initial_value']),
      initialRemarks: _asStr(json['initial_remarks']),
      initialImage: _mediaStr(json['initial_image']),
      initialVideo: _mediaStr(json['initial_video']),
      initialAudio: _mediaStr(json['initial_audio']),
      initialFile: _mediaStr(json['initial_file']),
      initialMultiImages: json['initial_multi_images'] == null
          ? const <String>[]
          : _mediaStrList(json['initial_multi_images']),
    );

Map<String, dynamic> _$InspectionFieldToJson(
  _InspectionField instance,
) => <String, dynamic>{
  'id': instance.id,
  'field_id': instance.fieldId,
  'title': instance.title,
  'field_type': instance.fieldType,
  'is_required': instance.isRequired,
  'has_remarks': instance.hasRemarks,
  'has_image': instance.hasImage,
  'has_video': instance.hasVideo,
  'has_file': instance.hasFile,
  'has_multiple_images': instance.hasMultipleImages,
  'order': instance.order,
  'metadata': instance.metadata,
  'options': instance.options.map((e) => e.toJson()).toList(),
  'reference_media': instance.referenceMedia.map((e) => e.toJson()).toList(),
  'initial_value': instance.initialValue,
  'initial_remarks': instance.initialRemarks,
  'initial_image': instance.initialImage,
  'initial_video': instance.initialVideo,
  'initial_audio': instance.initialAudio,
  'initial_file': instance.initialFile,
  'initial_multi_images': instance.initialMultiImages,
};

_DropdownOption _$DropdownOptionFromJson(Map<String, dynamic> json) =>
    _DropdownOption(
      id: (json['id'] as num?)?.toInt(),
      value: json['value'] as String?,
      label: json['label'] as String?,
      colorName: json['color_name'] as String?,
      colorCode: json['color_code'] as String? ?? '#000000',
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$DropdownOptionToJson(_DropdownOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'label': instance.label,
      'color_name': instance.colorName,
      'color_code': instance.colorCode,
      'order': instance.order,
    };

_ReferenceMedia _$ReferenceMediaFromJson(Map<String, dynamic> json) =>
    _ReferenceMedia(
      id: (json['id'] as num?)?.toInt(),
      mediaType: _readMediaType(json, 'mediaType') as String?,
      filePath: json['file_path'] as String?,
      url: json['url'] as String?,
      description: json['description'] as String?,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ReferenceMediaToJson(_ReferenceMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mediaType': instance.mediaType,
      'file_path': instance.filePath,
      'url': instance.url,
      'description': instance.description,
      'order': instance.order,
    };
