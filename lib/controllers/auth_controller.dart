import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/api/api_result.dart';
import '../services/local_inspection_service.dart';

part 'auth_controller.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    User? user,
    String? errorMessage,
  }) = _AuthState;
}

/// Auth state. keepAlive (plain NotifierProvider) so it survives navigation.
/// Flutter-agnostic — no BuildContext; screens navigate via GoRouter redirect.
class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repo;

  @override
  AuthState build() {
    _repo = ref.read(authRepositoryProvider);
    return const AuthState(isLoading: true);
  }

  /// Called once at startup (from SplashScreen).
  Future<void> bootstrap() async {
    if (!await _repo.isLoggedIn()) {
      state = const AuthState(isAuthenticated: false);
      return;
    }
    final cached = await _repo.readCachedUser();
    if (!ref.mounted) return;
    state = state.copyWith(
        isAuthenticated: true, user: cached, isLoading: false);

    // Validate/refresh session in the background.
    final res = await _repo.getProfile();
    if (!ref.mounted) return;
    switch (res) {
      case ApiSuccess(:final data):
        state = state.copyWith(
            user: data, isAuthenticated: true, isLoading: false);
      case ApiUnauthorized():
        await _clearSession();
      case _:
        state = state.copyWith(isLoading: false); // keep cached user
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repo.login(email: email, password: password);
    if (!ref.mounted) return false;
    switch (res) {
      case ApiSuccess(:final data):
        state = AuthState(isAuthenticated: true, user: data);
        return true;
      case ApiUnauthorized(:final message):
      case ApiBadRequest(:final message):
      case ApiForbidden(:final message):
      case ApiClientError(:final message):
        state = state.copyWith(
            isLoading: false, errorMessage: message ?? 'Invalid credentials');
        return false;
      case ApiNotFound():
        state = state.copyWith(
            isLoading: false, errorMessage: 'Login failed');
        return false;
      case ApiServerError():
        state = state.copyWith(
            isLoading: false, errorMessage: 'Server error. Please try again.');
        return false;
      case ApiNetworkError():
        state = state.copyWith(
            isLoading: false, errorMessage: 'No connection. Check your network.');
        return false;
    }
  }

  Future<void> logout() async {
    await _clearSession();
  }

  Future<void> _clearSession() async {
    await _repo.logout();
    // ponytail: clear the in-progress draft on logout; keep the pending queue
    // (unsynced work) to avoid data loss. Guarded — box may be absent in tests.
    try {
      await ref.read(localInspectionServiceProvider).clearDraft();
    } catch (_) {}
    if (!ref.mounted) return;
    state = const AuthState(isAuthenticated: false);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
