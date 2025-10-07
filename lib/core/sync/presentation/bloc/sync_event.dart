import 'package:equatable/equatable.dart';

/// Events for the Sync BLoC
abstract class SyncEvent extends Equatable {
  const SyncEvent();
}

/// Trigger initial sync when app starts (after authentication)
/// This performs both upstream (push pending) and downstream (pull critical data)
class InitialSyncRequested extends SyncEvent {
  const InitialSyncRequested();

  @override
  List<Object?> get props => [];
}

/// Trigger foreground sync when app comes to foreground
/// This syncs non-critical entities (audio_comments, waveforms)
class ForegroundSyncRequested extends SyncEvent {
  const ForegroundSyncRequested();

  @override
  List<Object?> get props => [];
}

/// Trigger upstream sync to push pending operations
class UpstreamSyncRequested extends SyncEvent {
  const UpstreamSyncRequested();

  @override
  List<Object?> get props => [];
}

class DownstreamSyncRequested extends SyncEvent {
  const DownstreamSyncRequested();

  @override
  List<Object?> get props => [];
}
