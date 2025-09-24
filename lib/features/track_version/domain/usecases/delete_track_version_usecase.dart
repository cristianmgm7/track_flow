import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/waveform/domain/repositories/waveform_repository.dart';
import 'package:trackflow/features/audio_comment/domain/repositories/audio_comment_repository.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';

class DeleteTrackVersionParams {
  final TrackVersionId versionId;

  DeleteTrackVersionParams({required this.versionId});
}

@lazySingleton
class DeleteTrackVersionUseCase {
  final TrackVersionRepository trackVersionRepository;
  final WaveformRepository waveformRepository;
  final AudioCommentRepository audioCommentRepository;
  final AudioStorageRepository audioStorageRepository;

  DeleteTrackVersionUseCase(
    this.trackVersionRepository,
    this.waveformRepository,
    this.audioCommentRepository,
    this.audioStorageRepository,
  );

  Future<Either<Failure, Unit>> call(DeleteTrackVersionParams params) async {
    try {
      // First, get the track version to obtain the trackId
      final versionResult = await trackVersionRepository.getById(
        params.versionId,
      );
      if (versionResult.isLeft()) {
        return versionResult.map((_) => unit);
      }
      final trackVersion = versionResult.getOrElse(
        () => throw Exception('Version not found'),
      );

      // Delete waveforms for the version
      final waveformResult = await waveformRepository.deleteWaveformsForVersion(
        trackVersion.trackId,
        params.versionId,
      );
      if (waveformResult.isLeft()) {
        // Log error but continue with other deletions
        // You might want to add logging here
      }

      // Delete comments for the version
      final commentResult = await audioCommentRepository
          .deleteCommentsByVersion(params.versionId);
      if (commentResult.isLeft()) {
        // Log error but continue with other deletions
        // You might want to add logging here
      }

      // Delete audio file for the version
      final audioResult = await audioStorageRepository.deleteAudioVersionFile(
        trackVersion.trackId,
        params.versionId,
      );
      if (audioResult.isLeft()) {
        // Log error but continue with version deletion
        // You might want to add logging here
      }

      // Finally, delete the track version itself
      return trackVersionRepository.deleteVersion(params.versionId);
    } catch (e) {
      return Left(
        ServerFailure('Failed to delete track version and related data: $e'),
      );
    }
  }
}
