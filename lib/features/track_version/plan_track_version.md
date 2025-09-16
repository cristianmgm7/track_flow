## Track Versioning — Implementation Plan (V1)

### Goal
Introduce first-class linear versions for tracks. Each version is its own audio asset with independent comments and a simple review flow, while the `Track` is the stable identity shown in a project. Keep scope lean, reuse the current upload/playback pipelines, and respect the existing Clean Architecture (domain → data → presentation with BLoC/usecases/repositories).

### Non‑Goals (V1)
- No branching/merging of versions; strictly linear (v1 → v2 → v3 …).
- No waveform diffs between versions (visual compare may come later).
- No complex approval states beyond basic status metadata.

---

## Architecture & Data Model

### Aggregates and Entities
- Track (aggregate root for versions)
  - id (String)
  - projectId (String)
  - title (String)
  - activeVersionId (String)
  - createdAt (DateTime)
  - createdBy (String)

- TrackVersion (child entity)
  - id (String)
  - trackId (String)
  - versionNumber (int) // 1-based, monotonically increasing
  - label (String?) // optional human label for the version
  - fileLocalPath (String?) // local cache path (Isar/FS)
  - fileRemoteUrl (String?) // cloud URL if synced
  - durationMs (int?)
  - waveformCachePath (String?)
  - status (enum: processing, ready, failed)
  - createdAt (DateTime)
  - createdBy (String)

- VersionComment
  - id (String)
  - versionId (String)
  - authorId (String)
  - text (String)
  - timestampSec (double?) // optional time-based comment
  - resolved (bool, default false)
  - replyToId (String?) // basic threading (optional V1)
  - createdAt (DateTime)

Rules:
- New upload increments `versionNumber` and sets `Track.activeVersionId` to the new version.
- Comments attach to `versionId` (not `trackId`).
- Restore is implemented by setting `activeVersionId` to a previous `TrackVersion.id`.

### Storage
- Local (V1):
  - Isar collections: `Track`, `TrackVersion`, `VersionComment`.
  - Audio binary: existing audio cache approach; store under a path keyed by `versionId`.
- Remote (Phase 2, optional):
  - Firebase Storage: `tracks/{projectId}/{trackId}/v{n}/audio.ext`.
  - Firestore (or RTDB): metadata mirrors for sync.

### Integration with existing code
- Reuse current audio upload, caching, and playback services.
- Treat each `TrackVersion` as an "audio track instance"; the player binds to the currently active version.
- Minimal changes to project listing: show latest version badge; deep-link to Track Detail.

---

## Project Structure (new feature)

```
lib/features/track_version/
  domain/
    entities/
      track_version.dart
      version_comment.dart
    repositories/
      track_repository.dart
      track_version_repository.dart
      version_comment_repository.dart
    usecases/
      add_track_version_usecase.dart
      watch_track_versions_usecase.dart
      set_active_track_version_usecase.dart
      delete_track_version_usecase.dart
      restore_track_version_usecase.dart
      add_version_comment_usecase.dart
      watch_version_comments_usecase.dart
      get_active_version_usecase.dart
      get_version_by_id_usecase.dart
  data/
    models/
      track_model.dart            // if Track not already modeled elsewhere
      track_version_model.dart
      version_comment_model.dart
    datasources/
      local/
        track_local_data_source.dart
        track_version_local_data_source.dart
        version_comment_local_data_source.dart
      remote/                     // Phase 2 (optional)
        track_remote_data_source.dart
        track_version_remote_data_source.dart
        version_comment_remote_data_source.dart
    repositories/
      track_repository_impl.dart
      track_version_repository_impl.dart
      version_comment_repository_impl.dart
  presentation/
    blocs/
      track_versions/
        track_versions_bloc.dart
        track_versions_event.dart
        track_versions_state.dart
      version_comments/
        version_comments_bloc.dart
        version_comments_event.dart
        version_comments_state.dart
    screens/
      track_detail_screen.dart
    widgets/
      versions_list.dart
      add_version_button.dart
      version_comment_list.dart
      comment_input.dart
```

