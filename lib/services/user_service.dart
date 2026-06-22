import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/constants.dart';

/// Single owner of secure storage. Token, user JSON, profile-refresh timestamp.
/// Old app instantiated FlutterSecureStorage in 6 places with literal keys.
class UserService {
  UserService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<String?> readToken() => _storage.read(key: AppConstants.tokenKey);

  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: AppConstants.userKey, value: jsonEncode(user));

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: AppConstants.userKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastProfileUpdate(DateTime at) => _storage.write(
        key: AppConstants.lastProfileUpdateKey,
        value: at.toIso8601String(),
      );

  Future<DateTime?> readLastProfileUpdate() async {
    final raw = await _storage.read(key: AppConstants.lastProfileUpdateKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<bool> isLoggedIn() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears all secure storage (logout / session expiry).
  Future<void> clearAll() => _storage.deleteAll();
}

final userServiceProvider = Provider<UserService>((ref) => UserService());
