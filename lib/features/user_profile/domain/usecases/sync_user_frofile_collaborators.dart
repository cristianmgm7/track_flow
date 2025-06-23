import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@lazySingleton
class SyncUserProfileCollaboratorsUseCase {
  final ProjectsLocalDataSource projectsLocal;
  final UserProfileRepository userProfileRepo;

  SyncUserProfileCollaboratorsUseCase(this.projectsLocal, this.userProfileRepo);

  Future<void> call() async {
    final projects = await projectsLocal.getAllProjects();
    final collaboratorIds =
        projects
            .expand((p) => p.collaborators.map((c) => c['id'] as String))
            .toSet()
            .toList();
    if (collaboratorIds.isEmpty) return;
    final result = await userProfileRepo.getUserProfilesByIds(collaboratorIds);
    result.fold(
      (failure) => null,
      (profiles) async => await userProfileRepo.cacheUserProfiles(profiles),
    );
  }
}
