import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_audio_comments_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_audio_tracks_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_projects_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_collaborators_usecase.dart';
import 'package:trackflow/core/sync/domain/usecases/sync_user_profile_usecase.dart';

/// Manages downstream data synchronization (Remote → Local)
///
/// This service is responsible for pulling data from remote sources
/// and caching it locally. It uses existing sync use cases and provides
/// a unified interface for background sync operations.
///
/// Key responsibilities:
/// - Pull fresh data from remote sources
/// - Cache data locally via sync use cases
/// - Coordinate sync order and dependencies
/// - Report sync progress and state
@injectable
class SyncDataManager {
  final SyncProjectsUseCase _syncProjects;
  final SyncAudioTracksUseCase _syncAudioTracks;
  final SyncAudioCommentsUseCase _syncAudioComments;
  final SyncUserProfileUseCase _syncUserProfile;
  final SyncUserProfileCollaboratorsUseCase _syncUserProfileCollaborators;

  SyncDataManager({
    required SyncProjectsUseCase syncProjects,
    required SyncAudioTracksUseCase syncAudioTracks,
    required SyncAudioCommentsUseCase syncAudioComments,
    required SyncUserProfileUseCase syncUserProfile,
    required SyncUserProfileCollaboratorsUseCase syncUserProfileCollaborators,
  }) : _syncProjects = syncProjects,
       _syncAudioTracks = syncAudioTracks,
       _syncAudioComments = syncAudioComments,
       _syncUserProfile = syncUserProfile,
       _syncUserProfileCollaborators = syncUserProfileCollaborators;

  /// Perform full data synchronization with progress reporting
  ///
  /// This method coordinates the sync order based on data dependencies:
  /// 1. User profile first (required by other syncs)
  /// 2. Projects and collaborators in parallel
  /// 3. Audio tracks and comments in parallel
  Future<Either<Failure, Unit>> performFullSync({
    void Function(double progress)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1);

      // Step 1: Sync user profile first (required by other syncs)
      await _syncUserProfile();
      onProgress?.call(0.2);

      // Step 2: Sync projects and collaborators in parallel
      await Future.wait([_syncProjects(), _syncUserProfileCollaborators()]);
      onProgress?.call(0.6);

      // Step 3: Sync audio tracks and comments in parallel
      await Future.wait([_syncAudioTracks(), _syncAudioComments()]);
      onProgress?.call(1.0);

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Data sync failed: $e'));
    }
  }

  /// Perform incremental sync (lighter operation)
  ///
  /// This method performs a lighter sync operation,
  /// typically used for background refreshes.
  Future<Either<Failure, Unit>> performIncrementalSync() async {
    try {
      // For now, perform full sync
      // TODO: Implement incremental sync logic based on timestamps
      return await performFullSync();
    } catch (e) {
      return Left(ServerFailure('Incremental sync failed: $e'));
    }
  }

  /// Get the current sync state
  Future<Either<Failure, SyncState>> getCurrentSyncState() async {
    // For now, return a basic sync state
    // TODO: Implement actual sync state tracking
    return const Right(SyncState(status: SyncStatus.complete, progress: 1.0));
  }

  /// Watch for sync state changes
  Stream<SyncState> watchSyncState() {
    // For now, return a simple stream
    // TODO: Implement actual sync state streaming
    return Stream.value(
      const SyncState(status: SyncStatus.complete, progress: 1.0),
    );
  }

  /// Reset sync state and clear cached data
  Future<Either<Failure, Unit>> resetSyncState() async {
    try {
      // TODO: Implement sync state reset logic
      // This would typically clear sync timestamps, force full refresh, etc.
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Reset sync state failed: $e'));
    }
  }
}
