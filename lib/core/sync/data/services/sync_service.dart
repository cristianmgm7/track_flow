import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart';

/// Service that handles ONLY data synchronization
///
/// This service uses existing sync use cases and is responsible ONLY for sync operations.
/// It does NOT handle any session-related functionality.
@injectable
class SyncService {
  final SyncProjectsUseCase _syncProjects;
  final SyncAudioTracksUseCase _syncAudioTracks;
  final SyncAudioCommentsUseCase _syncAudioComments;
  final SyncUserProfileUseCase _syncUserProfile;
  final SyncUserProfileCollaboratorsUseCase _syncUserProfileCollaborators;

  SyncService({
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

  /// Get the current sync state
  Future<Either<Failure, SyncState>> getCurrentSyncState() async {
    // For now, return a basic sync state
    // In a real implementation, this would check actual sync status
    return const Right(SyncState(status: SyncStatus.complete, progress: 1.0));
  }

  /// Trigger background synchronization
  Future<Either<Failure, Unit>> triggerBackgroundSync() async {
    try {
      // Initialize app data with progress reporting
      await initializeAppData(
        onProgress: (progress) {
          // Emit progress updates
          print('Sync progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Background sync failed: $e'));
    }
  }

  /// Force a full synchronization
  Future<Either<Failure, Unit>> forceSync() async {
    try {
      // Force sync by calling initializeAppData
      await initializeAppData(
        onProgress: (progress) {
          print('Force sync progress: ${(progress * 100).toStringAsFixed(1)}%');
        },
      );

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Force sync failed: $e'));
    }
  }

  /// Initialize app data with progress reporting
  ///
  /// This method coordinates the sync order:
  /// 1. User profile first (required by other syncs)
  /// 2. Projects and collaborators in parallel
  /// 3. Audio tracks and comments in parallel
  Future<void> initializeAppData({
    void Function(double progress)? onProgress,
  }) async {
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
  }

  /// Reset sync state
  Future<Either<Failure, Unit>> resetSync() async {
    try {
      // Reset any sync state
      // For now, just return success
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Reset sync failed: $e'));
    }
  }

  /// Watch for sync state changes
  Stream<SyncState> watchSyncState() {
    // For now, return a simple stream
    // In a real implementation, this would emit actual sync state changes
    return Stream.value(
      const SyncState(status: SyncStatus.complete, progress: 1.0),
    );
  }
}
