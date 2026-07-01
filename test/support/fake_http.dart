import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:inspektor/services/api/api_wrapper.dart';

typedef CannedResponse = ({int status, Object body});

/// Dio adapter returning canned JSON per request (keyed off the request path).
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);
  final CannedResponse Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final r = handler(options);
    return ResponseBody.fromString(
      jsonEncode(r.body),
      r.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

ApiWrapper apiWrapperWith(
    CannedResponse Function(RequestOptions options) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.local'))
    ..httpClientAdapter = FakeHttpAdapter(handler);
  return ApiWrapper(dio);
}
