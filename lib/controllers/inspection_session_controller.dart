import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/inspection_submission_builder.dart';
import '../data/repositories/inspection_repository.dart';
import '../models/inspection_template_model.dart';
import '../models/local_inspection.dart';
import '../services/api/api_result.dart';
import '../services/connectivity_service.dart';
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

  /// Server-side resume: re-fetch a draft from the API and overlay its saved
  /// answers + already-uploaded media onto the local draft (local edits win;
  /// see [mergeServerData]). Recovers data saved on another session/device, and
  /// uploads any still-local media so it reaches the server. Falls back to the
  /// local-only [resumeDraft] when offline / on error. Returns true if a draft
  /// is now active.
  Future<bool> resumeFromServer(int inspectionId) async {
    final res =
        await ref.read(inspectionRepositoryProvider).resumeInspection(inspectionId);
    if (res is! ApiSuccess<InspectionInit>) {
      // Offline or server error — best-effort local resume so the inspector can
      // still continue from the on-device copy.
      return resumeDraft();
    }
    final init = res.data;

    // Seed from the local draft ONLY when it plausibly belongs to this
    // inspection (its id is null/unstamped or matches) — never merge a DIFFERENT
    // unfinished draft's data into this one (cf. old commit 1ec205c).
    // ponytail: single in-progress draft slot by design; resuming a different
    // server draft replaces the current one. Multi-slot drafts if ever needed.
    final local = _svc.getDraft();
    final belongs = local != null &&
        !local.isCompleted &&
        (local.inspectionId == null || local.inspectionId == inspectionId);
    var base = (belongs ? local : null) ??
        LocalInspection(
          id: _uuid.v4(),
          createdAt: DateTime.now(),
          status: LocalStatus.draft,
          inspectionId: inspectionId,
        );
    base = mergeServerData(
      base.copyWith(
        inspectionId: inspectionId,
        inspectionTemplate: init.template.toJson(),
      ),
      init.template,
    );
    state = base;
    _persist();

    // Re-cache reference guides without re-downloading the whole set.
    try {
      unawaited(ReferenceMediaCache.prefetch(
        init.template.referenceImageUrls,
        revalidate: false,
      ));
    } catch (e, st) {
      AppLogger.error('server resume prefetch failed',
          error: e, stackTrace: st);
    }

    // Push any still-local media to the server now (offline-captured files that
    // never synced). Fire-and-forget — failures stay queued for the next sync.
    unawaited(_uploadPendingOnResume());
    return true;
  }

  /// Uploads each still-local pending media for the active draft and patches the
  /// draft with the returned URL. No-op when offline or nothing is pending.
  Future<void> _uploadPendingOnResume() async {
    final start = state;
    if (start == null || start.pendingMedia.isEmpty) return;
    if (!await ref.read(connectivityServiceProvider).hasInternet()) return;
    final repo = ref.read(inspectionRepositoryProvider);
    for (final m in [...start.pendingMedia]) {
      ApiResult<String> res;
      try {
        res = await repo.uploadMedia(
          filePath: m.localPath,
          inspectionId: state?.inspectionId,
          section: m.section,
          itemId: m.itemId,
        );
      } catch (e, st) {
        AppLogger.error('resume media upload threw for ${m.itemId}',
            error: e, stackTrace: st);
        continue;
      }
      if (res is ApiSuccess<String>) _applyUploadedMedia(m, res.data);
    }
  }

  /// Replace a just-uploaded media's local path with its URL in the matching
  /// draft map (keyed by [PendingMedia.itemId] == fieldKey) and drop it from the
  /// pending queue.
  void _applyUploadedMedia(PendingMedia m, String url) => _update((d) {
        final pending =
            d.pendingMedia.where((x) => x.localPath != m.localPath).toList();
        switch (m.kind) {
          case 'video':
            return d.copyWith(
                pendingMedia: pending,
                itemVideos: {...d.itemVideos, m.itemId: url});
          case 'audio':
            return d.copyWith(
                pendingMedia: pending,
                itemAudios: {...d.itemAudios, m.itemId: url});
          case 'file':
            return d.copyWith(
                pendingMedia: pending,
                itemFiles: {...d.itemFiles, m.itemId: url});
          default:
            final list = [...(d.itemMultiImages[m.itemId] ?? const <String>[])];
            final idx = list.indexOf(m.localPath);
            if (idx >= 0) {
              list[idx] = url;
              return d.copyWith(
                  pendingMedia: pending,
                  itemMultiImages: {...d.itemMultiImages, m.itemId: list});
            }
            return d.copyWith(
                pendingMedia: pending,
                itemImages: {...d.itemImages, m.itemId: url});
        }
      });

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

/// Overlays the server's resumed answers ([InspectionField.initial_*] +
/// [InspectionInitializationResponse.savedFields]) onto [draft], filling ONLY
/// empty fields so an inspector's unsynced local edits are never overwritten.
/// Pure (no I/O) → unit-testable. Mirrors the old `_mergeServerInitialData`.
LocalInspection mergeServerData(
    LocalInspection draft, InspectionInitializationResponse tmpl) {
  final values = {...draft.itemValues};
  final remarks = {...draft.itemRemarks};
  final images = {...draft.itemImages};
  final videos = {...draft.itemVideos};
  final audios = {...draft.itemAudios};
  final files = {...draft.itemFiles};
  final multi = {...draft.itemMultiImages};

  void fillStr(Map<String, String> m, String key, String? v) {
    if (v == null || v.isEmpty) return;
    final cur = m[key];
    if (cur == null || cur.isEmpty) m[key] = v;
  }

  void fillList(String key, List<String> v) {
    if (v.isEmpty) return;
    final cur = multi[key];
    if (cur == null || cur.isEmpty) multi[key] = v;
  }

  for (final section in tmpl.structure.sections) {
    for (final f in section.fields) {
      final key = fieldKey(f);
      // 1) structure-embedded initial_*
      fillStr(values, key, f.initialValue);
      fillStr(remarks, key, f.initialRemarks);
      fillStr(images, key, f.initialImage);
      fillStr(videos, key, f.initialVideo);
      fillStr(audios, key, f.initialAudio);
      fillStr(files, key, f.initialFile);
      fillList(key, f.initialMultiImages);
      // 2) saved_sections / fields[] (keyed by field_id, falling back to id)
      final saved = tmpl.savedFields[key] ??
          (f.fieldId != null ? tmpl.savedFields[f.fieldId!] : null) ??
          (f.id != null ? tmpl.savedFields[f.id!.toString()] : null);
      if (saved != null) {
        fillStr(values, key, saved['value']?.toString());
        fillStr(remarks, key, saved['remarks']?.toString());
        fillStr(images, key, saved['image'] as String?);
        fillStr(videos, key, saved['video'] as String?);
        fillStr(audios, key, saved['audio'] as String?);
        fillStr(files, key, saved['file'] as String?);
        final mi = saved['multiImages'];
        if (mi is List) fillList(key, mi.cast<String>());
      }
    }
  }

  return draft.copyWith(
    itemValues: values,
    itemRemarks: remarks,
    itemImages: images,
    itemVideos: videos,
    itemAudios: audios,
    itemFiles: files,
    itemMultiImages: multi,
  );
}
