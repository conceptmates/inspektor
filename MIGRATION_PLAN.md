# Certifide Inspektor — Migration / Rewrite Plan

Rewrite of the old `Certifide_inspektor` app into this clean app, following
`architecture.md` (Riverpod 3 + Dart 3 + freezed + GoRouter + Dio/ApiWrapper).
**Same UI, flow, and logic** for the in-scope features; clean structure; only
the APIs the app actually uses.

## Scope (decided)

| Decision | Choice |
|---|---|
| Feature scope | **Core inspection only** |
| Theme | **Dark-only** (single dark `ThemeData`, `themeMode` fixed dark) |
| Offline storage | **Unify two Hive systems into one queue + fix the sync status bug** |

**IN scope:** auth (login, session bootstrap, refresh, logout, me) · home
dashboard (stats chart + "Start Inspection" hero) · vehicle/template selection ·
dynamic inspection capture (text/date/dropdown/image/video/audio/file/multi-image,
remarks, flag-issues, reference media, RC verify) · media capture (camera/video/
audio/file + compress + local save) · offline draft autosave/resume · offline
submission queue + auto-sync · reports (my-history) · history · profile + logout.

**OUT (dropped):** Car-Spy new/used car listings · admin Add User · admin Add
Credits / token allocation · Approvals · Attendance · Work Assigned · inspector
token-balance drawer badge.

## Source of truth

- **Behavior/UI/flow** → old app `Certifide_inspektor/lib/**`.
- **API** → the old app's **actual calls** to `https://api.certifide.in/api`.
  The CRM `certifide-crm/API_*.md` docs are **stale/partial** (missing
  `/dynamic-inspections/initialize`, `/inspection/upload-image`,
  `/dynamic-inspections/my-history`, `/dynamic-inspections/stats`,
  `/ulip/vehicle-details`, `/admin/vehicles/models`). Do **not** drop a used
  endpoint because the CRM markdown omits it. (If a real call later 404s,
  revisit against the live backend.)

## API surface — KEEP (only what in-scope flows call)

Base URL: `https://api.certifide.in/api` (centralize in `dio_client.dart`).
Auth: JWT Bearer in `flutter_secure_storage` key `jwt_token`; user JSON in `user_data`.

| Method + Path | Purpose | Auth | Used by (new) |
|---|---|---|---|
| `POST /auth/login` | Login → JWT + user | public | auth_repository |
| `GET /auth/me` | Current user / session bootstrap | bearer | auth_repository |
| `POST /auth/refresh` | Refresh JWT (carries current bearer) | bearer | dio auth interceptor |
| `GET /admin/vehicles/models` | Brand+model catalog for vehicle form | bearer | inspection_repository |
| `POST /dynamic-inspections/initialize` | Start inspection → template + `inspection_id` | bearer | inspection_repository |
| `POST /ulip/vehicle-details` | RC/registration lookup (`regno` field verify) | bearer | inspection_repository |
| `POST /inspection/upload-image` | Multipart media upload (image/video/audio/file) | bearer | inspection_repository |
| `POST /dynamic-inspections` | Final submit of completed inspection | bearer | inspection_repository |
| `PUT /inspections/{id}` | Update/persist answers (offline sync resend) | bearer | inspection_repository (offline sync) |
| `GET /dynamic-inspections?page=` | Inspection history list (paginated) | bearer | history_controller |
| `GET /dynamic-inspections/my-history?page=` | Current inspector's reports (paginated) | bearer | reports_controller |
| `GET /dynamic-inspections/stats?period&from&to` | Home dashboard stats | bearer | stats_controller |

Logout = client-side (clear secure storage + offline boxes); old app sent no
logout request. (Optional `POST /auth/logout` can be added later.)

## API surface — DROP

- Admin/approver: `POST /auth/register`, `GET /tokens/inspectors`,
  `POST /tokens/allocate`, `GET /tokens/balance`, `POST /inspections/{id}/approve-api`.
- Car-Spy: `GET /cars/new`, `GET /cars/old`, `GET /cars/filters`.
- Dead (0 callers in old app): `POST /inspections/initial`, `GET /auth/me` via
  `isTokenValid`, the whole `VehicleCatalogApi` class.

## Old → new structural fixes (apply throughout)

