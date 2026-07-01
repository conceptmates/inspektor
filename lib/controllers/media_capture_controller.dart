import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/local_inspection.dart';
import '../services/api/api_result.dart';
import '../services/connectivity_service.dart';
import '../services/media_storage_service.dart';
import '../utils/logger.dart';
import 'inspection_session_controller.dart';

/// Handles capture → local save → upload (or queue offline) → write to the
/// draft session. State maps a field key → busy (uploading) flag.
///
/// Every capture runs through [_run], which registers its future so [settle]
/// can await all outstanding work. Submit calls [settle] first: a photo captured
/// moments before submit uploads asynchronously and, until it resolves, is
/// neither an uploaded URL in the draft nor a `pendingMedia` entry — so a
/// straight submit would strip it (httpOnly) and finalise the report without it.
/// [settle] guarantees each capture has landed (URL on success, pending entry on
/// failure) before submit reads the draft and chooses its path.
class MediaCaptureController extends Notifier<Map<String, bool>> {
  // Outstanding capture+upload operations, awaited by [settle] before submit.
  final Set<Future<void>> _inFlight = <Future<void>>{};
  // Per-key busy ref count. A multi-image field reuses ONE key for every photo,
  // so a plain boolean would be cleared by whichever capture finishes first
  // while its siblings are still uploading — making the busy flag (and any guard
  // built on it, e.g. the submit wait-sheet) unreliable. Count up on start,
  // down on finish; the field is busy while the count is > 0.
  final Map<String, int> _busyCount = <String, int>{};

  @override
  Map<String, bool> build() => const {};

  bool isBusy(String key) => (_busyCount[key] ?? 0) > 0;

  /// Whether any capture/upload is still running.
  bool get hasInFlight => _inFlight.isNotEmpty;

  /// Number of capture/upload operations still running.
  int get inFlightCount => _inFlight.length;

  /// Awaits every outstanding capture+upload — including any that start while we
  /// wait (a burst still resolving) — so the draft is fully consistent before
  /// submit chooses its path. Errors are swallowed: each op already logs and
  /// settles its own state via [_guarded]; we only need them finished.
  Future<void> settle() async {
    while (_inFlight.isNotEmpty) {
      await Future.wait([..._inFlight].map((f) => f.catchError((_) {})));
    }
  }

  Future<void> captureImage({
    required String key,
    required String section,
    required String savedOrRawPath,
    bool alreadySaved = false,
  }) =>
      _run(key, () async {
        final saved = alreadySaved
            ? savedOrRawPath
            : await ref.read(mediaStorageServiceProvider).saveImage(savedOrRawPath);
        final url = await _upload(saved, section, key, 'image');
        ref.read(inspectionSessionControllerProvider.notifier).setImage(key, url);
      });

  Future<void> captureVideo({
    required String key,
    required String section,
    required String rawPath,
  }) =>
      _run(key, () async {
        final saved = await ref
            .read(mediaStorageServiceProvider)
            .saveMedia(rawPath, 'inspection_videos');
        final url = await _upload(saved, section, key, 'video');
        ref.read(inspectionSessionControllerProvider.notifier).setVideo(key, url);
      });

  Future<void> captureAudio({
    required String key,
    required String section,
    required String rawPath,
  }) =>
      _run(key, () async {
        final saved = await ref
            .read(mediaStorageServiceProvider)
            .saveMedia(rawPath, 'inspection_audios');
        final url = await _upload(saved, section, key, 'audio');
        ref.read(inspectionSessionControllerProvider.notifier).setAudio(key, url);
      });

  Future<void> captureFile({
    required String key,
    required String section,
    required String rawPath,
  }) =>
      _run(key, () async {
        final saved = await ref
            .read(mediaStorageServiceProvider)
            .saveMedia(rawPath, 'inspection_files');
        final url = await _upload(saved, section, key, 'file');
        ref.read(inspectionSessionControllerProvider.notifier).setFile(key, url);
      });

  Future<void> addImageToMulti({
    required String key,
    required String section,
    required String rawPath,
  }) =>
      _run(key, () async {
        final saved =
            await ref.read(mediaStorageServiceProvider).saveImage(rawPath);
        final url = await _upload(saved, section, key, 'image');
        // Append atomically inside the notifier (read + write in one _update) so
        // concurrent captures for the same multi-image field can never clobber
        // each other's URL. (See InspectionSessionController.appendMultiImage.)
        ref
            .read(inspectionSessionControllerProvider.notifier)
            .appendMultiImage(key, url);
      });

  /// Uploads if online; otherwise (or on failure) keeps the local path and
  /// queues it for sync. Returns the URL (online) or local path (offline).
  Future<String> _upload(
      String localPath, String section, String itemId, String kind) async {
    final draft = ref.read(inspectionSessionControllerProvider);
    // Cheap radio check, not a full reachability probe — the latter adds a
    // multi-host network probe per capture. If the upload fails (incl. "wifi
    // but no internet"), we fall through to the offline queue below.
    final online = await ref.read(connectivityServiceProvider).hasNetwork();
    if (online) {
      final res = await ref.read(inspectionRepositoryProvider).uploadMedia(
            filePath: localPath,
            inspectionId: draft?.inspectionId,
            section: section,
            itemId: itemId,
          );
      if (res is ApiSuccess<String>) return res.data;
    }
    // Offline or upload failed → keep local + queue for later sync.
    ref.read(inspectionSessionControllerProvider.notifier).addPendingMedia(
          PendingMedia(
              localPath: localPath, section: section, itemId: itemId, kind: kind),
        );
    return localPath;
  }

  /// Runs [action], tracking it in [_inFlight] (so [settle] can await it) and
  /// keeping the per-key busy count in sync. The returned future never throws —
  /// errors are caught and logged in [_guarded].
  Future<void> _run(String key, Future<void> Function() action) {
    final future = _guarded(key, action);
    _inFlight.add(future);
    future.whenComplete(() => _inFlight.remove(future));
    return future;
  }

  Future<void> _guarded(String key, Future<void> Function() action) async {
    _bumpBusy(key, 1);
    try {
      await action();
    } catch (e, st) {
      // The callers discard this future, so without a catch a local-save/IO or
      // upload failure would surface as an unhandled async error. Log it (don't
      // let it vanish). ponytail: no user-facing SnackBar yet — busy clears and
      // the live camera returns; add an error entry to state if UX needs it.
      AppLogger.error('media capture failed for $key', error: e, stackTrace: st);
    } finally {
      _bumpBusy(key, -1);
    }
  }

  void _bumpBusy(String key, int delta) {
    final next = (_busyCount[key] ?? 0) + delta;
    if (next > 0) {
      _busyCount[key] = next;
    } else {
      _busyCount.remove(key);
    }
    if (!ref.mounted) return;
    final map = {...state};
    if ((_busyCount[key] ?? 0) > 0) {
      map[key] = true;
    } else {
      map.remove(key);
    }
    state = map;
  }
}

final mediaCaptureControllerProvider =
    NotifierProvider<MediaCaptureController, Map<String, bool>>(
        MediaCaptureController.new);
