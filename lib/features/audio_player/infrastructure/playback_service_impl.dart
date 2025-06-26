import 'package:just_audio/just_audio.dart' as ja;
import 'package:trackflow/features/audio_player/domain/services/playback_service.dart';

class PlaybackServiceImpl implements PlaybackService {
  final ja.AudioPlayer _player = ja.AudioPlayer();

  @override
  Future<void> play({required String url}) async {
    await _player.setUrl(url);
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<PlayerState> get playerStateStream =>
      _player.playerStateStream.map((state) {
        switch (state.processingState) {
          case ja.ProcessingState.idle:
            return PlayerState.idle;
          case ja.ProcessingState.loading:
            return PlayerState.loading;
          case ja.ProcessingState.ready:
            return state.playing ? PlayerState.playing : PlayerState.paused;
          case ja.ProcessingState.completed:
            return PlayerState.stopped;
          case ja.ProcessingState.buffering:
            return PlayerState.loading;
          default:
            return PlayerState.error;
        }
      });

  @override
  Future<void> dispose() => _player.dispose();

  @override
  Stream<Duration?> get durationStream => _player.durationStream;
}
