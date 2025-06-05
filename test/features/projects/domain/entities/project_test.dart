import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/core/entities/unique_id.dart';
// Assuming UserId is defined somewhere in your codebase

void main() {
  group('Project', () {
    final id = UniqueId();
    final ownerId = UserId.fromUniqueString('user-123');
    final name = ProjectName('Test Project');
    final description = ProjectDescription('A test project description.');
    final createdAt = DateTime(2024, 5, 17, 12, 0, 0);
    final updatedAt = DateTime(2024, 5, 18, 12, 0, 0);

    test('should create a valid Project', () {
      final project = Project(
        id: ProjectId(id.value),
        ownerId: ownerId,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      expect(project.id, id);
      expect(project.ownerId, ownerId);
      expect(project.name, name);
      expect(project.description, description);
      expect(project.createdAt, createdAt);
      expect(project.updatedAt, updatedAt);
    });

    test('copyWith should update fields correctly', () {
      final project = Project(
        id: ProjectId(id.value),
        ownerId: ownerId,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      final newId = UniqueId();
      final newOwnerId = UserId.fromUniqueString('user-456');
      final newName = ProjectName('New Name');
      final newDescription = ProjectDescription('New description.');
      final newCreatedAt = DateTime(2024, 6, 1, 10, 0, 0);
      final newUpdatedAt = DateTime(2024, 6, 2, 10, 0, 0);

      final updated = project.copyWith(
        id: ProjectId(newId.value),
        ownerId: newOwnerId,
        name: newName,
        description: newDescription,
        createdAt: newCreatedAt,
        updatedAt: newUpdatedAt,
      );

      expect(updated.id, newId);
      expect(updated.ownerId, newOwnerId);
      expect(updated.name, newName);
      expect(updated.description, newDescription);
      expect(updated.createdAt, newCreatedAt);
      expect(updated.updatedAt, newUpdatedAt);
    });
  });
}
