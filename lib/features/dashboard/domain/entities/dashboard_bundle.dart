import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

/// Aggregate bundle for dashboard preview data
class DashboardBundle {
  final List<Project> projectPreview; // up to 6
  final List<AudioTrack> trackPreview; // up to 6
  final List<AudioComment> recentComments; // up to 8

  const DashboardBundle({
    required this.projectPreview,
    required this.trackPreview,
    required this.recentComments,
  });

  DashboardBundle copyWith({
    List<Project>? projectPreview,
    List<AudioTrack>? trackPreview,
    List<AudioComment>? recentComments,
  }) {
    return DashboardBundle(
      projectPreview: projectPreview ?? this.projectPreview,
      trackPreview: trackPreview ?? this.trackPreview,
      recentComments: recentComments ?? this.recentComments,
    );
  }
}


