import '../../../../core/entities/unique_id.dart';
import '../../../audio_track/domain/entities/audio_track.dart';

/// Arguments for the track detail screen
class TrackDetailScreenArgs {
  final ProjectId projectId;
  final AudioTrack track;
  final TrackVersionId versionId; // selected/active version

  TrackDetailScreenArgs({
    required this.projectId,
    required this.track,
    required this.versionId,
  });
}
