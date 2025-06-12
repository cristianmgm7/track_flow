part of 'audio_player_cubit.dart';

abstract class AudioPlayerState {
  final String url;
  AudioPlayerState(this.url);
}

class AudioPlayerInitial extends AudioPlayerState {
  AudioPlayerInitial() : super('');
}

class AudioPlayerPlaying extends AudioPlayerState {
  AudioPlayerPlaying(super.url);
}

class AudioPlayerPaused extends AudioPlayerState {
  AudioPlayerPaused() : super('');
}

class AudioPlayerStopped extends AudioPlayerState {
  AudioPlayerStopped() : super('');
}

class AudioPlayerError extends AudioPlayerState {
  final String message;
  AudioPlayerError(this.message) : super('');
}
