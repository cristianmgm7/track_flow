import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'manage_collabolators_event.dart';
import 'manage_collabolators_state.dart';

@injectable
class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;
  final AddCollaboratorToProjectUseCase addCollaboratorUseCase;

  ManageCollaboratorsBloc({
    required this.updateCollaboratorRoleUseCase,
    required this.addCollaboratorUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<AddCollaborator>(_onAddCollaborator);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
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
    result.fold(
      (failure) =>
          emit(ManageCollaboratorsError(_mapFailureToMessage(failure))),
      (_) => emit(AddCollaboratorSuccess(event.collaboratorId.value)),
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
  }

  String _mapFailureToMessage(Failure failure) {
    // You can expand this method to handle different types of failures
    return failure is ServerFailure ? 'Server Failure' : 'Unexpected Error';
  }
}
