# Certifide Inspektor — Rewrite (clean architecture)

This app is a **ground-up rewrite** of an existing Vehicle Inspection app. Goal:
**same UI, same flow, same logic** — but restructured to `architecture.md`
(Riverpod 3, Dart 3 patterns, freezed, GoRouter, Dio + ApiWrapper). Drop the
unwanted/dead APIs; keep only endpoints actually used by the inspector app.

## Paths (reference)

| What | Path |
|---|---|
| **New app** (this — build here) | `/Users/mac/Documents/Conceptmate_workspace/certifide/inspektor` |
| **Old app** (source of truth for UI/flow/logic) | `/Users/mac/Documents/Conceptmate_workspace/certifide/Certifide_inspektor` |
| **Backend / CRM** (API docs source of truth) | `/Users/mac/Documents/Conceptmate_workspace/certifide/certifide-crm` |
| **Architecture spec** (MUST follow) | `./architecture.md` |
| **Migration plan** | `./MIGRATION_PLAN.md` |
| **Task tracking** | `./TASKS.md` |

> `certifide-crm` is a Vite/TS frontend, **not** the API server. The API surface
> is documented in its `API_ENDPOINTS_SUMMARY.md`, `API_DOCUMENTATION.md`,
> `ADMIN_API_DOCUMENTATION.md`. Treat those as the API source of truth.

## Old → new stack

| Concern | Old | New (per architecture.md) |
|---|---|---|
| State | Riverpod 2 codegen | Riverpod 3 `@riverpod`, freezed state |
| HTTP | `http` pkg, raw calls | Dio + `ApiWrapper` → sealed `ApiResult<T>` + logging interceptor |
| Routing | Navigator `routes:` + `AuthWrapper` | GoRouter single file + auth redirect |
| Models | hand-written | freezed + json_serializable |
| Offline | Hive boxes + secure storage | **keep** (draft/queue is core) |
| Sizing | raw px | flutter_screenutil |

Heavy native deps stay (camera, video, audio `record`, geolocator, image
compress, file picker, fl_chart, lottie) — real inspection features, not bloat.

## Rules

- **Follow `architecture.md` exactly** — folder layout, layer boundaries,
  Riverpod 3 patterns, GoRouter single-file, ApiWrapper/ApiResult, theme.
- **Only used APIs.** Don't port endpoints the old app never calls. Verify a
  call exists in old code before porting; cross-check shape against CRM docs.
- **Preserve UI + flow + logic** from the old app — restructure code, don't
  redesign behavior.
- **No hardcoded UI data / paths / colors.** Endpoints → `services/api_list.dart`;
  colors → `colorScheme`; sizes → ScreenUtil `.h/.w/.sp/.r`.
- **No `print`/`debugPrint`** in HTTP path — log via interceptor + `AppLogger`.
- **Riverpod 3:** `@riverpod`, Notifier/AsyncNotifier, `watch`/`read`/`listen`,
  pattern-match `AsyncValue`, immutable state, autoDispose by default.

## Workflow (per phase)

1. Implement the phase per `MIGRATION_PLAN.md`.
2. `flutter analyze` clean → `flutter test` green.
3. Update `TASKS.md` (check off + endpoint/symbol mapping).
4. Commit: `feat(p{N}): <phase title>`. Don't start next phase before commit.

Use subagents for parallel work without breaking the build. Use Flutter skills
proactively: `flutter-tester`, `flutter-api`, `flutter-model`, `flutter-riverpod`,
`flutter-router`, `flutter-feature`, `flutter-ui`, `flutter-theme`,
`clean-architecture`, `error-handling`. Ask 1–2 focused questions when a
requirement is unclear (per architecture.md "ask doubts").

## Modes

**ponytail** (full) + **caveman** (full) active for low-token, high-efficiency
work. Lazy = simplest thing that works per the ladder; never simplify away
validation, error handling, security, or offline-data safety.
