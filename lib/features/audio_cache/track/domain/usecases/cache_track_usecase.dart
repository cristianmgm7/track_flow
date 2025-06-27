import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../shared/domain/failures/cache_failure.dart';
import '../../../shared/domain/services/cache_orchestration_service.dart';
import '../../../shared/domain/value_objects/conflict_policy.dart';

@injectable
class CacheTrackUseCase {
  final CacheOrchestrationService _cacheOrchestrationService;

  CacheTrackUseCase(this._cacheOrchestrationService);

  /// Cache a single track for individual playback
  /// 
  /// [trackId] - Unique identifier for the track
  /// [audioUrl] - Source URL for the audio file
  /// [policy] - How to handle conflicts if track already exists
  /// 
  /// Returns success or specific failure for error handling
  Future<Either<CacheFailure, Unit>> call({
    required String trackId,
    required String audioUrl,
    ConflictPolicy policy = ConflictPolicy.lastWins,
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
      // Use 'individual' as the reference ID for single track caching
      const referenceId = 'individual';
      
      return await _cacheOrchestrationService.cacheAudio(
        trackId,
        audioUrl,
        referenceId,
        policy: policy,
      );
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

  /// Cache a track with custom reference ID
  /// Useful for when the track is cached from a specific context
  Future<Either<CacheFailure, Unit>> cacheWithReference({
    required String trackId,
    required String audioUrl,
    required String referenceId,
    ConflictPolicy policy = ConflictPolicy.lastWins,
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

    if (referenceId.isEmpty) {
      return Left(
        ValidationCacheFailure(
          message: 'Reference ID cannot be empty',
          field: 'referenceId',
          value: referenceId,
        ),
      );
    }

    try {
      return await _cacheOrchestrationService.cacheAudio(
        trackId,
        audioUrl,
        referenceId,
        policy: policy,
      );
    } catch (e) {
      return Left(
        ValidationCacheFailure(
          message: 'Unexpected error while caching track with reference: $e',
          field: 'cache_operation',
          value: {
            'trackId': trackId, 
            'audioUrl': audioUrl, 
            'referenceId': referenceId,
          },
        ),
      );
    }
  }
}