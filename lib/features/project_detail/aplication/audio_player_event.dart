import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/playback_source.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

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
