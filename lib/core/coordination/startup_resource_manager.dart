import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart';

@lazySingleton
class StartupResourceManager {
  final SyncProjectsUseCase syncProjects;
  final SyncAudioTracksUseCase syncAudioTracks;
  final SyncAudioCommentsUseCase syncAudioComments;
  final SyncUserProfileUseCase syncUserProfile;
  final SyncUserProfileCollaboratorsUseCase syncUserProfileCollaborators;

  StartupResourceManager(
    this.syncAudioComments,
    this.syncAudioTracks,
    this.syncProjects,
    this.syncUserProfile,
    this.syncUserProfileCollaborators,
  );

  /// Initializes app data with optional progress reporting
  ///
  /// Syncs data in optimal order:
  /// 1. User profile first (required by other syncs)
  /// 2. Projects and collaborators in parallel (both depend on profile)
  /// 3. Audio tracks and comments in parallel (depend on projects)
  Future<void> initializeAppData({
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Step 1: Sync user profile first (other syncs may depend on it)
      onProgress?.call(0.2);
      await syncUserProfile();

      // Step 2 & 3: Sync projects and collaborators in parallel
      onProgress?.call(0.4);
      await Future.wait([syncProjects(), syncUserProfileCollaborators()]);

      // Step 4 & 5: Sync content that depends on projects
      onProgress?.call(0.8);
      await Future.wait([syncAudioTracks(), syncAudioComments()]);

      // Complete
      onProgress?.call(1.0);
    } catch (e) {
      // Log error and rethrow for proper error handling upstream
      rethrow;
    }
  }

  Future<void> refreshAppData() async {
    await initializeAppData();
  }
}
