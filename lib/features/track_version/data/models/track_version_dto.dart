import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

class TrackVersionDTO {
  static const String collection = 'track_versions';
  final String id;
  final String trackId;
  final int versionNumber;
  final String? label;
  final String? fileLocalPath;
  final String? fileRemoteUrl;
  final int? durationMs;
  final String? waveformCachePath;
  final String status; // processing | ready | failed
  final DateTime createdAt;
  final String createdBy;
  final bool isDeleted;
  final int? version; // For sync metadata
  final DateTime? lastModified; // For sync metadata

  const TrackVersionDTO({
    required this.id,
    required this.trackId,
    required this.versionNumber,
    this.label,
    this.fileLocalPath,
    this.fileRemoteUrl,
    this.durationMs,
    this.waveformCachePath,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    this.isDeleted = false,
    this.version,
    this.lastModified,
  });

  factory TrackVersionDTO.fromJson(Map<String, dynamic> json) {
    return TrackVersionDTO(
      id: json['id'] as String,
      trackId: json['trackId'] as String,
      versionNumber: json['versionNumber'] as int,
      label: json['label'] as String?,
      fileLocalPath: json['fileLocalPath'] as String?,
      fileRemoteUrl: json['fileRemoteUrl'] as String?,
      durationMs: json['durationMs'] as int?,
      waveformCachePath: json['waveformCachePath'] as String?,
      status: json['status'] as String,
      createdAt:
          json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
      isDeleted: json['isDeleted'] as bool? ?? false,
      version: json['version'] as int?,
      lastModified:
          json['lastModified'] != null
              ? (json['lastModified'] is Timestamp
                  ? (json['lastModified'] as Timestamp).toDate()
                  : DateTime.parse(json['lastModified'] as String))
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackId': trackId,
      'versionNumber': versionNumber,
      'label': label,
      'fileLocalPath': fileLocalPath,
      'fileRemoteUrl': fileRemoteUrl,
      'durationMs': durationMs,
      'waveformCachePath': waveformCachePath,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'isDeleted': isDeleted,
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
    };
  }

  factory TrackVersionDTO.fromDomain(TrackVersion version) {
    return TrackVersionDTO(
      id: version.id.value,
      trackId: version.trackId.value,
      versionNumber: version.versionNumber,
      label: version.label,
      fileLocalPath: version.fileLocalPath,
      fileRemoteUrl: version.fileRemoteUrl,
      durationMs: version.durationMs,
      status: version.status.name,
      createdAt: version.createdAt,
      createdBy: version.createdBy.value,
    );
  }

  TrackVersion toDomain() {
    return TrackVersion(
      id: TrackVersionId.fromUniqueString(id),
      trackId: AudioTrackId.fromUniqueString(trackId),
      versionNumber: versionNumber,
      label: label,
      fileLocalPath: fileLocalPath,
      fileRemoteUrl: fileRemoteUrl,
      durationMs: durationMs,
      status: TrackVersionStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => TrackVersionStatus.ready,
      ),
      createdAt: createdAt,
      createdBy: UserId.fromUniqueString(createdBy),
    );
  }
}
