import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import '../../services/api/api_result.dart';
import '../../services/api/api_wrapper.dart';
import '../../services/api_list.dart';
import '../../services/dio_client.dart';
import '../../services/user_service.dart';

/// Auth domain ops. Controllers depend on this, not on ApiWrapper/UserService.
class AuthRepository {
  AuthRepository({required ApiWrapper api, required UserService userService})
      : _api = api,
        _userService = userService;

  final ApiWrapper _api;
  final UserService _userService;

  Future<ApiResult<User>> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      APIList.login,
      body: {'email': email, 'password': password},
      useAuth: false,
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);

    final body = res.data;
    final data = (body['data'] as Map?)?.cast<String, dynamic>();
    final token = data?['access_token'] as String?;
    final userJson = (data?['user'] as Map?)?.cast<String, dynamic>();
    if (token == null || userJson == null) {
      return ApiBadRequest(message: body['message']?.toString() ?? 'Login failed');
    }
    await _userService.saveToken(token);
    await _userService.saveUser(userJson);
    return ApiSuccess(User.fromJson(userJson));
  }

  /// GET /auth/me — current user; refreshes cached user.
  Future<ApiResult<User>> getProfile() async {
    final res = await _api.get<Map<String, dynamic>>(
      APIList.me,
      fromJson: _asMap,
    );
    if (res is! ApiSuccess<Map<String, dynamic>>) return castApiError(res);

    final data = (res.data['data'] as Map?)?.cast<String, dynamic>();
    final userJson =
        (data?['user'] as Map?)?.cast<String, dynamic>() ?? data;
    if (userJson == null) return const ApiNotFound(message: 'Profile not found');
    await _userService.saveUser(userJson);
    await _userService.saveLastProfileUpdate(DateTime.now());
    return ApiSuccess(User.fromJson(userJson));
  }

  Future<User?> readCachedUser() async {
    final json = await _userService.readUser();
    return json == null ? null : User.fromJson(json);
  }

  Future<bool> isLoggedIn() => _userService.isLoggedIn();

  /// Logout is client-side (old app sent no request). Caller also clears Hive.
  Future<void> logout() => _userService.clearAll();

  static Map<String, dynamic> _asMap(dynamic d) =>
      (d as Map).cast<String, dynamic>();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.read(apiWrapperProvider),
    userService: ref.read(userServiceProvider),
  );
});
