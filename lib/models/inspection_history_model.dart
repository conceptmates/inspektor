import 'package:freezed_annotation/freezed_annotation.dart';

part 'inspection_history_model.freezed.dart';

/// History/report row. Display-only — built from the API's dual response shapes
/// (`/dynamic-inspections` and the older `/inspections`) via [fromApi].
@freezed
abstract class InspectionHistory with _$InspectionHistory {
  const factory InspectionHistory({
    required String id,
    required String inspectorName,
    required String status,
    required DateTime date,
    @Default(<String, dynamic>{}) Map<String, dynamic> vehicleInfo,
    Map<String, String>? links,
  }) = _InspectionHistory;

  factory InspectionHistory.fromApi(Map<String, dynamic> json) {
    Map<String, dynamic> vinfo;
    final rawVinfo = json['vehicle_info'];
    if (rawVinfo is Map) {
      vinfo = rawVinfo.cast<String, dynamic>();
    } else {
      final brand = (json['vehicle_brand'] as Map?)?['name'];
      final model = (json['vehicle_model'] as Map?)?['name'];
      vinfo = {
        'registration_number':
            json['registration_number'] ?? json['reference_number'],
        'make_model':
            [brand, model].where((e) => e != null).join(' ').trim(),
        'variant': json['variant'],
        'manufacturing_year': json['year'] ?? json['manufacturing_year'],
        'fuel_type': json['fuel_type'],
      };
    }

    final inspector = (json['inspector'] as Map?)?['name'] ??
        (json['user'] as Map?)?['name'];

    var status = (json['status'] ?? '').toString();
    if (status.isEmpty) {
      status = json['is_approved'] == true ? 'approved' : 'pending';
    }

    final reportUrl = json['report_url']?.toString();

    return InspectionHistory(
      id: (json['id'] ?? '').toString(),
      inspectorName: inspector?.toString() ?? '',
      status: status,
      date: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      vehicleInfo: vinfo,
      links: reportUrl != null ? {'view': reportUrl} : null,
    );
  }
}
