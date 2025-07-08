import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_context/domain/services/audio_context_service.dart';
import '../entities/track_context.dart';

/// Use case for watching track business context changes
/// Provides real-time updates for collaboration scenarios
@injectable
class WatchTrackContextUseCase {
  const WatchTrackContextUseCase(this._audioContextService);

  final AudioContextService _audioContextService;

  /// Watch context changes for a specific track
  /// Returns a stream that emits context updates
  Stream<TrackContext> call(String trackId) {
    return _audioContextService.watchTrackContext(trackId);
  }
}
