import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/management/domain/entities/cached_track_bundle.dart';
import 'package:trackflow/features/audio_cache/shared/domain/entities/download_progress.dart';
import 'package:trackflow/features/audio_cache/shared/domain/failures/cache_failure.dart'
    as cache;
import 'package:trackflow/features/audio_cache/shared/domain/services/cache_maintenance_service.dart';
import 'package:trackflow/features/audio_cache/shared/domain/repositories/audio_download_repository.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class GetCachedTrackBundlesUseCase {
  GetCachedTrackBundlesUseCase(
    this._cacheMaintenanceService,
    this._audioTrackRepository,
    this._userProfileRepository,
    this._projectsRepository,
    this._audioDownloadRepository,
  );

  final CacheMaintenanceService _cacheMaintenanceService;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileRepository _userProfileRepository;
  final ProjectsRepository _projectsRepository;
  final AudioDownloadRepository _audioDownloadRepository;

  Future<Either<Failure, List<CachedTrackBundle>>> call() async {
    try {
      final cachedEither = await _cacheMaintenanceService.getAllCachedAudios();

      return await cachedEither.fold(
        (cacheFailure) async {
          return Left(_toFailure(cacheFailure));
        },
        (cachedAudios) async {
          // Preload active downloads map for quick lookup
          final activeDownloadsEither =
              await _audioDownloadRepository.getActiveDownloads();
          final Map<String, DownloadProgress> trackIdToProgress = {};
          activeDownloadsEither.fold((_) => null, (list) {
            for (final p in list) {
              trackIdToProgress[p.trackId] = p;
            }
          });

          final List<CachedTrackBundle> bundles = [];
          for (final cached in cachedAudios) {
            final AudioTrackId trackId = AudioTrackId.fromUniqueString(
              cached.trackId,
            );

            // Fetch track
            final trackEither = await _audioTrackRepository.getTrackById(
              trackId,
            );
            AudioTrack? track = trackEither.fold((_) => null, (t) => t);

            // Fetch uploader profile (best-effort)
            final uploaderEither =
                track != null
                    ? await _userProfileRepository.getUserProfile(
                      track.uploadedBy,
                    )
                    : null;
            final uploader = uploaderEither?.fold((_) => null, (p) => p);

            // Fetch project name (best-effort)
            String? projectName;
            if (track != null) {
              final projectEither = await _projectsRepository.getProjectById(
                track.projectId,
              );
              projectEither.fold((_) => null, (project) {
                projectName = project.name.value.getOrElse(() => '');
              });
            }

            // Active download if any
            final activeDownload = trackIdToProgress[cached.trackId];

            bundles.add(
              CachedTrackBundle(
                cached: cached,
                track: track,
                uploader: uploader,
                projectName:
                    (projectName != null && projectName!.isNotEmpty)
                        ? projectName
                        : null,
                activeDownload: activeDownload,
              ),
            );
          }

          return Right(bundles);
        },
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Failure _toFailure(cache.CacheFailure failure) {
    return ServerFailure(failure.message);
  }
}
