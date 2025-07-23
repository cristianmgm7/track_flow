import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor_factory.dart';

void main() {
  group('OperationExecutorFactory', () {
    late OperationExecutorFactory factory;

    setUp(() {
      factory = OperationExecutorFactory();
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

    test('should throw UnsupportedError for null entity type', () {
      // Act & Assert
      expect(
        () => factory.getExecutor('non_existent_type'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    group('error messages', () {
      test('should provide helpful error message for unsupported type', () {
        // Act & Assert
        try {
          factory.getExecutor('invalid_type');
          fail('Should have thrown UnsupportedError');
        } catch (e) {
          expect(e, isA<UnsupportedError>());
          expect(e.toString(), contains('invalid_type'));
        }
      });
    });

    group('supported types consistency', () {
      test('supported entity types should not be empty', () {
        expect(factory.supportedEntityTypes, isNotEmpty);
      });

      test('supported entity types should contain specific required types', () {
        final supportedTypes = factory.supportedEntityTypes;

        // These are the core types our app needs
        expect(supportedTypes, contains('project'));
        expect(supportedTypes, contains('audio_track'));
        expect(supportedTypes, contains('audio_comment'));
        expect(supportedTypes, contains('user_profile'));
      });

      test('supported entity types should not contain duplicates', () {
        final supportedTypes = factory.supportedEntityTypes;
        final uniqueTypes = supportedTypes.toSet();

        expect(supportedTypes.length, equals(uniqueTypes.length));
      });
    });
  });
}
