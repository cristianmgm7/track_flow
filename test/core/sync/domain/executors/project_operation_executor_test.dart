import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

// Simple manual mock for testing
class MockProjectRemoteDataSource implements ProjectRemoteDataSource {
  final List<String> callLog = [];
  final Map<String, dynamic> responses = {};

  void setResponse(String method, dynamic response) {
    responses[method] = response;
  }

  @override
  Future<Either<Failure, ProjectDTO>> createProject(ProjectDTO project) async {
    callLog.add('createProject: ${project.id}');
    if (responses.containsKey('createProject')) {
      final response = responses['createProject'];
      if (response is ProjectDTO) {
        return Right(response);
      } else if (response is Failure) {
        return Left(response);
      }
    }
    return Right(project);
  }

  @override
  Future<Either<Failure, Unit>> updateProject(ProjectDTO project) async {
    callLog.add('updateProject: ${project.id}');
    if (responses.containsKey('updateProject')) {
      final response = responses['updateProject'];
      if (response is Failure) {
        return Left(response);
      }
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteProject(String projectId) async {
    callLog.add('deleteProject: $projectId');
    if (responses.containsKey('deleteProject')) {
      final response = responses['deleteProject'];
      if (response is Failure) {
        return Left(response);
      }
    }
    return const Right(unit);
  }

  @override
  Future<Either<Failure, ProjectDTO>> getProjectById(String projectId) async {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProjectDTO>>> getUserProjects(
    String userId,
  ) async {
    throw UnimplementedError();
  }
}

void main() {
  late ProjectOperationExecutor executor;
  late MockProjectRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockProjectRemoteDataSource();
    executor = ProjectOperationExecutor(mockRemoteDataSource);
  });

  group('ProjectOperationExecutor', () {
    const testEntityId = 'test-project-id';
    const testOwnerId = 'test-owner-id';
    const testProjectName = 'Test Project';
    const testProjectDescription = 'Test Description';

    test('should have correct entityType', () {
      expect(executor.entityType, equals('project'));
    });

    group('execute CREATE operation', () {
      test('should successfully create project with valid data', () async {
        // Arrange
        final operationData = {
          'name': testProjectName,
          'description': testProjectDescription,
          'ownerId': testOwnerId,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'create',
          priority: SyncPriority.high,
          operationData: jsonEncode(operationData),
        );

        // Act
        await executor.execute(operation);

        // Assert
        expect(
          mockRemoteDataSource.callLog,
          contains('createProject: $testEntityId'),
        );
      });

      test('should handle missing optional fields gracefully', () async {
        // Arrange
        final operationData = {
          'name': testProjectName,
          'ownerId': testOwnerId,
          // Missing description and createdAt
        };

        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'create',
          priority: SyncPriority.high,
          operationData: jsonEncode(operationData),
        );

        // Act
        await executor.execute(operation);

        // Assert
        expect(
          mockRemoteDataSource.callLog,
          contains('createProject: $testEntityId'),
        );
      });

      test('should throw exception when remote creation fails', () async {
        // Arrange
        mockRemoteDataSource.setResponse(
          'createProject',
          const ServerFailure('Creation failed'),
        );

        final operationData = {'name': testProjectName, 'ownerId': testOwnerId};

        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'create',
          priority: SyncPriority.high,
          operationData: jsonEncode(operationData),
        );

        // Act & Assert
        expect(() => executor.execute(operation), throwsA(isA<Exception>()));
      });
    });

    group('execute UPDATE operation', () {
      test('should successfully update project with valid data', () async {
        // Arrange
        final operationData = {
          'name': 'Updated Project Name',
          'description': 'Updated Description',
          'ownerId': testOwnerId,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'update',
          priority: SyncPriority.medium,
          operationData: jsonEncode(operationData),
        );

        // Act
        await executor.execute(operation);

        // Assert
        expect(
          mockRemoteDataSource.callLog,
          contains('updateProject: $testEntityId'),
        );
      });
    });

    group('execute DELETE operation', () {
      test('should successfully delete project', () async {
        // Arrange
        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'delete',
          priority: SyncPriority.medium,
        );

        // Act
        await executor.execute(operation);

        // Assert
        expect(
          mockRemoteDataSource.callLog,
          contains('deleteProject: $testEntityId'),
        );
      });
    });

    group('execute with invalid operation type', () {
      test('should throw UnsupportedError for unknown operation', () async {
        // Arrange
        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'unknown_operation',
          priority: SyncPriority.medium,
        );

        // Act & Assert
        expect(
          () => executor.execute(operation),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('execute with malformed JSON', () {
      test('should handle empty operation data', () async {
        // Arrange
        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'create',
          priority: SyncPriority.medium,
          operationData: null,
        );

        // Act
        await executor.execute(operation);

        // Assert
        expect(
          mockRemoteDataSource.callLog,
          contains('createProject: $testEntityId'),
        );
      });
    });
  });
}
