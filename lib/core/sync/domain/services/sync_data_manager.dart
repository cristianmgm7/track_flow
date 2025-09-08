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

      // Each use case is responsible for:
      // - Checking if it needs sync (timing, intervals, etc.)
      // - Only updating data that changed
      // - Preserving local data on failures

      await Future.wait<void>([
        // Projects: Smart sync with SyncMetadata (15 min intervals)
        _syncProjects(),

        // User profile: Simple preservation logic
        _syncUserProfile(),

        // Audio: Simple preservation logic
        _syncAudioTracks(),
        _syncAudioComments(),

        // Track versions: smart incremental sync
        _syncTrackVersions(),

        // Waveforms: pull from storage by version if missing locally
        _syncWaveforms(),

        // Collaborators: Depends on projects, simple sync
        _syncUserProfileCollaborators(),

        // Notifications: Smart sync with preservation logic
        _syncNotifications(),
      ]);

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
  /// - 'audio_comments_{trackId}' → downstream sync only for that track's comments
  Future<Either<Failure, Unit>> performIncrementalSyncForKey(
    String syncKey,
  ) async {
    try {
      if (syncKey.startsWith('audio_comments_')) {
        final trackId = syncKey.substring('audio_comments_'.length);
        await _syncAudioComments(scopedTrackId: trackId);
        return const Right(unit);
      }

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

      // Fallback to regular incremental sync
      return await performIncrementalSync();
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
