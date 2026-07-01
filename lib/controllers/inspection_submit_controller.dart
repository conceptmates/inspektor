import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/inspection_submission_builder.dart';
import '../data/repositories/inspection_repository.dart';
import '../models/inspection_template_model.dart';
import '../models/local_inspection.dart';
import '../services/api/api_result.dart';
import '../services/connectivity_service.dart';
import '../services/local_inspection_service.dart';
import 'inspection_session_controller.dart';
import 'offline_inspection_controller.dart';

typedef SubmitState = ({bool isSubmitting, String? error});
typedef SubmitOutcome = ({bool queued, SubmitResult? result, String? error});

/// Finalizes an inspection: online submit, or queue offline (or on online
/// failure). On success the draft is cleared.
class InspectionSubmitController extends Notifier<SubmitState> {
  @override
  SubmitState build() => (isSubmitting: false, error: null);

  Future<SubmitOutcome> submit() async {
    final draft = ref.read(inspectionSessionControllerProvider);
    if (draft == null) {
      return (queued: false, result: null, error: 'No active inspection');
    }

    final template = draft.inspectionTemplate != null
        ? InspectionInitializationResponse.fromJson(draft.inspectionTemplate!)
        : const InspectionInitializationResponse();

    state = (isSubmitting: true, error: null);

    final online = await ref.read(connectivityServiceProvider).hasInternet();
    // Media that still has a local path (captured offline, or an upload that
    // failed mid-session) must be uploaded before finalising — a direct submit
    // would strip those paths (httpOnly) and finalise the media blank, then
    // clear the draft. Route through the queue so sync uploads + patches first.
    final hasUnuploadedMedia = draft.pendingMedia.isNotEmpty;
    if (online && !hasUnuploadedMedia) {
      // Finalise the existing server draft (minted at initialize). The full body
      // is sent so anything not yet save-stepped is persisted in the same call.
      // httpOnly: strip local media paths — only uploaded URLs are valid here.
      final id = draft.inspectionId;
      if (id == null) {
        // No server draft id — initialize never completed. Don't silently create
        // a duplicate; surface it so the user can restart the inspection.
        const msg = 'Inspection was not initialized. Please restart it.';
        state = (isSubmitting: false, error: msg);
        return (queued: false, result: null, error: msg);
      }
      final serverBody = buildSubmissionBody(
          draft: draft, template: template, httpOnly: true);
      final res =
          await ref.read(inspectionRepositoryProvider).submitInspectionById(
                id,
                serverBody,
              );
      if (!ref.mounted) return (queued: false, result: null, error: null);
      if (res is ApiSuccess<SubmitResult>) {
        await ref.read(inspectionSessionControllerProvider.notifier).complete();
        state = (isSubmitting: false, error: null);
        return (queued: false, result: res.data, error: null);
      }
      // The server was reachable but rejected the request (validation / 5xx).
      // Surface the message and keep the draft so the user can fix and resubmit
      // — do NOT silently queue it as "saved offline". Only a genuine network
      // error (below) falls through to the offline queue.
      if (res is! ApiNetworkError) {
        final msg = _errorMessage(res) ?? 'Failed to submit inspection';
        state = (isSubmitting: false, error: msg);
        return (queued: false, result: null, error: msg);
      }
    }

    // Offline queue: keep local media paths so sync can upload + patch them.
    final queueBody = buildSubmissionBody(draft: draft, template: template);
    await _queueOffline(draft, queueBody);
    if (!ref.mounted) return (queued: true, result: null, error: null);
    await ref.read(inspectionSessionControllerProvider.notifier).complete();
    state = (isSubmitting: false, error: null);
    // If we're online but queued only because media still needs uploading, kick
    // an immediate sync so it doesn't sit until the next connectivity change.
    if (online && hasUnuploadedMedia) {
      unawaited(
          ref.read(offlineInspectionControllerProvider.notifier).syncAll());
    }
    return (queued: true, result: null, error: null);
  }

  String? _errorMessage(ApiResult<Object?> r) => switch (r) {
        ApiBadRequest(:final message) => message,
        ApiUnauthorized(:final message) => message,
        ApiForbidden(:final message) => message,
        ApiNotFound(:final message) => message,
        ApiClientError(:final message) => message,
        ApiServerError(:final message) => message,
        ApiNetworkError(:final message) => message,
        ApiSuccess() => null,
      };

  Future<void> _queueOffline(LocalInspection draft, Map<String, dynamic> body) {
    final queued = draft.copyWith(
      status: LocalStatus.pending,
      submissionData: body,
      updatedAt: DateTime.now(),
      // ponytail: pending media is derived during sync (P7) from local paths.
    );
    return ref.read(localInspectionServiceProvider).upsertPending(queued);
  }
}

final inspectionSubmitControllerProvider =
    NotifierProvider<InspectionSubmitController, SubmitState>(
        InspectionSubmitController.new);
