import 'package:trackflow/features/track_version/domain/entities/track_version.dart';

class ActiveVersionSummary {
  final String trackId;
  final String versionId;
  final TrackVersionStatus status;
  final String? fileRemoteUrl;

  const ActiveVersionSummary({
    required this.trackId,
    required this.versionId,
    required this.status,
    required this.fileRemoteUrl,
  });
}
