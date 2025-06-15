import 'package:trackflow/features/project_detail/aplication/playback_source.dart';

enum PlayerVisualContext { miniPlayer, commentPlayer }

abstract class AudioPlayerState {
  PlaybackSource get source;
  PlayerVisualContext get visualContext;
}

class AudioPlayerIdle extends AudioPlayerState {
  @override
  PlaybackSource get source => throw UnimplementedError();

  @override
  PlayerVisualContext get visualContext => PlayerVisualContext.miniPlayer;
}

abstract class AudioPlayerActiveState extends AudioPlayerState {
  @override
  final PlaybackSource source;
  @override
  final PlayerVisualContext visualContext;

  AudioPlayerActiveState(this.source, this.visualContext);

  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
  });
}

class AudioPlayerPlaying extends AudioPlayerActiveState {
  AudioPlayerPlaying(super.source, super.visualContext);

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
  }) {
    return AudioPlayerPlaying(
      source ?? this.source,
      visualContext ?? this.visualContext,
    );
  }
}

class AudioPlayerPaused extends AudioPlayerActiveState {
  AudioPlayerPaused(super.source, super.visualContext);

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
  }) {
    return AudioPlayerPaused(
      source ?? this.source,
      visualContext ?? this.visualContext,
    );
  }
}
