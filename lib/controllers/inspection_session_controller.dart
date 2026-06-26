import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/inspection_template_model.dart';
import '../models/local_inspection.dart';
import '../services/local_inspection_service.dart';
import '../services/reference_media_cache.dart';
import '../utils/logger.dart';

/// The in-progress inspection draft (single source of truth for the inspection
/// screen). Replaces the old split ownership between inspection_page widget
/// state and InspectionSessionSnapshot. Persists every change to the draft box.
///
/// ponytail: persists on every mutation (one small JSON put). If autosave proves
/// heavy with many images, add a debounce here — keep the API the same.
class InspectionSessionController extends Notifier<LocalInspection?> {
  static const _uuid = Uuid();

  @override
  LocalInspection? build() => null;

  LocalInspectionService get _svc => ref.read(localInspectionServiceProvider);

  void startNew({
    required Map<String, dynamic> vehicleDetails,
    Map<String, dynamic>? template,
    int? inspectionId,
  }) {
    state = LocalInspection(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      status: LocalStatus.draft,
      vehicleDetails: vehicleDetails,
      inspectionTemplate: template,
      inspectionId: inspectionId,
    );
    _persist();
  }

  /// Resume the saved draft, if any. Returns true if restored.
  bool resumeDraft() {
    final draft = _svc.getDraft();
    if (draft == null || draft.isCompleted) return false;
    state = draft;
    // Re-entering a draft: warm only reference images NOT already on disk
    // (revalidate:false) so resume doesn't re-download the whole guide set —
    // initialize already revalidated them. Fire-and-forget.
    final tmpl = draft.inspectionTemplate;
    if (tmpl != null) {
      try {
        unawaited(ReferenceMediaCache.prefetch(
          InspectionInitializationResponse.fromJson(tmpl).referenceImageUrls,
          revalidate: false,
        ));
      } catch (e, st) {
        AppLogger.error('resume prefetch parse failed',
            error: e, stackTrace: st);
      }
    }
    return true;
  }

  void setSection(int index) => _update((d) => d.copyWith(currentSection: index));

  void setValue(String itemId, String value) =>
      _update((d) => d.copyWith(itemValues: {...d.itemValues, itemId: value}));

  void setText(String itemId, String value) => _update(
      (d) => d.copyWith(textFieldValues: {...d.textFieldValues, itemId: value}));

  void setRemark(String itemId, String value) =>
      _update((d) => d.copyWith(itemRemarks: {...d.itemRemarks, itemId: value}));

  void setImage(String itemId, String path) =>
      _update((d) => d.copyWith(itemImages: {...d.itemImages, itemId: path}));

  void setVideo(String itemId, String path) =>
      _update((d) => d.copyWith(itemVideos: {...d.itemVideos, itemId: path}));

  void setAudio(String itemId, String path) =>
      _update((d) => d.copyWith(itemAudios: {...d.itemAudios, itemId: path}));

  void setFile(String itemId, String path) =>
      _update((d) => d.copyWith(itemFiles: {...d.itemFiles, itemId: path}));

  void setMultiImages(String itemId, List<String> paths) => _update(
      (d) => d.copyWith(itemMultiImages: {...d.itemMultiImages, itemId: paths}));

  // --- media removal (re-capture / discard) ---
  // Each remover also drops the matching offline upload entry (by local path),
  // otherwise a media captured offline then deleted would be re-uploaded and
  // resurrected into the submission body during sync.
  void removeImage(String itemId) => _update((d) => d.copyWith(
        itemImages: {...d.itemImages}..remove(itemId),
        pendingMedia: _dropPending(d, d.itemImages[itemId]),
      ));

  void removeVideo(String itemId) => _update((d) => d.copyWith(
        itemVideos: {...d.itemVideos}..remove(itemId),
        pendingMedia: _dropPending(d, d.itemVideos[itemId]),
      ));

  void removeAudio(String itemId) => _update((d) => d.copyWith(
        itemAudios: {...d.itemAudios}..remove(itemId),
        pendingMedia: _dropPending(d, d.itemAudios[itemId]),
      ));

  void removeFile(String itemId) => _update((d) => d.copyWith(
        itemFiles: {...d.itemFiles}..remove(itemId),
        pendingMedia: _dropPending(d, d.itemFiles[itemId]),
      ));

  void removeMultiImageAt(String itemId, int index) => _update((d) {
        final list = [...(d.itemMultiImages[itemId] ?? const <String>[])];
        if (index < 0 || index >= list.length) return d;
        final removed = list.removeAt(index);
        return d.copyWith(
          itemMultiImages: {...d.itemMultiImages, itemId: list},
          pendingMedia: _dropPending(d, removed),
        );
      });

  /// Drops any queued upload whose local path matches [path] (the value just
  /// removed). No-op when [path] is null or already an uploaded http URL.
  List<PendingMedia> _dropPending(LocalInspection d, String? path) =>
      (path == null || path.isEmpty)
          ? d.pendingMedia
          : d.pendingMedia.where((m) => m.localPath != path).toList();

  void setFlagged(String itemId, List<String> flags) => _update((d) =>
      d.copyWith(itemFlaggedIssues: {...d.itemFlaggedIssues, itemId: flags}));

  void setSubmissionData(Map<String, dynamic> body) =>
      _update((d) => d.copyWith(submissionData: body));

  void addPendingMedia(PendingMedia media) =>
      _update((d) => d.copyWith(pendingMedia: [...d.pendingMedia, media]));

  void setServerInspectionId(int id) =>
      _update((d) => d.copyWith(inspectionId: id));

  /// Inspection finished and submitted (online or queued) — clear the draft.
  Future<void> complete() async {
    await _svc.clearDraft();
    state = null;
  }

  void _update(LocalInspection Function(LocalInspection) change) {
    final cur = state;
    if (cur == null) return;
    state = change(cur).copyWith(updatedAt: DateTime.now());
    _persist();
  }

  void _persist() {
    final s = state;
    if (s != null) _svc.saveDraft(s); // fire-and-forget; Hive put is fast
  }
}

final inspectionSessionControllerProvider =
    NotifierProvider<InspectionSessionController, LocalInspection?>(
        InspectionSessionController.new);
