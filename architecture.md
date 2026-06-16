# Flutter App Architecture Guide

> A generalized, scalable Flutter architecture using **Riverpod** for state management.  
> This structure is designed to be reusable across any type of Flutter application.

**Always use this structure.** New features, screens, and code must follow the folder layout, layer boundaries, and conventions defined below. Do not introduce alternate patterns (e.g. different folder names, logic in UI, or ad-hoc state) — keep the codebase consistent with this architecture. You can adapt folder names (e.g. feature-first) or routing (e.g. AutoRoute) to your team; the patterns below still apply.

---

## 📁 Project Structure

Use **snake_case** for all folder names. Preferred: `controllers/`, `models/`, `screens/` (not PascalCase).

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration (if using Firebase)
├── app/                         # App-level configuration
│   └── router/
│       └── app_router.dart      # GoRouter + RouteNames + RoutePaths (single file)
│
├── controllers/                 # Riverpod Providers (State Management)
│   ├── auth_controller.dart
│   ├── global_controller.dart
│   ├── [feature]_controller.dart
│   └── ...
│
├── data/                        # Data layer utilities + optional repositories
│   ├── helper.dart              # Helper functions
│   ├── exceptions.dart          # Custom exceptions
│   ├── result.dart              # Result wrapper for API responses
│   └── repositories/            # Optional: Repository layer (see Architecture Layers)
│   │   ├── auth_repository.dart
│   │   └── [feature]_repository.dart
│
├── locale/                      # Internationalization (i18n)
│   ├── language.dart            # Language configuration
│   ├── english.dart
│   ├── spanish.dart
│   ├── arabic.dart
│   └── [language].dart
│
├── models/                      # Data Models / Entities
│   ├── user_model.dart
│   ├── [feature]_model.dart
│   └── ...
│
├── screens/                     # UI Layer (Screens & Widgets)
│   ├── authentication/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── widgets/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── widgets/
│   ├── splash/
│   │   └── splash_screen.dart
│   └── widgets/                 # Shared/Common Widgets
│       ├── constant.dart
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── loading_widget.dart
│
├── services/                    # Services Layer (API, Storage, etc.)
│   ├── api/                     # Centralized API layer
│   │   ├── api_result.dart      # Sealed ApiResult<T> (Success, NotFound, etc.)
│   │   └── api_wrapper.dart     # Centralized API wrapper (get, post, put, patch, delete, upload)
│   ├── api_list.dart            # API endpoints
│   ├── dio_client.dart          # HTTP client configuration (prefer DI via provider)
│   ├── server.dart              # Server communication
│   ├── user_service.dart        # User-related services
│   ├── notification_service.dart
│   └── validators.dart          # Input validation
│
└── utils/                       # Utilities & Constants
    ├── api_logging_interceptor.dart  # Dio interceptor for API request/response logging
    ├── logger.dart                   # Centralized logger (dart:developer.log, prettyPrintJson)
    ├── font_size.dart
    ├── image.dart
    ├── size_config.dart
    ├── style.dart
    ├── colors.dart
    └── constants.dart

assets/
├── fonts/                       # Custom fonts (declare in pubspec under flutter/fonts)
├── icons/                       # In-app icon assets (not the launcher icon)
└── images/                      # Image assets
    ├── common/                  # Shared images (logo, placeholders)
    ├── onboarding/              # Optional: by feature or screen
    ├── [feature]/               # Optional: feature-specific images
    └── animations/              # Lottie or other animation JSONs
        └── *.json

test/                            # Unit & Widget tests
└── widget_test.dart

docs/                            # Documentation and external API specs (outside lib)
└── postman/                     # Postman collection/environment JSON files for API integration when provided by user
    └── *.json                   # e.g. MyAPI.postman_collection.json, environment.json
```

Place Postman export JSON here when integrating APIs from a provided collection.

---

## 🏗️ Architecture Layers

### 1. **Presentation Layer** (`screens/`)

- Contains all UI components (Screens & Widgets)
- Organized by feature/module
- Each feature folder contains:
  - Main screen file
  - `widgets/` subfolder for feature-specific widgets
- Shared widgets go in `screens/widgets/`

### 2. **State Management Layer** (`controllers/`)

- Uses **Riverpod** providers for state management
- Each controller (Notifier) manages state for a specific feature
- Controllers depend on **repositories** (or, if no repository layer, on services). Do not put UI controllers in Notifiers (see Avoid Common Mistakes).

### 3. **Repository Layer** (optional but recommended)

- **Purpose:** Decouple controllers from the network. Repository exposes domain operations; services handle raw HTTP.
- **Flow:** Controller → Repository → Service → API. Repository can add caching, fallbacks (e.g. cache then network), and data transformation.
- **Testing:** Mock the repository in tests instead of the entire service/HTTP stack.
- Place in `data/repositories/` (e.g. `auth_repository.dart`, `mosque_repository.dart`). Inject the service into the repository via constructor; provide repository via Riverpod.

### 4. **Data Layer** (`models/`, `data/`)

- `models/`: Data classes representing entities. Prefer **freezed** (see Model Example).
- `data/`: Helper utilities, result wrappers, exceptions.

### 5. **Services Layer** (`services/`)

- API communication
- Local storage
- External service integrations
- Validation logic

#### API usage structure (Centralized API wrapper)

All API calls go through a **single wrapper** (`ApiWrapper` in `services/api/api_wrapper.dart`) that exposes generic methods: `get`, `post`, `put`, `patch`, `delete`, `upload`. The wrapper depends on `DioClient` and uses it internally; app code does not call Dio directly for HTTP.

Each method accepts an optional parameter (e.g. **`useAuth`**). **Public** endpoints (login, register, forgot password, public content) use `useAuth: false` so no `Authorization` header is sent. **Protected** endpoints (profile, update profile, delete, etc.) use `useAuth: true` so the wrapper attaches the token. Examples: public — `_api.post(APIList.login, body: {...}, useAuth: false)`; protected — `_api.get<Profile>(APIList.profile, useAuth: true, fromJson: ...)`.

The wrapper returns a **sealed** `ApiResult<T>` (defined in `services/api/api_result.dart`):

- **Success:** `ApiSuccess<T>(T data)` for status 200–299
- **Errors:** `ApiBadRequest`, `ApiUnauthorized`, `ApiForbidden`, `ApiNotFound`, `ApiClientError` (other 4xx), `ApiServerError` (5xx), `ApiNetworkError` (connection/timeout)

Callers handle every outcome with an **exhaustive switch** on `ApiResult`; no try/catch is required for normal HTTP/network outcomes. Status codes are mapped in one place inside the wrapper (200 → Success, 404 → NotFound, 502 → ServerError, etc.). Logging stays in the **Dio interceptor** (pretty-printed request/response); the wrapper does not duplicate logging.

**Example — service (protected endpoint with `useAuth: true`):**

```dart
Future<ApiResult<Profile>> getProfile() async {
  return _api.get<Profile>(APIList.profile, useAuth: true, fromJson: (json) => Profile.fromJson(json as Map<String, dynamic>));
}
```

**Example — controller (exhaustive switch):**

```dart
final result = await profileService.getProfile();
switch (result) {
  case ApiSuccess(:final data):
    state = state.copyWith(profile: data);
  case ApiNotFound():
    state = state.copyWith(errorMessage: 'Profile not found');
  case ApiUnauthorized():
    ref.read(authControllerProvider.notifier).checkAuth();
  case ApiServerError(:final statusCode):
    state = state.copyWith(errorMessage: 'Server error. Try again.');
  case ApiNetworkError(:final message):
    state = state.copyWith(errorMessage: 'No connection.');
  case ApiBadRequest(:final message): case ApiForbidden(:final message): case ApiClientError(:final message):
    state = state.copyWith(errorMessage: message ?? 'Request failed');
}
```

#### API request/response logging

All API request/response logging is done via a **Dio interceptor**; services do not log HTTP calls manually. The interceptor runs for every request (**onRequest**), every response (**onResponse**), and every error (**onError**).

- **Request:** method, URI, query parameters, headers, and body are logged.
- **Response/error:** status code, duration, and response/error body are logged.
- **Bodies** are logged as **pretty-printed JSON** (indented) when possible, via `AppLogger.prettyPrintJson`.
- All logging goes through **AppLogger**, which uses **dart:developer.log()** — no `print()` or `debugPrint()` in the API logging path.

**Implementation:** `ApiLoggingInterceptor` in `utils/api_logging_interceptor.dart`; registered in `DioClient._setupInterceptors()` in `services/dio_client.dart`. The centralized logger is in `utils/logger.dart`.

### 6. **Utilities** (`utils/`)

- Constants, styles, colors
- Size configurations
- Asset paths

---

## 🧭 Routing (GoRouter)

Use **GoRouter** for declarative routing. No Auto Route; keep routing in **one file** (`app_router.dart`) with route names, path constants, and the router.

### Folder structure

```
lib/
├── app/
│   └── router/
│       └── app_router.dart      # RouteNames + RoutePaths + GoRouter (single file)
├── screens/                     # or features/
│   ├── authentication/
│   ├── home/
│   └── ...
└── main.dart
```

### Single file: app_router.dart (RouteNames + RoutePaths + GoRouter)

Define route names and paths at the top of the same file; use only these constants in the router. No hardcoded strings.

```dart
import 'package:go_router/go_router.dart';

