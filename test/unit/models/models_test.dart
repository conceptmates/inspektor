import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/models/inspection_history_model.dart';
import 'package:inspektor/models/inspection_stats_model.dart';
import 'package:inspektor/models/inspection_template_model.dart';
import 'package:inspektor/models/local_inspection.dart';
import 'package:inspektor/models/user_model.dart';
import 'package:inspektor/models/vehicle_model.dart';

void main() {
  test('User parses roles from [{name}] and flags admin', () {
    final u = User.fromJson({
      'id': 1,
      'name': 'Insp',
      'email': 'a@b.c',
      'roles': [
        {'name': 'inspector'},
        {'name': 'admin'},
      ],
    });
    expect(u.roles, ['inspector', 'admin']);
    expect(u.isAdmin, true);
    expect(u.hasRole('inspector'), true);
  });

  test('Inspection template engine parses snake_case + dual keys', () {
    final res = InspectionInitializationResponse.fromJson({
      'template_type': {'id': 1, 'display_name': 'Default'},
      'vehicle_info': {'brand': 'Toyota', 'color': 'Red'}, // color, not colour
      'structure': {
        'sections': [
          {
            'id': 1,
            'name': 'exterior',
            'order': 1,
            'fields': [
              {
                'id': 9,
                'field_id': 'regno',
                'title': 'Reg No',
                'field_type': 'text',
                'is_required': true,
                'has_image': true,
                'options': [
                  {'id': 1, 'value': 'ok', 'label': 'OK', 'color_code': '#0f0'},
                ],
                'reference_media': [
                  {'id': 1, 'type': 'image', 'url': 'http://x/y.png'},
                ],
              },
            ],
          },
        ],
      },
    });
    expect(res.templateType?.displayName, 'Default');
    expect(res.vehicleInfo?.colour, 'Red'); // color -> colour
    final field = res.structure.sections.single.fields.single;
    expect(field.fieldId, 'regno');
    expect(field.isRequired, true);
    expect(field.hasImage, true);
    expect(field.options.single.colorCode, '#0f0');
    expect(field.referenceMedia.single.mediaType, 'image'); // type -> mediaType
  });

  test('VehicleModel parses nested brand/category', () {
    final v = VehicleModel.fromJson({
      'id': 5,
      'brand_id': 2,
      'name': 'Corolla',
      'brand': {'id': 2, 'name': 'Toyota'},
    });
    expect(v.name, 'Corolla');
    expect(v.brand?.name, 'Toyota');
    expect(v.brandId, 2);
  });

  test('InspectionStats.fromApi reads meta + buckets', () {
    final s = InspectionStats.fromApi({
      'meta': {'period': 'daily', 'from': '2026-06-01', 'to': '2026-06-30'},
      'totals': {'total': 10, 'approved': 7, 'pending': 3},
      'buckets': [
        {'bucket': '2026-06-01', 'total': 2, 'approved': 1},
        {'bucket': '2026-06-02', 'total': 0},
      ],
    });
    expect(s.period, 'daily');
    expect(s.totals.total, 10);
    expect(s.buckets.length, 2);
    expect(s.activeBuckets.length, 1); // bucket with total 0 excluded
  });

  test('InspectionHistory.fromApi synthesizes vehicle info + status', () {
    final h = InspectionHistory.fromApi({
      'id': 42,
      'created_at': '2026-06-20T10:00:00Z',
      'vehicle_brand': {'name': 'Honda'},
      'vehicle_model': {'name': 'City'},
      'registration_number': 'KA01AB1234',
      'is_approved': true,
      'user': {'name': 'Insp One'},
      'report_url': 'http://r/1',
    });
    expect(h.id, '42');
    expect(h.inspectorName, 'Insp One');
    expect(h.status, 'approved'); // derived from is_approved
    expect(h.vehicleInfo['make_model'], 'Honda City');
    expect(h.links?['view'], 'http://r/1');
  });

  test('LocalInspection JSON round-trip preserves draft + queue', () {
    final original = LocalInspection(
      id: 'uuid-1',
      createdAt: DateTime.parse('2026-06-22T08:00:00Z'),
      status: LocalStatus.pending,
      inspectionId: 99,
      itemValues: {'regno': 'KA01AB1234'},
      itemMultiImages: {
        'summary': ['a.jpg', 'b.jpg'],
      },
      pendingMedia: [
        const PendingMedia(
            localPath: '/tmp/a.jpg', section: 'exterior', itemId: 'front'),
      ],
    );
    final round = LocalInspection.fromJson(original.toJson());
    expect(round, original);
    expect(round.status, LocalStatus.pending);
    expect(round.itemMultiImages['summary'], ['a.jpg', 'b.jpg']);
    expect(round.pendingMedia.single.section, 'exterior');
  });
}
