import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/core/error/failures.dart';

abstract class ProjectDetailState extends Equatable {
  const ProjectDetailState();

  @override
  List<Object?> get props => [];
}

class ProjectDetailsInitial extends ProjectDetailState {}

class ProjectDetailsLoading extends ProjectDetailState {}

class ProjectDetailsLoaded extends ProjectDetailState {
  final Project project;
  final List<UserProfile> participants;
  final bool isOwner;
  final bool isAdmin;

  const ProjectDetailsLoaded({
    required this.project,
    required this.participants,
    required this.isOwner,
    required this.isAdmin,
  });

  @override
  List<Object?> get props => [project, participants, isOwner, isAdmin];
}

class ProjectDetailsError extends ProjectDetailState {
  final Failure failure;

  const ProjectDetailsError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class ProjectDetailsUpdatingParticipant extends ProjectDetailState {}

class ProjectDetailsParticipantUpdated extends ProjectDetailState {}

class ProjectDetailsLiveUpdated extends ProjectDetailState {
  final List<UserProfile> participants;

  const ProjectDetailsLiveUpdated(this.participants);

  @override
  List<Object?> get props => [participants];
}