// --- Route names (for goNamed) ---
class RouteNames {
  static const home = 'home';
  static const login = 'login';
  static const chat = 'chat';
  static const profile = 'profile';
}

// --- Route paths (no hardcoded paths in routes) ---
class RoutePaths {
  static const home = '/';
  static const login = '/login';
  static const chat = '/chat';
  static const chatDetail = '/chat/:id';  // parametrized route
  static const profile = '/profile';
}

// --- Router ---
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  routes: [
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.chatDetail,
      name: RouteNames.chat,
      builder: (context, state) {
        final chatId = state.pathParameters['id']!;
        return ChatScreen(chatId: chatId);
      },
    ),
    GoRoute(
      path: RoutePaths.profile,
      name: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
```

### Use named navigation (best practice)

Prefer `context.goNamed` with path parameters instead of building URLs by hand:

```dart
// Prefer: named route + pathParameters
context.goNamed(RouteNames.chat, pathParameters: {'id': '123'});

// Avoid: hardcoded path (typos, inconsistency)
context.go('/chat/123');
```

### Setup in main.dart

When using GoRouter, use `MaterialApp.router` so the router owns navigation. Do not set `home:` — the router handles initial and subsequent routes.

```dart
MaterialApp.router(
  routerConfig: ref.watch(appRouterProvider), // Router is provided by Riverpod (see below)
  // ...
);
```

### Auth redirect (for protected routes)

Use a **RouterNotifier** (or similar) that holds a ref and implements `Listenable` so GoRouter can re-run redirect when auth state changes. **Provide the GoRouter itself as a Riverpod provider** so it is built inside ProviderScope with access to `ref` — a top-level `final appRouter = GoRouter(...)` cannot use `ref` and would crash. Pattern:

```dart
// RouterNotifier: reads auth and notifies GoRouter to re-run redirect
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref);
  final Ref _ref;

  void refresh() => notifyListeners();

  bool get isLoggedIn =>
      _ref.read(authControllerProvider).isAuthenticated;
}

@Riverpod(keepAlive: true)
GoRouterRefreshNotifier routerRefreshNotifier(Ref ref) {
  final notifier = GoRouterRefreshNotifier(ref);
  ref.listen(authControllerProvider, (_, __) => notifier.refresh()); // React to auth changes so redirect runs
  ref.onDispose(notifier.dispose);
  return notifier;
}

