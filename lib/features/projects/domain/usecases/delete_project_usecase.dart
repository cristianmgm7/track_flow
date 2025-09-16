import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';

@lazySingleton
class DeleteProjectUseCase {
  final ProjectsRepository _projectsRepository;
  final SessionStorage _sessionStorage;
  final ProjectTrackService _projectTrackService;

  DeleteProjectUseCase(
    this._projectsRepository,
    this._sessionStorage,
    this._projectTrackService,
  );

  Future<Either<Failure, Unit>> call(Project project) async {
    final userIdResult = await _sessionStorage.getUserId();
    if (userIdResult == null) {
      return left(AuthenticationFailure('User ID not found'));
    }
    try {
      final updatedProject = project.deleteProject(
        requester: UserId.fromUniqueString(userIdResult),
      );
      // 1) Attempt to delete all tracks of this project (and their cached audio)
      try {
        final tracksEitherStream = _projectTrackService.watchTracksByProject(
          updatedProject.id,
        );
        final tracksEither = await tracksEitherStream.first;
        await tracksEither.fold(
          (failure) async {
            // Ignore and proceed; project deletion should still continue
          },
          (tracks) async {
            for (final track in tracks) {
              await _projectTrackService.deleteTrack(
                project: updatedProject,
                requester: UserId.fromUniqueString(userIdResult),
                trackId: track.id,
              );
            }
          },
        );
      } catch (_) {
        // Best-effort cascade; continue even if track deletion fails
      }

      // 2) Delete the project itself
      return _projectsRepository.deleteProject(updatedProject.id);
    } on ProjectException catch (e) {
      return left(ProjectException(e.message));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }
}
