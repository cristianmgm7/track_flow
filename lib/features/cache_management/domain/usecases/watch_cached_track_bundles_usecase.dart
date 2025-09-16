import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/cache_management/domain/entities/cached_track_bundle.dart';
import '../services/cache_maintenance_service.dart';
// Download progress not used here anymore
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';

@injectable
class WatchCachedTrackBundlesUseCase {
  WatchCachedTrackBundlesUseCase(
    this._maintenanceService,
    this._audioTrackRepository,
    this._userProfileRepository,
    this._projectsRepository,
    this._trackVersionRepository,
  );

  final CacheMaintenanceService _maintenanceService;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileRepository _userProfileRepository;
  final ProjectsRepository _projectsRepository;
  final TrackVersionRepository _trackVersionRepository;

  Stream<Either<Failure, List<CachedTrackBundle>>> call() async* {
    await for (final cachedAudios in _maintenanceService.watchCachedAudios()) {
      try {
        final bundles = await Future.wait(
          cachedAudios.map((cached) async {
            final trackId = AudioTrackId.fromUniqueString(cached.trackId);
            final versionId = TrackVersionId.fromUniqueString(cached.versionId);

            final trackEither = await _audioTrackRepository.getTrackById(
              trackId,
            );
            final AudioTrack? track = trackEither.fold((_) => null, (t) => t);

            // Fetch version details
            final versionEither = await _trackVersionRepository.getById(
              versionId,
            );
            final version = versionEither.fold((_) => null, (v) => v);

            final uploaderEither =
                track != null
                    ? await _userProfileRepository.getUserProfile(
                      track.uploadedBy,
                    )
                    : null;
            final uploader = uploaderEither?.fold((_) => null, (p) => p);

            String? projectName;
            if (track != null) {
              final projectEither = await _projectsRepository.getProjectById(
                track.projectId,
              );
              projectEither.fold((_) => null, (project) {
                projectName = project.name.value.getOrElse(() => '');
              });
            }

            return CachedTrackBundle(
              cached: cached,
              track: track,
              version: version,
              uploader: uploader,
              projectName:
                  (projectName != null && projectName!.isNotEmpty)
                      ? projectName
                      : null,
              activeDownload: null,
            );
          }),
        );

        yield Right(bundles);
      } catch (e) {
        yield Left(ServerFailure(e.toString()));
      }
    }
  }
}