// Provide the router so it is built inside ProviderScope (ref is valid here). Use ref.read for the notifier so GoRouter is not re-created on every auth change (only refreshListenable triggers redirect).
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final notifier = ref.read(routerRefreshNotifierProvider);
  return GoRouter(
    refreshListenable: notifier,
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
    redirect: (context, state) {
      if (!notifier.isLoggedIn && state.fullPath != RoutePaths.login) {
        return RoutePaths.login;
      }
      return null;
    },
    routes: [ /* ... */ ],
  );
}
```

The notifier subscribes to auth via `ref.listen` above, so redirect re-runs automatically when auth state changes. See [GoRouter + Riverpod](https://pub.dev/documentation/go_router/latest/topics/GoRouterWithRef-topic.html).

### ShellRoute for bottom navigation (tabs)

Use `ShellRoute` when you have a persistent layout (e.g. bottom nav) with multiple top-level routes:

```dart
ShellRoute(
  builder: (context, state, child) {
    return MainNavigationScreen(child: child);
  },
  routes: [
    GoRoute(
      path: RoutePaths.home,
      name: RouteNames.home,
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.profile,
      name: RouteNames.profile,
      builder: (_, __) => const ProfileScreen(),
    ),
  ],
);
```

### Pro tips

- **Single file:** Keep `RouteNames`, `RoutePaths`, and `appRouter` in **one file** (`app_router.dart`); use only these constants in the router (no hardcoded path or name strings).
- Always use **named routes** (`goNamed`, `pushNamed`) with `RouteNames` and `RoutePaths`.
- Use **ShellRoute** for tab/bottom-nav layouts.
- Use **pathParameters** for dynamic segments (e.g. `/chat/:id`) instead of query parsing where possible.

---

## 🌓 Theme (Dark & Light Mode)

### Overview

- Support **Light**, **Dark**, and **System** (follow device); persist the chosen mode across restarts (e.g. via `adaptive_theme`).
- In short: entry loads saved theme mode, root widget wraps the app with `AdaptiveTheme` (and optionally a shader-based transition), and the user changes mode from a profile or settings screen.

### Process (what we do)

1. **Entry:** In `main()`, before `runApp`, get the saved theme mode (e.g. `AdaptiveTheme.getThemeMode()`). Pass it into the root app widget.
2. **Root:** Wrap the app with `AdaptiveTheme`; provide `light` and `dark` `ThemeData`, and `initial` from the saved mode. In the `builder`, pass the current theme into `MaterialApp` (and optionally wrap with `ShaderTheme` + `ThemeShockWaveArea` for an animated transition).
3. **Theme definitions:** One place (e.g. a static class) exposes `lightTheme` and `darkTheme` — each a `ThemeData` with `useMaterial3`, `ColorScheme`, and component themes (AppBar, Card, buttons, input, chip, bottom nav, snackbar, etc.). Use shared color constants for light; for dark use the same seed or a dark palette. Optionally attach a custom `ThemeExtension` (e.g. feature-specific colors) in both themes.
4. **Switcher UI:** On the profile or settings screen, use a control (e.g. switch or segmented control) that reads current mode via `AdaptiveTheme.of(context).modeChangeNotifier` (or equivalent) and, on change, calls `setLight()` / `setDark()` / `setSystem()` and, if using a shader transition, the switcher’s `changeTheme(theme: lightTheme)` or `changeTheme(theme: darkTheme)` so the animation runs.

### Where things live (generic)

- **Entry:** `main.dart` — load saved theme, pass to root.
- **Root:** Root app widget (e.g. in `app.dart`) — `AdaptiveTheme` (+ optional `ShaderTheme`).
- **Themes:** A single theme file (e.g. `app_theme.dart` or under `utils/` / a `theme/` module) — `lightTheme`, `darkTheme`.
- **Colors:** Shared constants (e.g. `colors.dart` or `app_colors.dart`) used when building themes.
- **Custom / per-screen colors:** **`themes/{screen_name}/`** (e.g. `themes/quran/`, `themes/profile/`). Each screen that needs its own colors or a `ThemeExtension` has a folder here; register that extension in the central `lightTheme` / `darkTheme`.
- **Switcher UI:** Profile or Settings screen.

### Dependencies

- **Required:** `adaptive_theme` — persistence and Light/Dark/System API.
- **Optional:** `shader_theme_switcher` — animated theme transition. If the **Required Dependencies** section already lists these, the Theme section can say “See **Required Dependencies** for packages” instead of duplicating versions.

### Using theme in widgets

- Use `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`, `Theme.of(context).brightness`.
- For **custom colors:** `Theme.of(context).extension<YourScheme>()` (or equivalent). Define and place per-screen extensions under **`themes/{screen_name}/`** (e.g. `themes/quran/`). Avoid hardcoded colors so light and dark stay consistent.

### Data flow

- **Startup:** In `main()`, call `AdaptiveTheme.getThemeMode()` (async, from storage), then `runApp` with the root widget receiving the saved mode. Root widget wraps with `AdaptiveTheme(light: ..., dark: ..., initial: savedMode)`. In the `builder`, you get the current `theme`; pass it to `MaterialApp` (single `theme` — AdaptiveTheme already switches which one is active). Optionally wrap the `MaterialApp` in `ShaderTheme` + `ThemeShockWaveArea` for an animated transition.
- **When the user changes theme in Settings:** Call `AdaptiveTheme.of(context).setLight()` / `setDark()` / `setSystem()`. If using `ShaderTheme`, also call `ThemeSwitcherPoint`’s `changeTheme(theme: lightTheme)` or `changeTheme(theme: darkTheme)` so the shader animation runs; persistence is still handled by AdaptiveTheme.

### Implementation details

- **Entry point:** Before `runApp`, await `AdaptiveTheme.getThemeMode()` and pass the result into the root app widget.
- **Root app widget:** Use `AdaptiveTheme` with `light` and `dark` as the two `ThemeData`s; `initial` is the saved mode (or default e.g. `AdaptiveThemeMode.light`). In `builder`, receive current `theme` and pass it to `MaterialApp`. Optionally wrap with `ShaderTheme` and `ThemeShockWaveArea`; when switching, use `ThemeSwitcherPoint(builder: (context, changeTheme) => ...)` and call `changeTheme(theme: lightTheme)` or `darkTheme` in addition to `setLight()` / `setDark()` / `setSystem()`.
- **Color constants:** Define one place for brand/semantic colors (primary, secondary, surface, background, text, error, divider, etc.). Use these when building both light and dark `ThemeData`; for dark you may use different constants (e.g. primaryLight, surfaceDark).
- **Theme definitions:** One static class with `static ThemeData get lightTheme` and `static ThemeData get darkTheme`. Use `ColorScheme.fromSeed()` or explicit `ColorScheme` with your constants; set `useMaterial3: true`. Configure `colorScheme`, `scaffoldBackgroundColor`, `appBarTheme`, `cardTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `textButtonTheme`, `inputDecorationTheme`, `chipTheme`, `bottomNavigationBarTheme`, `snackBarTheme`, `dividerTheme`. For dark theme, override `textTheme` so text colors use `scheme.onSurface` / `onSurfaceVariant` for contrast. Attach custom `ThemeExtension` in `extensions: [YourScheme.light()]` or `.dark()`.
- **Custom theme extension:** Implement `ThemeExtension<YourScheme>` with named constructors for light and dark (e.g. `YourScheme.light()`, `YourScheme.dark()`), and implement `copyWith` and `lerp` for transitions. Register in `ThemeData.extensions` in both `lightTheme` and `darkTheme`. Place per-screen extensions under **`themes/{screen_name}/`**. In widgets: `Theme.of(context).extension<YourScheme>()?.someColor`.
- **Settings / profile — theme switcher:** Use `ValueListenableBuilder<AdaptiveThemeMode>` with `valueListenable: AdaptiveTheme.of(context).modeChangeNotifier`. Compute “is dark currently” as `mode == AdaptiveThemeMode.dark || (mode == AdaptiveThemeMode.system && MediaQuery.platformBrightness == Brightness.dark)`. For each option (Light / Dark / System), call `setLight()` / `setDark()` / `setSystem()`. If using `ShaderTheme`, wrap the control in `ThemeSwitcherPoint` and call `changeTheme(theme: lightTheme)` or `changeTheme(theme: darkTheme)`. Optional: a quick toggle (e.g. switch) that toggles between light and dark.
- **Optional animated toggle widget:** A small toggle (e.g. sun/moon) that takes `isDark` (from current mode + system brightness) and `onTap`. On tap: if dark, call `setLight()` + `changeTheme(theme: lightTheme)`; else `setDark()` + `changeTheme(theme: darkTheme)`. Use theme colors for background and icons.

### Checklist for another app

- [ ] Add `adaptive_theme` (and optionally `shader_theme_switcher`) to `pubspec.yaml`.
- [ ] Create `lightTheme` and `darkTheme` in a single theme file, using shared color constants.
- [ ] Optionally add a `ThemeExtension` for feature-specific colors; register in both themes and implement `copyWith` + `lerp`; place under **`themes/{screen_name}/`** per screen.
- [ ] In `main()`, await `AdaptiveTheme.getThemeMode()` and pass to root widget.
- [ ] In root widget, wrap with `AdaptiveTheme(light: ..., dark: ..., initial: ...)` and use `builder` to pass `theme` to `MaterialApp`; add `ShaderTheme` + `ThemeShockWaveArea` if desired.
- [ ] In Settings or profile, use `AdaptiveTheme.of(context).setLight/setDark/setSystem` and, if using shader switcher, `ThemeSwitcherPoint` + `changeTheme(...)`.
- [ ] In UI, use `Theme.of(context).colorScheme`, `theme.textTheme`, and `theme.extension<YourScheme>()` instead of hardcoded colors.

### Reference

- A standalone copy of this theme architecture guide is in **docs/THEME_ARCHITECTURE.md** for reuse in other projects.

---

## 🧠 Riverpod 3 Best Practices

### 0️⃣ Core Mental Model

**Riverpod** = State container + reactive rebuild + async wrapper + dependency graph.

- **Think in:** “State changes → UI reacts”
- **Never think in:** `setState`, global variables, event bus

### 1️⃣ Always Use @riverpod (Modern API)

**Sync state:**

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

**Async state:**

```dart
@riverpod
class UserController extends _$UserController {
  @override
  Future<User> build() async {
    return fetchUser();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(fetchUser);
  }
}
```

Prefer `AsyncValue.guard()` over manual try/catch.

### 2️⃣ UI Usage Rules

| Purpose | Use | Example |
|--------|-----|--------|
| **Reactive UI** | `ref.watch` | `final state = ref.watch(userControllerProvider);` |
| **One-off actions** | `ref.read` | `ref.read(userControllerProvider.notifier).refresh();` |
| **Side effects** | `ref.listen` | Navigate on auth success, start audio on call started |

**Watch for UI:**

```dart
final state = ref.watch(userControllerProvider);
```

**Read for actions:**

```dart
ref.read(userControllerProvider.notifier).refresh();
```

**Listen for side effects:**

```dart
ref.listen(authProvider, (prev, next) {
  if (next case AsyncData(:final user)) {
    context.goNamed(RouteNames.home);
  }
});
```

### 3️⃣ Always Use Pattern Matching (Dart 3)

```dart
switch (state) {
  AsyncData(:final value) => Text(value.name),
  AsyncLoading() => const CircularProgressIndicator(),
  AsyncError(:final error) => Text("Error"),
}
```

Avoid `.when()` in new code.

### 4️⃣ AsyncValue Best Practices

- **First load** → full loading: `state = const AsyncValue.loading();`
- **Background refresh** → keep data: `state = AsyncValue.data(state.value!.copyWith(isRefreshing: true));`
- In Riverpod 3, `AsyncValue.valueOrNull` was removed; use `.value` (and handle null or check `hasValue`) instead.
- In Riverpod 3, `AsyncValue` is sealed and can expose `isFromCache` for offline/async persistence; useful for data-heavy or offline-capable UIs.
- In Riverpod 3, **AsyncValue** can expose an optional **progress** field (e.g. on `AsyncLoading`); set it from providers to show custom progress in the UI (file uploads, long operations).
- **Optimistic update:** save previous state, apply update, on API failure restore previous:

