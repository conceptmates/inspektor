import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import '../../screens/authentication/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/splash/splash_screen.dart';

// --- Route names (for goNamed) ---
class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const home = 'home';
}

// --- Route paths ---
class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
}

/// Bridges Riverpod auth state → GoRouter (re-runs redirect on auth change).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

/// Provided via Riverpod so redirect can read auth state.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      if (auth.isLoading) {
        return loc == RoutePaths.splash ? null : RoutePaths.splash;
      }
      if (!auth.isAuthenticated) {
        return loc == RoutePaths.login ? null : RoutePaths.login;
      }
      // Authenticated — leave splash/login behind.
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
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (_, _) => const HomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
