import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

enum PlayerVisualContext { miniPlayer, commentPlayer }

enum PlaybackSourceType { track, comment }

class PlaybackSource {
  final PlaybackSourceType type;

  const PlaybackSource({required this.type});
}

abstract class AudioPlayerState extends Equatable {
  final PlayerVisualContext visualContext;
  const AudioPlayerState(this.visualContext);

  @override
  List<Object?> get props => [visualContext];
}

class AudioPlayerIdle extends AudioPlayerState {
  const AudioPlayerIdle() : super(PlayerVisualContext.miniPlayer);
}

abstract class AudioPlayerActiveState extends AudioPlayerState {
  final PlaybackSource source;
  final AudioTrack track;
  final UserProfile collaborator;

  const AudioPlayerActiveState(
    this.source,
    PlayerVisualContext visualContext,
    this.track,
    this.collaborator,
  ) : super(visualContext);

  @override
  List<Object?> get props => [source, visualContext, track, collaborator];

  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
  });
}

class AudioPlayerPlaying extends AudioPlayerActiveState {
  const AudioPlayerPlaying(
    super.source,
    super.visualContext,
    super.track,
    super.collaborator,
  );

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
  }) {
    return AudioPlayerPlaying(
      source ?? this.source,
      visualContext ?? this.visualContext,
      track ?? this.track,
      collaborator ?? this.collaborator,
    );
  }
}

class AudioPlayerPaused extends AudioPlayerActiveState {
  const AudioPlayerPaused(
    super.source,
    super.visualContext,
    super.track,
    super.collaborator,
  );

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
  }) {
    return AudioPlayerPaused(
      source ?? this.source,
      visualContext ?? this.visualContext,
      track ?? this.track,
      collaborator ?? this.collaborator,
    );
  }
}

class AudioPlayerLoading extends AudioPlayerActiveState {
  const AudioPlayerLoading(
    super.source,
    super.visualContext,
    super.track,
    super.collaborator,
  );

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
  }) {
    return AudioPlayerLoading(
      source ?? this.source,
      visualContext ?? this.visualContext,
      track ?? this.track,
      collaborator ?? this.collaborator,
    );
  }
}
