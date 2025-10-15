import 'dart:async';
import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:trackflow/features/audio_player/domain/entities/playback_session.dart';
import 'package:trackflow/features/audio_player/domain/entities/playback_state.dart';
import 'package:trackflow/features/audio_player/domain/entities/audio_track_metadata.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../../domain/services/comment_audio_playback_service.dart';

@LazySingleton(as: CommentAudioPlaybackService)
class CommentAudioPlaybackServiceImpl implements CommentAudioPlaybackService {
  CommentAudioPlaybackServiceImpl();

  final AudioPlayer _player = AudioPlayer();
  PlaybackSession _session = PlaybackSession.initial();
  final StreamController<PlaybackSession> _controller = StreamController<PlaybackSession>.broadcast();

  bool _listenersSetup = false;

  void _setupListeners() {
    if (_listenersSetup) return;
    _player.positionStream.listen((pos) => _emit(_session.copyWith(position: pos)));
    _player.durationStream.listen((dur) {
      if (dur != null && _session.currentTrack != null) {
        _emit(_session.copyWith(currentTrack: _session.currentTrack!.copyWith(duration: dur)));
      }
    });
    _player.playerStateStream.listen((ps) {
      final s = switch (ps.processingState) {
        ProcessingState.idle => PlaybackState.stopped,
        ProcessingState.loading || ProcessingState.buffering => PlaybackState.loading,
        ProcessingState.ready => ps.playing ? PlaybackState.playing : PlaybackState.paused,
        ProcessingState.completed => PlaybackState.completed,
      };
      _emit(_session.copyWith(state: s));
    });
    _listenersSetup = true;
  }

  void _emit(PlaybackSession next) { _session = next; _controller.add(next); }

  @override
  Stream<PlaybackSession> get sessionStream => _controller.stream;

  @override
  PlaybackSession get currentSession => _session;

  @override
  Future<void> play({String? localPath, String? remoteUrl, required String commentId}) async {
    final url = localPath ?? remoteUrl;
    if (url == null) throw Exception('No audio source provided');

    _setupListeners();
    _emit(_session.copyWith(state: PlaybackState.loading));

    // Build minimal metadata for the comment
    final metadata = AudioTrackMetadata(
      id: AudioTrackId.fromUniqueString(commentId),
      title: 'Audio Comment',
      artist: 'Comment',
      duration: Duration.zero,
    );

    final uri = url.startsWith('/') || url.startsWith('file://')
        ? Uri.file(url.startsWith('file://') ? url.replaceFirst('file://', '') : url)
        : Uri.parse(url);

    if (uri.isScheme('file')) {
      final path = uri.toFilePath();
      if (!File(path).existsSync()) {
        throw Exception('Local audio file not found at path: $path');
      }
    }

    await _player.setAudioSource(AudioSource.uri(uri));
    _emit(_session.copyWith(currentTrack: metadata));
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> stop() async {
    await _player.stop();
    _emit(_session.copyWith(state: PlaybackState.stopped, position: Duration.zero));
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> dispose() async {
    await _player.dispose();
    await _controller.close();
  }
}


