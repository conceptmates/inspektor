import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/data/repositories/inspection_repository.dart';
import 'package:inspektor/models/inspection_stats_model.dart';
import 'package:inspektor/services/api/api_result.dart';

import '../../support/fake_http.dart';

void main() {
  test('getStats parses meta + totals', () async {
    final repo = InspectionRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'data': {
              'meta': {'period': 'daily'},
              'totals': {'total': 5, 'approved': 3},
            },
          },
        )));
    final r = await repo.getStats();
    expect(r, isA<ApiSuccess<InspectionStats>>());
    expect((r as ApiSuccess<InspectionStats>).data.totals.total, 5);
  });

  test('getHistory parses list + pagination', () async {
    final repo = InspectionRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'data': {
              'inspections': [
                {'id': 1, 'created_at': '2026-06-20T00:00:00Z', 'is_approved': false},
              ],
              'pagination': {'current_page': 1, 'last_page': 2},
            },
          },
        )));
    final r = await repo.getHistory(1);
    expect(r, isA<ApiSuccess<HistoryPage>>());
    final page = (r as ApiSuccess<HistoryPage>).data;
    expect(page.items.single.status, 'pending'); // derived from is_approved
    expect(page.pagination.hasMore, true);
  });

  test('getVehicleModels derives sorted unique brands', () async {
    final repo = InspectionRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'data': [
              {'id': 1, 'name': 'Corolla', 'brand': {'id': 2, 'name': 'Toyota'}},
              {'id': 2, 'name': 'City', 'brand': {'id': 1, 'name': 'Honda'}},
              {'id': 3, 'name': 'Civic', 'brand': {'id': 1, 'name': 'Honda'}},
            ],
          },
        )));
    final r = await repo.getVehicleModels();
    expect(r, isA<ApiSuccess<VehicleCatalog>>());
    final cat = (r as ApiSuccess<VehicleCatalog>).data;
    expect(cat.models.length, 3);
    expect(cat.brands.map((b) => b.name).toList(), ['Honda', 'Toyota']);
  });

  test('5xx is passed through as ApiServerError', () async {
    final repo = InspectionRepository(
        apiWrapperWith((_) => (status: 503, body: {'message': 'down'})));
    final r = await repo.getStats();
    expect(r, isA<ApiServerError<InspectionStats>>());
  });

  test('resumeInspection parses template + saved_sections + id', () async {
    final repo = InspectionRepository(apiWrapperWith((_) => (
          status: 200,
          body: {
            'data': {
              'inspection_id': 123,
              'structure': {
                'sections': [
                  {
                    'name': 'b',
                    'fields': [
                      {'field_id': 'a', 'title': 'A', 'initial_value': 'X'},
                    ],
                  },
                ],
              },
              'saved_sections': [
                {
                  'name': 'b',
                  'items': [
                    {'fieldId': 'a', 'value': 'X', 'imagePath': 'https://cdn/a.jpg'},
                  ],
                },
              ],
            },
          },
        )));
    final r = await repo.resumeInspection(123);
    expect(r, isA<ApiSuccess<InspectionInit>>());
    final init = (r as ApiSuccess<InspectionInit>).data;
    expect(init.inspectionId, 123);
    expect(init.template.savedFields['a']!['image'], 'https://cdn/a.jpg');
    expect(init.template.structure.sections.single.fields.single.initialValue,
        'X');
  });
}
