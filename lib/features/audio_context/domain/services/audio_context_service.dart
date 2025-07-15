import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';

import '../entities/track_context.dart';

/// Service for providing business context for audio tracks
/// Separated from pure audio playback concerns
abstract class AudioContextService {
  /// Get business context for a specific track
  Future<Either<Failure, TrackContext>> getTrackContext(AudioTrackId trackId);
}
