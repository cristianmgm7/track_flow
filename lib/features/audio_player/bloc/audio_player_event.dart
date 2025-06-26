import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_player/bloc/audio_player_state.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/playlist/domain/entities/playlist.dart';

abstract class AudioPlayerEvent {}

class PlayAudioRequested extends AudioPlayerEvent {
  final PlaybackSource source;
  final PlayerVisualContext visualContext;
  final AudioTrack track;
  final UserProfile collaborator;

  PlayAudioRequested({
    required this.source,
    required this.visualContext,
    required this.track,
    required this.collaborator,
  });
}

class PauseAudioRequested extends AudioPlayerEvent {}

class ResumeAudioRequested extends AudioPlayerEvent {}

class StopAudioRequested extends AudioPlayerEvent {}

class ChangeVisualContext extends AudioPlayerEvent {
  final PlayerVisualContext visualContext;

  ChangeVisualContext(this.visualContext);
}

class PlayPlaylistRequested extends AudioPlayerEvent {
  final Playlist playlist;
  final int startIndex;
  PlayPlaylistRequested(this.playlist, {this.startIndex = 0});
}

class SkipToNextRequested extends AudioPlayerEvent {}

class SkipToPreviousRequested extends AudioPlayerEvent {}

class ToggleShuffleRequested extends AudioPlayerEvent {}

class ToggleRepeatModeRequested extends AudioPlayerEvent {}

class SeekToPositionRequested extends AudioPlayerEvent {
  final Duration position;
  SeekToPositionRequested(this.position);
}

class RestorePlaybackStateRequested extends AudioPlayerEvent {}

class SavePlaybackStateRequested extends AudioPlayerEvent {}
