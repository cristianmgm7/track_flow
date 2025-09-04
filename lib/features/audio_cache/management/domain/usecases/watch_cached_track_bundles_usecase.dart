import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_cache/management/domain/entities/cached_track_bundle.dart';
import 'package:trackflow/features/audio_cache/shared/domain/usecases/watch_cached_audios_usecase.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/download_progress.dart';
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class WatchCachedTrackBundlesUseCase {
  WatchCachedTrackBundlesUseCase(
    this._watchCachedAudios,
    this._audioDownloadRepository,
    this._audioTrackRepository,
    this._userProfileRepository,
    this._projectsRepository,
  );

  final WatchCachedAudiosUseCase _watchCachedAudios;
  final AudioDownloadRepository _audioDownloadRepository;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileRepository _userProfileRepository;
  final ProjectsRepository _projectsRepository;

  Stream<Either<Failure, List<CachedTrackBundle>>> call() async* {
    await for (final cachedAudios in _watchCachedAudios()) {
      try {
        // Active downloads snapshot
        final activeDownloadsEither =
            await _audioDownloadRepository.getActiveDownloads();
        final Map<String, DownloadProgress> trackIdToProgress = {};
        activeDownloadsEither.fold((_) => null, (list) {
          for (final p in list) {
            trackIdToProgress[p.trackId] = p;
          }
        });

        final bundles = await Future.wait(
          cachedAudios.map((cached) async {
            final trackId = AudioTrackId.fromUniqueString(cached.trackId);

            final trackEither = await _audioTrackRepository.getTrackById(
              trackId,
            );
            final AudioTrack? track = trackEither.fold((_) => null, (t) => t);

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

            final activeDownload = trackIdToProgress[cached.trackId];
            return CachedTrackBundle(
              cached: cached,
              track: track,
              uploader: uploader,
              projectName:
                  (projectName != null && projectName!.isNotEmpty)
                      ? projectName
                      : null,
              activeDownload: activeDownload,
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
