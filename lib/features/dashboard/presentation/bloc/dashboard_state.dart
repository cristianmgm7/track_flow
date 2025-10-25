import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/presentation/models/project_ui_model.dart';
import 'package:trackflow/features/audio_track/presentation/models/audio_track_ui_model.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';

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
  final List<ProjectUiModel> projectPreview;
  final List<AudioTrackUiModel> trackPreview;
  final List<AudioCommentUiModel> recentComments;
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
        // REMOVED manual expansion - UI models handle equality properly
        projectPreview,
        trackPreview,
        recentComments,
        isLoading,
        failureOption,
      ];

  DashboardLoaded copyWith({
    List<ProjectUiModel>? projectPreview,
    List<AudioTrackUiModel>? trackPreview,
    List<AudioCommentUiModel>? recentComments,
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


