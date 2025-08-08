import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/user_profile/domain/usecases/watch_userprofiles.dart';

class CollaboratorsBundle {
  final Project project;
  final List<UserProfile> userProfiles;

  CollaboratorsBundle({required this.project, required this.userProfiles});
}

@lazySingleton
class WatchCollaboratorsBundleUseCase {
  final ProjectsRepository _projectsRepository;
  final WatchUserProfilesUseCase _watchUserProfiles;

  WatchCollaboratorsBundleUseCase(
    this._projectsRepository,
    this._watchUserProfiles,
  );

  Stream<Either<Failure, CollaboratorsBundle>> call(ProjectId projectId) {
    final Stream<Either<Failure, Project?>> project$ = _projectsRepository
        .watchProjectById(projectId);

    return project$
        .switchMap<Either<Failure, CollaboratorsBundle>>((eitherProject) {
          return eitherProject.fold(
            (failure) => Stream<Either<Failure, CollaboratorsBundle>>.value(
              left<Failure, CollaboratorsBundle>(failure),
            ),
            (project) {
              if (project == null) {
                return Stream<Either<Failure, CollaboratorsBundle>>.value(
                  left<Failure, CollaboratorsBundle>(
                    DatabaseFailure('Project not found in local cache'),
                  ),
                );
              }

              final List<String> collaboratorIds =
                  project.collaborators.map((c) => c.userId.value).toList();

              final Stream<Either<Failure, List<UserProfile>>> profiles$ =
                  _watchUserProfiles(collaboratorIds);

              return profiles$.map<Either<Failure, CollaboratorsBundle>>((
                eitherProfiles,
              ) {
                return eitherProfiles.fold(
                  (failure) => left<Failure, CollaboratorsBundle>(failure),
                  (profiles) => right<Failure, CollaboratorsBundle>(
                    CollaboratorsBundle(
                      project: project,
                      userProfiles: profiles,
                    ),
                  ),
                );
              });
            },
          );
        })
        .onErrorReturnWith(
          (e, _) => left<Failure, CollaboratorsBundle>(
            ServerFailure('Failed to watch collaborators: $e'),
          ),
        );
  }
}
