import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';

@lazySingleton
class ResumeAudioUseCase {
  final PlaybackService _playbackService;

  ResumeAudioUseCase(this._playbackService);

  Future<void> call() async {
    await _playbackService.resume();
  }
}