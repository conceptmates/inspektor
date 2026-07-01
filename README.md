# Certifide Inspektor

Vehicle inspection app — a clean-architecture rewrite of the legacy
`Certifide_inspektor`. Same UI/flow/logic, restructured per `architecture.md`.

## Stack

- **Riverpod 3** (manual `NotifierProvider`/`AsyncNotifierProvider`) — state
- **Dio** + `ApiWrapper` → sealed `ApiResult<T>` — networking
- **freezed** + `json_serializable` — models
- **GoRouter** — routing (auth redirect + bottom-nav shell)
- **hive_ce** — offline draft + submission queue (JSON in `Box<String>`)
- **flutter_screenutil** — responsive sizing · **fl_chart**, **lottie**
- camera / record / file_picker / image compress / geolocator — media capture

> No `riverpod_generator` / Hive adapter codegen (analyzer-version conflicts —
> see `pubspec.yaml`). freezed + json_serializable codegen IS used.

## Layout (`lib/`)

```
app/router/        GoRouter (RouteNames + RoutePaths + appRouterProvider)
controllers/       Riverpod notifiers (auth, session, submit, stats, lists, offline, media)
data/              repositories/, submission builder
models/            freezed models (user, template engine, vehicle, history, stats, offline)
services/          api/ (ApiWrapper, ApiResult), dio_client, api_list, user/local/connectivity/media storage
screens/           authentication, splash, shell, home, inspection (+widgets), reports, history, offline, profile
themes/ utils/     dark theme, logger, interceptor, colors, constants
```

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after model changes
flutter run
flutter analyze && flutter test
```

API base: `https://api.certifide.in/api` (in `services/dio_client.dart`).

## Docs

- `architecture.md` — the architecture this app follows (authoritative).
- `MIGRATION_PLAN.md` — scope, kept/dropped endpoints, phase plan.
- `TASKS.md` — per-phase progress tracker.
- `.cursor/rules/` — per-concern rules (theme/api/ui/state/router/ai_usage).
