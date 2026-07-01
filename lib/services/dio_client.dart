import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/api_logging_interceptor.dart';
import '../utils/constants.dart';
import 'api/api_wrapper.dart';
import 'api_list.dart';
import 'user_service.dart';

/// Single source of the base URL.
const String apiBaseUrl = 'https://api.certifide.in/api';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: AppConstants.connectionTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  final auth = AuthInterceptor(ref.read(userServiceProvider))..dio = dio;
  dio.interceptors.add(auth);
  dio.interceptors.add(ApiLoggingInterceptor());
  return dio;
});

final apiWrapperProvider =
    Provider<ApiWrapper>((ref) => ApiWrapper(ref.read(dioClientProvider)));

/// Attaches the bearer token (when `useAuth != false`) and, on 401, refreshes
/// once and retries the original request. QueuedInterceptorsWrapper serializes
/// concurrent requests so a single refresh runs while others wait.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor(this._userService);

  final UserService _userService;
  late final Dio dio; // set after construction (dio → interceptor → dio cycle)
  bool _isRefreshing = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final useAuth = options.extra['useAuth'] != false;
    if (useAuth) {
      final token = await _userService.readToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final is401 = err.response?.statusCode == 401;
    final useAuth = err.requestOptions.extra['useAuth'] != false;
    final skipRefresh = err.requestOptions.extra['skipRefresh'] == true;

    if (is401 && useAuth && !skipRefresh && !_isRefreshing) {
      _isRefreshing = true;
      String? newToken;
      try {
        newToken = await _refreshToken();
      } catch (_) {
        // Refresh itself failed → the session is genuinely dead. Clear creds.
        _isRefreshing = false;
        await _userService.clearAll();
        return handler.next(err);
      }
      _isRefreshing = false;
      if (newToken == null) {
        await _userService.clearAll();
        return handler.next(err);
      }
      // Retry with the fresh token. A failure HERE is not an auth failure —
      // a transient 500/timeout must NOT wipe a valid new token. Only a fresh
      // 401 (the new token is rejected too) clears credentials.
      final req = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken';
      try {
        return handler.resolve(await dio.fetch<dynamic>(req));
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) await _userService.clearAll();
        return handler.next(e);
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshToken() async {
    final token = await _userService.readToken();
    if (token == null) return null;
    final res = await dio.post<dynamic>(
      APIList.refresh,
      options: Options(
        extra: {'skipRefresh': true},
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    final data = res.data;
    final newToken = switch (data) {
      {'data': {'access_token': final String t}} => t,
      {'access_token': final String t} => t,
      _ => null,
    };
    if (newToken != null) await _userService.saveToken(newToken);
    return newToken;
  }
}
