import 'package:equatable/equatable.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

/// Track context containing business domain information
/// This is separate from pure audio concerns and provides collaboration context
class TrackContext extends Equatable {
  const TrackContext({
    required this.trackId,
    this.collaborator,
    this.projectId,
    this.projectName,
    this.uploadedAt,
    this.lastModified,
    this.tags,
    this.description,
    this.activeVersionId,
    this.activeVersionNumber,
    this.activeVersionLabel,
    this.activeVersionStatus,
    this.activeVersionDuration,
    this.activeVersionFileUrl,
  });

  /// The audio track ID this context refers to
  final String trackId;

  /// User who uploaded/owns this track
  final TrackContextCollaborator? collaborator;

  /// Project this track belongs to
  final String? projectId;

  /// Project name for display
  final String? projectName;

  /// When the track was uploaded
  final DateTime? uploadedAt;

  /// Last modification timestamp
  final DateTime? lastModified;

  /// Tags associated with the track
  final List<String>? tags;

  /// Track description or notes
  final String? description;

  /// Active track version information sourced from track versions domain
  final String? activeVersionId;
  final int? activeVersionNumber;
  final String? activeVersionLabel;
  final TrackVersionStatus? activeVersionStatus;
  final Duration? activeVersionDuration;
  final String? activeVersionFileUrl;

  @override
  List<Object?> get props => [
    trackId,
    collaborator,
    projectId,
    projectName,
    uploadedAt,
    lastModified,
    tags,
    description,
    activeVersionId,
    activeVersionNumber,
    activeVersionLabel,
    activeVersionStatus,
    activeVersionDuration,
    activeVersionFileUrl,
  ];

  TrackContext copyWith({
    String? trackId,
    TrackContextCollaborator? collaborator,
    String? projectId,
    String? projectName,
    DateTime? uploadedAt,
    DateTime? lastModified,
    List<String>? tags,
    String? description,
    String? activeVersionId,
    int? activeVersionNumber,
    String? activeVersionLabel,
    TrackVersionStatus? activeVersionStatus,
    Duration? activeVersionDuration,
    String? activeVersionFileUrl,
  }) {
    return TrackContext(
      trackId: trackId ?? this.trackId,
      collaborator: collaborator ?? this.collaborator,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastModified: lastModified ?? this.lastModified,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      activeVersionId: activeVersionId ?? this.activeVersionId,
      activeVersionNumber: activeVersionNumber ?? this.activeVersionNumber,
      activeVersionLabel: activeVersionLabel ?? this.activeVersionLabel,
      activeVersionStatus: activeVersionStatus ?? this.activeVersionStatus,
      activeVersionDuration:
          activeVersionDuration ?? this.activeVersionDuration,
      activeVersionFileUrl: activeVersionFileUrl ?? this.activeVersionFileUrl,
    );
  }

  @override
  String toString() =>
      'TrackContext(trackId: $trackId, collaborator: ${collaborator?.name}, project: $projectName)';
}

/// Lightweight collaborator information used by track context
class TrackContextCollaborator extends Equatable {
  const TrackContextCollaborator({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.role,
  });

  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? role;

  @override
  List<Object?> get props => [id, name, email, avatarUrl, role];

  @override
  String toString() => 'TrackContextCollaborator(id: $id, name: $name)';
}
