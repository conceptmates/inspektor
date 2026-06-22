import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/local_inspection.dart';
import '../services/api/api_result.dart';
import '../services/connectivity_service.dart';
import '../services/local_inspection_service.dart';

typedef OfflineState = ({
  List<LocalInspection> items,
  bool isLoading,
  Map<String, bool> submitting,
});

/// The offline submission queue + connectivity-triggered auto-sync.
/// Retry uploads pending media, rewrites the body with returned URLs, submits,
/// and removes the record on success.
class OfflineInspectionController extends Notifier<OfflineState> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _autoSyncing = false;

  LocalInspectionService get _svc => ref.read(localInspectionServiceProvider);

  @override
  OfflineState build() {
    final conn = ref.read(connectivityServiceProvider);
    _sub = conn.onChanged.listen((results) async {
      if (results.every((r) => r == ConnectivityResult.none)) return;
      if (await conn.hasInternet()) await syncAll();
    });
    ref.onDispose(() => _sub?.cancel());
    return (items: _svc.getPending(), isLoading: false, submitting: const {});
  }

  void reload() => state = (
        items: _svc.getPending(),
        isLoading: false,
        submitting: state.submitting,
      );

  Future<void> syncAll() async {
    if (_autoSyncing) return;
    _autoSyncing = true;
    try {
      for (final insp in _svc.getPending()) {
        if (state.submitting[insp.id] == true) continue;
        await retry(insp);
      }
    } finally {
      _autoSyncing = false;
    }
  }

  Future<void> retry(LocalInspection inspection) async {
    _setSubmitting(inspection.id, true);
    final repo = ref.read(inspectionRepositoryProvider);

    var current = inspection;
    var body = Map<String, dynamic>.from(current.submissionData ?? const {});
    final stillPending = <PendingMedia>[];

    for (final media in current.pendingMedia) {
      final res = await repo.uploadMedia(
        filePath: media.localPath,
        inspectionId: current.inspectionId,
        section: media.section,
        itemId: media.itemId,
        fieldName: media.kind == 'image' ? 'image' : media.kind,
      );
      if (res is ApiSuccess<String>) {
        _patchBody(body, media, res.data);
      } else {
        stillPending.add(media); // retry next time
      }
    }

    current =
        current.copyWith(pendingMedia: stillPending, submissionData: body);
    await _svc.upsertPending(current); // persist progress

    final submitRes = await repo.submitInspection(body);
    if (!ref.mounted) return;
    if (submitRes is ApiSuccess) {
      await _svc.markSubmitted(inspection.id);
    }
    _clearSubmitting(inspection.id);
    reload();
  }

  Future<void> delete(String id) async {
    await _svc.delete(id);
    reload();
  }

  void _setSubmitting(String id, bool v) => state = (
        items: state.items,
        isLoading: state.isLoading,
        submitting: {...state.submitting, id: v},
      );

  void _clearSubmitting(String id) {
    final next = {...state.submitting}..remove(id);
    state = (items: state.items, isLoading: state.isLoading, submitting: next);
  }

  /// Rewrite the submission body item paths (local → uploaded URL).
  void _patchBody(Map<String, dynamic> body, PendingMedia m, String url) {
    final data = body['inspection_data'];
    if (data is! Map) return;
    final section = data[m.section];
    if (section is Map) {
      _patchItems(section['items'], m, url);
    } else {
      for (final s in data.values) {
        if (s is Map) _patchItems(s['items'], m, url);
      }
    }
  }

  void _patchItems(dynamic items, PendingMedia m, String url) {
    if (items is! List) return;
    for (final item in items) {
      if (item is! Map || item['fieldId'] != m.itemId) continue;
      switch (m.kind) {
        case 'video':
          item['videoPath'] = url;
        case 'audio':
          item['audioPath'] = url;
        case 'file':
          item['filePath'] = url;
        default:
          final multi = item['multiImages'];
          if (multi is List) {
            final idx = multi.indexWhere(
                (e) => e is String && !e.startsWith('http'));
            if (idx >= 0) {
              multi[idx] = url;
            } else {
              item['imagePath'] = url;
            }
          } else {
            item['imagePath'] = url;
          }
      }
    }
  }
}

final offlineInspectionControllerProvider =
    NotifierProvider<OfflineInspectionController, OfflineState>(
        OfflineInspectionController.new);
