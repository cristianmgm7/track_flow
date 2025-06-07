import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/core/error/value_failure.dart';

void main() {
  group('ProjectDescription', () {
    test('should return right when description is valid', () {
      const validDescription = 'A valid project description.';
      final projectDescription = ProjectDescription(validDescription);
      expect(
        projectDescription.value.fold((l) => null, (r) => r),
        validDescription,
      );
    });

    test('should return failure when description exceeds max length', () {
      final longDescription = 'a' * (ProjectDescription.maxLength + 1);
      final projectDescription = ProjectDescription(longDescription);
      expect(
        projectDescription.value.fold(
          (l) => l is ExceedingLength<String>,
          (r) => false,
        ),
        true,
      );
    });

    test('should return right when description is empty (allowed)', () {
      final projectDescription = ProjectDescription('');
      expect(projectDescription.value.fold((l) => null, (r) => r), '');
    });
  });
}
