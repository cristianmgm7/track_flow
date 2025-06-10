import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioTrack extends Equatable {
  final AudioTrackId id;
  final String name;
  final String url;
  final Duration duration;
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime createdAt;

  const AudioTrack({
    required this.id,
    required this.name,
    required this.url,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
    id,
    name,
    url,
    duration,
    projectId,
    uploadedBy,
    createdAt,
  ];

  bool belongsToProject(ProjectId projectId) {
    return this.projectId == projectId;
  }

  AudioTrack copyWith({
    AudioTrackId? id,
    String? name,
    String? url,
    Duration? duration,
    ProjectId? projectId,
    UserId? uploadedBy,
    DateTime? createdAt,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      projectId: projectId ?? this.projectId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
