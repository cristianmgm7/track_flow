import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
import 'package:trackflow/core/error/value_failure.dart';

void main() {
  group('ProjectName Value Object Tests', () {
    test('should create valid project name', () {
      // Arrange
      const validName = 'My Project';

      // Act
      final projectName = ProjectName(validName);

      // Assert
      expect(projectName.value.isRight(), true);
      expect(
        projectName.value.fold((l) => null, (r) => r),
        validName,
      );
    });

    test('should return failure for empty name', () {
      // Act
      final projectName = ProjectName('');

      // Assert
      expect(projectName.value.isLeft(), true);
      expect(
        projectName.value.fold((l) => l, (r) => null),
        isA<ValueFailure<String>>(),
      );
    });

    test('should return failure for too long name', () {
      // Arrange
      final tooLongName = 'A' * 51; // Exceeds max length of 50

      // Act
      final projectName = ProjectName(tooLongName);

      // Assert
      expect(projectName.value.isLeft(), true);
      expect(
        projectName.value.fold((l) => l, (r) => null),
        isA<ExceedingLength>(),
      );
    });

    test('should handle valid name within max length', () {
      // Arrange
      final validName = 'A' * 50; // Exactly max length

      // Act
      final projectName = ProjectName(validName);

      // Assert
      expect(projectName.value.isRight(), true);
      expect(
        projectName.value.fold((l) => null, (r) => r),
        validName,
      );
    });

    test('should create project name with spaces', () {
      // Arrange
      const nameWithSpaces = 'My Project Name';

      // Act
      final projectName = ProjectName(nameWithSpaces);

      // Assert
      expect(projectName.value.isRight(), true);
      expect(
        projectName.value.fold((l) => null, (r) => r),
        nameWithSpaces,
      );
    });

    test('should return string representation correctly', () {
      // Arrange
      const validName = 'Test Project';
      final projectName = ProjectName(validName);

      // Act
      final stringRepresentation = projectName.toString();

      // Assert
      expect(stringRepresentation, validName);
    });
  });
}