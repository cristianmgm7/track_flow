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

  Future<void> initializeAppData() async {
    await Future.wait([
      syncAudioComments(),
      syncAudioTracks(),
      syncProjects(),
      syncUserProfile(),
      syncUserProfileCollaborators(),
    ]);
  }

  Future<void> refreshAppData() async {
    // Si necesitas lógica especial para forzar refresco, agrégala aquí
    await initializeAppData();
  }
}
