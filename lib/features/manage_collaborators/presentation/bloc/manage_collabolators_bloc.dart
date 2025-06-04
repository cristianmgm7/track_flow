import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/load_user_profile_collaborators_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'manage_collabolators_event.dart';
import 'manage_collabolators_state.dart';

@injectable
class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final LoadUserProfileCollaboratorsUseCase loadUserProfileCollaboratorsUseCase;
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;

  ManageCollaboratorsBloc({
    required this.loadUserProfileCollaboratorsUseCase,
    required this.updateCollaboratorRoleUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<LoadCollaborators>(_onLoadCollaborators);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
  }

  Future<void> _onLoadCollaborators(
    LoadCollaborators event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await loadUserProfileCollaboratorsUseCase(
      ProjectWithCollaborators(
        projectId: event.projectWithCollaborators.projectId,
        collaborators: event.projectWithCollaborators.collaborators,
      ),
    );
    result.fold(
      (failure) =>
          emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
      (collaborators) => emit(
        ManageCollaboratorsLoaded(
          collaborators: collaborators,
          roles: {for (var c in collaborators) c.id: c.role!},
        ),
      ),
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
