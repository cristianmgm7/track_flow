import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_state_persistence.dart';

@lazySingleton
class StopAudioUseCase {
  final PlaybackService _playbackService;
  final PlaybackStatePersistence _playbackStatePersistence;

  StopAudioUseCase(
    this._playbackService,
    this._playbackStatePersistence,
  );

  Future<void> call() async {
    await _playbackService.stop();
    await _playbackStatePersistence.clearPlaybackState();
  }
}