```dart
final previous = state;
state = updatedState;
try {
  await apiCall();
} catch (_) {
  state = previous;
}
```

### 5️⃣ Keep UI Dumb

- Put logic in the **Notifier**, not in widgets.
- **Bad:** `onPressed: () async { await apiCall(); }`
- **Good:** `onPressed: () { ref.read(userControllerProvider.notifier).refresh(); }`

### 6️⃣ Provider Type Decision Tree

| Situation | Use |
|-----------|-----|
| Simple toggle | Notifier |
| API call | AsyncNotifier |
| Computed value | Provider |
| Stream | StreamProvider |
| Screen-scoped state (forms, modals, detail) | **autoDispose** (default) |

**Default to autoDispose** for screen-scoped state so providers are disposed when the user leaves the screen (avoids memory leaks and stale state). With `@riverpod`, providers are **autoDispose by default**; use `@Riverpod(keepAlive: true)` to keep alive. For raw `Provider` (without code gen), use `Provider(isAutoDispose: true)`; the old `Provider.autoDispose()` style is removed in Riverpod 3.

### 7️⃣ Keep Simple UI State Simple

Okay to keep tiny flags simple. In Riverpod 3, prefer the `@riverpod` Notifier for toggles (e.g. password visibility):

```dart
@riverpod
class PasswordVisibility extends _$PasswordVisibility {
  @override
  bool build() => false;
  void toggle() => state = !state;
}
```

In Riverpod 3, `StateProvider` and `StateNotifierProvider` are in `package:flutter_riverpod/legacy.dart`; prefer the Notifier above for new code. Don't over-engineer small flags. **If you use `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider`, you must import them from `package:flutter_riverpod/legacy.dart`** — importing from `package:flutter_riverpod/flutter_riverpod.dart` without the legacy import will cause a compile error.

### 8️⃣ Invalidate to Force Reload

```dart
ref.invalidate(userControllerProvider);
```

This reruns `build()`. Good for: logout, pull-to-refresh, hard reset.

### 9️⃣ Avoid Common Mistakes

- Calling `build()` manually
- Mutating list directly (`state.add(...)`)
- Using `ref.watch` inside loops
- Mixing GetX / Bloc / Provider patterns with Riverpod
- Doing navigation inside `watch` (use `ref.listen` for side effects)
- Putting `TextEditingController` or other Flutter UI controllers inside a Notifier — keep them in the widget (e.g. `ConsumerStatefulWidget`) and pass only plain data (e.g. `userId`, `password`) into the Notifier
- After an `await` in a provider, check `if (!ref.mounted) return;` (or skip updating state) so you don't update state after the provider was disposed
- In Riverpod 3, **FamilyNotifier** is removed; use a plain `Notifier` (or `AsyncNotifier`) with a `.family` provider (e.g. `@riverpod` with a family parameter) instead.
- When **ref.watch** or **ref.read** rethrows an error, Riverpod 3 wraps it in **ProviderException**. In catch blocks or error handlers that check the error type, unwrap it (e.g. use `ProviderException.cause` or check for `ProviderException` and handle the inner error).

### 🔟 Immutability Rule

- **Always:** `state = [...state, newItem];` or `state = state.copyWith(...);`
- **Never:** `state.add(newItem);` — won’t trigger rebuild

### 1️⃣1️⃣ Replace EventBus with ref.listen

Instead of `eventBus.fire(...)`, use state-driven side effects:

```dart
ref.listen(callProvider, (prev, next) {
  if (next == CallState.started) {
    startAudio();
  }
});
```

State-driven > event-driven.

### 1️⃣2️⃣ Feature-First Architecture

Organize by feature; keep domain logic in Notifiers and UI in screens/widgets.

### 1️⃣3️⃣ Performance Optimization

Use `.select()` when only one field is needed:

```dart
final name = ref.watch(userProvider.select((u) => u.name));
```

Prevents full rebuild when other fields change.

### 1️⃣4️⃣ Testing

