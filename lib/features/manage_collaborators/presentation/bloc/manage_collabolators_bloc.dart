import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/get_project_with_user_profiles.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'manage_collabolators_event.dart';
import 'manage_collabolators_state.dart';

@injectable
class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;
  final AddCollaboratorToProjectUseCase addCollaboratorUseCase;
  final GetProjectWithUserProfilesUseCase getProjectWithUserProfilesUseCase;

  ManageCollaboratorsBloc({
    required this.updateCollaboratorRoleUseCase,
    required this.addCollaboratorUseCase,
    required this.getProjectWithUserProfilesUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<AddCollaborator>(_onAddCollaborator);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
    on<JoinProjectWithIdRequested>(_onJoinProjectWithIdRequested);
    on<GetProjectWithUserProfiles>(_onGetProjectWithUserProfiles);
  }

  Future<void> _onGetProjectWithUserProfiles(
    GetProjectWithUserProfiles event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    final result = await getProjectWithUserProfilesUseCase.call(
      GetProjectWithUserProfilesParams(projectId: event.projectId),
    );
    result.fold(
      (failure) =>
          emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
      (projectWithUserProfiles) =>
          emit(ManageCollaboratorsLoaded(projectWithUserProfiles)),
    );
  }

  Future<void> _onAddCollaborator(
    AddCollaborator event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsInitial());
    final result = await addCollaboratorUseCase.call(
      AddCollaboratorToProjectParams(
        projectId: event.projectId,
        collaboratorId: event.collaboratorId,
      ),
    );
    await result.fold(
      (failure) async {
        emit(ManageCollaboratorsError(_mapFailureToMessage(failure)));
      },
      (_) async {
        final updatedResult = await getProjectWithUserProfilesUseCase.call(
          GetProjectWithUserProfilesParams(projectId: event.projectId),
        );
        updatedResult.fold(
          (failure) =>
              emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
          (projectWithUserProfiles) =>
              emit(ManageCollaboratorsLoaded(projectWithUserProfiles)),
        );
      },
    );
  }

  Future<void> _onUpdateCollaboratorRole(
    UpdateCollaboratorRole event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    final result = await updateCollaboratorRoleUseCase(
      UpdateCollaboratorRoleParams(
        projectId: event.projectId,
        userId: event.userId,
        role: event.newRole,
      ),
    );
    result.fold(
      (failure) =>
          emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
      (_) => emit(
        UpdateCollaboratorRoleSuccess(
          event.projectId.value,
          event.userId.value,
        ),
      ),
    );
    add(GetProjectWithUserProfiles(projectId: event.projectId));
  }

  Future<void> _onJoinProjectWithIdRequested(
    JoinProjectWithIdRequested event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    // Emit a loading state if necessary
    // emit(ProjectsLoading());
    // Simulate a network call or use a use case to join the project
    // For now, let's assume the operation is successful
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    // Emit success state
    // emit(JoinProjectSuccess(project: event.projectId));
    // Handle errors and emit error state if needed
    // emit(ManageCollaboratorsError('Error message'));
  }

  String _mapFailureToMessage(Failure failure) {
    // You can expand this method to handle different types of failures
    return failure is ServerFailure ? 'Server Failure' : 'Unexpected Error';
  }
}
