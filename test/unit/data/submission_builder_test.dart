import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/data/inspection_submission_builder.dart';
import 'package:inspektor/models/inspection_template_model.dart';
import 'package:inspektor/models/local_inspection.dart';

void main() {
  test('buildSubmissionBody maps draft + template into API body', () {
    final template = InspectionInitializationResponse.fromJson({
      'template_type': {'name': 'default'},
      'structure': {
        'sections': [
          {
            'id': 1,
            'name': 'exterior',
            'title': 'Exterior',
            'order': 1,
            'fields': [
              {
                'id': 9,
                'field_id': 'regno',
                'title': 'Reg No',
                'field_type': 'text',
                'order': 1,
              },
            ],
          },
        ],
      },
    });

    final draft = LocalInspection(
      id: 'x',
      createdAt: DateTime(2026, 6, 22),
      vehicleDetails: const {
        'vehicle_brand_id': 2,
        'vehicle_model_id': 5,
        'colour': 'Red',
      },
      itemValues: const {'regno': 'KA01AB1234'},
      itemRemarks: const {'regno': 'clear'},
    );

    final body = buildSubmissionBody(draft: draft, template: template);

    expect(body['template_type'], 'default');
    expect(body['vehicle_brand_id'], 2);
    expect(body['color'], 'Red');
    expect(body['registration_number'], 'KA01AB1234');

    final items = (body['inspection_data']
        as Map)['exterior']['items'] as List;
    expect(items.single['fieldId'], 'regno');
    expect(items.single['value'], 'KA01AB1234');
    expect(items.single['remarks'], 'clear');
  });
}
