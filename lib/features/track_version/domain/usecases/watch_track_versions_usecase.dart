import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

@lazySingleton
class WatchTrackVersionsUseCase {
  final TrackVersionRepository repository;
  WatchTrackVersionsUseCase(this.repository);

  Stream<Either<Failure, List<TrackVersion>>> call(AudioTrackId trackId) {
    return repository.watchVersionsByTrack(trackId);
  }
}
