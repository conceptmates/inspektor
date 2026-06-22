# Certifide Inspektor — Task Tracker

Scope: **core inspection only · dark-only · unified offline**. See `MIGRATION_PLAN.md`.
Mark `[x]` when done. Each phase ends: `flutter analyze` clean → `flutter test`
green → commit `feat(p{N}): <title>`.

Legend: ⬜ todo · 🟦 in progress · ✅ done

---

## P0 — Scaffold + config  ✅
- [x] `pubspec.yaml`: Riverpod 3 (`flutter_riverpod ^3.3.2`), `dio`, `freezed`+`json_serializable`, `go_router`, `flutter_screenutil`, `flutter_secure_storage`, `hive_ce`+`hive_ce_flutter`, all media deps, `connectivity_plus`, `internet_connection_checker`, `fl_chart`, `lottie`, `flutter_svg`, `url_launcher`, `intl`, `uuid`, `path_provider`; dev: `build_runner`, `freezed`, `json_serializable`, `flutter_lints`
  - **Deviations (version conflicts, see pubspec comment):** dropped `riverpod_generator`/`riverpod_annotation` → use hand-written `NotifierProvider` (Riverpod 3, no `@riverpod`); dropped `custom_lint`/`riverpod_lint` (analyzer 8-vs-9 clash); `hive`→`hive_ce`; no `hive_*_generator` → offline records stored as JSON in `Box<String>` via freezed `toJson`/`fromJson`; no `shared_preferences` (secure storage covers token/user/timestamp). **Add riverpod_generator + lints back when analyzer constraints align.**
- [x] `analysis_options.yaml` (default flutter_lints; riverpod_lint deferred)
- [x] folder tree (`app/router`, `screens/home`, `themes`, `utils`; rest added per phase)
- [x] `main.dart`: ProviderScope + ScreenUtilInit + Hive init
- [x] `app/router/app_router.dart` skeleton (RouteNames + RoutePaths + GoRouter provider)
- [x] `utils/logger.dart` (AppLogger), `utils/colors.dart`, `utils/constants.dart`, `utils/api_logging_interceptor.dart`, `themes/app_theme.dart` (dark)
- [x] moved `assets/images` + `assets/lottie` + declared in pubspec
- [x] smoke `flutter test` green · `flutter analyze` clean · commit

## P1 — API core  ✅
- [x] `services/api/api_result.dart` — sealed `ApiResult<T>` (Success + 7 error variants)
- [x] `services/api/api_wrapper.dart` — get/post/put/patch/delete/upload, `useAuth`, status→ApiResult mapping (`mapError` exposed for tests)
- [x] `services/dio_client.dart` — `dioClientProvider` + `apiWrapperProvider`, base URL, `AuthInterceptor` (attach token via `useAuth` extra), 401 → refresh → retry once (QueuedInterceptorsWrapper, `skipRefresh` guard)
- [x] `services/api_list.dart` — 12 KEEP endpoints only
- [x] `services/user_service.dart` — `FlutterSecureStorage`, centralized keys (`jwt_token`/`user_data`/`last_profile_update`) + `userServiceProvider`
- [~] `data/exceptions.dart` — skipped (YAGNI; ApiResult covers HTTP outcomes — add a domain exception when a real throw site needs it)
- [x] tests: 8 ApiWrapper mapping cases (200/400/401/403/404/422/500/network) green · UserService is thin pass-through, no test (trivial) · commit

## P2 — Models (freezed)  ✅
- [x] `user_model.dart` (typed; roles parsed from `[{name}]`; isAdmin/hasRole)
- [x] template family: `InspectionInitializationResponse`, `InspectionTemplate`, `VehicleInfo`, `InspectionStructure`, `InspectionSection`, `InspectionField`, `DropdownOption`, `ReferenceMedia` (snake_case + dual-key readers color/colour, type/media_type, template_type/templateType)
- [x] `vehicle_model.dart` (`VehicleBrand`, `VehicleCategory`, `VehicleModel`)
- [x] `inspection_history_model.dart` (`fromApi` dual-shape synthesizer, no toJson)
- [x] `inspection_stats_model.dart` (`fromApi` reads meta + totals + buckets; activeBuckets)
- [x] `pagination_data_model.dart` (+ hasMore)
- [x] unified `local_inspection.dart` — one `LocalInspection` (draft+queue+submitted via `LocalStatus`) + `PendingMedia`, stored as JSON in `Box<String>` (no Hive adapter codegen). `build.yaml` sets `explicit_to_json: true` for clean round-trip.
- [x] tests: 6 model parse/round-trip cases green · commit

