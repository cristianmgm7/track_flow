## Sync downstream optimization and on-demand strategy

### Context and current issues

- Background downstream is triggered frequently via generic `triggerBackgroundSync(syncKey: ...)` calls that fall back to a broad incremental sync when the key is not explicitly supported.
- `SyncDataManager.performIncrementalSync()` runs many entity syncs in parallel without respecting data dependencies, leading to races and redundant pulls.
- `performIncrementalSyncForKey()` supports a small set of keys and otherwise falls back to the broad incremental sync; this magnifies redundant work when many repositories trigger background sync with different keys.
- Track versions and waveforms may not synchronize in the right order; waveforms can run before versions update the cache, and its fallback only consults local versions (not remote), resulting in gaps.
- Comments were historically tied to `trackId`. Domain now uses `versionId`, but DTO/document still use the `trackId` field storing a version id (pre-schema rename), creating confusion and routing inconsistencies.

### Data dependency graph (DAG)

- user_session → user_profile
- user_profile → projects (optional dependency for collaborators discovery)
- projects → collaborators
- projects → audio_tracks
- audio_tracks → track_versions
- track_versions → waveforms
- notifications → user_session (independent of project graph)

Implication: Downstream orchestration must respect staging: A) profile/projects → B) collaborators/tracks/notifications → C) versions → D) waveforms.

### Root causes of repeated downstream

- Per-key deduplication in `BackgroundSyncCoordinator` allows multiple distinct keys to run overlapping syncs.
- Unsupported keys cause fallback to broad incremental sync, running all use cases again.
- Repositories trigger background sync on cache read paths with granular keys that aren’t recognized by the manager, amplifying fallback runs.

### Architectural decisions

1) Stage-based orchestration in `SyncDataManager`
- Replace global `Future.wait` with staged execution that honors dependencies:
  - Stage A: user_profile, projects
  - Stage B: collaborators, audio_tracks, notifications
  - Stage C: track_versions
  - Stage D: waveforms
- Within a stage, run independent use cases in parallel; await between stages.

2) Expand and normalize syncKey routing
- Recognize and scope the most common triggers to avoid fallback:
  - projects: `project_{id}`, `projects_{ownerId}`
  - audio_tracks: `audio_track_{id}`, `audio_tracks_{projectId}`
  - audio_comments (version-scoped): `audio_comments_{versionId}` (normalize naming)
  - track_versions: `track_versions`, `track_versions_track_{trackId}`
  - waveforms: `waveform_{versionId}`
- Keys should trigger only the minimal, dependency-safe work. If a key requires deps (e.g., waveform needs versions), delegate to the right stage or convert to a staged mini-run (versions → waveform for that scope).

3) Trigger policy (reads vs writes)
- Writes: always call `triggerUpstreamSync` only; do not pull downstream as part of write paths.
- Reads/cache-miss: trigger downstream only with recognized scoped keys and enforce per-entity TTL (e.g., 15 min) to avoid storms; if within TTL or offline, no trigger.

4) Coordinator-level coalescing and debounce
- Introduce a short debounce (300–500ms) for downstream triggers; batch concurrent triggers.
- Maintain a global downstream lock; while a downstream is in progress, buffer scopes and reconcile them into a consolidated run at the end (or drop them when TTLs deem unnecessary).

5) Waveforms correctness
- Remove fallback logic that attempts to operate without versions; waveforms must run after versions are synced (Stage D after Stage C).
- For `waveform_{versionId}` scoped runs, allow direct resolution using local version; if absent, enqueue a scoped versions sync first, then waveform.
- Add per-version/track TTL to avoid frequent re-fetch of the same waveform.

6) Track versions TTL and scope
- Maintain 15-minute TTL but persist it per user and optionally per track for better granularity.
- If zero versions exist locally, treat as cache cold-start and force a pull.

7) Repositories trigger hygiene
- For read paths, trigger only supported keys; avoid generic triggers that cause fallback to broad incremental sync.
- For write paths, switch to upstream-only triggers consistently.

8) Telemetry hygiene
- Reduce verbose downstream logs; keep per-entity counters and last-duration timings.

### Comments feature: current state and plan

Findings
- Domain entity uses `versionId`. DTO/document store a `trackId` field that actually holds a version id (pre-schema rename), confirmed in code comments and mappings.
- `SyncAudioCommentsUseCase` treats its `scopedTrackId` as a version id and performs `getCommentsByVersionId(versionId)`.
- Repository triggers downstream with `syncKey: 'audio_comments_version_{versionId}'`, but the manager currently only recognizes `audio_comments_{...}`; this mismatch forces fallback.

