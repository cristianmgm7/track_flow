import 'package:injectable/injectable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/audio_track/domain/usecases/delete_audio_track_usecase.dart';

@lazySingleton
class DeleteProjectUseCase {
  final ProjectsRepository _projectsRepository;
  final SessionStorage _sessionStorage;
  final ProjectTrackService _projectTrackService;
  final DeleteAudioTrack _deleteAudioTrackUseCase;

  DeleteProjectUseCase(
    this._projectsRepository,
    this._sessionStorage,
    this._projectTrackService,
    this._deleteAudioTrackUseCase,
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

      // 1) Get all tracks for this project to perform cascade deletion
      final tracksEitherStream = _projectTrackService.watchTracksByProject(
        updatedProject.id,
      );
      final tracksEither = await tracksEitherStream.first;

      // 2) Delete all tracks using the specialized use case that handles the complete cascade
      final List<String> deletionErrors = [];

      await tracksEither.fold(
        (failure) async {
          // Track the error but continue with project deletion
          deletionErrors.add('Failed to get tracks: ${failure.message}');
        },
        (tracks) async {
          // Delete each track using the specialized use case
          for (final track in tracks) {
            final deleteTrackResult = await _deleteAudioTrackUseCase.call(
              DeleteAudioTrackParams(
                trackId: track.id,
                projectId: updatedProject.id,
              ),
            );

            // Track deletion errors but don't fail the entire operation
            deleteTrackResult.fold(
              (failure) => deletionErrors.add(
                'Failed to delete track ${track.id}: ${failure.message}',
              ),
              (_) => null, // Success - continue
            );
          }
        },
      );

      // 3) Delete the project itself
      final projectDeletionResult = await _projectsRepository.deleteProject(
        updatedProject.id,
      );

      // 4) Handle the result
      return projectDeletionResult.fold((failure) => Left(failure), (_) {
        // Project deleted successfully
        // Log any track deletion errors for debugging but don't fail the operation
        if (deletionErrors.isNotEmpty) {
          // Note: Track deletion errors occurred but project was deleted:
          // ${deletionErrors.join(', ')}
        }
        return const Right(unit);
      });
    } on ProjectException catch (e) {
      return Left(ProjectException(e.message));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
