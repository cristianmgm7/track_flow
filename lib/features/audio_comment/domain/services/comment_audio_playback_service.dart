import 'package:trackflow/features/audio_player/domain/entities/playback_session.dart';

/// Lightweight playback service dedicated to audio comments.
/// Separate instance from the main track player to avoid state collisions.
abstract class CommentAudioPlaybackService {
  /// Stream of playback session updates for comment audio
  Stream<PlaybackSession> get sessionStream;

  /// Current session snapshot
  PlaybackSession get currentSession;

  /// Play an audio comment by local path or remote URL
  Future<void> play({String? localPath, String? remoteUrl, required String commentId});

  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<void> dispose();
}


