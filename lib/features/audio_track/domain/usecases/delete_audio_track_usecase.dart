import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

// Params
class DeleteAudioTrackParams {
  final AudioTrackId trackId;
  final ProjectId projectId;

  DeleteAudioTrackParams({required this.trackId, required this.projectId});
}

@lazySingleton
class DeleteAudioTrack {
  final SessionStorage sessionStorage;
  final ProjectDetailRepository projectDetailRepository;
  final ProjectTrackService projectTrackService;

  DeleteAudioTrack(
    this.sessionStorage,
    this.projectDetailRepository,
    this.projectTrackService,
  );

  Future<Either<Failure, Unit>> call(DeleteAudioTrackParams params) async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return Future.value(Left(ServerFailure('User not found')));
    }
    final project = await projectDetailRepository.getProjectById(
      params.projectId,
    );
    return project.fold((failure) => Left(failure), (project) async {
      return await projectTrackService.deleteTrack(
        project: project,
        requester: UserId.fromUniqueString(userId),
        trackId: params.trackId,
      );
    });
  }
}
