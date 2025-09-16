import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

/// Handles sync operations for Project entities
///
/// This executor is responsible for translating sync operations
/// into appropriate calls to the ProjectRemoteDataSource.
@injectable
class ProjectOperationExecutor implements OperationExecutor {
  final ProjectRemoteDataSource _remoteDataSource;

  ProjectOperationExecutor(this._remoteDataSource);

  @override
  String get entityType => 'project';

  @override
  Future<void> execute(SyncOperationDocument operation) async {
    final operationData =
        operation.operationData != null
            ? jsonDecode(operation.operationData!) as Map<String, dynamic>
            : <String, dynamic>{};

    switch (operation.operationType) {
      case 'create':
        await _executeCreate(operation, operationData);
        break;

      case 'update':
        await _executeUpdate(operation, operationData);
        break;

      case 'delete':
        await _executeDelete(operation);
        break;

      default:
        throw UnsupportedError(
          'Unknown project operation: ${operation.operationType}',
        );
    }
  }

  /// Execute project creation
  Future<void> _executeCreate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    final projectDto = ProjectDTO(
      id: operation.entityId,
      name: operationData['name'] ?? '',
      description: operationData['description'] ?? '',
      ownerId: operationData['ownerId'] ?? '',
      createdAt: DateTime.parse(
        operationData['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: null,
      // ✅ Include collaborators data for creation
      collaborators:
          (operationData['collaborators'] as List<dynamic>?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          [],
      collaboratorIds:
          (operationData['collaboratorIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isDeleted: operationData['isDeleted'] as bool? ?? false,
      version: operationData['version'] as int? ?? 1,
      lastModified:
          operationData['lastModified'] != null
              ? DateTime.parse(operationData['lastModified'])
              : null,
    );

    final result = await _remoteDataSource.createProject(projectDto);
    result.fold(
      (failure) => throw Exception('Failed to create project: ${failure.message}'),
      (_) => {}, // Success case
    );
  }

  /// Execute project update
  Future<void> _executeUpdate(
    SyncOperationDocument operation,
    Map<String, dynamic> operationData,
  ) async {
    // ✅ FIXED: Use complete data from operationData instead of creating incomplete DTO
    final projectDto = ProjectDTO(
      id: operation.entityId,
      name: operationData['name'] ?? '',
      description: operationData['description'] ?? '',
      ownerId: operationData['ownerId'] ?? '',
      createdAt: DateTime.parse(
        operationData['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt:
          operationData['updatedAt'] != null
              ? DateTime.parse(operationData['updatedAt'])
              : null,
      // ✅ CRITICAL FIX: Include collaborators data to prevent data loss
      collaborators:
          (operationData['collaborators'] as List<dynamic>?)
              ?.map((e) => (e as Map).cast<String, dynamic>())
              .toList() ??
          [],
      collaboratorIds:
          (operationData['collaboratorIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isDeleted: operationData['isDeleted'] as bool? ?? false,
      // ✅ Include sync metadata
      version: operationData['version'] as int? ?? 1,
      lastModified:
          operationData['lastModified'] != null
              ? DateTime.parse(operationData['lastModified'])
              : null,
    );

    final result = await _remoteDataSource.updateProject(projectDto);
    result.fold(
      (failure) => throw Exception('Failed to update project: ${failure.message}'),
      (_) => {}, // Success case
    );
  }

  /// Execute project deletion
  Future<void> _executeDelete(SyncOperationDocument operation) async {
    final result = await _remoteDataSource.deleteProject(operation.entityId);
    result.fold(
      (failure) => throw Exception('Failed to delete project: ${failure.message}'),
      (_) => {}, // Success case
    );
  }
}