- Use **ProviderContainer** (and **overrides**) to test providers in isolation. In Riverpod 3, prefer **ProviderContainer.test()**, which creates a container and disposes it when the test ends (avoids leaks): `final container = ProviderContainer.test(overrides: [repositoryProvider.overrideWith((ref) => MockRepository())]);`
- Override repositories/services with mocks so no real HTTP runs.
- Test **Notifiers** by reading the provider and calling methods; assert on state.
- Prefer **constructor-injected** dependencies (repositories, services) so they can be overridden in tests. Avoid static singletons for anything that touches the network.
- For **widget tests**, Riverpod 3 adds **WidgetTester.container** to obtain the `ProviderContainer` from the test context. **NotifierProvider.overrideWithBuild** lets you mock only `Notifier.build` without mocking the whole notifier. Both are useful for widget testing.
- See [Riverpod testing docs](https://riverpod.dev/docs/how_to/testing) for patterns.

### Provider scopes per feature

Use **ProviderScope** with **overrides** to isolate a feature (or a route subtree) with its own provider values — e.g. inject mocks in tests or give a feature its own repository implementation:

```dart
ProviderScope(
  overrides: [
    chatRepositoryProvider.overrideWithValue(mockRepo),
  ],
  child: ChatFeatureWidget(), // or a route subtree
)
```

Useful for (1) **tests** — inject mocks per test or feature, and (2) **feature-level overrides** — e.g. a chat module with its own scope and overrides.

### ProviderObserver (debugging and production)

For debugging and production observability, use a **ProviderObserver** to log provider updates and errors. Implement `ProviderObserver` and override `didUpdateProvider` and `providerDidFail`; then pass your observer to `ProviderScope(observers: [YourObserver()])`. This helps trace state changes and catch provider failures. See [Riverpod observers](https://riverpod.dev/docs/concepts2/observers).

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(ProviderObserverContext context, Object? previousValue, Object? newValue) {
    // Log or send to analytics when a provider updates
  }

  @override
  void providerDidFail(ProviderObserverContext context, Object error, StackTrace stackTrace) {
    // Log provider errors
  }
}

// In main: ProviderScope(observers: [AppProviderObserver()], child: MyApp(...))
```

### 1️⃣5️⃣ Golden Rules (Production Apps)

- Domain logic in Notifier
- Async = AsyncNotifier
- UI listens (watch), does not control (read for actions only)
- Prefer pattern matching for AsyncValue
- Use optimistic updates where it improves UX
- Avoid global mutable state
- Avoid custom event bus unless absolutely necessary
- Keep state immutable
- Use feature-based structure

### Ultra Short Summary

**Riverpod 3 professional setup:**

- `@riverpod` everywhere
- Notifier for sync, AsyncNotifier for async
- `ref.watch` → UI
- `ref.read` → action
- `ref.listen` → side effects
- `switch` pattern matching for AsyncValue
- Immutable state
- Optimistic updates for better UX

Riverpod 3 adds automatic retry for failed providers, pause/resume when widgets leave the screen, and (experimental) offline persistence and mutations. For side effects (e.g. form submit, button actions) with loading/error/success, consider Riverpod 3's **mutations** (`@mutation`) so the UI can react without providers being disposed mid-flight; see the Riverpod docs for mutation usage.

---

## 📦 Required Dependencies

**Riverpod 3** requires **Dart 3.7+** (and Flutter 3.24+). If `flutter pub get` fails due to version conflicts with `json_serializable`, either switch to Flutter beta or pin `flutter_riverpod: ^3.1.0`. Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management (Riverpod 3)
  flutter_riverpod: ^3.3.1
  riverpod_annotation: ^4.0.2

  # Models: freezed for immutable data, ==/hashCode/copyWith
  freezed_annotation: ^2.4.1
  # json_serializable optional but recommended for fromJson/toJson

  # Networking
  dio: ^5.4.0

  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # UI Utilities
  flutter_screenutil: ^5.9.3

  # Routing (GoRouter - declarative routing, use app/router/)
  # GoRouter 17 requires Flutter 3.32 / Dart 3.8; if on older Flutter SDK, use latest compatible (e.g. ^14.0.0 for Flutter 3.24)
  go_router: ^17.0.0

  # Internationalization
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.0

  # Firebase (optional; Flutterfire v3 — ensure Flutter SDK and Gradle/AGP are compatible)
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^16.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

  # Code Generation (Riverpod 3)
  riverpod_generator: ^4.0.3
  build_runner: ^2.4.8
  freezed: ^2.4.5
  # json_serializable: ^6.7.1  # if using json_serializable

  # Riverpod lint rules (riverpod_lint requires custom_lint to run)
  custom_lint: ^0.7.0
  riverpod_lint: ^2.3.0

  # Native splash and app icon (run once after config)
  flutter_native_splash: ^2.3.0
  flutter_launcher_icons: ^0.14.0
```

After adding the above, run code generation (see **Code Generation Commands** for full details):

```bash
dart run build_runner build --delete-conflicting-outputs
```

Ensure `analysis_options.yaml` enables the Riverpod plugin so `riverpod_lint` runs. **Ensure `custom_lint` is in dev_dependencies** so riverpod_lint rules actually run.

```yaml
analyzer:
  plugins:
    - riverpod_lint
```

---

## 🚀 Implementation Examples

### 1. Main Entry Point (`main.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router/app_router.dart';
import 'controllers/global_controller.dart';
import 'locale/language.dart';
import 'services/notification_service.dart';

// For Firebase (optional)
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'firebase_options.dart';

// Background message handler (Firebase)
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   AppLogger.log('Received background message: ${message.notification?.title}');
// }

// Shared preferences provider — override in ProviderScope or you get a clear error
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError(
    'sharedPreferencesProvider was not overridden. '
    'Add overrides: [sharedPreferencesProvider.overrideWithValue(prefs)] in ProviderScope.',
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize(); // Prevents null-check failures in headless/test environments

  // Initialize Firebase (optional)
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Get saved language
  final langCode = sharedPreferences.getString('lang') ?? 'en';
  final langKey = sharedPreferences.getString('langKey') ?? 'US';
  final langValue = Locale(langCode, langKey);

  // Lock orientation (optional)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: MyApp(lang: langValue),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final Locale lang;

  const MyApp({super.key, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Design size from Figma/XD
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (ctx, child) {
        return MaterialApp.router(
          routerConfig: ref.watch(appRouterProvider),
          title: 'App Name',
          debugShowCheckedModeBanner: false,
          locale: currentLocale ?? lang,
          localizationsDelegates: Languages.localizationsDelegates,
          supportedLocales: Languages.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
        );
      },
    );
  }
}
```

**Note (flutter_screenutil):** Use `builder:` so `MaterialApp.router` is built inside the callback — that way ScreenUtil is initialized before theme/routes and `.sp` in ThemeData works. Do not pass MaterialApp as `child:` or theme is evaluated before measurement. If you need to lock system text scaling, use `MediaQuery` in the builder, e.g.:

```dart
builder: (ctx, child) {
  return MediaQuery(
    data: MediaQuery.of(ctx).copyWith(textScaler: TextScaler.noScaling),
    child: MaterialApp.router(...),
  );
}
```

---

### 2. Controller Example (`controllers/auth_controller.dart`)

**Important:** Notifiers stay Flutter-agnostic. Do not put UI controllers in Notifiers (see Avoid Common Mistakes). The screen holds text controllers and uses `ref.listen(authControllerProvider, ...)` to navigate on success.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/login_model.dart';
import '../data/repositories/auth_repository.dart';  // or services if no repository
import '../services/validators.dart';

part 'auth_controller.g.dart';

// Auth State — use freezed in production for ==, hashCode, copyWith
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final LoginModel? user;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.user,
  });

  static final _sentinel = Object();

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Object? errorMessage = _sentinel,
    LoginModel? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
      user: user ?? this.user,
    );
  }
}

// Auth Controller Notifier — no TextEditingController, no BuildContext (keepAlive so auth survives navigation)
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  late final AuthRepository _authRepository;
  late final Validators _validators;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _validators = ref.read(validatorsProvider);
    return const AuthState();
  }

  Future<bool> login({required String userId, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final passValidator = _validators.validatePassword(value: password);
    if (passValidator != null) {
      state = state.copyWith(isLoading: false, errorMessage: passValidator);
      return false;
    }

    final result = await _authRepository.login(userId: userId, password: password);
    if (!ref.mounted) return false; // Check after async gap (see Avoid Common Mistakes)
    switch (result) {
      case ApiSuccess(:final data):
        state = state.copyWith(isLoading: false, isAuthenticated: true, user: data);
        return true;
      case ApiBadRequest(:final message):
      case ApiForbidden(:final message):
      case ApiClientError(:final message):
      case ApiNetworkError(:final message):
        state = state.copyWith(isLoading: false, errorMessage: message ?? 'Request failed');
        return false;
      case ApiUnauthorized():
      case ApiNotFound():
      case ApiServerError():
        state = state.copyWith(isLoading: false, errorMessage: 'Login failed');
        return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    if (!ref.mounted) return;
    state = const AuthState();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(api: ref.read(apiWrapperProvider), userService: ref.read(userServiceProvider));
}
```

`apiWrapperProvider` is defined in the Services layer (see Dio Client / apiWrapperProvider).

---

### 3. Global Controller (`controllers/global_controller.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_controller.g.dart';

// Locale Provider (keepAlive so locale survives navigation/hot reload)
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  Locale? build() {
    return null; // Will use default from SharedPreferences
  }

  void setLocale(Locale locale) {
    state = locale;
  }
}

// Simplified alias
final localeProvider = localeControllerProvider;

// App State Provider (keepAlive for global app state)
@Riverpod(keepAlive: true)
class AppState extends _$AppState {
  @override
  AppStateData build() {
    return const AppStateData();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}

class AppStateData {
  final bool isLoading;
  final bool isInitialized;
  final String? errorMessage;

  const AppStateData({
    this.isLoading = false,
    this.isInitialized = false,
    this.errorMessage,
  });

  static final _sentinel = Object();

  AppStateData copyWith({
    bool? isLoading,
    bool? isInitialized,
    Object? errorMessage = _sentinel,
  }) {
    return AppStateData(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }
}

// Theme Mode Provider (keepAlive for global theme state)
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }
}
```

---

### 4. Model Example (`models/user_model.dart`)

Prefer **freezed** (and optionally **json_serializable**) for models so you get `==`, `hashCode`, `copyWith`, and consistent serialization. That makes Riverpod’s `.select()` and rebuilds reliable.

**With freezed** (recommended): run the code generation command (see Code Generation Commands) to generate `user_model.freezed.dart` and `user_model.g.dart`.

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
    String? token,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

Without freezed, implement `copyWith`, `==`, and `hashCode` manually so `.select()` and equality checks work correctly.

---

### 5. Dio Client (`services/dio_client.dart`)

**Prefer dependency injection via Riverpod** so the client can be overridden in tests. Do **not** log HTTP in DioClient methods — use a **Dio interceptor** (e.g. `ApiLoggingInterceptor` in `utils/api_logging_interceptor.dart`) registered when building Dio; see "API request/response logging" in the Services layer.

Example: provide Dio (with interceptor) via provider; ApiWrapper receives it and uses it for all requests. Avoid static `DioClient.get()` / `DioClient.post()` so tests can inject a mock.

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/api_logging_interceptor.dart';

// Single source for base URL (used by Dio and by wrapper when building full URLs)
const String apiBaseUrl = 'https://your-api-base-url.com/api';

@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
  ));
  dio.interceptors.add(ApiLoggingInterceptor());
  // Add 401 handling: refresh token then retry (see "401 handling and retry" below)
  // Add auth interceptor that reads token from storage and sets Authorization header
  return dio;
}
```

**401 handling and retry:** The wrapper (or Dio client) should handle expired tokens: on **401**, call the refresh-token endpoint, then **retry the original request** with the new token. Use **QueuedInterceptorsWrapper** (not the abstract `QueuedInterceptor`) with an `_isRefreshing` flag so concurrent requests wait for a single refresh and you avoid deadlock when calling `dio.fetch` inside `onError`:

