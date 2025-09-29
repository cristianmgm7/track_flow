import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

class AudioTrackDTO {
  final AudioTrackId id;
  final String name;
  final String url; // cover art url
  final int duration;
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime? createdAt;
  final String extension;
  final TrackVersionId? activeVersionId; // Active version for playback
  final bool isDeleted;

  // ⭐ NEW: Sync metadata fields for proper offline-first sync
  final int version;
  final DateTime? lastModified;

  const AudioTrackDTO({
    required this.id,
    required this.name,
    required this.url,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    this.createdAt,
    required this.extension,
    this.activeVersionId,
    this.isDeleted = false,
    // ⭐ NEW: Sync metadata fields
    this.version = 1,
    this.lastModified,
  });

  static const String collection = 'audio_tracks';

  factory AudioTrackDTO.fromJson(Map<String, dynamic> json) {
    return AudioTrackDTO(
      id: AudioTrackId.fromUniqueString(json['id'] as String),
      name: json['name'] as String,
      url: json['url'] as String,
      duration: json['duration'] as int,
      projectId: ProjectId.fromUniqueString(json['projectId'] as String),
      uploadedBy: UserId.fromUniqueString(json['uploadedBy'] as String),
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['createdAt'] as String? ?? ''),
      extension: json['extension'] as String,
      activeVersionId:
          json['activeVersionId'] != null
              ? TrackVersionId.fromUniqueString(
                json['activeVersionId'] as String,
              )
              : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
      // ⭐ NEW: Parse sync metadata from JSON
      version: json['version'] as int? ?? 1,
      lastModified:
          json['lastModified'] is Timestamp
              ? (json['lastModified'] as Timestamp).toDate()
              : DateTime.tryParse(json['lastModified'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'name': name,
      'url': url,
      'duration': duration,
      'projectId': projectId.value,
      'uploadedBy': uploadedBy.value,
      'createdAt': createdAt?.toIso8601String(),
      'extension': extension,
      'activeVersionId': activeVersionId?.value,
      'isDeleted': isDeleted,
      // ⭐ NEW: Include sync metadata in JSON
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  AudioTrack toDomain() {
    return AudioTrack(
      id: id,
      name: name,
      url: url,
      duration: Duration(milliseconds: duration),
      projectId: projectId,
      uploadedBy: uploadedBy,
      createdAt: createdAt ?? DateTime.now(),
      activeVersionId: activeVersionId,
      isDeleted: isDeleted,
    );
  }

  static AudioTrackDTO fromDomain(
    AudioTrack track, {
    String? url,
    required String extension,
  }) {
    return AudioTrackDTO(
      projectId: track.projectId,
      uploadedBy: track.uploadedBy,
      id: track.id,
      name: track.name,
      url: url ?? track.url,
      duration: track.duration.inMilliseconds,
      createdAt: track.createdAt,
      extension: extension,
      activeVersionId: track.activeVersionId,
      // ⭐ NEW: Include sync metadata for new tracks
      version: 1, // Initial version for new tracks
      lastModified: track.createdAt, // Use createdAt as initial lastModified
    );
  }
}
