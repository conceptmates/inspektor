import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/local_inspection.dart';
import '../services/api/api_result.dart';
import '../services/connectivity_service.dart';
import '../services/media_storage_service.dart';
import 'inspection_session_controller.dart';

/// Handles capture → local save → upload (or queue offline) → write to the
/// draft session. State maps a field key → busy (uploading) flag.
class MediaCaptureController extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => const {};

  bool isBusy(String key) => state[key] ?? false;

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
        final current =
            ref.read(inspectionSessionControllerProvider)?.itemMultiImages[key] ??
                const [];
        ref
            .read(inspectionSessionControllerProvider.notifier)
            .setMultiImages(key, [...current, url]);
      });

  /// Uploads if online; otherwise (or on failure) keeps the local path and
  /// queues it for sync. Returns the URL (online) or local path (offline).
  Future<String> _upload(
      String localPath, String section, String itemId, String kind) async {
    final draft = ref.read(inspectionSessionControllerProvider);
    final online = await ref.read(connectivityServiceProvider).hasInternet();
    if (online) {
      final res = await ref.read(inspectionRepositoryProvider).uploadMedia(
            filePath: localPath,
            inspectionId: draft?.inspectionId,
            section: section,
            itemId: itemId,
            fieldName: kind == 'image' ? 'image' : kind,
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

  Future<void> _run(String key, Future<void> Function() action) async {
    state = {...state, key: true};
    try {
      await action();
    } finally {
      if (ref.mounted) {
        final next = {...state}..remove(key);
        state = next;
      }
    }
  }
}

final mediaCaptureControllerProvider =
    NotifierProvider<MediaCaptureController, Map<String, bool>>(
        MediaCaptureController.new);
