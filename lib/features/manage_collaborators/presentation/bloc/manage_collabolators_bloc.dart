import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'manage_collabolators_event.dart';
import 'manage_collabolators_state.dart';

@injectable
class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final AddCollaboratorToProjectUseCase addCollaboratorUseCase;
  final RemoveCollaboratorUseCase removeCollaboratorUseCase;
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;
  final LeaveProjectUseCase leaveProjectUseCase;
  final WatchUserProfilesUseCase watchUserProfilesUseCase;

  StreamSubscription<List<UserProfile>>? _profilesSubscription;

  ManageCollaboratorsBloc({
    required this.addCollaboratorUseCase,
    required this.removeCollaboratorUseCase,
    required this.updateCollaboratorRoleUseCase,
    required this.leaveProjectUseCase,
    required this.watchUserProfilesUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<WatchCollaborators>(_onWatchCollaborators);
    on<AddCollaborator>(_onAddCollaborator);
    on<RemoveCollaborator>(_onRemoveCollaborator);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
    on<LeaveProject>(_onLeaveProject);
  }

  Future<void> _onWatchCollaborators(
    WatchCollaborators event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    await _profilesSubscription?.cancel();
    final userIds = event.project.collaborators.map((c) => c.id.value).toList();
    _profilesSubscription = watchUserProfilesUseCase(userIds).listen(
      (profiles) {
        emit(ManageCollaboratorsLoaded(profiles));
      },
      onError: (error) {
        emit(ManageCollaboratorsError(error.toString()));
      },
    );
  }

  Future<void> _onAddCollaborator(
    AddCollaborator event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await addCollaboratorUseCase.call(
      AddCollaboratorToProjectParams(
        projectId: event.projectId,
        collaboratorId: event.collaboratorId,
      ),
    );
    result.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) {
        // Aquí deberías obtener el proyecto actualizado localmente
        // y luego disparar WatchCollaborators con ese proyecto actualizado
        // Por simplicidad, aquí se asume que event.project está actualizado
        add(WatchCollaborators(project: event.project));
      },
    );
  }

  Future<void> _onRemoveCollaborator(
    RemoveCollaborator event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await removeCollaboratorUseCase.call(
      RemoveCollaboratorParams(
        projectId: event.projectId,
        collaboratorId: event.userId,
      ),
    );
    result.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) {
        // Aquí deberías obtener el proyecto actualizado localmente
        // y luego disparar WatchCollaborators con ese proyecto actualizado
        add(
          WatchCollaborators(project: /* proyecto actualizado */ event.project),
        );
      },
    );
  }

  Future<void> _onUpdateCollaboratorRole(
    UpdateCollaboratorRole event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await updateCollaboratorRoleUseCase(
      UpdateCollaboratorRoleParams(
        projectId: event.projectId,
        userId: event.userId,
        role: event.newRole,
      ),
    );
    result.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) {
        // Aquí deberías obtener el proyecto actualizado localmente
        // y luego disparar WatchCollaborators con ese proyecto actualizado
        add(
          WatchCollaborators(project: /* proyecto actualizado */ event.project),
        );
      },
    );
  }

  Future<void> _onLeaveProject(
    LeaveProject event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await leaveProjectUseCase(
      LeaveProjectParams(
        projectId: event.projectId,
        userId: /* current user id */ UserId.fromUniqueString('currentUserId'),
      ),
    );
    result.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) => emit(ManageCollaboratorsLeaveSuccess()),
    );
  }

  @override
  Future<void> close() {
    _profilesSubscription?.cancel();
    return super.close();
  }
}
