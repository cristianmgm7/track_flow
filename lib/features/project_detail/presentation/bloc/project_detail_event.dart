import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class ProjectDetailEvent extends Equatable {
  const ProjectDetailEvent();

  @override
  List<Object?> get props => [];
}

class ProjectDetailsStarted extends ProjectDetailEvent {
  final ProjectId projectId;

  const ProjectDetailsStarted(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class ParticipantAdded extends ProjectDetailEvent {
  final UserId userId;

  const ParticipantAdded(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ParticipantRemoved extends ProjectDetailEvent {
  final UserId userId;

  const ParticipantRemoved(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ParticipantRoleChanged extends ProjectDetailEvent {
  final UserId userId;
  final UserRole newRole;

  const ParticipantRoleChanged(this.userId, this.newRole);

  @override
  List<Object?> get props => [userId, newRole];
}

class ProjectParticipantsUpdated extends ProjectDetailEvent {
  final List<UserProfile> updatedList;

  const ProjectParticipantsUpdated(this.updatedList);

  @override
  List<Object?> get props => [updatedList];
}
