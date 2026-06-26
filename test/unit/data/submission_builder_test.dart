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

  test('buildSectionItems maps one section into the /save-step item shape', () {
    final section = InspectionSection.fromJson({
      'id': 1,
      'name': 'body_panel',
      'title': 'Body & Panels',
      'order': 1,
      'fields': [
        {'id': 9, 'field_id': 'front_bumper', 'title': 'Front Bumper', 'order': 1},
        {'id': 10, 'field_id': 'hood', 'title': 'Hood', 'order': 2},
      ],
    });

    final draft = LocalInspection(
      id: 'x',
      createdAt: DateTime(2026, 6, 22),
      itemValues: const {'front_bumper': 'GOOD'},
      itemRemarks: const {'front_bumper': 'minor scratch'},
      itemImages: const {'front_bumper': 'https://cdn/abc.jpg'}, // uploaded URL
      itemMultiImages: const {
        'hood': ['https://cdn/1.jpg', 'https://cdn/2.jpg'],
      },
    );

    final items = buildSectionItems(section: section, draft: draft);

    expect(items.length, 2);
    // save-step keys items by field_id (server contract), not numeric id.
    expect(items.first['id'], 'front_bumper');
    expect(items.first['value'], 'GOOD');
    expect(items.first['remarks'], 'minor scratch');
    expect(items.first['imagePath'], 'https://cdn/abc.jpg');
    expect(items[1]['id'], 'hood');
    expect(items[1]['multiImages'], hasLength(2));
    expect(items[1]['value'], isNull);
  });

  test('buildSectionItems strips local (non-http) media paths (httpOnly)', () {
    final section = InspectionSection.fromJson({
      'id': 1,
      'name': 'body_panel',
      'order': 1,
      'fields': [
        {'id': 9, 'field_id': 'front_bumper', 'title': 'Front Bumper', 'order': 1},
      ],
    });
    // Captured offline / upload failed → draft holds a local filesystem path.
    final draft = LocalInspection(
      id: 'x',
      createdAt: DateTime(2026, 6, 22),
      itemImages: const {'front_bumper': '/storage/emulated/0/Inspektor/a.jpg'},
      itemMultiImages: const {
        'front_bumper': ['/storage/local.jpg', 'https://cdn/ok.jpg'],
      },
    );

    final items = buildSectionItems(section: section, draft: draft);

    // Local path must NOT be POSTed (server would store an unresolvable ref).
    expect(items.single['imagePath'], isNull);
    // Only the already-uploaded URL survives in the multi list.
    expect(items.single['multiImages'], ['https://cdn/ok.jpg']);
  });

  test('buildSubmissionBody item id is the field_id string, not numeric id', () {
    final template = InspectionInitializationResponse.fromJson({
      'structure': {
        'sections': [
          {
            'id': 1,
            'name': 'exterior',
            'order': 1,
            'fields': [
              {'id': 201, 'field_id': 'front_bumper', 'title': 'FB', 'order': 1},
            ],
          },
        ],
      },
    });
    final draft = LocalInspection(id: 'x', createdAt: DateTime(2026, 6, 22));

    final body = buildSubmissionBody(draft: draft, template: template);
    final item =
        ((body['inspection_data'] as Map)['exterior']['items'] as List).single;
    // Server matches items by field_id string; numeric 201 would be dropped.
    expect(item['id'], 'front_bumper');
  });
}
