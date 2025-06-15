import 'package:trackflow/features/project_detail/aplication/audio_player_state.dart';
import 'package:trackflow/features/project_detail/aplication/playback_source.dart';

abstract class AudioPlayerEvent {}

class PlayAudioRequested extends AudioPlayerEvent {
  final PlaybackSource source;
  final PlayerVisualContext visualContext;

  PlayAudioRequested({required this.source, required this.visualContext});
}

class PauseAudioRequested extends AudioPlayerEvent {}

class ResumeAudioRequested extends AudioPlayerEvent {}

class StopAudioRequested extends AudioPlayerEvent {}

class ChangeVisualContext extends AudioPlayerEvent {
  final PlayerVisualContext visualContext;

  ChangeVisualContext(this.visualContext);
}
