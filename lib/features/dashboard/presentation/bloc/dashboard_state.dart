import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_comment/domain/entities/audio_comment.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state before watching starts
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state (first load only)
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state with preview data
class DashboardLoaded extends DashboardState {
  final List<Project> projectPreview;
  final List<AudioTrack> trackPreview;
  final List<AudioComment> recentComments;
  final bool isLoading; // For subsequent updates
  final Option<Failure> failureOption; // For partial failures

  const DashboardLoaded({
    required this.projectPreview,
    required this.trackPreview,
    required this.recentComments,
    this.isLoading = false,
    this.failureOption = const None(),
  });

  @override
  List<Object?> get props => [
        // Use content signatures, not entity identity (id-only), to detect changes
        projectPreview
            .map((p) => [
                  p.id,
                  p.name,
                  p.description,
                  p.coverUrl,
                  p.coverLocalPath,
                  p.updatedAt,
                ])
            .toList(),
        trackPreview
            .map((t) => [
                  t.id,
                  t.name,
                  t.coverUrl,
                  t.coverLocalPath,
                  t.createdAt,
                  t.activeVersionId,
                ])
            .toList(),
        recentComments
            .map((c) => [
                  c.id,
                  c.content,
                  c.createdAt,
                  // audio comment extras that could affect rendering
                  c.audioStorageUrl,
                  c.localAudioPath,
                  c.audioDuration,
                  c.commentType,
                ])
            .toList(),
        isLoading,
        failureOption,
      ];

  DashboardLoaded copyWith({
    List<Project>? projectPreview,
    List<AudioTrack>? trackPreview,
    List<AudioComment>? recentComments,
    bool? isLoading,
    Option<Failure>? failureOption,
  }) {
    return DashboardLoaded(
      projectPreview: projectPreview ?? this.projectPreview,
      trackPreview: trackPreview ?? this.trackPreview,
      recentComments: recentComments ?? this.recentComments,
      isLoading: isLoading ?? this.isLoading,
      failureOption: failureOption ?? this.failureOption,
    );
  }
}

/// Error state (fatal failure, no data to display)
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}


