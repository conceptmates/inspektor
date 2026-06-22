import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inspection_history_model.dart';
import '../../models/inspection_stats_model.dart';
import '../../models/inspection_template_model.dart';
import '../../models/pagination_data_model.dart';
import '../../models/vehicle_model.dart';
import '../../services/api/api_result.dart';
import '../../services/api/api_wrapper.dart';
import '../../services/api_list.dart';
import '../../services/dio_client.dart';

typedef VehicleCatalog = ({List<VehicleModel> models, List<VehicleBrand> brands});
typedef InspectionInit = ({
  InspectionInitializationResponse template,
  int? inspectionId,
});
typedef SubmitResult = ({int? inspectionId, String? redirectUrl, String? uuid});
typedef HistoryPage = ({
  List<InspectionHistory> items,
  PaginationData pagination,
});

/// All inspection network ops. Returns typed [ApiResult]s.
class InspectionRepository {
  InspectionRepository(this._api);
  final ApiWrapper _api;

  /// GET /admin/vehicles/models — catalog + derived sorted brand list.
  Future<ApiResult<VehicleCatalog>> getVehicleModels() async {
    final res = await _api.get<dynamic>(APIList.vehicleModels);
    if (res is! ApiSuccess) return castApiError(res);
    final raw = res.data;
    final list = raw is List
        ? raw
        : (raw is Map ? (raw['data'] as List? ?? const []) : const []);
    final models = list
        .map((e) => VehicleModel.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return ApiSuccess((models: models, brands: _deriveBrands(models)));
  }

  /// POST /dynamic-inspections/initialize — template + inspection_id.
  Future<ApiResult<InspectionInit>> initializeInspection({
    required int vehicleBrandId,
    required int vehicleModelId,
    String? year,
    String? variant,
    String? colour,
    String? transmission,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      APIList.initializeInspection,
      body: {
        'vehicle_brand_id': vehicleBrandId,
        'vehicle_model_id': vehicleModelId,
        'year': ?year,
        'variant': ?variant,
        'color': ?colour,
        'transmission': ?transmission,
      },
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    final body = res.data;
    final data = (body['data'] as Map?)?.cast<String, dynamic>() ?? body;
    return ApiSuccess((
      template: InspectionInitializationResponse.fromJson(data),
      inspectionId:
          (body['inspection_id'] ?? data['inspection_id'] ?? data['id']) as int?,
    ));
  }

  /// POST /ulip/vehicle-details — RC lookup for the `regno` field.
  Future<ApiResult<Map<String, dynamic>>> verifyRegistration(
      String vehicleNumber) async {
    final res = await _api.post<Map<String, dynamic>>(
      APIList.ulipVehicleDetails,
      body: {'vehiclenumber': vehicleNumber},
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    final data =
        (res.data['data'] as Map?)?.cast<String, dynamic>() ?? res.data;
    return ApiSuccess(data);
  }

  /// POST /inspection/upload-image (multipart) — returns the stored media URL.
  /// Used for image, video, audio and file (via [fieldName]).
  Future<ApiResult<String>> uploadMedia({
    required String filePath,
    int? inspectionId,
    required String section,
    required String itemId,
    String fieldName = 'image',
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      'section': section,
      'itemId': itemId,
      'inspection_id': ?inspectionId,
    });
    final res = await _api.upload<Map<String, dynamic>>(
      APIList.uploadMedia,
      formData: formData,
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    final b = res.data;
    final media = b['imagePath'] ??
        b['videoPath'] ??
        b['audioPath'] ??
        b['filePath'] ??
        b['url'] ??
        b['path'] ??
        (b['data'] is Map ? (b['data']['url'] ?? b['data']['path']) : null);
    final url = media is Map
        ? (media['url'] ?? media['path'])?.toString()
        : media?.toString();
    if (url == null) return const ApiBadRequest(message: 'Upload failed');
    return ApiSuccess(url);
  }

  /// POST /dynamic-inspections — final submit.
  Future<ApiResult<SubmitResult>> submitInspection(
      Map<String, dynamic> body) async {
    final res = await _api.post<Map<String, dynamic>>(
      APIList.submitInspection,
      body: body,
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    final b = res.data;
    final data = (b['data'] as Map?)?.cast<String, dynamic>() ?? b;
    return ApiSuccess((
      inspectionId: (data['inspection_id'] ?? b['inspection_id']) as int?,
      redirectUrl: (data['redirect_url'] ?? b['redirect_url'])?.toString(),
      uuid: (data['uuid'] ?? b['uuid'])?.toString(),
    ));
  }

  /// PUT /inspections/{id} — resend/update answers (offline sync path).
  Future<ApiResult<Map<String, dynamic>>> updateInspection({
    required Object id,
    required Map<String, dynamic> body,
  }) async {
    final res = await _api.put<Map<String, dynamic>>(
      APIList.updateInspection(id),
      body: body,
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    return ApiSuccess(res.data);
  }

  /// GET /dynamic-inspections?page= — full history list.
  Future<ApiResult<HistoryPage>> getHistory(int page) =>
      _historyPage(APIList.inspectionHistory, page);

  /// GET /dynamic-inspections/my-history?page= — current inspector's reports.
  Future<ApiResult<HistoryPage>> getMyHistory(int page) =>
      _historyPage(APIList.myHistory, page);

  /// GET /dynamic-inspections/stats — dashboard stats.
  Future<ApiResult<InspectionStats>> getStats({
    String period = 'daily',
    String? from,
    String? to,
  }) async {
    final res = await _api.get<Map<String, dynamic>>(
      APIList.inspectionStats,
      query: {'period': period, 'from': ?from, 'to': ?to},
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    final data =
        (res.data['data'] as Map?)?.cast<String, dynamic>() ?? res.data;
    return ApiSuccess(InspectionStats.fromApi(data));
  }

  // --- helpers ---

  Future<ApiResult<HistoryPage>> _historyPage(String path, int page) async {
    final res = await _api.get<Map<String, dynamic>>(
      path,
      query: {'page': page},
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);
    final body = res.data;
    final data = body['data'];
    List<dynamic> rawList;
    Map<String, dynamic>? pag;
    if (data is Map) {
      rawList = (data['inspections'] ?? data['data'] ?? const []) as List? ??
          const [];
      pag = (data['pagination'] as Map?)?.cast<String, dynamic>() ??
          data.cast<String, dynamic>();
    } else if (data is List) {
      rawList = data;
      pag = (body['pagination'] as Map?)?.cast<String, dynamic>();
    } else {
      rawList = (body['inspections'] as List?) ?? const [];
      pag = (body['pagination'] as Map?)?.cast<String, dynamic>();
    }
    return ApiSuccess((
      items: rawList
          .map((e) =>
              InspectionHistory.fromApi((e as Map).cast<String, dynamic>()))
          .toList(),
      pagination:
          pag != null ? PaginationData.fromJson(pag) : const PaginationData(),
    ));
  }

  List<VehicleBrand> _deriveBrands(List<VehicleModel> models) {
    final byId = <int, VehicleBrand>{};
    for (final m in models) {
      if (m.brand != null) byId[m.brand!.id] = m.brand!;
    }
    return byId.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  static Map<String, dynamic> _asMap(dynamic d) =>
      (d as Map).cast<String, dynamic>();
}

final inspectionRepositoryProvider = Provider<InspectionRepository>(
  (ref) => InspectionRepository(ref.read(apiWrapperProvider)),
);
