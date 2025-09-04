import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';

import '../failures/cache_failure.dart';
import '../repositories/audio_download_repository.dart';
import '../repositories/audio_storage_repository.dart';
import '../../../../core/entities/unique_id.dart';

@injectable
class CacheTrackUseCase {
  final AudioDownloadRepository _audioDownloadRepository;
  final AudioStorageRepository _audioStorageRepository;

  CacheTrackUseCase(
    this._audioDownloadRepository,
    this._audioStorageRepository,
  );

  /// Cache a single track for individual playback
  ///
  /// [trackId] - Unique identifier for the track
  /// [audioUrl] - Source URL for the audio file
  ///
  /// Returns success or specific failure for error handling
  Future<Either<CacheFailure, Unit>> call({
    required String trackId,
    required String audioUrl,
  }) async {
    // Validate inputs
    if (trackId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Track ID cannot be empty',
          field: 'trackId',
          value: trackId,
        ),
      );
    }

    if (audioUrl.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Audio URL cannot be empty',
          field: 'audioUrl',
          value: audioUrl,
        ),
      );
    }

    // Validate URL format (basic validation)
    final uri = Uri.tryParse(audioUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      return Left(
        ValidationCacheFailure(
          message: 'Invalid audio URL format',
          field: 'audioUrl',
          value: audioUrl,
        ),
      );
    }

    try {
      final result = await _audioDownloadRepository.downloadAudio(
        AudioTrackId.fromUniqueString(trackId),
        audioUrl,
      );

      return await result.fold((failure) => Left(failure), (filePath) async {
        final storeResult = await _audioStorageRepository.storeAudio(
          AudioTrackId.fromUniqueString(trackId),
          File(filePath),
        );
        return storeResult.fold(
          (failure) => Left(failure),
          (_) => const Right(unit),
        );
      });
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while caching track: $e',
          field: 'cache_operation',
          value: {'trackId': trackId, 'audioUrl': audioUrl},
        ),
      );
    }
  }
}
