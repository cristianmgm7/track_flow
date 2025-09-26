import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

class TrackSummary extends Equatable {
  final AudioTrackId trackId;
  final TrackVersionId? activeVersionId;
  final TrackVersionStatus? status;
  final String? fileRemoteUrl;
  final int? durationMs;

  const TrackSummary({
    required this.trackId,
    this.activeVersionId,
    this.status,
    this.fileRemoteUrl,
    this.durationMs,
  });

  @override
  List<Object?> get props => [
    trackId,
    activeVersionId,
    status,
    fileRemoteUrl,
    durationMs,
  ];
}
