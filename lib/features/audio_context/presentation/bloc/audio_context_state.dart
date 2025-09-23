import 'package:equatable/equatable.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import '../../domain/entities/track_context.dart';

/// Audio context states for business domain information
/// Separated from pure audio player states to maintain SOLID principles
abstract class AudioContextState extends Equatable {
  const AudioContextState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no context is loaded
class AudioContextInitial extends AudioContextState {
  const AudioContextInitial();

  @override
  String toString() => 'AudioContextInitial';
}

/// Loading context for a track
class AudioContextLoading extends AudioContextState {
  const AudioContextLoading({this.trackId});

  final String? trackId;

  @override
  List<Object?> get props => [trackId];

  @override
  String toString() => 'AudioContextLoading(trackId: $trackId)';
}

/// Context loaded successfully
class AudioContextLoaded extends AudioContextState {
  const AudioContextLoaded(this.context);

  final TrackContext context;

  // Convenience getters for UI
  TrackContextCollaborator? get collaborator => context.collaborator;
  String? get projectId => context.projectId;
  String? get projectName => context.projectName;
  DateTime? get uploadedAt => context.uploadedAt;
  List<String>? get tags => context.tags;
  String? get description => context.description;
  String get trackId => context.trackId;
  String? get activeVersionId => context.activeVersionId;
  int? get activeVersionNumber => context.activeVersionNumber;
  String? get activeVersionLabel => context.activeVersionLabel;
  TrackVersionStatus? get activeVersionStatus => context.activeVersionStatus;
  Duration? get activeVersionDuration => context.activeVersionDuration;
  String? get activeVersionFileUrl => context.activeVersionFileUrl;

  @override
  List<Object?> get props => [context];

  @override
  String toString() =>
      'AudioContextLoaded(trackId: ${context.trackId}, '
      'collaborator: ${collaborator?.name}, project: $projectName)';
}

/// Error loading context
class AudioContextError extends AudioContextState {
  const AudioContextError(this.message, {this.trackId});

  final String message;
  final String? trackId;

  @override
  List<Object?> get props => [message, trackId];

  @override
  String toString() =>
      'AudioContextError(message: $message, trackId: $trackId)';
}

/// Context not found for track
class AudioContextNotFound extends AudioContextState {
  const AudioContextNotFound(this.trackId);

  final String trackId;

  @override
  List<Object?> get props => [trackId];

  @override
  String toString() => 'AudioContextNotFound(trackId: $trackId)';
}
