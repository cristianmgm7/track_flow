import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colabolator_role_usecase.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collaboators_event.dart';
import 'package:trackflow/features/manage_collaborators/presentation/bloc/manage_collabolators_state.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final ProjectRepository projectRepository;
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;

  ManageCollaboratorsBloc({
    required this.projectRepository,
    required this.updateCollaboratorRoleUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<LoadCollaborators>(_onLoadCollaborators);
    on<AddCollaborator>(_onAddCollaborator);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
    on<RemoveCollaborator>(_onRemoveCollaborator);
  }

  Future<void> _onLoadCollaborators(
    LoadCollaborators event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final Stream<Either<Failure, List<UserId>>> stream = projectRepository
        .observeProjectParticipants(event.projectId);
    await for (final Either<Failure, List<UserId>> failureOrCollaborators
        in stream) {
      failureOrCollaborators.fold(
        (failure) => emit(ManageCollaboratorsError(failure.toString())),
        (collaborators) {
          // Assuming a method to fetch UserProfile from UserId
          final List<UserProfile> userProfiles =
              collaborators.map((userId) => UserProfile(id: userId)).toList();
          emit(
            ManageCollaboratorsLoaded(collaborators: userProfiles, roles: {}),
          );
        },
      );
    }
  }

  Future<void> _onAddCollaborator(
    AddCollaborator event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    // Assuming a method to convert email to UserId
    final UserId userId = UserId.fromUniqueString(event.email);
    final Either<Failure, void> failureOrSuccess = await projectRepository
        .addParticipant(
          ProjectId.fromUniqueString(
            'currentProjectId',
          ), // Replace with actual project ID
          userId,
        );

    failureOrSuccess.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) => emit(CollaboratorActionSuccess()),
    );
  }

  Future<void> _onUpdateCollaboratorRole(
    UpdateCollaboratorRole event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final Either<Failure, void> failureOrSuccess =
        await updateCollaboratorRoleUseCase(
          UpdateCollaboratorRoleParams(
            projectId: ProjectId.fromUniqueString(
              'currentProjectId',
            ), // Replace with actual project ID
            userId: event.userId,
            role: event.newRole,
          ),
        );

    failureOrSuccess.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) => emit(CollaboratorActionSuccess()),
    );
  }

  Future<void> _onRemoveCollaborator(
    RemoveCollaborator event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final Either<Failure, void> failureOrSuccess = await projectRepository
        .removeParticipant(
          ProjectId.fromUniqueString(
            'currentProjectId',
          ), // Replace with actual project ID
          event.userId,
        );

    failureOrSuccess.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (_) => emit(CollaboratorActionSuccess()),
    );
  }
}
