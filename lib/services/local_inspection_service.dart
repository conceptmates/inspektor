import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../models/local_inspection.dart';
import 'media_storage_service.dart';

/// Unified offline store. One Hive `Box<String>` holds:
///  - the single in-progress DRAFT (under [draftKey], status draft), and
///  - the submission QUEUE (keyed by inspection id, status pending).
///
/// Stored as JSON via [LocalInspection.toJson]. **Bug fix vs old app:** offline
/// records are saved AND queried with the same status (`pending`), so
/// [getPending] always finds them (old app saved 'pending' but queried 'offline').
class LocalInspectionService {
  LocalInspectionService(this._box, [MediaStorageService? media])
      : _media = media ?? MediaStorageService();

  final Box<String> _box;
  final MediaStorageService _media;

  static const String boxName = 'inspections';
  static const String draftKey = '__current_draft__';

  // --- Draft (in-progress working copy) ---

  Future<void> saveDraft(LocalInspection draft) => _put(
        draftKey,
        draft.copyWith(status: LocalStatus.draft, updatedAt: DateTime.now()),
      );

  LocalInspection? getDraft() => _read(draftKey);

  Future<void> clearDraft() async {
    final d = getDraft();
    await _box.delete(draftKey);
    // Keep the JSON mirror when a queued (pending) entry shares this id: an
    // offline submit upserts the pending item then immediately clears the draft,
    // and both key their mirror by inspection id. Deleting here would erase the
    // queue item's mirror. The mirror is removed later by delete()/markSubmitted.
    if (d != null && getById(d.id) == null) unawaited(_media.deleteJson(d.id));
  }

  bool hasFreshDraft({Duration maxAge = const Duration(hours: 24)}) {
    final d = getDraft();
    if (d == null || d.isCompleted) return false;
    return DateTime.now().difference(d.updatedAt ?? d.createdAt) < maxAge;
  }

  // --- Submission queue ---

  /// Save/replace a pending (offline) inspection. Always status = pending.
  Future<void> upsertPending(LocalInspection insp) =>
      _put(insp.id, insp.copyWith(status: LocalStatus.pending));

  LocalInspection? getById(String id) => _read(id);

  List<LocalInspection> getPending() {
    final list = _queueEntries()
        .where((i) => i.status == LocalStatus.pending)
        .toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<LocalInspection> getPendingWithMedia() =>
      getPending().where((i) => i.hasPendingMedia).toList();

  Future<void> delete(String id) async {
    await _box.delete(id);
    unawaited(_media.deleteJson(id));
  }

  /// Sync succeeded — remove from queue + its JSON mirror.
  /// (Media-file cleanup happens in P7.)
  Future<void> markSubmitted(String id) => delete(id);

  // --- Cached template (offline-first start) ---
  // Stored under a reserved key prefix so it never parses as a queue entry.

  static String _templateKey(Object modelId) => '__template_$modelId';

  /// Remember the last template for a vehicle model so an inspection of the same
  /// type can be started with no network (id minted later, on sync).
  Future<void> cacheTemplate(Object modelId, Map<String, dynamic> templateJson) =>
      _box.put(_templateKey(modelId), jsonEncode(templateJson));

  Map<String, dynamic>? getCachedTemplate(Object modelId) {
    final raw = _box.get(_templateKey(modelId));
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // --- internals ---

  Iterable<LocalInspection> _queueEntries() => _box.keys
      .where((k) => k != draftKey && !(k as String).startsWith('__template_'))
      .map((k) => _read(k as String))
      .whereType<LocalInspection>();

  Future<void> _put(String key, LocalInspection insp) async {
    final json = jsonEncode(insp.toJson());
    await _box.put(key, json);
    unawaited(_media.writeJson(insp.id, json)); // visible mirror, best-effort
  }

  LocalInspection? _read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    try {
      return LocalInspection.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

final localInspectionServiceProvider = Provider<LocalInspectionService>(
  (ref) => LocalInspectionService(
    Hive.box<String>(LocalInspectionService.boxName),
    ref.read(mediaStorageServiceProvider),
  ),
);
