import 'package:trackflow/core/utils/app_logger.dart';

import '../../domain/entities/track_context.dart';
import '../../domain/usecases/load_track_context_usecase.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../../core/di/injection.dart';

/// Service for accessing track context in background scenarios
/// where Flutter widget tree is not available (notifications, background audio)
class TrackContextBackgroundService {
  static TrackContextBackgroundService? _instance;
  static TrackContextBackgroundService get instance =>
      _instance ??= TrackContextBackgroundService._();

  TrackContextBackgroundService._();

  // In-memory cache for current playing track context
  TrackContext? _currentContext;
  String? _currentTrackId;

  /// Update current context (called from UI layer)
  void updateCurrentContext(TrackContext context) {
    _currentContext = context;
    _currentTrackId = context.trackId;
  }

  /// Get current context from cache
  TrackContext? getCurrentContext() => _currentContext;

  /// Get context for specific track (for background scenarios)
  Future<TrackContext?> getContextForTrack(String trackId) async {
    // If requesting current cached track, return immediately
    if (_currentTrackId == trackId && _currentContext != null) {
      return _currentContext;
    }

    try {
      // Load fresh context directly using use case (bypassing BloC)
      final loadContextUseCase = sl<LoadTrackContextUseCase>();
      final result = await loadContextUseCase.call(
        AudioTrackId.fromUniqueString(trackId),
      );

      return result.fold(
        (failure) {
          AppLogger.warning('Failed to load context for background: $failure', tag: 'TRACK_CONTEXT_BACKGROUND_SERVICE');
          return null;
        },
        (context) {
          // Update cache with fresh context
          updateCurrentContext(context);
          return context;
        },
      );
    } catch (e) {
      AppLogger.warning('Error loading context for background: $e', tag: 'TRACK_CONTEXT_BACKGROUND_SERVICE');
      return null;
    }
  }

  /// Get artist name for background notifications
  Future<String> getArtistNameForTrack(String trackId) async {
    final context = await getContextForTrack(trackId);
    return context?.collaborator?.name ?? 'Unknown Artist';
  }

  /// Get duration for background notifications
  Future<Duration?> getDurationForTrack(String trackId) async {
    final context = await getContextForTrack(trackId);
    return context?.activeVersionDuration;
  }

  /// Get track info for background notifications
  Future<BackgroundTrackInfo> getTrackInfoForBackground(
    String trackId,
    String trackTitle,
  ) async {
    final context = await getContextForTrack(trackId);

    return BackgroundTrackInfo(
      trackId: trackId,
      title: trackTitle,
      artist: context?.collaborator?.name ?? 'Unknown Artist',
      duration: context?.activeVersionDuration,
      projectName: context?.projectName,
    );
  }

  /// Clear current context (when audio stops)
  void clearCurrentContext() {
    _currentContext = null;
    _currentTrackId = null;
  }
}

/// Data class for background track information
class BackgroundTrackInfo {
  final String trackId;
  final String title;
  final String artist;
  final Duration? duration;
  final String? projectName;

  const BackgroundTrackInfo({
    required this.trackId,
    required this.title,
    required this.artist,
    this.duration,
    this.projectName,
  });

  @override
  String toString() =>
      'BackgroundTrackInfo(title: $title, artist: $artist, duration: $duration)';
}
