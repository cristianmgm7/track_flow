abstract class PlaybackService {
  Future<void> play({required String url});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Stream<Duration> get positionStream;
  Stream<PlayerState> get playerStateStream;
  Stream<Duration?> get durationStream;
  Future<void> dispose();
}

enum PlayerState { idle, loading, playing, paused, stopped, error }
