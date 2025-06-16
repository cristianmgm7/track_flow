import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/project_detail/aplication/playback_source.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

enum PlayerVisualContext { miniPlayer, commentPlayer }

abstract class AudioPlayerState extends Equatable {
  PlaybackSource get source;
  PlayerVisualContext get visualContext;
  AudioTrack get track;
  UserProfile get collaborator;

  @override
  List<Object?> get props => [source, visualContext, track, collaborator];
}

class AudioPlayerIdle extends AudioPlayerState {
  @override
  PlaybackSource get source => throw UnimplementedError();

  @override
  PlayerVisualContext get visualContext => PlayerVisualContext.miniPlayer;

  @override
  AudioTrack get track => throw UnimplementedError();

  @override
  UserProfile get collaborator => throw UnimplementedError();
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
  AudioTrack get track => throw UnimplementedError();

  @override
  UserProfile get collaborator => throw UnimplementedError();

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
  AudioTrack get track => throw UnimplementedError();

  @override
  UserProfile get collaborator => throw UnimplementedError();

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

class AudioPlayerLoading extends AudioPlayerActiveState {
  AudioPlayerLoading(super.source, super.visualContext);

  @override
  AudioTrack get track => throw UnimplementedError();

  @override
  UserProfile get collaborator => throw UnimplementedError();

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
  }) {
    return AudioPlayerLoading(
      source ?? this.source,
      visualContext ?? this.visualContext,
    );
  }
}
