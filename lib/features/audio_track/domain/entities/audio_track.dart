import 'package:trackflow/core/domain/aggregate_root.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioTrack extends AggregateRoot<AudioTrackId> {
  final String name;
  final String url; // Cover art URL
  final Duration duration; // Duration of active version
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime createdAt;
  final TrackVersionId? activeVersionId; // Active version for playback
  final bool isDeleted;

  const AudioTrack({
    required AudioTrackId id,
    required this.name,
    required this.url,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    required this.createdAt,
    this.activeVersionId,
    this.isDeleted = false,
  }) : super(id);

  factory AudioTrack.create({
    required String name,
    required String url,
    required Duration duration,
    required ProjectId projectId,
    required UserId uploadedBy,
    TrackVersionId? activeVersionId,
    bool isDeleted = false,
  }) {
    return AudioTrack(
      id: AudioTrackId(),
      name: name,
      url: url,
      duration: duration,
      projectId: projectId,
      uploadedBy: uploadedBy,
      createdAt: DateTime.now(),
      activeVersionId: activeVersionId,
      isDeleted: isDeleted,
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
    TrackVersionId? activeVersionId,
    bool? isDeleted,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      projectId: projectId ?? this.projectId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      activeVersionId: activeVersionId ?? this.activeVersionId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool belongsToProject(ProjectId projectId) {
    return this.projectId == projectId;
  }
}
