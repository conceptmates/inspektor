import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/local_inspection.dart';
import '../services/local_inspection_service.dart';

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
