import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../models/local_inspection.dart';

/// Unified offline store. One Hive `Box<String>` holds:
///  - the single in-progress DRAFT (under [draftKey], status draft), and
///  - the submission QUEUE (keyed by inspection id, status pending).
///
/// Stored as JSON via [LocalInspection.toJson]. **Bug fix vs old app:** offline
/// records are saved AND queried with the same status (`pending`), so
/// [getPending] always finds them (old app saved 'pending' but queried 'offline').
class LocalInspectionService {
  LocalInspectionService(this._box);

  final Box<String> _box;

  static const String boxName = 'inspections';
  static const String draftKey = '__current_draft__';

  // --- Draft (in-progress working copy) ---

  Future<void> saveDraft(LocalInspection draft) => _put(
        draftKey,
        draft.copyWith(status: LocalStatus.draft, updatedAt: DateTime.now()),
      );

  LocalInspection? getDraft() => _read(draftKey);

  Future<void> clearDraft() => _box.delete(draftKey);

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

  Future<void> delete(String id) => _box.delete(id);

  /// Sync succeeded — remove from queue. (Media-file cleanup happens in P7.)
  Future<void> markSubmitted(String id) => _box.delete(id);

  // --- internals ---

  Iterable<LocalInspection> _queueEntries() => _box.keys
      .where((k) => k != draftKey)
      .map((k) => _read(k as String))
      .whereType<LocalInspection>();

  Future<void> _put(String key, LocalInspection insp) =>
      _box.put(key, jsonEncode(insp.toJson()));

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
  (ref) => LocalInspectionService(Hive.box<String>(LocalInspectionService.boxName)),
);
