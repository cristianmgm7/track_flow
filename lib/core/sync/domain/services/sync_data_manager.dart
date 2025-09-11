import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_projects_using_simple_service_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_using_simple_service_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_notifications_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_track_versions_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_waveforms_usecase.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// 📡 DOWNSTREAM SYNC MANAGER (Remote → Local)
///
/// Manages data synchronization from remote sources to local cache.
/// Uses individual use cases with their own smart timing logic.
///
/// STRATEGY:
/// 1. 📋 PROJECTS: Smart sync with 15min intervals (SyncMetadata-based)
/// 2. 👤 USER PROFILE: Simple sync with preservation logic
/// 3. 👥 COLLABORATORS: Depends on projects, simple sync
/// 4. 🎵 AUDIO: Audio tracks and comments with preservation
/// 5. ⚡ SMART: Each use case handles its own timing and changes
@injectable
class SyncDataManager {
  final SyncProjectsUsingSimpleServiceUseCase _syncProjects;
  final SyncAudioTracksUsingSimpleServiceUseCase _syncAudioTracks;
  final SyncAudioCommentsUseCase _syncAudioComments;
  final SyncUserProfileUseCase _syncUserProfile;
  final SyncUserProfileCollaboratorsUseCase _syncUserProfileCollaborators;
  final SyncNotificationsUseCase _syncNotifications;
  final SyncTrackVersionsUseCase _syncTrackVersions;
  final SyncWaveformsUseCase _syncWaveforms;

  SyncDataManager({
    required SyncProjectsUsingSimpleServiceUseCase syncProjects,
    required SyncAudioTracksUsingSimpleServiceUseCase syncAudioTracks,
    required SyncAudioCommentsUseCase syncAudioComments,
    required SyncUserProfileUseCase syncUserProfile,
    required SyncUserProfileCollaboratorsUseCase syncUserProfileCollaborators,
    required SyncNotificationsUseCase syncNotifications,
    required SyncTrackVersionsUseCase syncTrackVersions,
    required SyncWaveformsUseCase syncWaveforms,
  }) : _syncProjects = syncProjects,
       _syncAudioTracks = syncAudioTracks,
       _syncAudioComments = syncAudioComments,
       _syncUserProfile = syncUserProfile,
       _syncUserProfileCollaborators = syncUserProfileCollaborators,
       _syncNotifications = syncNotifications,
       _syncTrackVersions = syncTrackVersions,
       _syncWaveforms = syncWaveforms;

  // ============================================================================
  // 📡 MAIN SYNC OPERATIONS
  // ============================================================================

