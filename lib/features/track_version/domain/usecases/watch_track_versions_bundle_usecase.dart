import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

class TrackVersionsBundle {
  final AudioTrack track;
  final List<TrackVersion> versions;

  TrackVersionsBundle({required this.track, required this.versions});
}

@lazySingleton
class WatchTrackVersionsBundleUseCase {
  final AudioTrackRepository _audioTrackRepository;
  final TrackVersionRepository _trackVersionRepository;

  WatchTrackVersionsBundleUseCase(
    this._audioTrackRepository,
    this._trackVersionRepository,
  );

  Stream<Either<Failure, TrackVersionsBundle>> call(AudioTrackId trackId) {
    final track$ = _audioTrackRepository
        .watchTrackById(trackId)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())))
        .shareReplay(maxSize: 1);

    final versions$ = _trackVersionRepository
        .watchVersionsByTrack(trackId)
        .onErrorReturnWith((e, _) => left(ServerFailure(e.toString())))
        .shareReplay(maxSize: 1);

    return Rx.combineLatest2<
      Either<Failure, AudioTrack>,
      Either<Failure, List<TrackVersion>>,
      Either<Failure, TrackVersionsBundle>
    >(track$, versions$, (
      Either<Failure, AudioTrack> trackEither,
      Either<Failure, List<TrackVersion>> versionsEither,
    ) {
      return trackEither.fold(
        (failure) => left(failure),
        (track) => versionsEither.fold(
          (failure) => left(failure),
          (versions) =>
              right(TrackVersionsBundle(track: track, versions: versions)),
        ),
      );
    }).onErrorReturnWith(
      (e, _) =>
          left(ServerFailure('Failed to watch track versions bundle: $e')),
    );
  }
}
