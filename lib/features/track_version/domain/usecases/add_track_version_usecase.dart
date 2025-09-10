import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_track/domain/services/audio_metadata_service.dart';
import 'package:trackflow/features/waveform/domain/usecases/get_or_generate_waveform.dart';
import 'package:crypto/crypto.dart' as crypto;

class AddTrackVersionParams {
  final AudioTrackId trackId;
  final File file;
  final String? label;
  final Duration? duration; // Add duration parameter

  AddTrackVersionParams({
    required this.trackId,
    required this.file,
    this.label,
    this.duration,
  });
}

@lazySingleton
class AddTrackVersionUseCase {
  final SessionStorage sessionStorage;
  final TrackVersionRepository trackVersionRepository;
  final AudioMetadataService audioMetadataService;
  final AudioStorageRepository audioStorageRepository;
  final GetOrGenerateWaveform getOrGenerateWaveform;

  AddTrackVersionUseCase(
    this.sessionStorage,
    this.trackVersionRepository,
    this.audioMetadataService,
    this.audioStorageRepository,
    this.getOrGenerateWaveform,
  );

  Future<Either<Failure, TrackVersion>> call(
    AddTrackVersionParams params,
  ) async {
    try {
      final userId = await sessionStorage.getUserId();
      if (userId == null) {
        return Left(AuthenticationFailure('User not authenticated'));
      }

      // 1) Ensure file exists
      if (!await params.file.exists()) {
        return Left(ValidationFailure('Selected audio file does not exist'));
      }

      // 2) Extract duration if not provided
      final Duration duration;
      if (params.duration != null) {
        duration = params.duration!;
      } else {
        final durationEither = await audioMetadataService.extractDuration(
          params.file,
        );
        if (durationEither.isLeft()) {
          return durationEither.map((_) => throw Exception());
        }
        duration = durationEither.getOrElse(() => Duration.zero);
      }

      // 3) Create version first to get versionId, then cache with correct versionId
      final addEither = await trackVersionRepository.addVersion(
        trackId: params.trackId,
        file: params.file,
        label: params.label,
        duration: duration,
        createdBy: UserId.fromUniqueString(userId),
      );

      if (addEither.isLeft()) {
        return addEither;
      }

      final version = addEither.getOrElse(() => throw Exception());

      // 4) Cache audio locally using the actual versionId from created version
      final cacheEither = await audioStorageRepository.storeAudio(
        params.trackId,
        version.id, // Use the actual versionId from the created version
        params.file,
      );

      if (cacheEither.isLeft()) {
        // Rollback version creation if cache fails
        await trackVersionRepository.deleteVersion(version.id);
        final failure = cacheEither.fold((l) => l, (r) => null);
        return Left(CacheFailure(failure?.message ?? 'Failed to cache audio'));
      }

      final cached = cacheEither.getOrElse(() => throw Exception());
      final cachedFile = File(cached.filePath);

      // 5) Fire-and-forget waveform generation using cached file
      () async {
        try {
          final bytes = await cachedFile.readAsBytes();
          final audioSourceHash = crypto.sha1.convert(bytes).toString();
          await getOrGenerateWaveform(
            GetOrGenerateWaveformParams(
              versionId: version.id,
              audioFilePath: cachedFile.path,
              audioSourceHash: audioSourceHash,
              algorithmVersion: 1,
              targetSampleCount: null,
              forceRefresh: true,
            ),
          );
        } catch (_) {
          // swallow - waveform is best-effort
        }
      }();

      return Right(version);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to add track version: $e'));
    }
  }
}
