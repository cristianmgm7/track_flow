import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/data/repositories/firestore_project_repository.dart';
import 'package:trackflow/features/projects/data/repositories/local_project_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';

/// A repository that implements offline-first with sync capabilities.
///
/// This repository:
/// 1. Always writes to local storage first
/// 2. Syncs with Firestore when online
/// 3. Reads from local storage for immediate access
/// 4. Periodically syncs with Firestore in the background
class SyncProjectRepository implements ProjectRepository {
  final ProjectLocalDataSource _localDataSource;
  final FirestoreProjectRepository _remoteRepository;
  final LocalProjectRepository _localRepository;
  final Connectivity _connectivity;

  // Stream controller for sync status
  final _syncController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatus => _syncController.stream;

  // Queue for pending sync operations
  final _syncQueue = <SyncOperation>[];
  bool _isSyncing = false;

  SyncProjectRepository({
    ProjectLocalDataSource? localDataSource,
    FirestoreProjectRepository? remoteRepository,
    Connectivity? connectivity,
  }) : _localDataSource = localDataSource ?? HiveProjectLocalDataSource(),
       _remoteRepository = remoteRepository ?? FirestoreProjectRepository(),
       _localRepository = LocalProjectRepository(
         localDataSource: localDataSource,
       ),
       _connectivity = connectivity ?? Connectivity() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      _syncPendingOperations();
    }
  }

  Future<void> _syncPendingOperations() async {
    if (_isSyncing || _syncQueue.isEmpty) return;

    _isSyncing = true;
    _syncController.add(const SyncStatus.syncing());

    try {
      while (_syncQueue.isNotEmpty) {
        final operation = _syncQueue.removeAt(0);
        await _executeSyncOperation(operation);
      }
      _syncController.add(const SyncStatus.synced());
    } catch (e) {
      _syncController.add(SyncStatus.error(e.toString()));
      // Put the operation back in the queue
      if (_syncQueue.isNotEmpty) {
        _syncQueue.insert(0, _syncQueue.removeLast());
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _executeSyncOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.create:
          final result = await _remoteRepository.createProject(
            operation.project!,
          );
          result.fold((failure) => throw Exception(failure.message), (
            project,
          ) async {
            final dto = ProjectDTO.fromEntity(project);
            await _localDataSource.cacheProject(dto);
          });
          break;
        case SyncOperationType.update:
          final result = await _remoteRepository.updateProject(
            operation.project!,
          );
          result.fold((failure) => throw Exception(failure.message), (
            project,
          ) async {
            final dto = ProjectDTO.fromEntity(project);
            await _localDataSource.cacheProject(dto);
          });
          break;
        case SyncOperationType.delete:
          final result = await _remoteRepository.deleteProject(
            operation.projectId!,
          );
          result.fold((failure) => throw Exception(failure.message), (_) async {
            await _localDataSource.removeCachedProject(operation.projectId!);
          });
          break;
      }
    } catch (e) {
      _syncQueue.add(operation);
      rethrow;
    }
  }

  void _queueSyncOperation(SyncOperation operation) {
    _syncQueue.add(operation);
    _syncPendingOperations();
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    // Always write to local storage first
    final localResult = await _localRepository.createProject(project);

    return localResult.fold((failure) => Left(failure), (localProject) {
      // Queue sync operation
      _queueSyncOperation(SyncOperation.create(localProject));
      return Right(localProject);
    });
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    // Always update local storage first
    final localResult = await _localRepository.updateProject(project);

    return localResult.fold((failure) => Left(failure), (localProject) {
      // Queue sync operation
      _queueSyncOperation(SyncOperation.update(localProject));
      return Right(localProject);
    });
  }

  @override
  Future<Either<Failure, void>> deleteProject(String projectId) async {
    // Always delete from local storage first
    final localResult = await _localRepository.deleteProject(projectId);

    return localResult.fold((failure) => Left(failure), (_) {
      // Queue sync operation
      _queueSyncOperation(SyncOperation.delete(projectId));
      return const Right(null);
    });
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String projectId) async {
    // Always read from local storage first
    final localResult = await _localRepository.getProjectById(projectId);

    // If online and not found locally, try remote
    if (localResult.isLeft()) {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        final remoteResult = await _remoteRepository.getProjectById(projectId);
        return remoteResult.fold((failure) => Left(failure), (project) async {
          // Cache the remote project locally
          await _localRepository.createProject(project);
          return Right(project);
        });
      }
    }

    return localResult;
  }

  @override
  Either<Failure, Stream<List<Project>>> getUserProjects(String userId) {
    try {
      // Create a stream that combines local and remote data
      final stream = StreamController<List<Project>>();

      // Start with local data
      _localRepository.getUserProjects(userId).fold(
        (failure) => stream.addError(failure),
        (localStream) {
          localStream.listen(
            (projects) => stream.add(projects),
            onError: (error) => stream.addError(error),
          );
        },
      );

      // If online, sync with remote
      _connectivity.checkConnectivity().then((connectivityResult) {
        if (connectivityResult != ConnectivityResult.none) {
          _remoteRepository.getUserProjects(userId).fold(
            (failure) => stream.addError(failure),
            (remoteStream) {
              remoteStream.listen((projects) async {
                // Update local storage with remote data
                for (final project in projects) {
                  await _localRepository.createProject(project);
                }
                stream.add(projects);
              }, onError: (error) => stream.addError(error));
            },
          );
        }
      });

      return Right(stream.stream);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to setup projects stream: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Either<Failure, Stream<List<Project>>> getUserProjectsByStatus(
    String userId,
    String status,
  ) {
    try {
      // Create a stream that combines local and remote data
      final stream = StreamController<List<Project>>();

      // Start with local data
      _localRepository.getUserProjectsByStatus(userId, status).fold(
        (failure) => stream.addError(failure),
        (localStream) {
          localStream.listen(
            (projects) => stream.add(projects),
            onError: (error) => stream.addError(error),
          );
        },
      );

      // If online, sync with remote
      _connectivity.checkConnectivity().then((connectivityResult) {
        if (connectivityResult != ConnectivityResult.none) {
          _remoteRepository.getUserProjectsByStatus(userId, status).fold(
            (failure) => stream.addError(failure),
            (remoteStream) {
              remoteStream.listen((projects) async {
                // Update local storage with remote data
                for (final project in projects) {
                  await _localRepository.createProject(project);
                }
                stream.add(projects);
              }, onError: (error) => stream.addError(error));
            },
          );
        }
      });

      return Right(stream.stream);
    } catch (e) {
      return Left(
        UnexpectedFailure(
          message: 'Failed to setup projects stream: ${e.toString()}',
        ),
      );
    }
  }

  // Clean up resources
  void dispose() {
    _syncController.close();
  }
}

/// Represents the status of the sync operation
enum SyncStatusType { syncing, synced, error }

class SyncStatus {
  final SyncStatusType type;
  final String? error;

  const SyncStatus.syncing() : type = SyncStatusType.syncing, error = null;
  const SyncStatus.synced() : type = SyncStatusType.synced, error = null;
  const SyncStatus.error(this.error) : type = SyncStatusType.error;
}

/// Represents a sync operation to be performed
class SyncOperation {
  final SyncOperationType type;
  final Project? project;
  final String? projectId;

  const SyncOperation.create(this.project)
    : type = SyncOperationType.create,
      projectId = null;

  const SyncOperation.update(this.project)
    : type = SyncOperationType.update,
      projectId = null;

  const SyncOperation.delete(this.projectId)
    : type = SyncOperationType.delete,
      project = null;
}

enum SyncOperationType { create, update, delete }
