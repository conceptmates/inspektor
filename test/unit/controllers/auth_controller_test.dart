import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/controllers/auth_controller.dart';
import 'package:inspektor/data/repositories/auth_repository.dart';
import 'package:inspektor/services/user_service.dart';

import '../../support/fake_http.dart';

class _FakeUserService extends UserService {
  _FakeUserService() : super(storage: const FlutterSecureStorage());
  String? token;
  Map<String, dynamic>? user;
  @override
  Future<void> saveToken(String t) async => token = t;
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> saveUser(Map<String, dynamic> u) async => user = u;
  @override
  Future<Map<String, dynamic>?> readUser() async => user;
  @override
  Future<void> saveLastProfileUpdate(DateTime t) async {}
  @override
  Future<void> clearAll() async {
    token = null;
    user = null;
  }

  @override
  Future<bool> isLoggedIn() async => token != null;
}

AuthRepository _repo({required int status, required Object body}) =>
    AuthRepository(
      api: apiWrapperWith((_) => (status: status, body: body)),
      userService: _FakeUserService(),
    );

void main() {
  test('successful login sets authenticated state with user', () async {
    final container = ProviderContainer.test(overrides: [
      authRepositoryProvider.overrideWithValue(_repo(status: 200, body: {
        'status': 'success',
        'data': {
          'access_token': 'tok',
          'user': {
            'name': 'Insp',
            'roles': [
              {'name': 'inspector'},
            ],
          },
        },
      })),
    ]);

    final ok = await container
        .read(authControllerProvider.notifier)
        .login(email: 'a@b.c', password: 'pw');

    expect(ok, true);
    final state = container.read(authControllerProvider);
    expect(state.isAuthenticated, true);
    expect(state.user?.name, 'Insp');
    expect(state.errorMessage, isNull);
  });

  test('failed login (401) sets error, stays unauthenticated', () async {
    final container = ProviderContainer.test(overrides: [
      authRepositoryProvider.overrideWithValue(
          _repo(status: 401, body: {'message': 'Invalid login'})),
    ]);

    final ok = await container
        .read(authControllerProvider.notifier)
        .login(email: 'a', password: 'b');

    expect(ok, false);
    final state = container.read(authControllerProvider);
    expect(state.isAuthenticated, false);
    expect(state.errorMessage, 'Invalid login');
  });
}
