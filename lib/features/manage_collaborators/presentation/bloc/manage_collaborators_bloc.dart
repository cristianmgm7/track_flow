import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/watch_userprofiles.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/leave_project_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/find_user_by_email_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/add_collaborator_by_email_usecase.dart';
import 'manage_collaborators_event.dart';
import 'manage_collaborators_state.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';

@injectable
class ManageCollaboratorsBloc
    extends Bloc<ManageCollaboratorsEvent, ManageCollaboratorsState> {
  final AddCollaboratorToProjectUseCase addCollaboratorUseCase;
  final RemoveCollaboratorUseCase removeCollaboratorUseCase;
  final UpdateCollaboratorRoleUseCase updateCollaboratorRoleUseCase;
  final LeaveProjectUseCase leaveProjectUseCase;
  final WatchUserProfilesUseCase watchUserProfilesUseCase;
  final FindUserByEmailUseCase findUserByEmailUseCase;
  final AddCollaboratorByEmailUseCase addCollaboratorByEmailUseCase;

  StreamSubscription<Either<Failure, List<UserProfile>>>? _profilesSubscription;
  ManageCollaboratorsLoaded? _lastLoadedState;

  ManageCollaboratorsBloc({
    required this.addCollaboratorUseCase,
    required this.removeCollaboratorUseCase,
    required this.updateCollaboratorRoleUseCase,
    required this.leaveProjectUseCase,
    required this.watchUserProfilesUseCase,
    required this.findUserByEmailUseCase,
    required this.addCollaboratorByEmailUseCase,
  }) : super(ManageCollaboratorsInitial()) {
    on<WatchCollaborators>(_onWatchCollaborators);
    on<AddCollaborator>(_onAddCollaborator);
    on<AddCollaboratorByEmail>(_onAddCollaboratorByEmail);
    on<RemoveCollaborator>(_onRemoveCollaborator);
    on<UpdateCollaboratorRole>(_onUpdateCollaboratorRole);
    on<LeaveProject>(_onLeaveProject);
    on<SearchUserByEmail>(_onSearchUserByEmail);
    on<ClearUserSearch>(_onClearUserSearch);
  }

  Future<void> _onWatchCollaborators(
    WatchCollaborators event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    final userIds =
        event.project.collaborators.map((c) => c.userId.value).toList();
    await emit.onEach<Either<Failure, List<UserProfile>>>(
      watchUserProfilesUseCase(userIds),
      onData: (either) {
        either.fold(
          (failure) => emit(ManageCollaboratorsError(failure.toString())),
          (profiles) {
            final loadedState = ManageCollaboratorsLoaded(
              event.project, // ✅ Usa el proyecto actualizado que se pasa
              profiles,
            );
            _lastLoadedState = loadedState;
            emit(loadedState);
          },
        );
      },
      onError: (error, stackTrace) {
        emit(ManageCollaboratorsError(error.toString()));
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!);
        }
      },
    );
  }

  Future<void> _onAddCollaborator(
    AddCollaborator event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await addCollaboratorUseCase(
      AddCollaboratorToProjectParams(
        projectId: event.projectId,
        collaboratorId: event.collaboratorId,
      ),
    );
    result.fold(
      (failure) {
        String errorMessage;
        if (failure is ProjectPermissionException) {
          errorMessage = 'you do not have permission to add collaborators.';
        } else {
          errorMessage = failure.toString();
        }
        emit(ManageCollaboratorsError(errorMessage));
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!);
        }
      },
      (project) {
        emit(AddCollaboratorSuccess(project));
        add(WatchCollaborators(project: project));
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
      (failure) {
        String errorMessage;
        if (failure is ProjectPermissionException) {
          errorMessage =
              'you do not have permission to remove this collaborator.';
        } else {
          errorMessage = failure.toString();
        }
        emit(ManageCollaboratorsError(errorMessage));
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!);
        }
      },
      (project) {
        add(WatchCollaborators(project: project));
      },
    );
  }

  Future<void> _onUpdateCollaboratorRole(
    UpdateCollaboratorRole event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());
    final result = await updateCollaboratorRoleUseCase.call(
      UpdateCollaboratorRoleParams(
        projectId: event.projectId,
        userId: event.userId,
        role: event.newRole,
      ),
    );
    result.fold(
      (failure) {
        String errorMessage;
        if (failure is ProjectPermissionException) {
          errorMessage =
              'you do not have permission to edit the role of this collaborator.';
        } else {
          errorMessage = failure.toString();
        }
        emit(ManageCollaboratorsError(errorMessage));
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!);
        }
      },
      (project) {
        // Emit success state first
        emit(
          UpdateCollaboratorRoleSuccess(project, event.newRole.toShortString()),
        );
        // Then watch for updates
        add(WatchCollaborators(project: project));
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
        userId: UserId.fromUniqueString('currentUserId'),
      ),
    );
    result.fold(
      (failure) => emit(ManageCollaboratorsError(failure.toString())),
      (project) => emit(ManageCollaboratorsLeaveSuccess()),
    );
  }

  Future<void> _onSearchUserByEmail(
    SearchUserByEmail event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    final email = event.email.trim();

    // Clear search if email is empty
    if (email.isEmpty) {
      emit(ManageCollaboratorsInitial());
      return;
    }

    emit(UserSearchLoading());

    try {
      final result = await findUserByEmailUseCase.call(email);

      result.fold(
        (failure) => emit(UserSearchError(failure.message)),
        (user) => emit(UserSearchSuccess(user)),
      );
    } catch (e) {
      emit(UserSearchError('Unexpected error: $e'));
    }
  }

  void _onClearUserSearch(
    ClearUserSearch event,
    Emitter<ManageCollaboratorsState> emit,
  ) {
    emit(ManageCollaboratorsInitial());
  }

  Future<void> _onAddCollaboratorByEmail(
    AddCollaboratorByEmail event,
    Emitter<ManageCollaboratorsState> emit,
  ) async {
    emit(ManageCollaboratorsLoading());

    try {
      // Use the new use case that handles the complete flow:
      // 1. Find user by email
      // 2. Add collaborator
      // 3. Create notification
      final result = await addCollaboratorByEmailUseCase(
        AddCollaboratorByEmailParams(
          projectId: event.projectId,
          email: event.email,
          role: event.role,
        ),
      );

      result.fold(
        (failure) {
          String errorMessage;
          if (failure is ProjectPermissionException) {
            errorMessage = 'You do not have permission to add collaborators.';
          } else {
            errorMessage = failure.toString();
          }
          emit(ManageCollaboratorsError(errorMessage));
          if (_lastLoadedState != null) {
            emit(_lastLoadedState!);
          }
        },
        (project) {
          // Extract user name from email for success message
          final emailUsername = event.email.split('@').first;
          emit(
            AddCollaboratorByEmailSuccess(
              project,
              'Collaborator $emailUsername added successfully!',
            ),
          );
          add(WatchCollaborators(project: project));
        },
      );
    } catch (e) {
      emit(ManageCollaboratorsError('Unexpected error: $e'));
      if (_lastLoadedState != null) {
        emit(_lastLoadedState!);
      }
    }
  }

  @override
  Future<void> close() {
    _profilesSubscription?.cancel();
    return super.close();
  }
}
