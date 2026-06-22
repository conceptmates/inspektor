import 'package:dio/dio.dart';

import 'logger.dart';

/// Logs every Dio request/response/error as pretty JSON via AppLogger.
/// Registered in DioClient; services must NOT log HTTP manually.
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.log(
      '→ ${options.method} ${options.uri}\n'
      '${options.queryParameters.isNotEmpty ? "query: ${AppLogger.prettyPrintJson(options.queryParameters)}\n" : ""}'
      '${options.data != null ? "body: ${AppLogger.prettyPrintJson(options.data)}" : ""}',
    );
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.log(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}\n'
      '${AppLogger.prettyPrintJson(response.data)}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '✗ ${err.response?.statusCode ?? "ERR"} '
      '${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '${AppLogger.prettyPrintJson(err.response?.data ?? err.message)}',
      error: err,
    );
    super.onError(err, handler);
  }
}
