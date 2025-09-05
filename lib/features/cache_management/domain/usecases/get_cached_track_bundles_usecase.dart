import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/cache_management/domain/entities/cached_track_bundle.dart';
import 'package:trackflow/features/audio_cache/domain/failures/cache_failure.dart'
    as cache;
import '../services/cache_maintenance_service.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
// Removed dependency on AudioDownloadRepository
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/user_profile/domain/repositories/user_profile_repository.dart';

@injectable
class GetCachedTrackBundlesUseCase {
  GetCachedTrackBundlesUseCase(
    this._cacheMaintenanceService,
    this._audioStorageRepository,
    this._audioTrackRepository,
    this._userProfileRepository,
    this._projectsRepository,
  );

  final CacheMaintenanceService _cacheMaintenanceService;
  // ignore: unused_field
  final AudioStorageRepository _audioStorageRepository;
  final AudioTrackRepository _audioTrackRepository;
  final UserProfileRepository _userProfileRepository;
  final ProjectsRepository _projectsRepository;

  Future<Either<Failure, List<CachedTrackBundle>>> call() async {
    try {
      // Prefer reactive index from storage repository; fallback to maintenance
      final cachedEither = await _cacheMaintenanceService.getAllCachedAudios();

      return await cachedEither.fold(
        (cacheFailure) async {
          return Left(_toFailure(cacheFailure));
        },
        (cachedAudios) async {
          final bundles = await Future.wait(
            cachedAudios.map((cached) async {
              final AudioTrackId trackId = AudioTrackId.fromUniqueString(
                cached.trackId,
              );

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

              return CachedTrackBundle(
                cached: cached,
                track: track,
                uploader: uploader,
                projectName:
                    (projectName != null && projectName!.isNotEmpty)
                        ? projectName
                        : null,
                activeDownload: null,
              );
            }),
          );

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