Note: If a `Track` entity already exists under another feature (e.g., `audio_track`), we will either reuse it or relocate it into this feature as the aggregate root (keeping public API stable via exports).

---

## Use Cases — Contracts (Domain)

AddTrackVersion(trackId, fileRef, label?)
- Input: `trackId`, file handle/path/bytes, optional label
- Process: compute `versionNumber = last + 1`, store metadata, upload/copy audio, update `activeVersionId`
- Output: `TrackVersion`

WatchTrackVersions(trackId)
- Stream<List<TrackVersion>> ordered by `versionNumber` desc

SetActiveTrackVersion(trackId, versionId)
- Sets `Track.activeVersionId = versionId`

DeleteTrackVersion(versionId)
- Guard: cannot delete if it is the only version; if active, require switch first

RestoreTrackVersion(trackId, versionId)
- Convenience: same as `SetActiveTrackVersion`

AddVersionComment(versionId, text, timestampSec?)
- Adds comment; returns `VersionComment`

WatchVersionComments(versionId)
- Stream<List<VersionComment>> ordered by createdAt asc

GetActiveVersion(trackId)
- Returns `TrackVersion` for `activeVersionId`

GetVersionById(versionId)
- Returns `TrackVersion`

---

## Repository Interfaces

TrackRepository
- getById(String id) → Track?
- create(Track track) → Track
- setActiveVersion(String trackId, String versionId) → void
- watchByProjectId(String projectId) → Stream<List<Track>>

TrackVersionRepository
- add(TrackVersion version, File/Bytes file) → TrackVersion
- getByTrackId(String trackId) → List<TrackVersion>
- watchByTrackId(String trackId) → Stream<List<TrackVersion>>
- delete(String versionId) → void
- getById(String versionId) → TrackVersion?

VersionCommentRepository
- add(VersionComment comment) → VersionComment
- watchByVersionId(String versionId) → Stream<List<VersionComment>>
- delete(String commentId) → void
- resolve(String commentId, bool resolved) → void

---

## Data Layer

Models (Isar annotated)
- `TrackModel` (if needed), `TrackVersionModel`, `VersionCommentModel` with proper indexes

Local Data Sources
- `TrackLocalDataSource`: CRUD + `watchByProjectId`
- `TrackVersionLocalDataSource`: add/delete/get/watch + handle local file paths
- `VersionCommentLocalDataSource`: add/delete/resolve/watch

Remote Data Sources (Phase 2)
- Firebase Storage upload/download
- Firestore sync of metadata and comments

Repository Implementations
- Compose local + remote; in V1 use local only, with hooks for future sync

---

## Presentation Layer (BLoC + UI)

TrackVersionsBloc
- Events: `Load(trackId)`, `AddVersion(file,label)`, `SetActive(versionId)`, `Delete(versionId)`, `Restore(versionId)`
- States: `initial`, `loading`, `loaded(versions, activeVersionId)`, `error`
- Streaming: use `await emit.onEach(WatchTrackVersions)` to avoid emit-after-complete issues

VersionCommentsBloc
- Events: `Load(versionId)`, `Add(text,timestamp?)`, `Delete(commentId)`, `Resolve(commentId,resolved)`
- States: `initial`, `loading`, `loaded(comments)`, `error`
- Streaming: `await emit.onEach(WatchVersionComments)`

TrackDetailScreen
- Header audio player bound to active version
- VersionsList (latest first) with actions: Set Active, Restore, Delete (guarded), metadata chips (versionNumber, label, duration)
- AddVersionButton to pick/import audio and trigger `AddTrackVersion`
- Comments panel bound to the selected version (default: active)
- Badge on project list cards showing `vN` (lightweight enhancement in existing screens)

Accessibility & UX
- Clear visual distinction between versions
- Confirmations for destructive actions (delete)
- Offline-friendly: show local versions immediately; queue uploads if needed

---

## Migration & Backward Compatibility

Assuming existing audio entries currently represent a single versioned track:
1) For each existing audio entry in a project, create a `Track` aggregate (1-to-1).
2) Convert the existing audio entry to `TrackVersion` with `versionNumber = 1`.
3) Set `Track.activeVersionId` to that version.
4) Update references in UI to open `TrackDetailScreen` for that `Track`.

