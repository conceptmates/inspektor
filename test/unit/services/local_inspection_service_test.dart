import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:inspektor/models/local_inspection.dart';
import 'package:inspektor/services/local_inspection_service.dart';

void main() {
  late Directory dir;
  late Box<String> box;
  late LocalInspectionService svc;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('hive_local_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('test_inspections');
    svc = LocalInspectionService(box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_inspections', path: dir.path);
    dir.deleteSync(recursive: true);
  });

  LocalInspection make(String id, LocalStatus status) => LocalInspection(
        id: id,
        createdAt: DateTime(2026, 6, 22),
        status: status,
      );

  test('draft saved/retrieved and excluded from the pending queue', () async {
    await svc.saveDraft(make('draft-1', LocalStatus.draft));
    expect(svc.getDraft(), isNotNull);
    expect(svc.getPending(), isEmpty);
  });

  test('pending inspection IS found by getPending (status-fix regression)',
      () async {
    await svc.upsertPending(make('a', LocalStatus.pending));
    final pending = svc.getPending();
    expect(pending.length, 1);
    expect(pending.single.id, 'a');
    expect(pending.single.status, LocalStatus.pending);
  });

  test('markSubmitted removes from queue', () async {
    await svc.upsertPending(make('a', LocalStatus.pending));
    await svc.markSubmitted('a');
    expect(svc.getPending(), isEmpty);
  });

  test('getPendingWithMedia only returns entries with pending media', () async {
    await svc.upsertPending(make('no-media', LocalStatus.pending));
    await svc.upsertPending(make('with-media', LocalStatus.pending).copyWith(
      pendingMedia: const [
        PendingMedia(localPath: '/tmp/x.jpg', section: 's', itemId: 'i'),
      ],
    ));
    final withMedia = svc.getPendingWithMedia();
    expect(withMedia.single.id, 'with-media');
  });
}