## P3 — Repositories + storage/sync  ✅
- [x] `data/repositories/auth_repository.dart` (login, getProfile/me, readCachedUser, logout-local). `castApiError<T>` helper added to api_result.
- [x] `data/repositories/inspection_repository.dart` (vehicle models+derived brands, initialize, ulip RC, uploadMedia multipart, submit, update, getHistory, getMyHistory, getStats). Typed records: VehicleCatalog/InspectionInit/SubmitResult/HistoryPage.
- [x] `services/local_inspection_service.dart` — unified `Box<String>` JSON store: draft (saveDraft/getDraft/hasFreshDraft) + queue (upsertPending/getPending/getPendingWithMedia/markSubmitted) with **one** status. Boxes opened in `main`.
- [x] `services/connectivity_service.dart` (connectivity_plus + internet probe + onChanged stream)
- [~] sync orchestration → P4 offline controller (composes repo + storage); media file-copy/export + `reports_cache_service` → P6/P7 (built where used)
- [x] tests: auth_repo (login success/401), inspection_repo (stats/history/vehicles/5xx parse), local_inspection_service (status-fix regression) — all green · commit

## P4 — Controllers (Riverpod 3)  ⬜
- [ ] `controllers/auth_controller.dart` (freezed AuthState; login/logout/bootstrap; no BuildContext)
- [ ] `controllers/inspection_session_controller.dart` (in-progress session snapshot)
- [ ] `controllers/offline_inspection_controller.dart` (queue list + retry + auto-sync; Timer/StreamSub in `onDispose`)
- [ ] `controllers/stats_controller.dart` (daily + monthly AsyncNotifier)
- [ ] `controllers/history_controller.dart` + `controllers/reports_controller.dart` (paginated AsyncNotifier)
- [ ] router: `routerRefreshNotifier` + `appRouter` provider with auth redirect
- [ ] tests: controllers w/ mocked repos (ProviderContainer.test) · commit

## P5 — Auth + shell + home + profile  ⬜
- [ ] `screens/authentication/login_screen.dart` (+ session bootstrap / splash)
- [ ] shell: ShellRoute + bottom nav (Home / Reports / Profile)
- [ ] `screens/home/home_screen.dart` (stats chart via fl_chart + "Start Inspection" hero + resume-draft dialog)
- [ ] `screens/profile/profile_screen.dart` (view + logout)
- [ ] shared widgets: `custom_button`, `custom_text_field`, `loading_widget` (lottie), `error_widget`
- [ ] widget test: login · commit

## P6 — Inspection flow (the heart)  ⬜
- [ ] `screens/inspection/vehicle_details_form.dart` (brand→model cascade + fields → initialize)
- [ ] `screens/inspection/inspection_screen.dart` (dynamic render, per-field nav, sections drawer, progress)
- [ ] field types: text/date, dropdown, image, video, audio, file, multi-image (≤11), remarks, flag-issues, RC verify (`regno`)
- [ ] capture widgets: `section_camera_card`, `section_video_camera_card`, audio (record), file picker; review/rotate overlays
- [ ] `widgets/inspection_field_info_sheet.dart` + `constants/inspection_field_explanations`
- [ ] reference media view + info button
- [ ] autosave (500ms debounce) + resume (snapshot → Hive → refetch template) + lifecycle flush
- [ ] submit: online (`/dynamic-inspections`) + offline fallback (queue) + `inspection_success_screen.dart`
- [ ] widget test: dynamic render of a sample template · commit

## P7 — Reports / History / Offline  ⬜
- [ ] `screens/reports/reports_screen.dart` (my-history, pagination, pull-refresh)
- [ ] `screens/history/history_screen.dart` (history list, infinite scroll, status chips, open report URL)
- [ ] `screens/offline/local_inspections_screen.dart` (queue list, per-item retry, cooldown)
- [ ] error + loading states wired; connectivity banner
- [ ] tests: list/pagination · commit

## P8 — Polish + cursor rules  ⬜
- [ ] dark theme finalize (single `darkTheme`, no hardcoded colors in widgets)
- [ ] dead-code audit (no leftover Car-Spy/admin/attendance refs)
- [ ] `.cursor/rules/`: theme · api · ui · state · router · ai_usage (always-on)
- [ ] full `flutter analyze` + `flutter test` green
- [ ] README · commit

---

## Endpoint ↔ Dart symbol map (fill as built)

| Endpoint | api_list const | Repository method | Controller |
|---|---|---|---|
| POST /auth/login | `login` | | |
| GET /auth/me | `me` | | |
| POST /auth/refresh | `refresh` | | |
| GET /admin/vehicles/models | `vehicleModels` | | |
| POST /dynamic-inspections/initialize | `initializeInspection` | | |
| POST /ulip/vehicle-details | `ulipVehicleDetails` | | |
| POST /inspection/upload-image | `uploadMedia` | | |
| POST /dynamic-inspections | `submitInspection` | | |
| PUT /inspections/{id} | `updateInspection` | | |
| GET /dynamic-inspections?page= | `inspectionHistory` | | |
| GET /dynamic-inspections/my-history?page= | `myHistory` | | |
| GET /dynamic-inspections/stats | `inspectionStats` | | |