```dart
class AuthInterceptor extends QueuedInterceptorsWrapper {
  late final Dio dio; // Set after construction to avoid circular ref (dio → interceptor → dio)
  bool _isRefreshing = false;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        await refreshToken(); // your refresh logic
        _isRefreshing = false;
        handler.resolve(await dio.fetch(err.requestOptions));
      } catch (e) {
        _isRefreshing = false;
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
final dio = Dio(baseOptions);
final authInterceptor = AuthInterceptor();
authInterceptor.dio = dio;
dio.interceptors.add(authInterceptor);
```

Use this `dioClientProvider` (or a wrapper that holds Dio + token refresh logic) inside your ApiWrapper/service so all HTTP goes through one injectable client.

Provide the API wrapper so repositories (e.g. AuthRepository) can depend on it. Define `ApiWrapper` in `services/api/api_wrapper.dart` to use Dio and return `ApiResult<T>`; then expose it via a provider:

```dart
final apiWrapperProvider = Provider<ApiWrapper>((ref) => ApiWrapper(ref.read(dioClientProvider)));
```

Controllers and repositories should read `apiWrapperProvider` (not Dio directly) so the API layer stays testable.

---

### 6. API List (`services/api_list.dart`)

Hold **paths only**; the Dio client (or ApiWrapper) uses a single `baseUrl` constant (e.g. `apiBaseUrl` in the Dio section) and combines base + path when making requests so the base URL is defined in one place.

```dart
class APIList {
  // Paths only; base URL is in Dio client / apiBaseUrl constant
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String refreshToken = '/refresh-token';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String changePassword = '/change-password';

  static const String settings = '/settings';
  static const String languages = '/languages';

  static String getItemById(int id) => '/items/$id';
  static String updateItem(int id) => '/items/$id/update';
  static String deleteItem(int id) => '/items/$id/delete';

  /// Append page/limit query params. Use when endpoint has no query string; if it already has params, build at call site with Uri.parse(endpoint).replace(queryParameters: {...}).
  static String paginate(String endpoint, int page, {int limit = 20}) {
    final separator = endpoint.contains('?') ? '&' : '?';
    return '$endpoint${separator}page=$page&limit=$limit';
  }
}
```

---

### 7. User Service (`services/user_service.dart`)

Inject **SharedPreferences** via the constructor (from `sharedPreferencesProvider` in main) so you reuse one instance instead of calling `SharedPreferences.getInstance()` on every read/write.

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  UserService({required SharedPreferences prefs, FlutterSecureStorage? storage})
      : _prefs = prefs,
        _storage = storage ?? const FlutterSecureStorage();

  final SharedPreferences _prefs;
  final FlutterSecureStorage _storage;

  // Secure Storage (for sensitive data like tokens)
  Future<void> saveSecure({required String key, required String? value}) async {
    if (value != null) {
      await _storage.write(key: key, value: value);
    }
  }

  Future<String?> readSecure({required String key}) async {
    return _storage.read(key: key);
  }

  Future<void> deleteSecure({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<void> clearSecureStorage() async {
    await _storage.deleteAll();
  }

  // Shared Preferences (for non-sensitive data) — use injected _prefs
  Future<void> saveString({required String key, required String? value}) async {
    if (value != null) {
      await _prefs.setString(key, value);
    }
  }

  Future<String?> readString({required String key}) async {
    return _prefs.getString(key);
  }

  Future<void> saveBoolean({required String key, required bool value}) async {
    await _prefs.setBool(key, value);
  }

  Future<bool> readBoolean({required String key}) async {
    return _prefs.getBool(key) ?? false;
  }

  Future<void> saveInt({required String key, required int value}) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> readInt({required String key}) async {
    return _prefs.getInt(key);
  }

  Future<void> remove({required String key}) async {
    await _prefs.remove(key);
  }

  Future<void> removeAll() async {
    await _prefs.clear();
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await readSecure(key: 'token');
    return token != null && token.isNotEmpty;
  }
}

// Provide UserService from sharedPreferencesProvider (keepAlive — avoid recreating on nav and storage races)
@Riverpod(keepAlive: true)
UserService userService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserService(prefs: prefs);
}
```

---

### 8. Validators (`services/validators.dart`)

```dart
class Validators {
  const Validators();

  // Email validation
  String? validateEmail({String? value}) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation
  String? validatePassword({String? value, int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  // Confirm password validation
  String? validateConfirmPassword({String? password, String? confirmPassword}) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Confirm password is required';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Phone validation
  String? validatePhone({String? value}) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-()]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required field validation
  String? validateRequired({String? value, String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Minimum length validation
  String? validateMinLength({String? value, int minLength = 3, String fieldName = 'This field'}) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  // Maximum length validation
  String? validateMaxLength({String? value, int maxLength = 255, String fieldName = 'This field'}) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    return null;
  }

  // Numeric validation
  String? validateNumeric({String? value, String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }

    return null;
  }
}

// Singleton for stateless validators — inject via ref.read(validatorsProvider) in AuthController
@Riverpod(keepAlive: true)
Validators validators(Ref ref) => const Validators();
```

---

### 9. Screen Example (`screens/authentication/login_screen.dart`)

**Pattern:** Do not put UI controllers in Notifiers (see Avoid Common Mistakes). Use `ref.listen(authControllerProvider, ...)` to navigate when auth succeeds (side effect), not inside the login method. Use theme colors (see Flutter UI Best Practices) instead of `Colors.grey` / `Colors.red`; the example below uses `colors.onSurfaceVariant` and `colors.error`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../controllers/auth_controller.dart';
import '../../app/router/app_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final authNotifier = ref.read(authControllerProvider.notifier);

    // Side effect: navigate when authenticated (do not pass context into Notifier)
    ref.listen(authControllerProvider, (prev, next) {
      if (next.isAuthenticated && context.mounted) {
        context.goNamed(RouteNames.home);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.h),
              Text('Welcome Back', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              SizedBox(height: 8.h),
              Text('Sign in to continue', style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant), textAlign: TextAlign.center),
              SizedBox(height: 48.h),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email or Username',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureText,
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
              SizedBox(height: 24.h),
              if (authState.errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Text(authState.errorMessage!, style: TextStyle(color: colors.error, fontSize: 14.sp), textAlign: TextAlign.center),
                ),
              CustomButton(
                text: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: () => authNotifier.login(
                  userId: _emailController.text,
                  password: _passwordController.text,
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(onPressed: () {}, child: const Text('Forgot Password?')),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(onPressed: () {}, child: const Text('Sign Up')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 10. Common Widgets (`screens/widgets/`)

#### `custom_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? colors.primary,
          foregroundColor: textColor ?? colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
```

#### `custom_text_field.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: colors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: colors.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
    );
  }
}
```

#### `loading_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? colors.primary,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 16.h),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

### 11. Utils Examples

#### `utils/colors.dart`

Use these constants only when defining `ThemeData` (e.g. in `lightTheme` / `darkTheme`); never use `AppColors` directly in widgets — use `Theme.of(context).colorScheme` in widgets so dark mode works.

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Secondary Colors
  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFF5F5F5);
  static const Color greyDark = Color(0xFF616161);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
}
```

#### `utils/constants.dart`

```dart
class AppConstants {
  // App Info
  static const String appName = 'Your App Name';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String languageKey = 'lang';
  static const String themeKey = 'theme';
  static const String onboardingKey = 'onboarding_completed';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 2);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}
```

---

## 🧪 Testing Structure

```
test/
├── unit/
│   ├── controllers/
│   │   └── auth_controller_test.dart
│   ├── services/
│   │   └── user_service_test.dart
│   └── models/
│       └── user_model_test.dart
├── widget/
│   ├── screens/
│   │   └── login_screen_test.dart
│   └── widgets/
│       └── custom_button_test.dart
└── integration/
    └── app_test.dart
