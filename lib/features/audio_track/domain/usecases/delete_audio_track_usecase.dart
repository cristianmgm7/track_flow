import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';

// Params
class DeleteAudioTrackParams {
  final String trackId;

  DeleteAudioTrackParams({required this.trackId});
}

class DeleteAudioTrack {
  final AudioTrackRepository repository;

  DeleteAudioTrack(this.repository);

  Future<Either<Failure, Unit>> call(String trackId) {
    return repository.deleteTrack(trackId);
  }
}
