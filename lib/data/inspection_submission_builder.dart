import '../models/inspection_template_model.dart';
import '../models/local_inspection.dart';

/// Stable key for a field's per-item state across the screen + builder.
String fieldKey(InspectionField f) =>
    f.fieldId ?? f.id?.toString() ?? (f.title ?? '');

bool _isRegField(InspectionField f) {
  final id = f.fieldId?.toLowerCase() ?? '';
  return id == 'regno' || id.contains('reg');
}

/// Builds the `/dynamic-inspections` submission body from the draft + template.
/// Pure (no I/O) so it is unit-testable. Mirrors the old `_buildSubmissionBody`.
Map<String, dynamic> buildSubmissionBody({
  required LocalInspection draft,
  required InspectionInitializationResponse template,
}) {
  final vd = draft.vehicleDetails ?? const {};
  final inspectionData = <String, dynamic>{};
  String? registrationNumber;

  for (final section in template.structure.sections) {
    final items = <Map<String, dynamic>>[];
    for (final f in section.fields) {
      final key = fieldKey(f);
      final value = draft.itemValues[key] ?? draft.textFieldValues[key];
      if (_isRegField(f) && value != null && value.isNotEmpty) {
        registrationNumber = value;
      }
      items.add({
        'id': f.id,
        'fieldId': f.fieldId,
        'fieldType': f.fieldType,
        'title': f.title,
        'value': value,
        'remarks': draft.itemRemarks[key],
        'imagePath': draft.itemImages[key],
        'videoPath': draft.itemVideos[key],
        'audioPath': draft.itemAudios[key],
        'filePath': draft.itemFiles[key],
        'multiImages': draft.itemMultiImages[key],
        'flaggedIssues': draft.itemFlaggedIssues[key],
      });
    }
    inspectionData[section.name ?? 'section_${section.id}'] = {
      'title': section.title ?? section.name,
      'items': items,
    };
  }

  return {
    'template_type': template.templateType?.name ?? 'default',
    'vehicle_brand_id': vd['vehicle_brand_id'],
    'vehicle_model_id': vd['vehicle_model_id'],
    'year': vd['year'],
    'variant': vd['variant'],
    'color': vd['colour'] ?? vd['color'],
    'transmission': vd['transmission'],
    'registration_number': registrationNumber ?? vd['registration_number'],
    'inspection_data': inspectionData,
  };
}
