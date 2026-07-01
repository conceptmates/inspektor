import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/inspection_repository.dart';
import '../models/inspection_template_model.dart';
import '../services/api/api_result.dart';
import '../services/local_inspection_service.dart';
import '../services/reference_media_cache.dart';
import 'inspection_session_controller.dart';

/// Brand+model catalog for the vehicle-details dropdowns.
class VehicleCatalogController extends AsyncNotifier<VehicleCatalog> {
  @override
  Future<VehicleCatalog> build() async {
    final res = await ref.read(inspectionRepositoryProvider).getVehicleModels();
    return switch (res) {
      ApiSuccess(:final data) => data,
      ApiNetworkError() =>
        throw Exception('No connection. Check your network.'),
      _ => throw Exception('Could not load vehicles. Please try again.'),
    };
  }
}

final vehicleCatalogProvider =
    AsyncNotifierProvider<VehicleCatalogController, VehicleCatalog>(
        VehicleCatalogController.new);

typedef SetupState = ({bool isLoading, String? error});

/// Starts a dynamic inspection: calls initialize, seeds the draft session.
class InspectionSetupController extends Notifier<SetupState> {
  @override
  SetupState build() => (isLoading: false, error: null);

  /// Returns true on success (session seeded; caller navigates to inspection).
  Future<bool> start({
    required int brandId,
    required int modelId,
    required Map<String, dynamic> vehicleDetails,
    String? year,
    String? variant,
    String? colour,
    String? transmission,
  }) async {
    state = (isLoading: true, error: null);
    final res =
        await ref.read(inspectionRepositoryProvider).initializeInspection(
              vehicleBrandId: brandId,
              vehicleModelId: modelId,
              year: year,
              variant: variant,
              colour: colour,
              transmission: transmission,
            );
    if (!ref.mounted) return false;

    switch (res) {
      case ApiSuccess(:final data):
        final templateJson = data.template.toJson();
        // Cache the template for this model so the same inspection type can be
        // started offline next time (offline-first start; id minted on sync).
        unawaited(ref
            .read(localInspectionServiceProvider)
            .cacheTemplate(modelId, templateJson));
        // Warm the offline reference-image cache now, while definitely online,
        // so guides stay visible if the inspector drops offline mid-inspection.
        // Fire-and-forget — never blocks the flow.
        unawaited(
            ReferenceMediaCache.prefetch(data.template.referenceImageUrls));
        ref.read(inspectionSessionControllerProvider.notifier).startNew(
              vehicleDetails: vehicleDetails,
              template: templateJson,
              inspectionId: data.inspectionId,
            );
        state = (isLoading: false, error: null);
        return true;
      case ApiNetworkError():
        // Offline-first start: if we've cached this model's template before,
        // start a draft with no server id. The offline queue mints the id and
        // submits on reconnect (see OfflineInspectionController.retry).
        final cached = ref
            .read(localInspectionServiceProvider)
            .getCachedTemplate(modelId);
        if (cached != null) {
          ref.read(inspectionSessionControllerProvider.notifier).startNew(
                vehicleDetails: vehicleDetails,
                template: cached,
                inspectionId: null,
              );
          state = (isLoading: false, error: null);
          return true;
        }
        state = (
          isLoading: false,
          error: 'No connection. Connect once to start this inspection type.'
        );
        return false;
      case ApiUnauthorized():
      case ApiServerError():
        state = (isLoading: false, error: 'Server error. Please try again.');
        return false;
      case ApiBadRequest(:final message):
      case ApiForbidden(:final message):
      case ApiNotFound(:final message):
      case ApiClientError(:final message):
        state = (
          isLoading: false,
          error: message ?? 'Could not start inspection.'
        );
        return false;
    }
  }
}

final inspectionSetupControllerProvider =
    NotifierProvider<InspectionSetupController, SetupState>(
        InspectionSetupController.new);
