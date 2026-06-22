import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/inspection_submission_builder.dart';
import '../data/repositories/inspection_repository.dart';
import '../models/inspection_template_model.dart';
import '../models/local_inspection.dart';
import '../services/api/api_result.dart';
import '../services/connectivity_service.dart';
import '../services/local_inspection_service.dart';
import 'inspection_session_controller.dart';

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
    final body = buildSubmissionBody(draft: draft, template: template);

    state = (isSubmitting: true, error: null);

    final online = await ref.read(connectivityServiceProvider).hasInternet();
    if (online) {
      final res =
          await ref.read(inspectionRepositoryProvider).submitInspection(body);
      if (!ref.mounted) return (queued: false, result: null, error: null);
      if (res is ApiSuccess<SubmitResult>) {
        await ref.read(inspectionSessionControllerProvider.notifier).complete();
        state = (isSubmitting: false, error: null);
        return (queued: false, result: res.data, error: null);
      }
      // online submit failed → fall through to offline queue (no data loss)
    }

    await _queueOffline(draft, body);
    if (!ref.mounted) return (queued: true, result: null, error: null);
    await ref.read(inspectionSessionControllerProvider.notifier).complete();
    state = (isSubmitting: false, error: null);
    return (queued: true, result: null, error: null);
  }

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
