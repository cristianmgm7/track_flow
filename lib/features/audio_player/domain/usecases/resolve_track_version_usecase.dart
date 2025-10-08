import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import '../entities/audio_failure.dart';

/// Pure version resolution use case
/// ONLY handles resolving AudioTrack to its active TrackVersion
/// Orchestrates between AudioTrack and TrackVersion repositories
@injectable
class ResolveTrackVersionUseCase {
  const ResolveTrackVersionUseCase({
    required AudioTrackRepository audioTrackRepository,
    required TrackVersionRepository trackVersionRepository,
  })  : _audioTrackRepository = audioTrackRepository,
        _trackVersionRepository = trackVersionRepository;

  final AudioTrackRepository _audioTrackRepository;
  final TrackVersionRepository _trackVersionRepository;

  /// Resolve track to its active version
  /// Handles: track fetching, active version lookup, version resolution
  /// Does NOT handle: playback, caching, business rules
  Future<Either<AudioFailure, TrackVersion>> call(
    AudioTrackId trackId,
  ) async {
    try {
      // 1. Get track to find activeVersionId
      final trackResult = await _audioTrackRepository.getTrackById(trackId);

      return await trackResult.fold(
        (failure) async => Left(TrackNotFoundFailure(trackId.value)),
        (audioTrack) async {
          // 2. Check if track has an active version
          if (audioTrack.activeVersionId == null) {
            return Left(
              VersionNotFoundFailure(
                'Track ${trackId.value} has no active version',
              ),
            );
          }

          // 3. Get version from repository
          final versionResult = await _trackVersionRepository.getById(
            audioTrack.activeVersionId!,
          );

          return versionResult.fold(
            (failure) => Left(
              VersionNotFoundFailure(audioTrack.activeVersionId!.value),
            ),
            (version) {
              // 4. Validate version has playable source
              if ((version.fileLocalPath == null ||
                   version.fileLocalPath!.isEmpty) &&
                  (version.fileRemoteUrl == null ||
                   version.fileRemoteUrl!.isEmpty)) {
                return Left(
                  AudioSourceFailure(
                    'Version ${version.id.value} has no audio source',
                  ),
                );
              }

              return Right(version);
            },
          );
        },
      );
    } catch (e) {
      if (e.toString().contains('not found')) {
        return Left(TrackNotFoundFailure(trackId.value));
      } else if (e.toString().contains('network')) {
        return const Left(NetworkFailure());
      } else {
        return Left(
          PlaybackFailure('Failed to resolve track version: ${e.toString()}'),
        );
      }
    }
  }
}
