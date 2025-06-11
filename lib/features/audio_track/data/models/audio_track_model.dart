import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

class AudioTrackDTO {
  final String id;
  final String name;
  final String url;
  final int durationMs;
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime? createdAt;

  const AudioTrackDTO({
    required this.id,
    required this.name,
    required this.url,
    required this.durationMs,
    required this.projectId,
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
      projectId: ProjectId.fromUniqueString(json['projectId'] as String),
      uploadedBy: UserId.fromUniqueString(json['uploadedBy'] as String),
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
      'projectId': projectId.value,
      'uploadedBy': uploadedBy.value,
      'createdAt': createdAt,
    };
  }

  AudioTrack toDomain() {
    return AudioTrack(
      id: AudioTrackId.fromUniqueString(id),
      name: name,
      url: url,
      duration: Duration(milliseconds: durationMs),
      projectId: projectId,
      uploadedBy: uploadedBy,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
}
