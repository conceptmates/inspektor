import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inspektor/data/repositories/auth_repository.dart';
import 'package:inspektor/models/user_model.dart';
import 'package:inspektor/services/api/api_result.dart';
import 'package:inspektor/services/user_service.dart';

import '../../support/fake_http.dart';

/// In-memory UserService (no secure-storage platform channel in unit tests).
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

void main() {
  test('login success saves token + returns typed User', () async {
    final users = _FakeUserService();
    final repo = AuthRepository(
      api: apiWrapperWith((_) => (
            status: 200,
            body: {
              'status': 'success',
              'data': {
                'access_token': 'tok-123',
                'user': {
                  'id': 1,
                  'name': 'Insp',
                  'roles': [
                    {'name': 'inspector'},
                  ],
                },
              },
            },
          )),
      userService: users,
    );

    final r = await repo.login(email: 'a@b.c', password: 'pw');
    expect(r, isA<ApiSuccess<User>>());
    expect((r as ApiSuccess<User>).data.name, 'Insp');
    expect(users.token, 'tok-123');
  });

  test('login 401 -> ApiUnauthorized, no token saved', () async {
    final users = _FakeUserService();
    final repo = AuthRepository(
      api: apiWrapperWith((_) => (status: 401, body: {'message': 'bad creds'})),
      userService: users,
    );

    final r = await repo.login(email: 'a', password: 'b');
    expect(r, isA<ApiUnauthorized<User>>());
    expect(users.token, isNull);
  });
}
