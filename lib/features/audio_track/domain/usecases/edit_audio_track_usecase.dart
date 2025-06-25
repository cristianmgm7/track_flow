import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/services/project_track_service.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';

class EditAudioTrackParams {
  final AudioTrackId trackId;
  final ProjectId projectId;
  final String newName;

  EditAudioTrackParams({
    required this.trackId,
    required this.projectId,
    required this.newName,
  });
}

@lazySingleton
class EditAudioTrackUseCase {
  final ProjectTrackService projectTrackService;
  final ProjectDetailRepository projectDetailRepository;

  EditAudioTrackUseCase(this.projectTrackService, this.projectDetailRepository);

  Future<Either<Failure, Unit>> call(EditAudioTrackParams params) async {
    return await projectTrackService.editTrackName(
      trackId: params.trackId,
      projectId: params.projectId,
      newName: params.newName,
    );
  }
}
