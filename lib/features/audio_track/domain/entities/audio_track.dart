import 'package:trackflow/core/domain/aggregate_root.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class AudioTrack extends AggregateRoot<AudioTrackId> {
  final String name;
  final String coverUrl; // Cover art URL (renamed from 'url')
  final String? coverLocalPath; // Local cached cover art path
  final Duration duration; // Duration of active version
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime createdAt;
  final TrackVersionId? activeVersionId; // Active version for playback
  final bool isDeleted;

  const AudioTrack({
    required AudioTrackId id,
    required this.name,
    required this.coverUrl,
    this.coverLocalPath,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    required this.createdAt,
    this.activeVersionId,
    this.isDeleted = false,
  }) : super(id);

  factory AudioTrack.create({
    required String name,
    String? coverUrl, // Renamed parameter
    String? coverLocalPath,   // New parameter
    required Duration duration,
    required ProjectId projectId,
    required UserId uploadedBy,
    TrackVersionId? activeVersionId,
    bool isDeleted = false,
  }) {
    return AudioTrack(
      id: AudioTrackId(),
      name: name,
      coverUrl: coverUrl ?? '',
      coverLocalPath: coverLocalPath,
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
    String? coverUrl,        // Renamed parameter
    String? coverLocalPath,  // New parameter
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
      coverUrl: coverUrl ?? this.coverUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
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
