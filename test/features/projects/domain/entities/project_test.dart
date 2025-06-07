import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';

// Assuming UserId is defined somewhere in your codebase

void main() {
  group('Project', () {
    final id = UniqueId();
    final ownerId = UserId.fromUniqueString('user-123');
    final name = ProjectName('Test Project');
    final description = ProjectDescription('A test project description.');
    final createdAt = DateTime(2024, 5, 17, 12, 0, 0);
    final updatedAt = DateTime(2024, 5, 18, 12, 0, 0);

    test('should update project correctly', () {
      final project = Project(
        id: ProjectId.fromUniqueString(id.value),
        ownerId: ownerId,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final collaborator = ProjectCollaborator.create(
        userId: ownerId,
        role: ProjectRole.owner,
      );

      project.addCollaborator(collaborator);

      final newName = ProjectName('Updated Project Name');
      final newDescription = ProjectDescription('Updated project description.');

      final updatedProject = project.updateProject(
        requester: ownerId,
        newName: newName,
        newDescription: newDescription,
      );

      expect(updatedProject.name, newName);
      expect(updatedProject.description, newDescription);
      expect(updatedProject.updatedAt, isNotNull);
    });

    test('should delete project correctly', () {
      final project = Project(
        id: ProjectId.fromUniqueString(id.value),
        ownerId: ownerId,
        name: name,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final collaborator = ProjectCollaborator.create(
        userId: ownerId,
        role: ProjectRole.owner,
      );

      project.addCollaborator(collaborator);

      final deletedProject = project.deleteProject(requester: ownerId);

      expect(deletedProject.isDeleted, isTrue);
      expect(deletedProject.updatedAt, isNotNull);
    });
  });
}
