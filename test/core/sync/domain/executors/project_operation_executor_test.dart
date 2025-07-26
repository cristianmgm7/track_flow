import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

import 'project_operation_executor_test.mocks.dart';

@GenerateMocks([ProjectRemoteDataSource])
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

        when(mockRemoteDataSource.createProject(any)).thenAnswer(
          (_) async => Right(
            ProjectDTO(
              id: testEntityId,
              name: testProjectName,
              description: testProjectDescription,
              ownerId: testOwnerId,
              updatedAt: null,
              createdAt: DateTime.now(),
            ),
          ),
        );

        // Act
        await executor.execute(operation);

        // Assert
        verify(mockRemoteDataSource.createProject(any)).called(1);

        // Verify the ProjectDTO was created correctly
        final capturedDto =
            verify(
                  mockRemoteDataSource.createProject(captureAny),
                ).captured.first
                as ProjectDTO;

        expect(capturedDto.id, equals(testEntityId));
        expect(capturedDto.name, equals(testProjectName));
        expect(capturedDto.description, equals(testProjectDescription));
        expect(capturedDto.ownerId, equals(testOwnerId));
        expect(capturedDto.updatedAt, isNull);
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

        when(mockRemoteDataSource.createProject(any)).thenAnswer(
          (_) async => Right(
            ProjectDTO(
              id: testEntityId,
              name: testProjectName,
              description: '',
              ownerId: testOwnerId,
              updatedAt: null,
              createdAt: DateTime.now(),
            ),
          ),
        );

        // Act
        await executor.execute(operation);

        // Assert
        final capturedDto =
            verify(
                  mockRemoteDataSource.createProject(captureAny),
                ).captured.first
                as ProjectDTO;

        expect(capturedDto.description, equals(''));
        expect(capturedDto.createdAt, isNotNull);
      });

      test('should throw exception when remote creation fails', () async {
        // Arrange
        final operationData = {'name': testProjectName, 'ownerId': testOwnerId};

        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'create',
          priority: SyncPriority.high,
          operationData: jsonEncode(operationData),
        );

        when(
          mockRemoteDataSource.createProject(any),
        ).thenAnswer((_) async => const Left(ServerFailure('Creation failed')));

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

        when(
          mockRemoteDataSource.updateProject(any),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        await executor.execute(operation);

        // Assert
        verify(mockRemoteDataSource.updateProject(any)).called(1);

        final capturedDto =
            verify(
                  mockRemoteDataSource.updateProject(captureAny),
                ).captured.first
                as ProjectDTO;

        expect(capturedDto.id, equals(testEntityId));
        expect(capturedDto.name, equals('Updated Project Name'));
        expect(capturedDto.description, equals('Updated Description'));
        expect(capturedDto.updatedAt, isNotNull);
      });

      test('should throw exception when remote update fails', () async {
        // Arrange
        final operationData = {'name': 'Updated Name', 'ownerId': testOwnerId};

        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'update',
          priority: SyncPriority.medium,
          operationData: jsonEncode(operationData),
        );

        when(
          mockRemoteDataSource.updateProject(any),
        ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));

        // Act & Assert
        expect(() => executor.execute(operation), throwsA(isA<Exception>()));
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

        when(
          mockRemoteDataSource.deleteProject(any),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        await executor.execute(operation);

        // Assert
        verify(mockRemoteDataSource.deleteProject(testEntityId)).called(1);
      });

      test('should throw exception when remote deletion fails', () async {
        // Arrange
        final operation = SyncOperationDocument.create(
          entityType: 'project',
          entityId: testEntityId,
          operationType: 'delete',
          priority: SyncPriority.medium,
        );

        when(
          mockRemoteDataSource.deleteProject(any),
        ).thenAnswer((_) async => const Left(ServerFailure('Deletion failed')));

        // Act & Assert
        expect(() => executor.execute(operation), throwsA(isA<Exception>()));
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

        when(mockRemoteDataSource.createProject(any)).thenAnswer(
          (_) async => Right(
            ProjectDTO(
              id: testEntityId,
              name: '',
              description: '',
              ownerId: '',
              updatedAt: null,
              createdAt: DateTime.now(),
            ),
          ),
        );

        // Act
        await executor.execute(operation);

        // Assert
        verify(mockRemoteDataSource.createProject(any)).called(1);

        final capturedDto =
            verify(
                  mockRemoteDataSource.createProject(captureAny),
                ).captured.first
                as ProjectDTO;

        expect(capturedDto.name, equals(''));
        expect(capturedDto.description, equals(''));
        expect(capturedDto.ownerId, equals(''));
      });
    });
  });
}
