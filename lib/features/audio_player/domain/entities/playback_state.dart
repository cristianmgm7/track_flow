/// Pure audio playback states without business logic coupling
enum PlaybackState {
  /// Audio is currently playing
  playing,

  /// Audio is paused (can be resumed)
  paused,

  /// Audio is stopped (position reset to beginning)
  stopped,

  /// Audio is loading/buffering
  loading,

  /// An error occurred during playback
  error,

  /// Audio playback completed
  completed,
}