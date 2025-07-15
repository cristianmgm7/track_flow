import 'package:injectable/injectable.dart';
import '../../domain/entities/playback_session.dart';
import '../../domain/repositories/playback_persistence_repository.dart';

/// Simple implementation of PlaybackPersistenceRepository
/// For now, this is a no-op implementation to resolve DI issues
/// TODO: Implement actual persistence logic
@LazySingleton(as: PlaybackPersistenceRepository)
class PlaybackPersistenceRepositoryImpl
    implements PlaybackPersistenceRepository {
  @override
  Future<void> savePlaybackState(PlaybackSession session) async {
    // TODO: Implement actual persistence
  }

  @override
  Future<PlaybackSession?> loadPlaybackState() async {
    // TODO: Implement actual persistence
    return null;
  }

  @override
  Future<void> clearPlaybackState() async {
    // TODO: Implement actual persistence
  }

  @override
  Future<bool> hasPlaybackState() async {
    // TODO: Implement actual persistence
    return false;
  }

  @override
  Future<void> saveQueue(List<String> trackIds, int currentIndex) async {
    // TODO: Implement actual persistence
  }

  @override
  Future<({List<String> trackIds, int currentIndex})?> loadQueue() async {
    // TODO: Implement actual persistence
    return null;
  }

  @override
  Future<void> saveTrackPosition(String trackId, Duration position) async {
    // TODO: Implement actual persistence
  }

  @override
  Future<Duration?> loadTrackPosition(String trackId) async {
    // TODO: Implement actual persistence
    return null;
  }

  @override
  Future<void> clearTrackPositions() async {
    // TODO: Implement actual persistence
  }
}
