import 'package:trackflow/core/domain/aggregate_root.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioTrack extends AggregateRoot<AudioTrackId> {
  final String name;
  final String url;
  final Duration duration;
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime createdAt;

  const AudioTrack({
    required AudioTrackId id,
    required this.name,
    required this.url,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    required this.createdAt,
  }) : super(id);

  factory AudioTrack.create({
    required String name,
    required String url,
    required Duration duration,
    required ProjectId projectId,
    required UserId uploadedBy,
  }) {
    return AudioTrack(
      id: AudioTrackId(),
      name: name,
      url: url,
      duration: duration,
      projectId: projectId,
      uploadedBy: uploadedBy,
      createdAt: DateTime.now(),
    );
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


  bool belongsToProject(ProjectId projectId) {
    return this.projectId == projectId;
  }
}
