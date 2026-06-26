import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:inspektor/controllers/inspection_session_controller.dart';
import 'package:inspektor/models/local_inspection.dart';
import 'package:inspektor/services/local_inspection_service.dart';

void main() {
  late Directory dir;
  late Box<String> box;
  late ProviderContainer container;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('hive_session_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('test_session');
    container = ProviderContainer(overrides: [
      localInspectionServiceProvider
          .overrideWithValue(LocalInspectionService(box)),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await box.close();
    await Hive.deleteBoxFromDisk('test_session', path: dir.path);
    dir.deleteSync(recursive: true);
  });

  InspectionSessionController ctrl() =>
      container.read(inspectionSessionControllerProvider.notifier);
  LocalInspection? draft() =>
      container.read(inspectionSessionControllerProvider);

  test('removeImage also drops the matching offline PendingMedia', () {
    final c = ctrl();
    c.startNew(vehicleDetails: const {});
    c.setImage('field1', '/storage/Inspektor/a.jpg');
    c.addPendingMedia(const PendingMedia(
        localPath: '/storage/Inspektor/a.jpg', section: 's', itemId: 'field1'));
    expect(draft()!.pendingMedia, hasLength(1));

    c.removeImage('field1');

    expect(draft()!.itemImages.containsKey('field1'), isFalse);
    // The queued upload must be dropped too, else sync resurrects the deleted
    // image into the submission body.
    expect(draft()!.pendingMedia, isEmpty);
  });

  test('removeMultiImageAt drops only the removed element’s PendingMedia', () {
    final c = ctrl();
    c.startNew(vehicleDetails: const {});
    c.setMultiImages('f', ['/local/1.jpg', '/local/2.jpg']);
    c.addPendingMedia(const PendingMedia(
        localPath: '/local/1.jpg', section: 's', itemId: 'f'));
    c.addPendingMedia(const PendingMedia(
        localPath: '/local/2.jpg', section: 's', itemId: 'f'));

    c.removeMultiImageAt('f', 0);

    expect(draft()!.itemMultiImages['f'], ['/local/2.jpg']);
    final paths = draft()!.pendingMedia.map((m) => m.localPath).toList();
    expect(paths, ['/local/2.jpg']); // only the removed one is gone
  });
}