Data migration can be done lazily on first open (detect missing `Track` and create wrapper) or via a one-time script.

---

## Step-by-Step Implementation Tasks (M1 → M3)

M1 — Domain & Data
1. Define entities: `TrackVersion`, `VersionComment` (+ `Track` if not present)
2. Create repository interfaces and use case contracts listed above
3. Implement Isar models and local data sources
4. Implement repository implementations (local-only)
5. Unit tests: entities, repositories, and use cases

M2 — Presentation & UI
6. Create `TrackVersionsBloc` and `VersionCommentsBloc` with streams
7. Build `TrackDetailScreen` scaffold with header player, versions list, add version
8. Build comments panel (list + input) bound to selected version
9. Wire navigation from project → track detail
10. Widget tests for version switching and comments

M3 — Polishing
11. Guard rails (delete/active constraints), empty states, errors
12. Duration/waveform caching per `versionId`
13. Project list enhancement to show latest version badge

Phase 2 — Remote Sync (optional)
14. Add Firebase data sources and sync flows
15. Notifications on new version and comments

---

## API Sketches (Dart)

// Domain: entities
class TrackVersion {
  final String id;
  final String trackId;
  final int versionNumber;
  final String? label;
  final String? fileLocalPath;
  final String? fileRemoteUrl;
  final int? durationMs;
  final String? waveformCachePath;
  final TrackVersionStatus status;
  final DateTime createdAt;
  final String createdBy;
  const TrackVersion({
    required this.id,
    required this.trackId,
    required this.versionNumber,
    this.label,
    this.fileLocalPath,
    this.fileRemoteUrl,
    this.durationMs,
    this.waveformCachePath,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });
}

enum TrackVersionStatus { processing, ready, failed }

class VersionComment {
  final String id;
  final String versionId;
  final String authorId;
  final String text;
  final double? timestampSec;
  final bool resolved;
  final String? replyToId;
  final DateTime createdAt;
  const VersionComment({
    required this.id,
    required this.versionId,
    required this.authorId,
    required this.text,
    this.timestampSec,
    this.resolved = false,
    this.replyToId,
    required this.createdAt,
  });
}

// Domain: usecases (signatures)
abstract class AddTrackVersionUseCase {
  Future<TrackVersion> call({
    required String trackId,
    required String filePathOrBytes,
    String? label,
  });
}

abstract class WatchTrackVersionsUseCase {
  Stream<List<TrackVersion>> call({ required String trackId });
}

abstract class SetActiveTrackVersionUseCase {
  Future<void> call({ required String trackId, required String versionId });
}

abstract class AddVersionCommentUseCase {
  Future<VersionComment> call({
    required String versionId,
    required String text,
    double? timestampSec,
  });
}

abstract class WatchVersionCommentsUseCase {
  Stream<List<VersionComment>> call({ required String versionId });
}

// Presentation: Bloc streaming pattern (sketch)
// await emit.onEach(trackVersionsStream, onData: (versions) => emit(...));

---

## Testing Strategy
- Unit tests: repositories and use cases (happy paths, guards, errors)
- Widget tests: Track Detail interactions, add version, switch, comments
- Integration tests: migration path (existing audio → Track/TrackVersion)

---

## Acceptance Criteria
- Can create a new version on an existing track; active version updates to the latest
- Can switch active version to any previous version
- Each version shows and stores its own comments
- Streams update UI in real time (local-first)
- Basic guards prevent deleting the only/active version improperly

---

## Rollout & Metrics
- Behind a feature flag if needed (Phase 2 for remote sync)
- Metrics: `version_added`, `version_switched`, `comment_added`
- Success: 95%+ adds without error, <1s UI update after actions (local)

---

## Next Steps (after plan approval)
1) Implement M1 (domain/data) with Isar and wire to existing audio upload service
2) Build Track Detail UI (M2) and integrate blocs
3) Add migration shim for existing audio items
4) Evaluate Phase 2 (remote sync) based on usage


