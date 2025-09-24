import 'package:audio_service/audio_service.dart' as audio_service;
import '../../../audio_context/infrastructure/services/track_context_background_service.dart';
import '../../domain/services/audio_playback_service.dart';
import '../../domain/entities/playback_state.dart' as domain;
import '../../../../core/di/injection.dart';

/// Background audio handler for when app is terminated or backgrounded
/// Handles media controls from lock screen, notifications, and car integration
class TrackFlowBackgroundAudioHandler extends audio_service.BaseAudioHandler
    with audio_service.QueueHandler, audio_service.SeekHandler {
  final AudioPlaybackService _audioService;
  final TrackContextBackgroundService _backgroundContext;

  TrackFlowBackgroundAudioHandler._({
    required AudioPlaybackService audioService,
    required TrackContextBackgroundService backgroundContext,
  }) : _audioService = audioService,
       _backgroundContext = backgroundContext {
    _listenToAudioServiceChanges();
  }

  /// Factory constructor using service locator
  static Future<TrackFlowBackgroundAudioHandler> create() async {
    final audioService = sl<AudioPlaybackService>();
    final backgroundContext = TrackContextBackgroundService.instance;

    return TrackFlowBackgroundAudioHandler._(
      audioService: audioService,
      backgroundContext: backgroundContext,
    );
  }

  /// Listen to playback session changes and update media item
  void _listenToAudioServiceChanges() {
    _audioService.sessionStream.listen((session) async {
      // Update playback state
      playbackState.add(
        audio_service.PlaybackState(
          controls: [
            audio_service.MediaControl.skipToPrevious,
            _isPlaying(session.state)
                ? audio_service.MediaControl.pause
                : audio_service.MediaControl.play,
            audio_service.MediaControl.skipToNext,
          ],
          systemActions: const {
            audio_service.MediaAction.seek,
            audio_service.MediaAction.seekForward,
            audio_service.MediaAction.seekBackward,
          },
          playing: _isPlaying(session.state),
          processingState: _mapToAudioServiceState(session.state),
          updatePosition: session.position,
        ),
      );

      // Update media item with rich context information
      if (session.currentTrack != null) {
        final trackId = session.currentTrack!.id.value;
        final title = session.currentTrack!.title;

        // Get enhanced info from background service
        final backgroundInfo = await _backgroundContext
            .getTrackInfoForBackground(trackId, title);

        mediaItem.add(
          audio_service.MediaItem(
            id: trackId,
            title: title,
            artist: backgroundInfo.artist,
            duration: backgroundInfo.duration,
            album: backgroundInfo.projectName,
            artUri:
                session.currentTrack!.coverUrl?.isNotEmpty == true
                    ? Uri.parse(session.currentTrack!.coverUrl!)
                    : null,
          ),
        );
      }
    });
  }

  bool _isPlaying(domain.PlaybackState state) {
    return state == domain.PlaybackState.playing;
  }

  audio_service.AudioProcessingState _mapToAudioServiceState(
    domain.PlaybackState state,
  ) {
    switch (state) {
      case domain.PlaybackState.loading:
        return audio_service.AudioProcessingState.loading;
      case domain.PlaybackState.playing:
        return audio_service.AudioProcessingState.ready;
      case domain.PlaybackState.paused:
        return audio_service.AudioProcessingState.ready;
      case domain.PlaybackState.stopped:
        return audio_service.AudioProcessingState.idle;
      case domain.PlaybackState.error:
        return audio_service.AudioProcessingState.error;
      case domain.PlaybackState.completed:
        return audio_service.AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() async {
    await _audioService.resume();
  }

  @override
  Future<void> pause() async {
    await _audioService.pause();
  }

  @override
  Future<void> stop() async {
    await _audioService.stop();
    _backgroundContext.clearCurrentContext();
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    await _audioService.skipToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _audioService.skipToPrevious();
  }

  /// Custom action: Get current track context for external integrations
  Future<Map<String, dynamic>?> getCurrentTrackContext() async {
    final session = _audioService.currentSession;
    if (session.currentTrack == null) return null;

    final trackId = session.currentTrack!.id.value;
    final context = await _backgroundContext.getContextForTrack(trackId);

    if (context == null) return null;

    return {
      'trackId': trackId,
      'title': session.currentTrack!.title,
      'artist': context.collaborator?.name,
      'projectName': context.projectName,
      'duration': context.activeVersionDuration?.inMilliseconds,
      'position': session.position.inMilliseconds,
    };
  }
}
