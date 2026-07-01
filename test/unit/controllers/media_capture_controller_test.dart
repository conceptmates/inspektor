import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:inspektor/controllers/inspection_session_controller.dart';
import 'package:inspektor/controllers/inspection_submit_controller.dart';
import 'package:inspektor/controllers/media_capture_controller.dart';
import 'package:inspektor/data/repositories/inspection_repository.dart';
import 'package:inspektor/models/local_inspection.dart';
import 'package:inspektor/services/api/api_result.dart';
import 'package:inspektor/services/connectivity_service.dart';
import 'package:inspektor/services/local_inspection_service.dart';
import 'package:inspektor/services/media_storage_service.dart';

class _FakeConn implements ConnectivityService {
  @override
  Future<bool> hasInternet() async => true;
  @override
  Future<bool> hasNetwork() async => true;
  @override
  Stream<List<ConnectivityResult>> get onChanged =>
      const Stream<List<ConnectivityResult>>.empty();
}

/// Returns paths unchanged so tests don't need the image-compress plugin.
class _FakeStorage extends MediaStorageService {
  @override
  Future<String> saveImage(String srcPath) async => srcPath;
  @override
  Future<String> saveMedia(String srcPath, String sub) async => srcPath;
}

/// Each uploadMedia call parks on a Completer so the test controls exactly when
/// (and in what order) uploads finish — the crux of the race being tested.
class _FakeRepo implements InspectionRepository {
  final List<Completer<ApiResult<String>>> uploads = [];
  Map<String, dynamic>? submittedBody;

  @override
  Future<ApiResult<String>> uploadMedia({
    required String filePath,
    int? inspectionId,
    required String section,
    required String itemId,
  }) {
    final c = Completer<ApiResult<String>>();
    uploads.add(c);
    return c.future;
  }

  @override
  Future<ApiResult<SubmitResult>> submitInspectionById(
      Object id, Map<String, dynamic> body) async {
    submittedBody = body;
    return const ApiSuccess((inspectionId: 1, redirectUrl: null, uuid: null));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late Box<String> box;
  late _FakeRepo repo;
  late ProviderContainer container;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('hive_media_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('test_media');
    repo = _FakeRepo();
    container = ProviderContainer(overrides: [
      localInspectionServiceProvider
          .overrideWithValue(LocalInspectionService(box)),
      mediaStorageServiceProvider.overrideWithValue(_FakeStorage()),
      connectivityServiceProvider.overrideWithValue(_FakeConn()),
      inspectionRepositoryProvider.overrideWithValue(repo),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await box.close();
    await Hive.deleteBoxFromDisk('test_media', path: dir.path);
    dir.deleteSync(recursive: true);
  });

  MediaCaptureController capture() =>
      container.read(mediaCaptureControllerProvider.notifier);
  InspectionSessionController session() =>
      container.read(inspectionSessionControllerProvider.notifier);
  LocalInspection? draft() =>
      container.read(inspectionSessionControllerProvider);

  test('settle() waits for an in-flight upload, then the URL is in the draft',
      () async {
    session().startNew(vehicleDetails: const {});
    unawaited(capture().captureImage(
        key: 'k', section: 's', savedOrRawPath: '/a.jpg', alreadySaved: true));
    await pumpEventQueue();

    // Upload not done yet: busy, and no URL recorded.
    expect(capture().isBusy('k'), isTrue);
    expect(capture().hasInFlight, isTrue);
    expect(draft()!.itemImages['k'], isNull);

    repo.uploads.single.complete(const ApiSuccess('https://cdn/a.jpg'));
    await capture().settle();

    expect(draft()!.itemImages['k'], 'https://cdn/a.jpg');
    expect(capture().isBusy('k'), isFalse);
    expect(capture().hasInFlight, isFalse);
  });

  test('concurrent multi-image captures all survive (atomic append)', () async {
    session().startNew(vehicleDetails: const {});
    // Two fire-and-forget captures for the SAME field, like rapid HUD taps.
    unawaited(
        capture().addImageToMulti(key: 'm', section: 's', rawPath: '/1.jpg'));
    unawaited(
        capture().addImageToMulti(key: 'm', section: 's', rawPath: '/2.jpg'));
    await pumpEventQueue();
    expect(repo.uploads.length, 2);

    // Complete out of order — the second upload finishes first.
    repo.uploads[1].complete(const ApiSuccess('https://cdn/2.jpg'));
    repo.uploads[0].complete(const ApiSuccess('https://cdn/1.jpg'));
    await capture().settle();

    final imgs = draft()!.itemMultiImages['m']!;
    expect(imgs.length, 2, reason: 'neither photo may overwrite the other');
    expect(imgs.toSet(), {'https://cdn/1.jpg', 'https://cdn/2.jpg'});
  });

  test('busy stays true until ALL same-key captures finish (ref count)',
      () async {
    session().startNew(vehicleDetails: const {});
    unawaited(
        capture().addImageToMulti(key: 'm', section: 's', rawPath: '/1.jpg'));
    unawaited(
        capture().addImageToMulti(key: 'm', section: 's', rawPath: '/2.jpg'));
    await pumpEventQueue();
    expect(capture().isBusy('m'), isTrue);

    repo.uploads[0].complete(const ApiSuccess('https://cdn/1.jpg'));
    await pumpEventQueue();
    // A plain boolean flag would read false here — the second upload is still
    // running, so the ref-counted flag must remain busy.
    expect(capture().isBusy('m'), isTrue);

    repo.uploads[1].complete(const ApiSuccess('https://cdn/2.jpg'));
    await capture().settle();
    expect(capture().isBusy('m'), isFalse);
  });

  test('submit() blocks on an in-flight upload and includes the photo',
      () async {
    final templateJson = {
      'structure': {
        'sections': [
          {
            'id': 1,
            'name': 'exterior',
            'order': 1,
            'fields': [
              {
                'id': 9,
                'field_id': 'photo1',
                'title': 'Photo',
                'field_type': 'image',
                'order': 1,
              },
            ],
          },
        ],
      },
    };
    session().startNew(
        vehicleDetails: const {'registration_number': 'KA01AB1234'},
        template: templateJson,
        inspectionId: 42);

    // Capture a photo whose upload is still in flight, then submit immediately.
    unawaited(capture().captureImage(
        key: 'photo1',
        section: 'exterior',
        savedOrRawPath: '/p.jpg',
        alreadySaved: true));
    await pumpEventQueue();

    var submitDone = false;
    final submitFuture = container
        .read(inspectionSubmitControllerProvider.notifier)
        .submit()
        .then((_) => submitDone = true);
    await pumpEventQueue();

    // Submit must NOT have finalised while the upload is unresolved.
    expect(submitDone, isFalse);
    expect(repo.submittedBody, isNull);

    repo.uploads.single.complete(const ApiSuccess('https://cdn/p.jpg'));
    await submitFuture;

    expect(submitDone, isTrue);
    final items = ((repo.submittedBody!['inspection_data'] as Map)['exterior']
        as Map)['items'] as List;
    // The once-in-flight photo made it into the submitted body as its URL.
    expect(items.single['imagePath'], 'https://cdn/p.jpg');
  });
}
