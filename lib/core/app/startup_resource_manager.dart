import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_comment/domain/usecases/sync_audio_comment_usecase.dart';
import 'package:trackflow/features/audio_track/domain/usecases/sync_audio_tracks_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/sync_projects_usecase.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_frofile_collaborators.dart';
import 'package:trackflow/features/user_profile/domain/usecases/sync_user_profile_usecase.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@lazySingleton
class StartupResourceManager {
  final SyncProjectsUseCase syncProjects;
  final SyncAudioTracksUseCase syncAudioTracks;
  final SyncAudioCommentsUseCase syncAudioComments;
  final SyncUserProfileUseCase syncUserProfile;
  final SyncUserProfileCollaboratorsUseCase syncUserProfileCollaborators;
  final SessionStorage sessionStorage;
  final AuthRepository authRepository;

  StartupResourceManager(
    this.syncAudioComments,
    this.syncAudioTracks,
    this.syncProjects,
    this.syncUserProfile,
    this.syncUserProfileCollaborators,
    this.sessionStorage,
    this.authRepository,
  );

  Future<void> initializeAppData() async {
    try {
      // Clear session storage to ensure clean state
      await sessionStorage.clearUserId();

      // Get the current authenticated user ID
      final userIdResult = await authRepository.getSignedInUserId();

      userIdResult.fold(
        (failure) {
          throw Exception('Failed to get user ID: ${failure.message}');
        },
        (userId) {
          // User ID obtained successfully
        },
      );

      // Save the user ID to session storage
      final userId = userIdResult.getOrElse(
        () => throw Exception('No user ID available'),
      );
      await sessionStorage.saveUserId(userId);

      await syncProjects();
      await syncAudioTracks();
      await syncUserProfileCollaborators();
      await syncAudioComments();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshAppData() async {
    await initializeAppData();
  }
}
