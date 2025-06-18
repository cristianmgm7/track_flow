import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/get_project_with_user_profiles.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'manage_collabolators_event.dart';
import 'manage_collabolators_state.dart';

@injectable
class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;
  final AddCollaboratorToProjectUseCase addCollaboratorUseCase;
  final GetProjectWithUserProfilesUseCase getProjectWithUserProfilesUseCase;
  final RemoveCollaboratorUseCase removeCollaboratorUseCase;
  final LeaveProjectUseCase leaveProjectUseCase;

  ManageCollaboratorsBloc({
    required this.addCollaboratorUseCase,
    required this.updateCollaboratorRoleUseCase,
    required this.getProjectWithUserProfilesUseCase,
    required this.removeCollaboratorUseCase,
    required this.leaveProjectUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<AddCollaborator>(_onAddCollaborator);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
    on<JoinProjectWithIdRequested>(_onJoinProjectWithIdRequested);
    on<GetProjectWithUserProfiles>(_onGetProjectWithUserProfiles);
    on<RemoveCollaborator>(_onRemoveCollaborator);
    on<LeaveProject>(_onLeaveProject);
    on<LoadUserProfiles>(_onLoadUserProfiles);
  }

  Future<void> _onGetProjectWithUserProfiles(
    GetProjectWithUserProfiles event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    final result = await getProjectWithUserProfilesUseCase.call(
      GetProjectWithUserProfilesParams(projectId: event.projectId),
    );
    await result.fold(
      (failure) async => emit(ManageCollaboratorsError(failure.toString())),
      (projectWithUserProfiles) async =>
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
        emit(ManageCollaboratorsError(failure.toString()));
      },
      (_) async {
        final updatedResult = await getProjectWithUserProfilesUseCase.call(
          GetProjectWithUserProfilesParams(projectId: event.projectId),
        );
        await updatedResult.fold(
          (failure) async => emit(ManageCollaboratorsError(failure.toString())),
          (projectWithUserProfiles) async =>
              emit(ManageCollaboratorsLoaded(projectWithUserProfiles)),
        );
      },
    );
  }

  Future<void> _onRemoveCollaborator(
    RemoveCollaborator event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    final result = await removeCollaboratorUseCase.call(
      RemoveCollaboratorParams(
        projectId: event.projectId,
        collaboratorId: event.userId,
      ),
    );
    await result.fold(
      (failure) async => emit(ManageCollaboratorsError(failure.toString())),
      (_) async {
        final updatedResult = await getProjectWithUserProfilesUseCase.call(
          GetProjectWithUserProfilesParams(projectId: event.projectId),
        );
        await updatedResult.fold(
          (failure) async => emit(ManageCollaboratorsError(failure.toString())),
          (projectWithUserProfiles) async =>
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
    await result.fold(
      (failure) async => emit(ManageCollaboratorsError(failure.toString())),
      (_) async => emit(
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

  Future<void> _onLoadUserProfiles(
    LoadUserProfiles event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    final result = await getProjectWithUserProfilesUseCase.call(
      GetProjectWithUserProfilesParams(projectId: event.project.id),
    );
    await result.fold(
      (failure) async => emit(ManageCollaboratorsError(failure.toString())),
      (projectWithUserProfiles) async =>
          emit(ManageCollaboratorsLoaded(projectWithUserProfiles)),
    );
  }

  Future<void> _onLeaveProject(
    LeaveProject event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final Either<Failure, void> failureOrSuccess = await leaveProjectUseCase
        .call(
          LeaveProjectParams(
            projectId: event.projectId,
            userId: UserId.fromUniqueString('currentUserId'),
          ),
        );

    failureOrSuccess.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) => emit(ManageCollaboratorsLeaveSuccess()),
    );
  }
}
