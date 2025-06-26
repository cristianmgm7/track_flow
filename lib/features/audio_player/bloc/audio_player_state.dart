import 'package:equatable/equatable.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

enum PlayerVisualContext { miniPlayer, commentPlayer }

enum PlaybackSourceType { track, comment }

enum RepeatMode { none, single, queue }

enum PlaybackQueueMode { normal, shuffle }

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
  final List<String> queue;
  final int currentIndex;
  final RepeatMode repeatMode;
  final PlaybackQueueMode queueMode;

  const AudioPlayerActiveState(
    this.source,
    PlayerVisualContext visualContext,
    this.track,
    this.collaborator,
    this.queue,
    this.currentIndex,
    this.repeatMode,
    this.queueMode,
  ) : super(visualContext);

  @override
  List<Object?> get props => [
        source,
        visualContext,
        track,
        collaborator,
        queue,
        currentIndex,
        repeatMode,
        queueMode,
      ];

  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
    List<String>? queue,
    int? currentIndex,
    RepeatMode? repeatMode,
    PlaybackQueueMode? queueMode,
  });
}

class AudioPlayerPlaying extends AudioPlayerActiveState {
  const AudioPlayerPlaying(
    super.source,
    super.visualContext,
    super.track,
    super.collaborator,
    super.queue,
    super.currentIndex,
    super.repeatMode,
    super.queueMode,
  );

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
    List<String>? queue,
    int? currentIndex,
    RepeatMode? repeatMode,
    PlaybackQueueMode? queueMode,
  }) {
    return AudioPlayerPlaying(
      source ?? this.source,
      visualContext ?? this.visualContext,
      track ?? this.track,
      collaborator ?? this.collaborator,
      queue ?? this.queue,
      currentIndex ?? this.currentIndex,
      repeatMode ?? this.repeatMode,
      queueMode ?? this.queueMode,
    );
  }
}

class AudioPlayerPaused extends AudioPlayerActiveState {
  const AudioPlayerPaused(
    super.source,
    super.visualContext,
    super.track,
    super.collaborator,
    super.queue,
    super.currentIndex,
    super.repeatMode,
    super.queueMode,
  );

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
    List<String>? queue,
    int? currentIndex,
    RepeatMode? repeatMode,
    PlaybackQueueMode? queueMode,
  }) {
    return AudioPlayerPaused(
      source ?? this.source,
      visualContext ?? this.visualContext,
      track ?? this.track,
      collaborator ?? this.collaborator,
      queue ?? this.queue,
      currentIndex ?? this.currentIndex,
      repeatMode ?? this.repeatMode,
      queueMode ?? this.queueMode,
    );
  }
}

class AudioPlayerLoading extends AudioPlayerActiveState {
  const AudioPlayerLoading(
    super.source,
    super.visualContext,
    super.track,
    super.collaborator,
    super.queue,
    super.currentIndex,
    super.repeatMode,
    super.queueMode,
  );

  @override
  AudioPlayerActiveState copyWith({
    PlaybackSource? source,
    PlayerVisualContext? visualContext,
    AudioTrack? track,
    UserProfile? collaborator,
    List<String>? queue,
    int? currentIndex,
    RepeatMode? repeatMode,
    PlaybackQueueMode? queueMode,
  }) {
    return AudioPlayerLoading(
      source ?? this.source,
      visualContext ?? this.visualContext,
      track ?? this.track,
      collaborator ?? this.collaborator,
      queue ?? this.queue,
      currentIndex ?? this.currentIndex,
      repeatMode ?? this.repeatMode,
      queueMode ?? this.queueMode,
    );
  }
}
