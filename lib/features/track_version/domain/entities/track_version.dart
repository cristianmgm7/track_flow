import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

enum TrackVersionStatus { processing, ready, failed }

class TrackVersion extends Equatable {
  final TrackVersionId id;
  final AudioTrackId trackId;
  final int versionNumber; // 1-based
  final String? label;
  final String? fileLocalPath;
  final String? fileRemoteUrl;
  final int? durationMs;
  final TrackVersionStatus status;
  final DateTime createdAt;
  final UserId createdBy;

  const TrackVersion({
    required this.id,
    required this.trackId,
    required this.versionNumber,
    this.label,
    this.fileLocalPath,
    this.fileRemoteUrl,
    this.durationMs,
    required this.status,
    required this.createdAt,
    required this.createdBy,
  });

  TrackVersion copyWith({
    TrackVersionId? id,
    AudioTrackId? trackId,
    int? versionNumber,
    String? label,
    String? fileLocalPath,
    String? fileRemoteUrl,
    int? durationMs,
    TrackVersionStatus? status,
    DateTime? createdAt,
    UserId? createdBy,
  }) {
    return TrackVersion(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      versionNumber: versionNumber ?? this.versionNumber,
      label: label ?? this.label,
      fileLocalPath: fileLocalPath ?? this.fileLocalPath,
      fileRemoteUrl: fileRemoteUrl ?? this.fileRemoteUrl,
      durationMs: durationMs ?? this.durationMs,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    trackId,
    versionNumber,
    label,
    fileLocalPath,
    fileRemoteUrl,
    durationMs,
    status,
    createdAt,
    createdBy,
  ];
}
