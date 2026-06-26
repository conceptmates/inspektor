import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'logger.dart';

/// Logs every Dio request/response/error via AppLogger. Registered in DioClient;
/// services must NOT log HTTP manually.
///
/// Request/response BODIES are logged only in debug builds and with sensitive
/// keys (password, tokens, Authorization) redacted, so credentials never reach
/// device logs in release.
class ApiLoggingInterceptor extends Interceptor {
  static const _sensitive = {
    'password',
    'password_confirmation',
    'current_password',
    'access_token',
    'refresh_token',
    'token',
    'authorization',
  };

  Object? _redact(Object? data) {
    if (data is Map) {
      return {
        for (final e in data.entries)
          e.key: _sensitive.contains(e.key.toString().toLowerCase())
              ? '***'
              : _redact(e.value),
      };
    }
    if (data is List) return data.map(_redact).toList();
    return data;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final query = options.queryParameters.isNotEmpty
        ? '\nquery: ${AppLogger.prettyPrintJson(_redact(options.queryParameters))}'
        : '';
    final body = (kDebugMode && options.data != null)
        ? '\nbody: ${AppLogger.prettyPrintJson(_redact(options.data))}'
        : '';
    AppLogger.log('→ ${options.method} ${options.uri}$query$body');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body =
        kDebugMode ? '\n${AppLogger.prettyPrintJson(_redact(response.data))}' : '';
    AppLogger.log(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}$body',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final body = kDebugMode
        ? '\n${AppLogger.prettyPrintJson(_redact(err.response?.data ?? err.message))}'
        : '';
    AppLogger.error(
      '✗ ${err.response?.statusCode ?? "ERR"} '
      '${err.requestOptions.method} ${err.requestOptions.uri}$body',
      error: err,
    );
    super.onError(err, handler);
  }
}
