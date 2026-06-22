import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Real reachability check: connectivity_plus (cheap) then an actual
/// internet probe (so "connected to wifi but no internet" is caught).
class ConnectivityService {
  const ConnectivityService();

  Future<bool> hasInternet() async {
    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) return false;
    return InternetConnectionChecker.createInstance().hasConnection;
  }

  /// Stream of connectivity changes (drives auto-sync in the offline controller).
  Stream<List<ConnectivityResult>> get onChanged =>
      Connectivity().onConnectivityChanged;
}

final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => const ConnectivityService());
