part of 'audio_player_cubit.dart';

abstract class AudioPlayerState {
  final AudioTrack track;
  AudioPlayerState(this.track);
}

class AudioPlayerInitial extends AudioPlayerState {
  AudioPlayerInitial(super.track);
}

class AudioPlayerPlaying extends AudioPlayerState {
  AudioPlayerPlaying(super.track);
}

class AudioPlayerPaused extends AudioPlayerState {
  AudioPlayerPaused(super.track);
}

class AudioPlayerStopped extends AudioPlayerState {
  AudioPlayerStopped(super.track);
}

class AudioPlayerError extends AudioPlayerState {
  final String message;
  AudioPlayerError(this.message, super.track);
}
