import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/core/error/value_failure.dart';

void main() {
  group('ProjectName', () {
    test('should return right when name is valid', () {
      const validName = 'Valid Project Name';
      final projectName = ProjectName(validName);
      expect(projectName.value.fold((l) => null, (r) => r), validName);
    });

    test('should return failure when name is empty', () {
      final projectName = ProjectName('');
      expect(
        projectName.value.fold((l) => l is EmptyField<String>, (r) => false),
        true,
      );
    });

    test('should return failure when name exceeds max length', () {
      final longName = 'a' * (ProjectName.maxLength + 1);
      final projectName = ProjectName(longName);
      expect(
        projectName.value.fold(
          (l) => l is ExceedingLength<String>,
          (r) => false,
        ),
        true,
      );
    });
  });
}
