import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

class AudioTrackDTO {
  final String id;
  final String name;
  final String url;
  final int durationMs;
  final List<String> projectIds;
  final String uploadedBy;
  final DateTime? createdAt;

  const AudioTrackDTO({
    required this.id,
    required this.name,
    required this.url,
    required this.durationMs,
    required this.projectIds,
    required this.uploadedBy,
    this.createdAt,
  });

  static const String collection = 'audio_tracks';

  factory AudioTrackDTO.fromJson(Map<String, dynamic> json) {
    return AudioTrackDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      durationMs: json['duration'] as int,
      projectIds: List<String>.from(json['projectIds'] as List),
      uploadedBy: json['uploadedBy'] as String,
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(json['createdAt'] as String? ?? '') ??
                  DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'duration': durationMs,
      'projectIds': projectIds,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt,
    };
  }

  AudioTrack toDomain() {
    return AudioTrack(
      id: AudioTrackId.fromUniqueString(id),
      name: name,
      url: url,
      duration: Duration(milliseconds: durationMs),
      projectId: ProjectId.fromUniqueString(projectIds.first),
      uploadedBy: UserId.fromUniqueString(uploadedBy),
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
