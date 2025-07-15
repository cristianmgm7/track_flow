import 'package:equatable/equatable.dart';

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
  });

  /// The audio track ID this context refers to
  final String trackId;

  /// User who uploaded/owns this track
  final UserProfile? collaborator;

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
      ];

  TrackContext copyWith({
    String? trackId,
    UserProfile? collaborator,
    String? projectId,
    String? projectName,
    DateTime? uploadedAt,
    DateTime? lastModified,
    List<String>? tags,
    String? description,
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
    );
  }

  @override
  String toString() => 'TrackContext(trackId: $trackId, collaborator: ${collaborator?.name}, project: $projectName)';
}

/// User profile information for track context
class UserProfile extends Equatable {
  const UserProfile({
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
  String toString() => 'UserProfile(id: $id, name: $name)';
}