```

---

## 🖼️ Assets, native splash & app icon

### Image assets structure

Keep all image assets under **`assets/images/`**. Use subfolders to group by usage (e.g. `common/`, `onboarding/`, or by feature). Declare them in `pubspec.yaml` so Flutter includes them in the build:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/common/
    # List each subfolder explicitly — Flutter does not recursively include subfolders
  fonts:
    - family: MyFont
      fonts:
        - asset: assets/fonts/MyFont-Regular.ttf
```

Reference images in code via path constants (avoid hardcoded strings). Use a small constants file or an `assets` helper:

```dart
// utils/image.dart or constants/asset_paths.dart
class AssetPaths {
  static const logo = 'assets/images/common/logo.png';
  static const placeholder = 'assets/images/common/placeholder.png';
}

// In widgets
Image.asset(AssetPaths.logo)
// or
DecorationImage(image: AssetImage(AssetPaths.placeholder), fit: BoxFit.cover)
```

Prefer **path constants** in one place so renaming or moving assets only requires updating the constant.

### Native splash screen

Use **flutter_native_splash** to generate platform-specific splash screens (Android 12+ splash API, iOS launch screen). Add the package and configure in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_native_splash: ^2.3.0

flutter_native_splash:
  color: "#2196F3"           # Background color
  image: assets/images/common/splash_logo.png   # Optional center image
  android_12:
    image: assets/images/common/splash_logo.png
    color: "#2196F3"
```

Then run **`dart run flutter_native_splash:create`** once (or when you change config). The package generates/updates the native splash resources; no manual editing of Android/iOS project files needed.

### App icon generator

Use **flutter_launcher_icons** to generate all required launcher icon sizes from a single source image (e.g. 1024x1024). Add the package and configure in `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"   # Source image (e.g. 1024x1024)
  # Optional: adaptive icon for Android
  # adaptive_icon_background: "#2196F3"
  # adaptive_icon_foreground: "assets/icons/foreground.png"
```

Then run **`dart run flutter_launcher_icons`** once (or when you change the source image). The package overwrites the default launcher icons in the Android and iOS projects.

**Summary:** Put source images in `assets/images/` (and optionally `assets/icons/` for the app icon source). Use **flutter_native_splash** and **flutter_launcher_icons** so splash and launcher icons are generated from assets instead of editing native projects by hand.

---

## 📋 Checklist for New Projects

1. **Setup**

   - [ ] Create Flutter project
   - [ ] Add dependencies to `pubspec.yaml`
   - [ ] Set up folder structure
   - [ ] Configure `analysis_options.yaml`

2. **Core**

   - [ ] Set up `main.dart` with ProviderScope
   - [ ] Configure DioClient with base URL
   - [ ] Set up API endpoints in `api_list.dart`
   - [ ] Create `UserService` for storage

3. **Features**

   - [ ] Create Models
   - [ ] Create Controllers (Providers)
   - [ ] Create Screens
   - [ ] Create Widgets

4. **Assets**

   - [ ] Add fonts to `assets/fonts/` and declare in `pubspec.yaml` under `flutter/fonts`
   - [ ] Add images under `assets/images/` (e.g. `common/`, feature subfolders) and declare in `pubspec.yaml` under `flutter/assets`
   - [ ] Add in-app icons to `assets/icons/` if needed
   - [ ] Use path constants (e.g. `AssetPaths`) when referencing images in code
   - [ ] **Native splash:** Add `flutter_native_splash`, configure in `pubspec.yaml`, then run `dart run flutter_native_splash:create`
   - [ ] **App icon:** Add `flutter_launcher_icons`, set `image_path` in `pubspec.yaml`, then run `dart run flutter_launcher_icons`

5. **Localization**

   - [ ] Set up language files
   - [ ] Configure localization delegates

6. **Testing**
   - [ ] Write unit tests
   - [ ] Write widget tests
   - [ ] Write integration tests

---

## 🔧 Code Generation Commands

Use **dart run** (recommended) for build_runner:

```bash
# Generate Riverpod (and freezed/json_serializable) code
dart run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
dart run build_runner watch --delete-conflicting-outputs
```

---

## 📝 Naming Conventions

| Type      | Convention                        | Example                       |
| --------- | --------------------------------- | ----------------------------- |
| Files     | snake_case                        | `auth_controller.dart`        |
| Classes   | PascalCase                        | `AuthController`              |
| Variables | camelCase                         | `userName`                    |
| Constants | camelCase or SCREAMING_SNAKE_CASE | `maxRetries` or `MAX_RETRIES` |
| Providers | camelCase + Provider suffix       | `authControllerProvider`      |
| Private   | Prefix with underscore            | `_privateMethod`              |

---

## Dart 3 & null handling

Use null safety and Dart 3 patterns consistently so code stays readable and crash-free.

### 1. Null-aware access (`?.`)

Prefer `?.` instead of explicit null checks when you only need to call a member or pass through null:

```dart
// Prefer
print(name?.length);

// Avoid (verbose)
if (name != null) {
  print(name.length);
}
```

`?.` runs only when not null and returns null otherwise instead of throwing.

### 2. Default value with `??`

Use `??` when a fallback is needed:

```dart
// Prefer
print(name ?? "Guest");

// Avoid
if (name == null) {
  print("Guest");
} else {
  print(name);
}
```

### 3. Assign if null (`??=`)

Use `??=` when you want to set a variable only if it is currently null:

```dart
// Prefer
name ??= "Guest";

// Avoid
if (name == null) {
  name = "Guest";
}
```

### 4. `late` when value is set before use

Use `late` for non-nullable fields that are guaranteed to be assigned before first use (e.g. in `initState` or constructor body). Do not use for values that may legitimately be absent.

```dart
late String token;  // Only if you guarantee it's assigned before use
```

### 5. Pattern matching for null (Dart 3)

Use pattern matching instead of `if (x != null)` when you want to bind a non-null variable:

```dart
// Prefer (Dart 3)
if (user case final u?) {
  print(u.name);
}

// Alternative
if (user != null) {
  print(user.name);
}
```

### 6. `switch` with null (Dart 3)

Use `switch` for null and type cases:

```dart
switch (value) {
  case null:
    print("No value");
  case String v:
    print(v);
  case int v:
    print(v.toString());
  default:
    break;
}
```

### 7. Flutter widgets: null-safe text and UI

Use `?.` and `??` so widgets get a single expression instead of branching:

```dart
// Prefer
return Text(user?.name ?? "No user");

// Avoid (verbose)
if (user != null) {
  return Text(user.name);
} else {
  return Text("No user");
}
```

### 8. Prefer `required` over optional nullable parameters

For parameters that are logically required, use `required` and a non-nullable type instead of a nullable one with a default of null:

```dart
// Prefer
class MyWidget extends StatelessWidget {
  final String title;
  const MyWidget({required this.title});
}

