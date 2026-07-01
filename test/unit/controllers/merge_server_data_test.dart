import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/controllers/inspection_session_controller.dart';
import 'package:inspektor/models/inspection_template_model.dart';
import 'package:inspektor/models/local_inspection.dart';

/// mergeServerData overlays the server's resumed answers onto a local draft,
/// filling ONLY empty fields so unsynced local edits always win (old 109ab5c).
void main() {
  final tmpl = InspectionInitializationResponse(
    structure: const InspectionStructure(sections: [
      InspectionSection(name: 'b', fields: [
        InspectionField(fieldId: 'a', initialValue: 'server-a'),
        InspectionField(fieldId: 'b', initialValue: 'server-b'),
        InspectionField(fieldId: 'c'),
      ]),
    ]),
    savedFields: {
      'c': {'value': 'saved-c', 'image': 'https://cdn/c.jpg'},
    },
  );

  test('fills empty fields, preserves local edits', () {
    final draft = LocalInspection(
      id: 'd',
      createdAt: DateTime(2026, 1, 1),
      itemValues: const {'a': 'local-a'}, // local edit
    );

    final merged = mergeServerData(draft, tmpl);

    expect(merged.itemValues['a'], 'local-a'); // local edit preserved
    expect(merged.itemValues['b'], 'server-b'); // filled from initial_*
    expect(merged.itemValues['c'], 'saved-c'); // filled from savedFields
    expect(merged.itemImages['c'], 'https://cdn/c.jpg');
  });

  test('does not overwrite a non-empty image with a server one', () {
    final draft = LocalInspection(
      id: 'd',
      createdAt: DateTime(2026, 1, 1),
      itemImages: const {'c': '/local/keep.jpg'},
    );
    final merged = mergeServerData(draft, tmpl);
    expect(merged.itemImages['c'], '/local/keep.jpg');
  });
}
