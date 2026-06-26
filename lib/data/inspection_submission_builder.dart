import '../models/inspection_template_model.dart';
import '../models/local_inspection.dart';

/// Stable key for a field's per-item state across the screen + builder.
String fieldKey(InspectionField f) =>
    f.fieldId ?? f.id?.toString() ?? (f.title ?? '');

bool _isRegField(InspectionField f) {
  final id = f.fieldId?.toLowerCase() ?? '';
  return id == 'regno' || id.contains('reg');
}

/// The server keys items by `field_id` (string). Never the numeric structure id.
String _itemId(InspectionField f) => f.fieldId ?? f.id?.toString() ?? fieldKey(f);

/// A single media path: dropped when [httpOnly] and it is a local (non-uploaded)
/// path. Posting a local `/storage/...` path makes the server store an
/// unresolvable reference, blanking the field on resume — so server POSTs send
/// only already-uploaded `http(s)` URLs; the offline queue keeps the local path
/// so sync can upload + patch it later.
String? _httpOrNull(String? v, bool httpOnly) =>
    (httpOnly && v != null && v.isNotEmpty && !v.startsWith('http')) ? null : v;

/// Multi-image list filtered to uploaded URLs when [httpOnly]; null/empty stays
/// null so the key is omitted rather than sent as an empty array.
List<String>? _allHttpOrNull(List<String>? v, bool httpOnly) {
  if (v == null) return null;
  if (!httpOnly) return v;
  final kept = v.where((e) => e.startsWith('http')).toList();
  return kept.isEmpty ? null : kept;
}

/// Builds the `items` array for ONE section in the `/save-step` shape (dynamic
/// workflow doc §3). `id` is the `field_id` the server keys on. Pure (no I/O).
///
/// [httpOnly] defaults true because every call site is a server POST (save-step):
/// local media paths must never be sent. Pass false only for a local snapshot.
List<Map<String, dynamic>> buildSectionItems({
  required InspectionSection section,
  required LocalInspection draft,
  bool httpOnly = true,
}) {
  final items = <Map<String, dynamic>>[];
  for (final f in section.fields) {
    final key = fieldKey(f);
    items.add({
      'id': _itemId(f),
      'title': f.title,
      'value': draft.itemValues[key] ?? draft.textFieldValues[key],
      'remarks': draft.itemRemarks[key],
      'imagePath': _httpOrNull(draft.itemImages[key], httpOnly),
      'multiImages': _allHttpOrNull(draft.itemMultiImages[key], httpOnly),
      'videoPath': _httpOrNull(draft.itemVideos[key], httpOnly),
      'audioPath': _httpOrNull(draft.itemAudios[key], httpOnly),
      'filePath': _httpOrNull(draft.itemFiles[key], httpOnly),
      'flaggedIssues': draft.itemFlaggedIssues[key],
    });
  }
  return items;
}

/// Builds the `/dynamic-inspections/{id}/submit` body from the draft + template.
/// Pure (no I/O) so it is unit-testable. Mirrors the old `_buildSubmissionBody`.
///
/// [httpOnly] strips local media paths for the online server POST. The offline
/// queue builds with `httpOnly: false` so the stored body keeps local paths that
/// the sync path (`_patchItems`) replaces with uploaded URLs before submitting.
Map<String, dynamic> buildSubmissionBody({
  required LocalInspection draft,
  required InspectionInitializationResponse template,
  bool httpOnly = false,
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
        // field_id string the server matches on (NOT the numeric structure id).
        'id': _itemId(f),
        'fieldId': f.fieldId,
        'fieldType': f.fieldType,
        'title': f.title,
        'value': value,
        'remarks': draft.itemRemarks[key],
        'imagePath': _httpOrNull(draft.itemImages[key], httpOnly),
        'videoPath': _httpOrNull(draft.itemVideos[key], httpOnly),
        'audioPath': _httpOrNull(draft.itemAudios[key], httpOnly),
        'filePath': _httpOrNull(draft.itemFiles[key], httpOnly),
        'multiImages': _allHttpOrNull(draft.itemMultiImages[key], httpOnly),
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
