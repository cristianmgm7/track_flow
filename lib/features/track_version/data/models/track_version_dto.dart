import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

class TrackVersionDTO {
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
  });

  factory TrackVersionDTO.fromDomain(TrackVersion version) {
    return TrackVersionDTO(
      id: version.id.value,
      trackId: version.trackId.value,
      versionNumber: version.versionNumber,
      label: version.label,
      fileLocalPath: version.fileLocalPath,
      fileRemoteUrl: version.fileRemoteUrl,
      durationMs: version.durationMs,
      waveformCachePath: version.waveformCachePath,
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
      waveformCachePath: waveformCachePath,
      status: TrackVersionStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => TrackVersionStatus.ready,
      ),
      createdAt: createdAt,
      createdBy: UserId.fromUniqueString(createdBy),
    );
  }
}
