import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import '../services/audio_context_service.dart';
import '../entities/track_context.dart';

/// Use case for loading track business context
/// Follows clean architecture principles by encapsulating business logic
@injectable
class LoadTrackContextUseCase {
  const LoadTrackContextUseCase(this._audioContextService);

  final AudioContextService _audioContextService;

  /// Load context for a specific track
  /// Returns null if track context cannot be found or loaded
  Future<Either<Failure, TrackContext>> call(AudioTrackId trackId) async {
    return await _audioContextService.getTrackContext(trackId);
  }
}
