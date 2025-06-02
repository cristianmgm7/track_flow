import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/projects/domain/usecases/add_collaborator_usecase.dart';

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailEvent, ProjectDetailState> {
  final AddCollaboratorUseCase addCollaboratorUseCase;

  ProjectDetailBloc({required this.addCollaboratorUseCase})
    : super(ProjectDetailsInitial()) {
    on<ProjectDetailsStarted>(_onProjectDetailsStarted);
    on<ParticipantAdded>(_onParticipantAdded);
    on<ParticipantRemoved>(_onParticipantRemoved);
    on<ParticipantRoleChanged>(_onParticipantRoleChanged);
    on<ProjectParticipantsUpdated>(_onProjectParticipantsUpdated);
  }

  Future<void> _onProjectDetailsStarted(
    ProjectDetailsStarted event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(ProjectDetailsLoading());
    // Logic to load project details goes here
    // For now, we'll just emit a loaded state with dummy data
    // emit(ProjectDetailsLoaded(...));
  }

  Future<void> _onParticipantAdded(
    ParticipantAdded event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(ProjectDetailsUpdatingParticipant());
    final result = await addCollaboratorUseCase(
      AddCollaboratorParams(projectId: event.projectId, userId: event.userId),
    );

    result.fold(
      (failure) => emit(ProjectDetailsError(failure)),
      (_) => emit(ProjectDetailsParticipantUpdated()),
    );
  }

  Future<void> _onParticipantRemoved(
    ParticipantRemoved event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(ProjectDetailsUpdatingParticipant());
    // Logic to remove participant goes here
    // For now, we'll just emit a participant updated state
    emit(ProjectDetailsParticipantUpdated());
  }

  Future<void> _onParticipantRoleChanged(
    ParticipantRoleChanged event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(ProjectDetailsUpdatingParticipant());
    // Logic to change participant role goes here
    // For now, we'll just emit a participant updated state
    emit(ProjectDetailsParticipantUpdated());
  }

  Future<void> _onProjectParticipantsUpdated(
    ProjectParticipantsUpdated event,
    Emitter<ProjectDetailState> emit,
  ) async {
    emit(ProjectDetailsLiveUpdated(event.updatedList));
  }
}