| Old smell | New |
|---|---|
| Static `ApiService`/`LocalStorageService`, no DI | Repositories + services via Riverpod providers, constructor-injected |
| `Map<String,dynamic>` everywhere, `result['success']` | freezed models + sealed `ApiResult<T>` exhaustive switch |
| `package:http`, per-call 401, proactive JWT decode | Dio + `ApiWrapper` + one auth interceptor (401 → refresh → retry once) |
| `BuildContext` inside `UserNotifier` | Notifiers Flutter-agnostic; navigate via `ref.listen` + GoRouter redirect |
| Navigator named routes + `AuthWrapper` | GoRouter single file + auth redirect + ShellRoute bottom nav |
| `print` / `dart:developer log` / `NetworkLogger` scattered | one `AppLogger`; HTTP logging only in Dio interceptor |
| Two `DropdownOption` classes; untyped template flattened to Map | one API `DropdownOption` (freezed); render from typed `InspectionField` |
| `inspection_page.dart` ~5000-line God widget | decomposed: screen + capture widgets + session controller |
| Two offline Hive models (`InspectionStorageModel` + `LocalInspection`) + status bug | one unified offline model/queue; offline submit + auto-sync use the **same** status; sync always picks up offline records |
| 3 divergent base URLs, keys hardcoded in 6 places | one `apiBaseUrl`; storage keys in `AppConstants`; one `UserService` |

## Offline design (unified)

One Hive model `LocalInspection` (the offline/submitted record) + draft autosave.
Preserve: 500ms-debounced autosave, resume-from-draft, in-memory session
snapshot for instant re-entry, media → local app storage + user-visible export
folder (`Certifide Inspections/{id}/...`), pending-media upload queue, and
connectivity-triggered auto-sync. **Fix:** offline-saved inspections use a single
canonical `status` so `getPendingInspections()`/auto-sync always find them
(old bug: saved `'pending'`, queried `'offline'`). Keep `ReportsCacheService`
(report URL cache) and add a report entry on offline-then-synced submits too.

Hive typeIds: keep `0` (draft) if a separate draft model is retained, else use a
single model. Adapters registered once in `main()` (no scattered re-registration).

## Phases

Each phase: implement → `flutter analyze` clean → `flutter test` green → update
`TASKS.md` → commit `feat(p{N}): <title>`. Don't start next phase before commit.
Use subagents for parallel within a phase; use Flutter skills.

| Phase | Title | Output |
|---|---|---|
| **P0** | Scaffold + config | pubspec deps, analysis_options + riverpod_lint, folder tree, `main.dart`, `app/router/app_router.dart` skeleton, `utils/` (logger, colors, constants, api_logging_interceptor), assets moved, smoke test green |
| **P1** | API core (data/services) | `api/api_result.dart` (sealed), `api/api_wrapper.dart`, `dio_client.dart` (+ auth/refresh interceptor), `api_list.dart` (KEEP only), `user_service.dart`, `data/exceptions.dart`; unit tests for ApiResult mapping + UserService |
| **P2** | Models (freezed) | user, inspection template family, vehicle brand/model, inspection_history, inspection_stats, pagination, unified offline model(s) + Hive adapter; fromJson round-trip tests |
| **P3** | Repositories + storage/sync | auth_repository, inspection_repository, unified local storage service + sync service, media/connectivity helpers; tests w/ mocked ApiWrapper |
| **P4** | Controllers (Riverpod 3) | auth_controller, inspection_session_controller, offline_inspection_controller (+auto-sync), stats/home, history + reports AsyncNotifiers, router refresh notifier + `appRouter` redirect; controller tests w/ mocked repos |
| **P5** | Auth + shell + home + profile | login_screen + session bootstrap, ShellRoute bottom nav (Home/Reports/Profile), home dashboard (stats chart + start-inspection hero), profile + logout; login widget test |
| **P6** | Inspection flow (the heart) | vehicle_details_form, inspection_screen (dynamic render + all field types + per-field nav), camera/video/audio/file capture widgets, field-info + flag-issues sheets, reference media, autosave/resume, inspection_success; render widget test |
| **P7** | Reports / History / Offline | reports_page (my-history), history_page, local_inspections_screen (queue + retry), pagination/infinite-scroll/pull-refresh, error + lottie loading widgets, connectivity banner; list tests |
| **P8** | Polish + cursor rules | dark theme polish, dead-code audit, `.cursor/rules/` (theme/api/ui/state/router/ai_usage) per architecture.md, full analyze + test pass, README |

## Acceptance per phase

- `flutter analyze` → 0 errors (warnings triaged).
- `flutter test` → green.
- No `print`/`debugPrint` in HTTP path; no hardcoded base URL/colors/paths.
- Layer boundaries hold (UI→controller→repository→service→ApiWrapper).
