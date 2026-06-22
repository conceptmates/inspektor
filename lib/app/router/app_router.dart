import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../screens/home/home_screen.dart';

// --- Route names (for goNamed) ---
class RouteNames {
  static const home = 'home';
  static const login = 'login';
}

// --- Route paths ---
class RoutePaths {
  static const home = '/';
  static const login = '/login';
}

/// Router provided via Riverpod so it can read `ref` (auth redirect added in P5).
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    routes: [
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
