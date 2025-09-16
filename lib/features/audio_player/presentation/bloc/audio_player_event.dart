import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../../domain/entities/repeat_mode.dart';
import '../../domain/entities/playback_session.dart';
import '../../../audio_track/domain/entities/audio_track.dart';

/// Pure audio player events - ONLY audio operations
/// NO: UserProfile, ProjectId, collaborators, or business context
abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize audio player and restore previous state if available
class AudioPlayerInitializeRequested extends AudioPlayerEvent {
  const AudioPlayerInitializeRequested();
}

/// Play a specific version by ID
/// Ignores track.activeVersionId and plays the specified version directly
class PlayVersionRequested extends AudioPlayerEvent {
  const PlayVersionRequested(this.versionId);

  /// Version ID to play - uses version's file and track's metadata
  final TrackVersionId versionId;

  @override
  List<Object?> get props => [versionId];

  @override
  String toString() => 'PlayVersionRequested(versionId: $versionId)';
}

/// Play a playlist starting from specified index
class PlayPlaylistRequested extends AudioPlayerEvent {
  /// For persisted playlists, provide playlistId. For ephemeral playlists, provide tracks.
  const PlayPlaylistRequested({
    this.playlistId,
    this.tracks,
    this.startIndex = 0,
  });

  /// Playlist ID to play (for persisted playlists)
  final PlaylistId? playlistId;

  /// List of tracks to play (for ephemeral playlists)
  final List<AudioTrack>? tracks;

  /// Starting track index in playlist
  final int startIndex;

  @override
  List<Object?> get props => [playlistId, tracks, startIndex];

  @override
  String toString() =>
      'PlayPlaylistRequested(playlistId: $playlistId, tracks: $tracks, startIndex: $startIndex)';
}

/// Pause current audio playback
class PauseAudioRequested extends AudioPlayerEvent {
  const PauseAudioRequested();
}

/// Resume paused audio playback
class ResumeAudioRequested extends AudioPlayerEvent {
  const ResumeAudioRequested();
}

/// Stop audio playback and reset position
class StopAudioRequested extends AudioPlayerEvent {
  const StopAudioRequested();
}

/// Skip to next track in queue
class SkipToNextRequested extends AudioPlayerEvent {
  const SkipToNextRequested();
}

/// Skip to previous track in queue
class SkipToPreviousRequested extends AudioPlayerEvent {
  const SkipToPreviousRequested();
}

/// Seek to specific position in current track
class SeekToPositionRequested extends AudioPlayerEvent {
  const SeekToPositionRequested(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];

  @override
  String toString() => 'SeekToPositionRequested(position: $position)';
}

/// Play a specific track if needed, then seek to a position atomically
class PlayAndSeekRequested extends AudioPlayerEvent {
  const PlayAndSeekRequested(this.trackId, this.position);

  final AudioTrackId trackId;
  final Duration position;

  @override
  List<Object?> get props => [trackId, position];

  @override
  String toString() =>
      'PlayAndSeekRequested(trackId: $trackId, position: $position)';
}

/// Toggle shuffle mode on/off
class ToggleShuffleRequested extends AudioPlayerEvent {
  const ToggleShuffleRequested();
}

/// Toggle repeat mode (none -> single -> queue -> none)
class ToggleRepeatModeRequested extends AudioPlayerEvent {
  const ToggleRepeatModeRequested();
}

/// Set specific repeat mode
class SetRepeatModeRequested extends AudioPlayerEvent {
  const SetRepeatModeRequested(this.mode);

  final RepeatMode mode;

  @override
  List<Object?> get props => [mode];

  @override
  String toString() => 'SetRepeatModeRequested(mode: $mode)';
}

/// Set audio volume (0.0 to 1.0)
class SetVolumeRequested extends AudioPlayerEvent {
  const SetVolumeRequested(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];

  @override
  String toString() => 'SetVolumeRequested(volume: $volume)';
}

/// Set playback speed (1.0 = normal speed)
class SetPlaybackSpeedRequested extends AudioPlayerEvent {
  const SetPlaybackSpeedRequested(this.speed);

  final double speed;

  @override
  List<Object?> get props => [speed];

  @override
  String toString() => 'SetPlaybackSpeedRequested(speed: $speed)';
}

/// Save current playback state for persistence
class SavePlaybackStateRequested extends AudioPlayerEvent {
  const SavePlaybackStateRequested();
}

/// Internal event: Session state changed from playback service
class SessionStateChanged extends AudioPlayerEvent {
  const SessionStateChanged(this.session);

  final PlaybackSession session;

  @override
  List<Object?> get props => [session];

  @override
  String toString() => 'SessionStateChanged(state: ${session.state})';
}

/// Internal event: Playback position updated
class PlaybackPositionUpdated extends AudioPlayerEvent {
  const PlaybackPositionUpdated(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}