// Avoid (nullable when value is always expected)
class MyWidget extends StatelessWidget {
  final String? title;
  MyWidget({this.title});
}
```

Use nullable only when the value is truly optional.

---

## 🎯 Best Practices

1. **State Management**

   - Keep controllers (Notifiers) focused on single responsibility; do not put UI controllers in Notifiers (see Avoid Common Mistakes).
   - Use `@riverpod` with Notifier/AsyncNotifier for complex state. Prefer autoDispose for screen-scoped state (see Provider Type Decision Tree).
   - Dispose resources in `ref.onDispose`; prefer constructor-injected dependencies (repositories, services) for testability.

2. **API Calls**

   - Use `ApiWrapper` and `ApiResult<T>` for HTTP calls; handle outcomes with an exhaustive switch on the sealed type (see **API usage structure** under Services Layer).
   - Always handle errors gracefully
   - Show loading states
   - Implement retry logic for failed requests. Riverpod 3 **retries failed async providers by default** (exponential backoff, up to ~10 times). For custom retry, use `@Riverpod(retry: myRetry)` or `ProviderScope(retry: myRetry, child: MyApp())` with a function like: `Duration? myRetry(int retryCount, Object error) { if (retryCount >= 5) return null; return Duration(milliseconds: 200 * (1 << retryCount)); }` (return `null` to stop retrying). If your AsyncNotifier (or provider) wraps an API call that already has its own retry logic, either disable Riverpod's auto-retry for that provider with `@Riverpod(retry: (_) => null)` or remove manual retry from the service layer to avoid double retries.

3. **Code Organization**

   - One widget per file
   - Group related functionality
   - Use barrel files for exports

4. **Performance**
   - Use `const` constructors where possible
   - Implement pagination for lists
   - Cache data when appropriate
   - For pausing off-screen widgets, the docs recommend `TickerMode` over `Visibility`.
   - Use **ref.listen(..., weak: true)** when you only want to react to changes without causing the provider to be initialized (e.g. avoid triggering a network request until needed).
   - For UI rules (ScreenUtil, colors, const, theme, lists), see **Flutter UI Best Practices**.

---

## Flutter UI Best Practices

### Must follow (enforced)

- **ScreenUtil for layout and text:** The app uses `flutter_screenutil`. Always use `.h`, `.w`, `.sp`, `.r` for dimensions and font sizes. Never use `MediaQuery.of(context).size` for layout widths/heights or hardcode pixel values (e.g. `width: 100`). Example: `SizedBox(height: 16.h)`, `Text('Hello', style: TextStyle(fontSize: 14.sp))`, `0.8.sw` for 80% screen width. For vertical spacing and padding, prefer `.w` over `.h` unless the element must scale with screen height — `.h` can cause overflow on shorter devices. Use `12.sm` for minimum font sizes (returns `min(12, 12.sp)`) so text doesn't grow too large on tablets. For custom bottom nav or status-bar-aware headers, use `ScreenUtil().bottomBarHeight` and `ScreenUtil().statusBarHeight`.
- **No hardcoded colors in widgets:** Never use `Colors.grey`, `Colors.red`, or `Color(0xFF...)` directly in widget trees. Use `Theme.of(context).colorScheme` (e.g. `colorScheme.primary`, `colorScheme.onSurfaceVariant`, `colorScheme.error`) or a project `ThemeExtension` (e.g. `Theme.of(context).extension<AppColorScheme>()?.textHint`). Keeps light/dark and theming consistent. Constants like `AppColors` (raw `Color(0xFF...)`) are only for building `ThemeData` (e.g. in `lightTheme` / `darkTheme`); never use them directly in widgets — use `colorScheme` in widgets so dark mode works.
- **const constructors:** Any widget whose children and parameters are compile-time constant must be marked `const` (e.g. `const Text('Sign In')`, `const SizedBox(width: 8)`, `const Icon(Icons.email)`). Do not use `const` where values depend on ScreenUtil (e.g. `16.h`) or runtime state. ScreenUtil extensions (`.h`, `.w`, `.sp`) are runtime values, so widgets using them cannot be `const`.

### Important (recommended)

- **Widget extraction:** If a subtree in `build()` exceeds roughly 20 lines or has a clear standalone responsibility (e.g. a card, a section header), extract it into a private or shared widget (e.g. `_MosqueCard`, `_SectionHeader`). Avoid 300-line `build()` methods.
- **Theme shorthand at top of build():** At the start of `build(BuildContext context)`, destructure theme once: `final theme = Theme.of(context); final colors = theme.colorScheme; final textTheme = theme.textTheme;` then use `colors.primary`, `textTheme.bodyLarge`, etc. Avoid repeating `Theme.of(context).` many times.
- **TextStyle from theme:** Prefer `theme.textTheme.headlineLarge`, `theme.textTheme.bodyMedium`, etc., and use `.copyWith(color: ..., fontSize: ...)` when overriding. Avoid raw `TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)` everywhere so font family and scale stay consistent with the theme.

### Good to follow

- **SafeArea:** Apply `SafeArea` at the outermost screen scaffold (e.g. wrapping the body of `Scaffold`), not on every inner widget. Avoid nesting multiple `SafeArea`s.
- **Dynamic lists:** For lists of variable length, use `ListView.builder` (or `ListView.separated`) so only visible items are built. Never use `Column(children: items.map((e) => ItemCard(e)).toList())` for long lists — it builds every item at once.
- **Loading states:** Prefer a consistent approach: full-screen loading for initial screen load, skeleton loaders where content shape is known, inline spinners for local actions (e.g. button). Document the chosen pattern in the guide so all screens stay consistent.
- **Back navigation with confirmation:** For screens where back should be confirmed (e.g. unsaved form, ongoing call), use `PopScope` (Flutter 3.22+). `WillPopScope` is deprecated.

---

> **Note:** See Code Generation Commands for build_runner.

---

## Using AI tools to build or extend this architecture

When using AI (e.g. Cursor) to implement or extend this architecture, follow the guidelines below so work stays consistent, requirements are clear, and syntax/docs are correct.

### Build phase by phase

- Work **phase by phase** (one phase per layer or concern) instead of a single large change.
- **Default phase order** (align with this doc):
  - **Phase 1:** Project structure, routing, and core config (main, router, ProviderScope).
  - **Phase 2:** Data and services (models, API list, Dio, ApiWrapper, repositories if used).
  - **Phase 3:** State management (controllers/providers, auth/global).
  - **Phase 4:** Presentation (screens, widgets, theme usage).
  - **Phase 5:** Cursor rules and polish (see Final phase: Cursor rules below).
- **If the overall requirement is large,** either:
  - break it into smaller prompts (one or a few phases per prompt), or
  - use a single larger prompt that explicitly lists all phases and requirements.

### Clarifying requirements (ask doubts)

- **Always ask the user** when there is any doubt about requirements in a prompt (e.g. ambiguous acceptance criteria, missing error handling, unclear business rules).
- In **each** prompt or sub-task, if anything is unclear (scope, behavior, or constraints), ask 1–2 focused questions before implementing.

### Resolving syntax and documentation doubts

- When in doubt about **syntax, APIs, or official docs** (e.g. Riverpod, Dio, Flutter), do not guess.
- Use **web search** for official documentation and current syntax.
- If the environment has **Context7 MCP** (or similar documentation MCP), use it to fetch up-to-date library docs and examples.
- Prefer official sources (e.g. riverpod.dev, pub.dev, api.flutter.dev) when resolving conflicts.

### Final phase: Cursor rules (implementation reflected in rules)

When the AI **implements** this architecture (or a feature following it), the **last phase** must ensure the implementation is reflected in **Cursor rules**, split by concern so future work stays consistent.

- **One rule file per concern** in `.cursor/rules/` (or equivalent):
  - **Theme** — colors, ThemeData, dark mode, extensions (e.g. `theme.mdc`).
  - **API** — ApiWrapper, ApiResult, APIList, Dio, interceptors, repositories.
  - **UI** — ScreenUtil, layout, widgets, Flutter UI Best Practices from this doc.
  - **State** — Riverpod (watch/read/listen), controllers, providers, testing.
  - **Router** — GoRouter, routes, redirect, ShellRoute.
  - **AI usage** — `ai_usage.mdc`. This rule **must always be triggered** (global / always-on) so the AI consistently follows: build phase by phase; ask doubts in each prompt when requirements are unclear; resolve syntax/docs via web search or Context7 MCP. Configure it to apply to every conversation or agent session in this project.
- **New features** must follow this rule structure: implement and update the relevant rule files so the codebase and rules stay in sync.
- The existing `.cursor/rules/ARCHITECTURE.md` (or project-level rule) can remain; the convention above **additionally** splits by theme, api, UI, state, router, and **ai_usage** (always-on).

### docs/postman directory and API integration

- **docs/postman/** (outside `lib/`) is the **canonical place** for Postman collection and environment JSON files when the **user provides** them for API integration.
- Place exported Postman collection (and optionally environment) JSON files in `docs/postman/`.
- When integrating APIs from a provided Postman collection: use these files as the reference for endpoints, request shapes, and (if applicable) env vars; implement in the app following this architecture (APIList paths, ApiWrapper, repositories, etc.).
- For a step-by-step integration plan when using a Postman collection, see `docs/POSTMAN_INTEGRATION_PLAN.md` (or equivalent) if present in the project.
