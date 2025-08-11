## TrackFlow pre‑production release checklist

This document captures must‑fix items and actionable tasks to prepare for launch.

### 1) Critical blockers (must fix before release)
- [ ] Naming typos in files/folders
  - [ ] Rename `features/navegation/` → `features/navigation/`
  - [ ] Rename `features/onboarding/domain/onboarding_usacase.dart` → `onboarding_usecase.dart`
  - [ ] Rename `features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart` → `update_collaborator_role_usecase.dart`
  - [ ] Update all imports and references after renames
- [ ] Duplicate/overlapping audio seek use cases
  - [ ] Consolidate `features/audio_player/domain/usecases/seek_to_position_usecase.dart` and `features/audio_player/domain/usecases/seek_audio_usecase.dart` into a single canonical use case (pick one name)
  - [ ] Remove the other file and update DI and call sites
- [ ] Deep link service duplication
  - [ ] Consolidate `core/services/deep_link_service.dart` and `core/services/dynamic_link_service.dart` into a single service (prefer naming aligned with Firebase Dynamic Links)
  - [ ] Update DI, imports, and call sites
- [ ] Stale codegen entries in `build.yaml`
  - [ ] Remove non‑existent files from Isar generator list: `test_collection.dart`, `cached_audio_document.dart`, `cache_metadata_document.dart`
  - [ ] Run codegen to validate: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Architecture docs vs implementation drift (audio)
  - [ ] `CLAUDE.md` mentions a centralized `PlaybackController`. Either:
    - Implement `PlaybackController` facade above `audio_player_service` + BLoC, or
    - Update docs to reflect current service+BLoC architecture
- [ ] Dependency overrides cleanup
  - [ ] Remove `dependency_overrides` for `analyzer` and `dart_style` in `pubspec.yaml` by aligning dependency versions (e.g., generators)
  - [ ] Ensure `flutter analyze` passes with no overrides

### 2) High priority (should fix pre‑launch)
- [ ] Tighten lint rules to catch naming and lifecycle issues
  - [ ] Augment `analysis_options.yaml` with stricter rules (see proposal below)
  - [ ] Add CI to fail on lint warnings
- [ ] Stream/BLoC lifecycle hygiene
  - [ ] Ensure every watcher BLoC cancels subscriptions in `close()` and during auth/session transitions (use `ResetableBlocMixin` consistently)
  - [ ] Add tests to verify proper disposal where feasible
- [ ] Theming enforcement
  - [ ] Audit presentation widgets to ensure they use `core/theme` tokens and components
  - [ ] Fix any hard‑coded styles
- [ ] Sync boundaries and conflict policy
  - [ ] Document conflict resolution per aggregate (Projects, Tracks, Comments, Playlists)
  - [ ] Add unit tests for conflict cases
- [ ] Clarify repository and service boundaries
  - [ ] Keep infra concerns out of domain; ensure domain `services` don’t leak data layer details

### 3) Detailed task plan

#### A. File/folder renames (git‑safe)
- Suggested commands:
  ```bash
  git mv lib/features/navegation lib/features/navigation
  git mv lib/features/onboarding/domain/onboarding_usacase.dart lib/features/onboarding/domain/onboarding_usecase.dart
  git mv lib/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart lib/features/manage_collaborators/domain/usecases/update_collaborator_role_usecase.dart
  ```
- Update imports:
  - Use IDE refactors or a search/replace for old paths to new ones.

#### B. Consolidate seek use case
- Pick one name (recommended: `seek_to_position_usecase.dart` for clarity).
- Steps:
  - Migrate logic into the chosen file and delete the other.
  - Update DI registration and references in `audio_player_bloc` and UI.

#### C. Unify deep link services
- Choose a single service, e.g., `dynamic_link_service.dart`.
- Steps:
  - Merge APIs; ensure handling for create/parse/observe links is complete.
  - Delete the redundant file; update DI and call sites.

#### D. Clean `build.yaml`
- Edit to remove non‑existent model entries:
  - `lib/features/playlist/data/models/test_collection.dart`
  - `lib/features/audio_cache/shared/data/models/cached_audio_document.dart`
  - `lib/features/audio_cache/shared/data/models/cache_metadata_document.dart`
