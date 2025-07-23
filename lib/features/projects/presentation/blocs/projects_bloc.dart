import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/usecases/watch_all_projects_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'projects_event.dart';
import 'projects_state.dart';
import 'package:trackflow/core/sync/domain/services/sync_status_provider.dart';
import 'package:trackflow/core/sync/domain/entities/sync_state.dart';

@injectable
class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final CreateProjectUseCase createProject;
  final UpdateProjectUseCase updateProject;
  final DeleteProjectUseCase deleteProject;
  final WatchAllProjectsUseCase watchAllProjects;
  final SyncStatusProvider _syncStatusProvider;

  StreamSubscription<Either<Failure, List<Project>>>? _projectsSubscription;

  //constructor
  ProjectsBloc({
    required this.createProject,
    required this.updateProject,
    required this.deleteProject,
    required this.watchAllProjects,
    required SyncStatusProvider syncStatusProvider,
  }) : _syncStatusProvider = syncStatusProvider,
       super(ProjectsInitial()) {
    _initializeSyncAwareness();
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<UpdateProjectRequested>(_onUpdateProjectRequested);
    on<DeleteProjectRequested>(_onDeleteProjectRequested);
    on<StartWatchingProjects>(_onStartWatchingProjects);
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await createProject.call(event.params);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (project) => emit(ProjectCreatedSuccess(project)),
    );
  }

  Future<void> _onUpdateProjectRequested(
    UpdateProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await updateProject(event.project);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (_) =>
          emit(const ProjectOperationSuccess('Project updated successfully')),
    );
  }

  Future<void> _onDeleteProjectRequested(
    DeleteProjectRequested event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());
    final result = await deleteProject.call(event.project);
    result.fold(
      (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
      (_) =>
          emit(const ProjectOperationSuccess('Project deleted successfully')),
    );
  }

  //Watching Projects stream
  Future<void> _onStartWatchingProjects(
    StartWatchingProjects event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(ProjectsLoading());

    // Listen to sync state changes for UI updates
    _syncStatusProvider.watchSyncState().listen((syncState) {
      if (state is ProjectsLoaded) {
        switch (syncState.status) {
          case SyncStatus.syncing:
            emit((state as ProjectsLoaded).copyWith(
              isSyncing: true,
              syncProgress: syncState.progress,
            ));
            break;
          case SyncStatus.complete:
            emit((state as ProjectsLoaded).copyWith(
              isSyncing: false,
              syncProgress: 1.0,
            ));
            break;
          case SyncStatus.error:
            emit((state as ProjectsLoaded).copyWith(
              isSyncing: false,
            ));
            break;
          case SyncStatus.initial:
            break;
        }
      }
    });

    await emit.onEach<Either<Failure, List<Project>>>(
      watchAllProjects(),
      onData: (eitherProjects) {
        eitherProjects.fold(
          (failure) => emit(ProjectsError(_mapFailureToMessage(failure))),
          (projects) {
            // Preserve sync state when updating projects
            final currentSyncState =
                state is ProjectsLoaded ? (state as ProjectsLoaded) : null;

            emit(
              ProjectsLoaded(
                projects: projects,
                isSyncing: currentSyncState?.isSyncing ?? isSyncing,
                syncProgress: currentSyncState?.syncProgress,
              ),
            );
          },
        );
      },
      onError:
          (error, stackTrace) => emit(
            ProjectsError(
              _mapFailureToMessage(ServerFailure(error.toString())),
            ),
          ),
    );
  }

  @override
  Future<void> close() {
    _projectsSubscription?.cancel();
    return super.close();
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is PermissionFailure) {
      return "You don't have permission to perform this action.";
    } else if (failure is DatabaseFailure) {
      return "A database error occurred. Please try again.";
    } else if (failure is AuthenticationFailure) {
      return "Authentication error. Please log in again.";
    } else if (failure is NetworkFailure) {
      return "No internet connection. Please check your network.";
    } else if (failure is ServerFailure) {
      return "A server error occurred. Please try again later.";
    } else if (failure is UnexpectedFailure) {
      return "An unexpected error occurred. Please try again later.";
    }
    return "An unknown error occurred.";
  }

  /// Initialize sync awareness with the new SyncService
  void _initializeSyncAwareness() {
    // Listen to sync state changes for UI updates
    _syncStatusProvider.watchSyncState().listen((syncState) {
      // Handle sync state changes
      if (syncState.status == SyncStatus.syncing) {
        // Sync is in progress
        if (state is ProjectsLoaded) {
          emit(
            (state as ProjectsLoaded).copyWith(
              isSyncing: true,
              syncProgress: syncState.progress,
            ),
          );
        }
      } else if (syncState.status == SyncStatus.complete) {
        // Sync completed
        if (state is ProjectsLoaded) {
          emit(
            (state as ProjectsLoaded).copyWith(
              isSyncing: false,
              syncProgress: 1.0,
            ),
          );
        }
      }
    });
  }
}
