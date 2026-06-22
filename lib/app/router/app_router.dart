import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../screens/authentication/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/inspection/inspection_screen.dart';
import '../../screens/inspection/vehicle_details_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/reports/reports_screen.dart';
import '../../screens/shell/main_shell.dart';
import '../../screens/splash/splash_screen.dart';

// --- Route names (for goNamed) ---
class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const home = 'home';
  static const reports = 'reports';
  static const profile = 'profile';
  static const vehicleDetails = 'vehicleDetails';
  static const inspection = 'inspection';
}

// --- Route paths ---
class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const reports = '/reports';
  static const profile = '/profile';
  static const vehicleDetails = '/vehicle-details';
  static const inspection = '/inspection';
}

/// Bridges Riverpod auth state → GoRouter (re-runs redirect on auth change).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      if (!auth.bootstrapped) {
        return loc == RoutePaths.splash ? null : RoutePaths.splash;
      }
      if (!auth.isAuthenticated) {
        return loc == RoutePaths.login ? null : RoutePaths.login;
      }
      if (loc == RoutePaths.splash || loc == RoutePaths.login) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.home,
              name: RouteNames.home,
              builder: (_, _) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.reports,
              name: RouteNames.reports,
              builder: (_, _) => const ReportsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.profile,
              name: RouteNames.profile,
              builder: (_, _) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: RoutePaths.vehicleDetails,
        name: RouteNames.vehicleDetails,
        builder: (_, _) => const VehicleDetailsScreen(),
      ),
      GoRoute(
        path: RoutePaths.inspection,
        name: RouteNames.inspection,
        builder: (_, _) => const InspectionScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