  /// 🚀 MAIN ENTRY POINT: Smart incremental sync
  /// Each use case handles its own timing and change detection
  Future<Either<Failure, Unit>> performIncrementalSync() async {
    try {
      AppLogger.sync(
        'DOWNSTREAM',
        'Starting smart sync with individual use case logic',
      );
      final startTime = DateTime.now();

      // Each use case is responsible for its own timing/TTL and change detection.
      // Orchestrate in stages to respect data dependencies:
      // A) profile/projects → B) collaborators/tracks/notifications → C) versions → D) waveforms

      // Stage A: user profile and projects
      await Future.wait<void>([_syncUserProfile(), _syncProjects()]);

      // Stage B: depends on projects
      await Future.wait<void>([
        _syncUserProfileCollaborators(),
        _syncAudioTracks(),
        _syncNotifications(),
      ]);

      // Stage C: depends on tracks
      await _syncTrackVersions();

      AppLogger.sync('DOWNSTREAM', 'Stage C (versions) completed');

      // Stage D: depends on versions (run in parallel)
      AppLogger.sync('DOWNSTREAM', 'Stage D (comments + waveforms) starting');
      // Prefer explicit per-version scoped sync to ensure downstream actually happens
      final versionIds = await _syncWaveforms.getLocalVersionIds();
      if (versionIds.isNotEmpty) {
        await Future.wait<void>([
          // Comments for each version
          ...versionIds.map((id) => _syncAudioComments(scopedVersionId: id)),
          // Waveforms for each version
          ...versionIds.map(
            (id) => _syncWaveforms(
              scopedVersionId: TrackVersionId.fromUniqueString(id),
            ),
          ),
        ]);
      } else {
        // Fallback: run generic syncs (no-ops if nothing to do)
        await Future.wait<void>([_syncAudioComments(), _syncWaveforms()]);
      }
      AppLogger.sync('DOWNSTREAM', 'Stage D (comments + waveforms) completed');

      final duration = DateTime.now().difference(startTime);
      AppLogger.sync(
        'DOWNSTREAM',
        'Smart incremental sync completed',
        duration: duration.inMilliseconds,
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error(
        'Incremental sync failed: $e',
        tag: 'SyncDataManager',
        error: e,
      );
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  /// Scoped incremental sync based on syncKey hints
  ///
  /// Supported keys:
  /// - 'audio_comments_{versionId}' → downstream sync only for that version's comments
  Future<Either<Failure, Unit>> performIncrementalSyncForKey(
    String syncKey,
  ) async {
    try {
      // App startup: run staged incremental sync
      if (syncKey == 'app_startup_sync' || syncKey == 'forced') {
        return await performIncrementalSync();
      }

      // Projects (scoped keys map to smart global projects sync for now)
      if (syncKey.startsWith('project_') || syncKey.startsWith('projects_')) {
        await _syncProjects();
        return const Right(unit);
      }

      // Audio tracks (scoped keys map to smart global tracks sync for now)
      if (syncKey.startsWith('audio_track_') ||
          syncKey.startsWith('audio_tracks_')) {
        await _syncAudioTracks();
        return const Right(unit);
      }

      // Comments (version-scoped)
      if (syncKey.startsWith('audio_comments_version_')) {
        final versionId = syncKey.substring('audio_comments_version_'.length);
        await _syncAudioComments(scopedVersionId: versionId);
        return const Right(unit);
      }

      // Backward compatibility: treat legacy audio_comments_{id} as version id
      if (syncKey.startsWith('audio_comments_')) {
        final versionId = syncKey.substring('audio_comments_'.length);
        await _syncAudioComments(scopedVersionId: versionId);
        return const Right(unit);
      }

      // Track versions (global or future scoped routing)
      if (syncKey == 'track_versions') {
        await _syncTrackVersions();
        return const Right(unit);
      }

      if (syncKey.startsWith('waveform_')) {
        final versionId = syncKey.substring('waveform_'.length);
        await _syncWaveforms(
          scopedVersionId: TrackVersionId.fromUniqueString(versionId),
        );
        return const Right(unit);
      }

      // Playlists not integrated yet: ignore playlist-related keys for now
      if (syncKey.startsWith('playlist_') || syncKey == 'playlists_refresh') {
        return const Right(unit);
      }

      // Unrecognized key: no-op to avoid triggering broad downstream syncs
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Scoped incremental sync failed: $e'));
    }
  }

  /// 🔄 FALLBACK: Full sync when incremental fails
  /// Forces sync of all entities regardless of their individual timing
  Future<Either<Failure, Unit>> performFullSync({
    void Function(double progress)? onProgress,
  }) async {
    try {
      AppLogger.sync('DOWNSTREAM', 'Starting full sync (fallback mode)');
      final startTime = DateTime.now();

      onProgress?.call(0.1);

      // Sync in dependency order: profile → projects/collaborators → audio
      await _syncUserProfile();
      onProgress?.call(0.3);

      await Future.wait<void>([
        _syncProjects(),
        _syncUserProfileCollaborators(),
        _syncNotifications(),
      ]);
      onProgress?.call(0.7);

      await Future.wait<void>([_syncAudioTracks(), _syncAudioComments()]);
      await Future.wait<void>([_syncTrackVersions(), _syncWaveforms()]);
      onProgress?.call(1.0);

      final duration = DateTime.now().difference(startTime);
      AppLogger.sync(
        'DOWNSTREAM',
        'Full sync completed',
        duration: duration.inMilliseconds,
      );

      return const Right(unit);
    } catch (e) {
      AppLogger.error('Full sync failed: $e', tag: 'SyncDataManager', error: e);
      return Left(ServerFailure('Full sync failed: $e'));
    }
  }

  // ============================================================================
  // 📊 MONITORING & STATUS
  // ============================================================================

  /// Get the current sync state for UI display
  Future<Either<Failure, SyncState>> getCurrentSyncState() async {
    try {
      // For now, return a basic sync state
      // Individual use cases handle their own state
      return const Right(SyncState(status: SyncStatus.complete, progress: 1.0));
    } catch (e) {
      return Left(ServerFailure('Failed to get sync state: $e'));
    }
  }

  /// Watch for sync state changes (simple implementation)
  Stream<SyncState> watchSyncState() {
    // For now, return current state
    // Individual use cases handle their own timing
    return Stream.fromFuture(
      getCurrentSyncState().then(
        (result) => result.fold(
          (failure) => SyncState.error(failure.message),
          (state) => state,
        ),
      ),
    );
  }

  /// Reset sync state (delegates to individual use cases)
  Future<Either<Failure, Unit>> resetSyncState() async {
    try {
      AppLogger.info(
        'Reset sync state requested - individual use cases handle their own state',
        tag: 'SyncDataManager',
      );
      // Each use case manages its own sync metadata/timing
      // Projects use case uses SyncMetadata in Isar
      // Others use simple preservation logic
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Failed to reset sync state: $e'));
    }
  }

  /// Get sync statistics from all use cases
  Future<Map<String, dynamic>> getSyncStatistics() async {
    try {
      // Get statistics from projects use case (most detailed)
      final projectStats = await _syncProjects.getSyncStatistics();

      return {
        'strategy': 'individual_use_case_logic',
        'projects': projectStats,
        'description':
            'Each use case handles its own timing and change detection',
        'intervals': {
          'projects': '15 minutes (SyncMetadata-based)',
          'user_profile': 'simple preservation logic',
          'audio_tracks': 'simple preservation logic',
          'audio_comments': 'simple preservation logic',
          'collaborators': 'simple preservation logic',
          'notifications': '15 minutes (smart sync)',
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
