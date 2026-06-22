import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/controllers/inspection_lists_controller.dart';
import 'package:inspektor/data/repositories/inspection_repository.dart';

import '../../support/fake_http.dart';

void main() {
  ProviderContainer containerWithPagedRepo() {
    final repo = InspectionRepository(apiWrapperWith((o) {
      final page = int.tryParse('${o.queryParameters['page']}') ?? 1;
      return (
        status: 200,
        body: {
          'data': {
            'inspections': [
              {
                'id': page,
                'created_at': '2026-06-20T00:00:00Z',
                'is_approved': page == 2,
              },
            ],
            'pagination': {'current_page': page, 'last_page': 2},
          },
        },
      );
    }));
    return ProviderContainer.test(
      overrides: [inspectionRepositoryProvider.overrideWithValue(repo)],
    );
  }

  test('history loads page 1, then loadMore appends page 2', () async {
    final container = containerWithPagedRepo();

    final first = await container.read(historyControllerProvider.future);
    expect(first.items.length, 1);
    expect(first.pagination.hasMore, true);

    await container.read(historyControllerProvider.notifier).loadMore();
    final after = container.read(historyControllerProvider).requireValue;
    expect(after.items.length, 2);
    expect(after.pagination.hasMore, false); // reached last page
  });

  test('first-load error surfaces as AsyncError', () async {
    final repo = InspectionRepository(
        apiWrapperWith((_) => (status: 500, body: {'message': 'boom'})));
    // Disable Riverpod 3's auto-retry so the failed build settles immediately.
    final container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [inspectionRepositoryProvider.overrideWithValue(repo)],
    );

    await expectLater(
      container.read(historyControllerProvider.future),
      throwsA(isA<Exception>()),
    );
  });
}
