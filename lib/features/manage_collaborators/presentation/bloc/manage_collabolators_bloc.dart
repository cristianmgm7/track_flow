import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/load_user_profile_collaborators_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'manage_collabolators_event.dart';
import 'manage_collabolators_state.dart';

@injectable
class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final LoadUserProfileCollaboratorsUseCase loadUserProfileCollaboratorsUseCase;
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;
  final AddCollaboratorToProjectUseCase addCollaboratorUseCase;

  ManageCollaboratorsBloc({
    required this.loadUserProfileCollaboratorsUseCase,
    required this.updateCollaboratorRoleUseCase,
    required this.addCollaboratorUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<AddCollaborator>(_onAddCollaborator);
    on<LoadCollaborators>(_onLoadCollaborators);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
  }

  UserRole get defaultUserRole => UserRole.viewer;
  Future<void> _onLoadCollaborators(
    LoadCollaborators event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await loadUserProfileCollaboratorsUseCase.call(
      ProjectWithCollaborators(project: event.project),
    );
    result.fold(
      (failure) =>
          emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
      (collaborators) {
        final filteredCollaborators =
            collaborators.whereType<UserProfile>().toList();
        emit(
          ManageCollaboratorsLoaded(
            collaborators: filteredCollaborators,
            roles: {
              for (var c in filteredCollaborators)
                c.id: c.role ?? defaultUserRole,
            },
          ),
        );
      },
    );
  }

  void _onAddCollaborator(
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
      (failure) =>
          emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
      (_) {
        emit(CollaboratorActionSuccess());
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
      (failure) =>
          emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
      (_) => emit(CollaboratorActionSuccess()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    // You can expand this method to handle different types of failures
    return failure is ServerFailure ? 'Server Failure' : 'Unexpected Error';
  }
}