- Validate codegen builds cleanly.

#### E. Audio architecture: controller vs service+BLoC
- Option 1: Implement `PlaybackController` facade (recommended if you want a single orchestrator):
  - Provide methods for play/pause/seek/queue/shuffle/repeat and delegate to services/use cases.
  - Inject controller into BLoCs or UI as the single entry point.
- Option 2: Update docs to reflect the current layering (service + domain use cases + BLoC) and remove `PlaybackController` references from `CLAUDE.md`.

#### F. Linting proposal (`analysis_options.yaml`)
- Add rules such as:
  - `always_use_package_imports: true`
  - `avoid_print: true`
  - `prefer_final_locals: true`
  - `prefer_final_in_for_each: true`
  - `unnecessary_late: true`
  - `public_member_api_docs: true` (for exported APIs)
  - `non_constant_identifier_names: true`
  - `file_names: true` (enforce snake_case)
  - `cascade_invocations: true`
  - `sort_constructors_first: true`
  - `avoid_redundant_argument_values: true`
- Gate on CI: `flutter analyze` must be clean.

#### G. Stream/BLoC lifecycle checklist
- Each BLoC:
  - Cancels all StreamSubscriptions in `@override Future<void> close()`
  - Uses `ResetableBlocMixin` where appropriate for session transitions
  - No lingering listeners after navigation/auth state changes

#### H. Sync conflict policy
- For each aggregate, define:
  - Source of truth (local vs remote)
  - Conflict rule (e.g., last write wins, field‑level merge)
  - Timestamps and vector/operation ordering strategy
- Add tests simulating offline edits and concurrent remote updates.

#### I. Theming adherence audit
- Search for hard‑coded colors/typography/spacing in `features/**/presentation/**` and replace with tokens from `core/theme`.

#### J. Dependency hygiene
- Run `flutter pub outdated` and align package versions (esp. generators) to remove `dependency_overrides`.
- Ensure codegen and analyze pass without overrides.

### 4) CI recommendations (GitHub Actions)
- Workflow steps:
  ```yaml
  name: CI
  on:
    pull_request:
    push:
      branches: [ main ]
  jobs:
    build:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: subosito/flutter-action@v2
          with:
            channel: stable
        - run: flutter pub get
        - run: flutter packages pub run build_runner build --delete-conflicting-outputs
        - run: flutter analyze
        - run: flutter test --coverage
  ```
- Add a separate job for integration tests if devices/emulators are available.

### 5) Testing matrix
- Domain/use case unit tests:
  - Auth, Upload Track, Add Audio Comment, Cache Playlist/Track, Play/Pause/Seek
- Data layer tests:
  - Repositories with mocked datasources (remote/local)
- Sync tests:
  - Pending ops queue, conflict resolution, incremental sync services
- Integration tests (already present) should run green end‑to‑end

### 6) Performance & Isar indexing
- Audit Isar models for indices on frequent queries (e.g., by `projectId`, `trackId`, `updatedAt`)
- Avoid over‑indexing; add tests/benchmarks where critical (large libraries)

### 7) Release validation runbook
- [ ] `flutter clean && flutter pub get`
- [ ] Codegen: `build_runner build`
- [ ] Static checks: `flutter analyze`
- [ ] Unit tests: `flutter test`
- [ ] Integration tests: `test/integration_test/run_e2e_tests.sh`
- [ ] Firebase env sanity (dev/staging/prod options present & correct)
- [ ] App size and performance smoke test on low‑end device
- [ ] Crash/analytics SDKs wired and verified

### 8) Post‑release monitoring
- Crashlytics alerts enabled, dashboards in place
- Analytics funnels for onboarding and core actions (create project, upload track, add comment, share link)
- Log sampling and privacy review

---

Notes from current repo scan
- Typos: `features/navegation`, `onboarding_usacase.dart`, `update_colaborator_role_usecase.dart`
- Duplicate seek use cases present
- Two deep link services exist (`deep_link_service.dart`, `dynamic_link_service.dart`)
- `build.yaml` lists non‑existent files for Isar generator
- `CLAUDE.md` mentions `PlaybackController` not present as such in code
- `pubspec.yaml` uses `dependency_overrides` for `analyzer` and `dart_style`
