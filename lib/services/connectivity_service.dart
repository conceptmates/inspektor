import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

/// Real reachability check: connectivity_plus (cheap radio state) then a
/// lightweight probe against OUR OWN backend — not a public DNS / Google ping.
///
/// What matters before a submit is "can I reach the Certifide API", so we ask
/// it directly. Socket-pinging 8.8.8.8 / 1.1.1.1 (the old
/// internet_connection_checker behaviour) fails on emulators and restricted
/// networks that can still reach our backend, wrongly forcing every submit into
/// the offline queue ("Saved Offline").
class ConnectivityService {
  const ConnectivityService(this._probe);

  final Dio _probe;

  Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) return false;
    return _backendReachable();
  }

  /// Any HTTP response — even 401/404/405 — proves the host answered, so we are
  /// online. Only a connect/timeout/socket failure (no response at all) counts
  /// as unreachable.
  Future<bool> _backendReachable() async {
    try {
      await _probe.get<void>(
        apiBaseUrl,
        options: Options(validateStatus: (_) => true),
      );
      return true;
    } on DioException catch (e) {
      return e.response != null;
    } catch (_) {
      return false;
    }
  }

  /// Cheap radio-state check (no DNS/HTTP probe). Use on hot paths like media
  /// capture where a full reachability probe per action adds visible latency —
  /// the actual upload result handles "connected but no internet" by failing.
  Future<bool> hasNetwork() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Stream of connectivity changes (drives auto-sync in the offline controller).
  Stream<List<ConnectivityResult>> get onChanged =>
      Connectivity().onConnectivityChanged;
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  // Dedicated short-timeout Dio for the reachability probe. The app Dio uses
  // 30s timeouts (right for real requests, far too slow for a pre-submit check)
  // and carries auth/refresh interceptors we don't want on a bare ping.
  final probe = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  return ConnectivityService(probe);
});
