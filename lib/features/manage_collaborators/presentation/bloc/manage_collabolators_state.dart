import 'package:equatable/equatable.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

abstract class ManageCollaboratorsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ManageCollaboratorsInitial extends ManageCollaboratorsState {}

class ManageCollaboratorsLoading extends ManageCollaboratorsState {}

class ManageCollaboratorsError extends ManageCollaboratorsState {
  final String message;
  ManageCollaboratorsError(this.message);
}

class CollaboratorActionSuccess extends ManageCollaboratorsState {}

/// Add Participant
class ParticipantAdded extends ManageCollaboratorsState {
  final String participantId;

  ParticipantAdded(this.participantId);

  @override
  List<Object?> get props => [participantId];
}

class JoinProjectSuccess extends ManageCollaboratorsState {
  final Project project;

  JoinProjectSuccess(this.project);

  @override
  List<Object?> get props => [project];
}

class JoinProjectFailure extends ManageCollaboratorsState {
  final String error;

  JoinProjectFailure(this.error);

  @override
  List<Object?> get props => [error];
}
