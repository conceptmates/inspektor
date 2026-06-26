import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:inspektor/controllers/offline_inspection_controller.dart';
import 'package:inspektor/data/repositories/inspection_repository.dart';
import 'package:inspektor/models/local_inspection.dart';
import 'package:inspektor/services/api/api_result.dart';
import 'package:inspektor/services/connectivity_service.dart';
import 'package:inspektor/services/local_inspection_service.dart';

class _FakeConn implements ConnectivityService {
  @override
  Future<bool> hasInternet() async => true;
  @override
  Stream<List<ConnectivityResult>> get onChanged =>
      Stream<List<ConnectivityResult>>.empty();
}

class _FakeRepo implements InspectionRepository {
  _FakeRepo(this.uploadByItem);
  final Map<String, ApiResult<String>> uploadByItem;
  bool submitCalled = false;

  @override
  Future<ApiResult<String>> uploadMedia({
    required String filePath,
    int? inspectionId,
    required String section,
    required String itemId,
  }) async =>
      uploadByItem[itemId] ?? const ApiNetworkError();

  @override
  Future<ApiResult<SubmitResult>> submitInspectionById(
      Object id, Map<String, dynamic> body) async {
    submitCalled = true;
    return const ApiSuccess(
        (inspectionId: 1, redirectUrl: null, uuid: null));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late Box<String> box;
  late LocalInspectionService svc;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('hive_offline_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('test_offline');
    svc = LocalInspectionService(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_offline', path: dir.path);
    dir.deleteSync(recursive: true);
  });

  LocalInspection make() => LocalInspection(
        id: 'insp1',
        createdAt: DateTime(2026, 6, 22),
        status: LocalStatus.pending,
        inspectionId: 99,
        // jsonDecode (like the real Hive-loaded body) yields modifiable nested
        // maps that _patchItems can rewrite.
        submissionData: jsonDecode(
          '{"inspection_data":{"s":{"items":['
          '{"fieldId":"a","imagePath":"/local/a.jpg"},'
          '{"fieldId":"b","imagePath":"/local/b.jpg"}]}}}',
        ) as Map<String, dynamic>,
        pendingMedia: const [
          PendingMedia(localPath: '/local/a.jpg', section: 's', itemId: 'a'),
          PendingMedia(localPath: '/local/b.jpg', section: 's', itemId: 'b'),
        ],
      );

  test('partial media upload does NOT finalise or delete the queue entry', () async {
    final pending = make();
    await svc.upsertPending(pending);

    // 'a' uploads, 'b' fails (flaky network).
    final repo = _FakeRepo({'a': const ApiSuccess('https://cdn/a.jpg')});
    final container = ProviderContainer(overrides: [
      localInspectionServiceProvider.overrideWithValue(svc),
      inspectionRepositoryProvider.overrideWithValue(repo),
      connectivityServiceProvider.overrideWithValue(_FakeConn()),
    ]);
    addTearDown(container.dispose);

    await container
        .read(offlineInspectionControllerProvider.notifier)
        .retry(pending);

    // Blocker fix: must not submit while any media is still pending, and the
    // entry must survive (markSubmitted would delete it → permanent loss).
    expect(repo.submitCalled, isFalse);
    final remaining = svc.getPending();
    expect(remaining, hasLength(1));
    expect(remaining.single.pendingMedia.map((m) => m.itemId).toList(), ['b']);
  });

  test('all media uploaded → submits and clears the queue entry', () async {
    final pending = make();
    await svc.upsertPending(pending);

    final repo = _FakeRepo({
      'a': const ApiSuccess('https://cdn/a.jpg'),
      'b': const ApiSuccess('https://cdn/b.jpg'),
    });
    final container = ProviderContainer(overrides: [
      localInspectionServiceProvider.overrideWithValue(svc),
      inspectionRepositoryProvider.overrideWithValue(repo),
      connectivityServiceProvider.overrideWithValue(_FakeConn()),
    ]);
    addTearDown(container.dispose);

    await container
        .read(offlineInspectionControllerProvider.notifier)
        .retry(pending);

    expect(repo.submitCalled, isTrue);
    expect(svc.getPending(), isEmpty); // markSubmitted removed it
  });
}
