import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/services/api/api_result.dart';
import 'package:inspektor/services/api/api_wrapper.dart';

class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter(this.status, this.body);
  final int status;
  final Object body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );

  @override
  void close({bool force = false}) {}
}

ApiWrapper _wrapper(HttpClientAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://test.local'));
  dio.httpClientAdapter = adapter;
  return ApiWrapper(dio);
}

void main() {
  test('200 -> ApiSuccess with parsed data', () async {
    final r = await _wrapper(_CannedAdapter(200, {
      'status': 'success',
      'data': {'n': 42},
    })).get<int>('/x', fromJson: (d) => (d as Map)['data']['n'] as int);
    expect(r, isA<ApiSuccess<int>>());
    expect((r as ApiSuccess<int>).data, 42);
  });

  test('400 -> ApiBadRequest with message', () async {
    final r =
        await _wrapper(_CannedAdapter(400, {'message': 'bad input'})).get('/x');
    expect(r, isA<ApiBadRequest>());
    expect((r as ApiBadRequest).message, 'bad input');
  });

  test('401 -> ApiUnauthorized', () async {
    expect(await _wrapper(_CannedAdapter(401, {})).get('/x'),
        isA<ApiUnauthorized>());
  });

  test('403 -> ApiForbidden', () async {
    expect(
        await _wrapper(_CannedAdapter(403, {})).get('/x'), isA<ApiForbidden>());
  });

  test('404 -> ApiNotFound', () async {
    expect(
        await _wrapper(_CannedAdapter(404, {})).get('/x'), isA<ApiNotFound>());
  });

  test('422 -> ApiClientError, message from errors map', () async {
    final r = await _wrapper(_CannedAdapter(422, {
      'errors': {
        'email': ['taken'],
      },
    })).post('/x');
    expect(r, isA<ApiClientError>());
    expect((r as ApiClientError).statusCode, 422);
    expect(r.message, 'taken');
  });

  test('500 -> ApiServerError', () async {
    final r = await _wrapper(_CannedAdapter(500, {})).get('/x');
    expect(r, isA<ApiServerError>());
    expect((r as ApiServerError).statusCode, 500);
  });

  test('connection error -> ApiNetworkError', () async {
    expect(await _wrapper(_ThrowingAdapter()).get('/x'), isA<ApiNetworkError>());
  });

  test('500 with summary + detail combines into one actionable message',
      () async {
    final r = await _wrapper(_CannedAdapter(500, {
      'status': 'error',
      'message': 'Failed to create inspection',
      'error': 'The registration number field is required.',
    })).post('/x');
    expect(r, isA<ApiServerError>());
    expect((r as ApiServerError).message,
        'Failed to create inspection: The registration number field is required.');
  });
}