Decisions
- Normalize naming to version semantics end-to-end:
  - Rename `scopedTrackId` → `scopedVersionId` in `SyncAudioCommentsUseCase`.
  - Route by `audio_comments_{versionId}` and add support for this key in `performIncrementalSyncForKey`.
  - Keep DTO/document backward compatible by writing both fields during transition or parsing either `versionId` or `trackId` on read. Target end-state field names: `versionId` (preferred).
- Position comments sync after versions in the staged orchestration:
  - Stage C.5: comments-by-version (after versions, before waveforms or parallel with waveforms if versions are guaranteed synced).
  - For scoped runs: if comments for a version are requested and versions for that version are missing locally, perform a scoped versions sync first, then comments.

Schema/data model adjustments (backward compatible)
- DTO: accept `versionId` (preferred) or fallback to `trackId` on read; on write, produce both temporarily: `{ versionId, trackId: versionId }`.
- Document: rename `trackId` → `versionId` and provide a migration path; during transition, keep both indices if necessary or maintain a derived field to avoid breaking queries. Ensure Isar migration scripts handle the rename.
- Remote (Firestore): gradually migrate documents to include `versionId`. Readers must accept both while migration completes.

### Concrete edits to implement

1) `SyncDataManager`
- Change `performIncrementalSync()` to staged orchestration A→B→C→D.
- Expand `performIncrementalSyncForKey()` to handle:
  - `project_{id}` → `_syncProjects()` scoped or no-op if TTL not expired.
  - `projects_{ownerId}` → `_syncProjects()` scoped list.
  - `audio_track_{id}` / `audio_tracks_{projectId}` → `_syncAudioTracks()` scoped.
  - `audio_comments_{versionId}` → `_syncAudioComments(scopedVersionId)`.
  - `track_versions` / `track_versions_track_{trackId}` → `_syncTrackVersions()` (scoped when possible).
  - `waveform_{versionId}` → ensure versions for that version exist, then `_syncWaveforms(scopedVersionId)`.
- Remove fallback to broad incremental when key is unrecognized; return success (no-op) to avoid redundant global work.

2) `BackgroundSyncCoordinator`
- Add debounce (300–500ms) for downstream triggers.
- Implement a global downstream lock with scope coalescing: while running, buffer incoming scopes; when finishing, compute the minimal next run needed (respect TTLs) and execute once.

3) `SyncWaveformsUseCase`
- Remove local-versions-empty fallback that attempts to infer via tracks only.
- Add `scopedVersionId` path: if provided, fetch waveform for that version; if version is missing locally, trigger a scoped versions sync and then fetch waveform.
- Add simple TTL per version to avoid repeated pulls.

4) Comments use case and repository
- Rename `scopedTrackId` → `scopedVersionId` and propagate through calls.
- Support `audio_comments_{versionId}` routing in the manager.
- Repository read/watch:
  - `watchCommentsByVersion(versionId)` triggers `audio_comments_{versionId}` (downstream), not a broad sync.
  - No downstream triggers on deprecated `watchCommentsByTrack`.
- Upstream (add/delete): continue to use `triggerUpstreamSync` only.

5) DTO/Document migrations (comments)
- DTO: accept both `versionId` or `trackId` (stores version id). Prefer emitting `versionId`; during migration, also emit `trackId` for backward compatibility.
- Document: add `versionId` field; write both for a release; read prefers `versionId` and falls back to `trackId`. Plan an Isar migration to drop `trackId` later.

### Migration and rollout

1) Introduce expanded key routing and staged orchestration (backward compatible).
2) Normalize comment keys and use case parameters to version semantics.
3) Ship DTO/document dual-field support for comments.
4) Add coordinator debounce + coalescing.
5) Remove waveform fallback, rely on staged order; add per-version TTL.
6) After one stable release, migrate comments storage to `versionId` only; update queries and indexes.

### KPIs and verification

- 50–80% reduction in downstream invocations per minute during typical usage.
- Zero waveform fetches preceding version updates on cold cache.
- Comments are present for the latest versions after a single staged run.
- No fallback to broad incremental sync for recognized keys (track by logs/metrics).
- App cold start shows local data immediately; background staged sync completes within target time (e.g., <3s on average connections).

### Appendix: routing table (target end-state)

- app_startup_sync → staged A→D run (TTL-respecting)
- project_{id} → projects scoped refresh (TTL + change detection)
- projects_{ownerId} → projects list scoped refresh
- audio_track_{id} → single track refresh
- audio_tracks_{projectId} → project tracks refresh
- track_versions → versions staged (C only)
- track_versions_track_{trackId} → versions for one track
- audio_comments_{versionId} → comments for one version
- waveform_{versionId} → waveform for one version (ensures versions exist)


