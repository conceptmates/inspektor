import 'package:dio/dio.dart';

import 'api_result.dart';

/// Maps raw response body → typed T. Receives the full decoded body
/// (the API envelope is inconsistent, so each caller extracts what it needs).
typedef ResultParser<T> = T Function(dynamic data);

/// Single wrapper for all HTTP. Returns sealed [ApiResult]. Depends on Dio
/// (provided via dioClientProvider); app code never calls Dio directly.
/// `useAuth` controls whether the auth interceptor attaches the bearer token.
class ApiWrapper {
  ApiWrapper(this._dio);
  final Dio _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    bool useAuth = true,
    ResultParser<T>? fromJson,
  }) =>
      _run(() => _dio.get(path, queryParameters: query, options: _opts(useAuth)),
          fromJson);

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool useAuth = true,
    ResultParser<T>? fromJson,
  }) =>
      _run(
          () => _dio.post(path,
              data: body, queryParameters: query, options: _opts(useAuth)),
          fromJson);

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? body,
    bool useAuth = true,
    ResultParser<T>? fromJson,
  }) =>
      _run(() => _dio.put(path, data: body, options: _opts(useAuth)), fromJson);

  Future<ApiResult<T>> patch<T>(
    String path, {
    Object? body,
    bool useAuth = true,
    ResultParser<T>? fromJson,
  }) =>
      _run(() => _dio.patch(path, data: body, options: _opts(useAuth)), fromJson);

  Future<ApiResult<T>> delete<T>(
    String path, {
    Object? body,
    bool useAuth = true,
    ResultParser<T>? fromJson,
  }) =>
      _run(
          () => _dio.delete(path, data: body, options: _opts(useAuth)), fromJson);

  /// Multipart upload (image/video/audio/file).
  Future<ApiResult<T>> upload<T>(
    String path, {
    required FormData formData,
    bool useAuth = true,
    ResultParser<T>? fromJson,
  }) =>
      _run(() => _dio.post(path, data: formData, options: _opts(useAuth)),
          fromJson);

  Options _opts(bool useAuth) => Options(extra: {'useAuth': useAuth});

  Future<ApiResult<T>> _run<T>(
    Future<Response<dynamic>> Function() request,
    ResultParser<T>? fromJson,
  ) async {
    try {
      final res = await request();
      final data = fromJson != null ? fromJson(res.data) : res.data as T;
      return ApiSuccess<T>(data);
    } on DioException catch (e) {
      return mapError<T>(e);
    } catch (e) {
      return ApiNetworkError<T>(message: e.toString());
    }
  }

  /// Status-code → ApiResult mapping (one place). Exposed for unit testing.
  static ApiResult<T> mapError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiNetworkError<T>(message: 'No connection. Check your network.');
      default:
        break;
    }
    final code = e.response?.statusCode;
    final msg = _extractMessage(e.response?.data);
    return switch (code) {
      400 => ApiBadRequest<T>(message: msg),
      401 => ApiUnauthorized<T>(message: msg),
      403 => ApiForbidden<T>(message: msg),
      404 => ApiNotFound<T>(message: msg),
      final int c when c >= 500 => ApiServerError<T>(statusCode: c, message: msg),
      final int c when c >= 400 => ApiClientError<T>(statusCode: c, message: msg),
      _ => ApiNetworkError<T>(message: msg ?? e.message),
    };
  }

  static String? _extractMessage(dynamic data) {
    if (data is! Map) return null;
    final summary = _asString(data['message']);
    final detail = _asString(data['error']) ??
        (data['errors'] is Map
            ? _asString((data['errors'] as Map).values.first)
            : null);
    // Show both when the server sends a generic summary plus a specific detail
    // (e.g. "Failed to create inspection: The registration number field is
    // required.") so the user sees the actionable part.
    if (summary != null && detail != null && detail != summary) {
      return '$summary: $detail';
    }
    return summary ?? detail;
  }

  static String? _asString(dynamic v) {
    if (v is String) return v;
    if (v is List && v.isNotEmpty) return v.first.toString();
    return null;
  }
}
