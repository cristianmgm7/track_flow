import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class AudioTrackDTO {
  final AudioTrackId id;
  final String name;
  final String url;
  final int duration;
  final ProjectId projectId;
  final UserId uploadedBy;
  final DateTime? createdAt;

  const AudioTrackDTO({
    required this.id,
    required this.name,
    required this.url,
    required this.duration,
    required this.projectId,
    required this.uploadedBy,
    this.createdAt,
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
              : null,
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
      'createdAt': createdAt,
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
    );
  }

  static AudioTrackDTO fromDomain(AudioTrack track, {String? url}) {
    return AudioTrackDTO(
      projectId: track.projectId,
      uploadedBy: track.uploadedBy,
      id: track.id,
      name: track.name,
      url: url ?? track.url,
      duration: track.duration.inMilliseconds,
      createdAt: track.createdAt,
    );
  }
}
