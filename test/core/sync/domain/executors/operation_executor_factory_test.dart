import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart';
import 'package:trackflow/core/sync/domain/executors/project_operation_executor.dart';
import 'package:trackflow/core/sync/domain/executors/audio_track_operation_executor.dart';
import 'package:trackflow/core/sync/domain/executors/audio_comment_operation_executor.dart';
import 'package:trackflow/core/sync/domain/executors/user_profile_operation_executor.dart';
void main() {
  late OperationExecutorFactory factory;

  setUp(() {
    factory = OperationExecutorFactory();
  });

  group('OperationExecutorFactory', () {
    test('should return ProjectOperationExecutor for project entity type', () {
      // Act
      final executor = factory.getExecutor('project');

      // Assert
      expect(executor, isA<ProjectOperationExecutor>());
      expect(executor.entityType, equals('project'));
    });

    test(
      'should return AudioTrackOperationExecutor for audio_track entity type',
      () {
        // Act
        final executor = factory.getExecutor('audio_track');

        // Assert
        expect(executor, isA<AudioTrackOperationExecutor>());
        expect(executor.entityType, equals('audio_track'));
      },
    );

    test(
      'should return AudioCommentOperationExecutor for audio_comment entity type',
      () {
        // Act
        final executor = factory.getExecutor('audio_comment');

        // Assert
        expect(executor, isA<AudioCommentOperationExecutor>());
        expect(executor.entityType, equals('audio_comment'));
      },
    );

    test(
      'should return UserProfileOperationExecutor for user_profile entity type',
      () {
        // Act
        final executor = factory.getExecutor('user_profile');

        // Assert
        expect(executor, isA<UserProfileOperationExecutor>());
        expect(executor.entityType, equals('user_profile'));
      },
    );

    test('should throw UnsupportedError for unknown entity type', () {
      // Act & Assert
      expect(
        () => factory.getExecutor('unknown_entity'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should throw UnsupportedError for empty string entity type', () {
      // Act & Assert
      expect(() => factory.getExecutor(''), throwsA(isA<UnsupportedError>()));
    });

    test('should have correct supported entity types', () {
      // Act
      final supportedTypes = factory.supportedEntityTypes;

      // Assert
      expect(
        supportedTypes,
        containsAll([
          'project',
          'audio_track',
          'audio_comment',
          'user_profile',
        ]),
      );
      expect(supportedTypes.length, equals(4));
    });

    group('consistency tests', () {
      test('all supported entity types should return valid executors', () {
        // Arrange
        final supportedTypes = factory.supportedEntityTypes;

        // Act & Assert
        for (final entityType in supportedTypes) {
          expect(
            () => factory.getExecutor(entityType),
            returnsNormally,
            reason: 'Entity type "$entityType" should return a valid executor',
          );

          final executor = factory.getExecutor(entityType);
          expect(
            executor.entityType,
            equals(entityType),
            reason: 'Executor should have matching entity type',
          );
        }
      });

      test(
        'executors should be different instances but same type for same entity',
        () {
          // Act
          final executor1 = factory.getExecutor('project');
          final executor2 = factory.getExecutor('project');

          // Assert
          expect(executor1, isA<ProjectOperationExecutor>());
          expect(executor2, isA<ProjectOperationExecutor>());
          // Both should be the same type but potentially different instances
          expect(executor1.runtimeType, equals(executor2.runtimeType));
        },
      );
    });
  });
}
