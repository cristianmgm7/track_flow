import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/audio_player/domain/entities/playback_session.dart';
import 'package:trackflow/features/audio_player/domain/entities/playback_state.dart';
import '../../domain/services/comment_audio_playback_service.dart';

sealed class CommentAudioState {}
class CommentAudioIdle extends CommentAudioState {}
class CommentAudioBuffering extends CommentAudioState {}
class CommentAudioPlaying extends CommentAudioState {
  final PlaybackSession session;
  CommentAudioPlaying(this.session);
}
class CommentAudioPaused extends CommentAudioState {
  final PlaybackSession session;
  CommentAudioPaused(this.session);
}
class CommentAudioError extends CommentAudioState {
  final String message;
  CommentAudioError(this.message);
}

@injectable
class CommentAudioCubit extends Cubit<CommentAudioState> {
  final CommentAudioPlaybackService _service;
  late final StreamSubscription<PlaybackSession> _subscription;

  CommentAudioCubit(this._service) : super(CommentAudioIdle()) {
    _subscription = _service.sessionStream.listen((session) {
      switch (session.state) {
        case PlaybackState.loading:
          emit(CommentAudioBuffering());
          break;
        case PlaybackState.playing:
          emit(CommentAudioPlaying(session));
          break;
        case PlaybackState.paused:
          emit(CommentAudioPaused(session));
          break;
        case PlaybackState.stopped:
        case PlaybackState.completed:
          emit(CommentAudioIdle());
          break;
        case PlaybackState.error:
          emit(CommentAudioError(session.error ?? 'Playback error'));
          break;
      }
    });
  }

  Future<void> play({String? localPath, String? remoteUrl, required String commentId}) async {
    await _service.play(localPath: localPath, remoteUrl: remoteUrl, commentId: commentId);
  }

  Future<void> pause() => _service.pause();
  Future<void> resume() => _service.resume();
  Future<void> seek(Duration d) => _service.seek(d);

  @override
  Future<void> close() async {
    await _service.stop();
    await _subscription.cancel();
    return super.close();
  }
}


