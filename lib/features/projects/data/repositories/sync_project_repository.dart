import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
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
          await _remoteRepository.createProject(operation.project!);
          break;
        case SyncOperationType.update:
          await _remoteRepository.updateProject(operation.project!);
          break;
        case SyncOperationType.delete:
          await _remoteRepository.deleteProject(operation.projectId!);
          break;
      }
    } catch (e) {
      // If sync fails, keep the operation in the queue
      _syncQueue.add(operation);
      rethrow;
    }
  }

  void _queueSyncOperation(SyncOperation operation) {
    _syncQueue.add(operation);
    _syncPendingOperations();
  }

  @override
  Future<Project> createProject(Project project) async {
    // Always write to local storage first
    final localProject = await _localRepository.createProject(project);

    // Queue sync operation
    _queueSyncOperation(SyncOperation.create(project));

    return localProject;
  }

  @override
  Future<void> updateProject(Project project) async {
    // Always update local storage first
    await _localRepository.updateProject(project);

    // Queue sync operation
    _queueSyncOperation(SyncOperation.update(project));
  }

  @override
  Future<void> deleteProject(String projectId) async {
    // Always delete from local storage first
    await _localRepository.deleteProject(projectId);

    // Queue sync operation
    _queueSyncOperation(SyncOperation.delete(projectId));
  }

  @override
  Future<Project?> getProject(String projectId) async {
    // Always read from local storage first
    return _localRepository.getProject(projectId);
  }

  @override
  Stream<List<Project>> getUserProjects(String userId) async* {
    // Start with local data
    yield* _localRepository.getUserProjects(userId);

    // If online, sync with remote
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        // Get remote data
        await for (final remoteProjects in _remoteRepository.getUserProjects(
          userId,
        )) {
          // Update local storage with remote data
          for (final project in remoteProjects) {
            await _localDataSource.cacheProject(ProjectDTO.fromEntity(project));
          }
          // Yield updated local data
          final localProjects = await _localDataSource.getCachedProjects(
            userId,
          );
          yield localProjects.map((dto) => dto.toEntity()).toList();
        }
      } catch (e) {
        // If sync fails, continue with local data
        print('Sync failed: $e');
      }
    }
  }

  @override
  Stream<List<Project>> getUserProjectsByStatus(
    String userId,
    String status,
  ) async* {
    // Start with local data
    yield* _localRepository.getUserProjectsByStatus(userId, status);

    // If online, sync with remote
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        // Get remote data
        await for (final remoteProjects in _remoteRepository
            .getUserProjectsByStatus(userId, status)) {
          // Update local storage with remote data
          for (final project in remoteProjects) {
            await _localDataSource.cacheProject(ProjectDTO.fromEntity(project));
          }
          // Yield updated local data
          final localProjects = await _localDataSource
              .getCachedProjectsByStatus(userId, status);
          yield localProjects.map((dto) => dto.toEntity()).toList();
        }
      } catch (e) {
        // If sync fails, continue with local data
        print('Sync failed: $e');
      }
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
