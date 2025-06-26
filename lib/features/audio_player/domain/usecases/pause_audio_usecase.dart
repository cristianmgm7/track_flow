import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';

@lazySingleton
class PauseAudioUseCase {
  final PlaybackService _playbackService;

  PauseAudioUseCase(this._playbackService);

  Future<void> call() async {
    await _playbackService.pause();
  }
}