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
    final operationData = operation.operationData != null 
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
        throw UnsupportedError('Unknown project operation: ${operation.operationType}');
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
    );
    
    await _remoteDataSource.createProject(projectDto);
  }

  /// Execute project update
  Future<void> _executeUpdate(
    SyncOperationDocument operation, 
    Map<String, dynamic> operationData,
  ) async {
    final projectDto = ProjectDTO(
      id: operation.entityId,
      name: operationData['name'] ?? '',
      description: operationData['description'] ?? '',
      ownerId: operationData['ownerId'] ?? '',
      createdAt: DateTime.now(), // This should come from local data
      updatedAt: DateTime.parse(
        operationData['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
    
    await _remoteDataSource.updateProject(projectDto);
  }

  /// Execute project deletion
  Future<void> _executeDelete(SyncOperationDocument operation) async {
    await _remoteDataSource.deleteProject(operation.entityId);
  }
}