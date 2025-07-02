import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_cache_repository.dart';

@lazySingleton
class SyncUserProfileCollaboratorsUseCase {
  final ProjectsLocalDataSource projectsLocal;
  final UserProfileCacheRepository userProfileCacheRepo;

  SyncUserProfileCollaboratorsUseCase(this.projectsLocal, this.userProfileCacheRepo);

  Future<void> call() async {
    final projectsResult = await projectsLocal.getAllProjects();
    final collaboratorIds = projectsResult.fold(
      (failure) => <String>[],
      (projects) => projects
          .expand((p) => p.collaboratorIds.map((c) => c))
          .toSet()
          .toList(),
    );
    if (collaboratorIds.isEmpty) return;
    final result = await userProfileCacheRepo.getUserProfilesByIds(collaboratorIds);
    result.fold(
      (failure) => null,
      (profiles) async => await userProfileCacheRepo.cacheUserProfiles(profiles),
    );
  }
}
