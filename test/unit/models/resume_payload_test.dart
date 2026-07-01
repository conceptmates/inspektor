import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/models/inspection_template_model.dart';

/// Server resume payloads come in several shapes; the model must flatten them
/// all into `savedFields` and surface per-field `initial_*` (cf. old 1773624).
void main() {
  test('saved_sections as list of sections + media object/string variants', () {
    final r = InspectionInitializationResponse.fromJson({
      'structure': {
        'sections': [
          {
            'name': 'body',
            'fields': [
              {'field_id': 'front', 'title': 'Front', 'initial_value': 'GOOD'},
              {'field_id': 'rear', 'title': 'Rear'},
            ],
          },
        ],
      },
      'saved_sections': [
        {
          'name': 'body',
          'items': [
            {
              'fieldId': 'front',
              'value': 'GOOD',
              'remarks': 'scratch',
              'imagePath': {'url': 'https://cdn/a.jpg'}, // object form
              'multiImages': ['https://cdn/1.jpg', {'path': 'https://cdn/2.jpg'}],
            },
            {'field_id': 'rear', 'videoPath': 'https://cdn/v.mp4'}, // string form
          ],
        },
      ],
    });

    expect(r.savedFields['front']!['value'], 'GOOD');
    expect(r.savedFields['front']!['remarks'], 'scratch');
    expect(r.savedFields['front']!['image'], 'https://cdn/a.jpg');
    expect(r.savedFields['front']!['multiImages'],
        ['https://cdn/1.jpg', 'https://cdn/2.jpg']);
    expect(r.savedFields['rear']!['video'], 'https://cdn/v.mp4');
    // per-field initial_* still surfaced from the structure
    expect(r.structure.sections.first.fields.first.initialValue, 'GOOD');
  });

  test('saved_sections as map keyed by section', () {
    final r = InspectionInitializationResponse.fromJson({
      'structure': {'sections': <dynamic>[]},
      'saved_sections': {
        'body': {
          'items': [
            {'fieldId': 'p', 'value': 'V'},
          ],
        },
      },
    });
    expect(r.savedFields['p']!['value'], 'V');
  });

  test('top-level fields[] with initial_* merges into savedFields', () {
    final r = InspectionInitializationResponse.fromJson({
      'structure': {'sections': <dynamic>[]},
      'fields': [
        {
          'field_id': 'x',
          'initial_value': 'A',
          'initial_image': 'https://cdn/x.jpg',
          'initial_multi_images': [
            {'url': 'https://cdn/m.jpg'}
          ],
        },
      ],
    });
    expect(r.savedFields['x']!['value'], 'A');
    expect(r.savedFields['x']!['image'], 'https://cdn/x.jpg');
    expect(r.savedFields['x']!['multiImages'], ['https://cdn/m.jpg']);
  });

  test('no saved data → empty savedFields (default)', () {
    final r = InspectionInitializationResponse.fromJson({
      'structure': {'sections': <dynamic>[]},
    });
    expect(r.savedFields, isEmpty);
  });
}
