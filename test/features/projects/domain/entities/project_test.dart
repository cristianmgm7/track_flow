import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';

void main() {
  group('Project Entity Tests', () {
    late Project testProject;
    late UserId ownerId;
    late UserId collaboratorId;

    setUp(() {
      ownerId = UserId.fromUniqueString('owner-123');
      collaboratorId = UserId.fromUniqueString('collaborator-456');

      testProject = Project(
        id: ProjectId.fromUniqueString('project-123'),
        name: ProjectName('Test Project'),
        description: ProjectDescription('Test Description'),
        ownerId: ownerId,
        collaborators: [
          ProjectCollaborator.create(
            userId: collaboratorId,
            role: ProjectRole.viewer,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    group('removeCollaborator', () {
      test('should remove collaborator successfully', () {
        // Act
        final updatedProject = testProject.removeCollaborator(collaboratorId);

        // Assert
        expect(updatedProject.collaborators.length, 0);
        expect(
          updatedProject.collaborators.any((c) => c.userId == collaboratorId),
          false,
        );
      });

      test('should throw exception when trying to remove owner', () {
        // Act & Assert
        expect(
          () => testProject.removeCollaborator(ownerId),
          throwsA(
            predicate(
              (e) =>
                  e is Exception &&
                  e.toString().contains('Cannot remove the project owner'),
            ),
          ),
        );
      });

      test(
        'should throw CollaboratorNotFoundException for non-existent user',
        () {
          // Arrange
          final nonExistentUserId = UserId.fromUniqueString('non-existent-789');

          // Act & Assert
          expect(
            () => testProject.removeCollaborator(nonExistentUserId),
            throwsA(isA<CollaboratorNotFoundException>()),
          );
        },
      );
    });

    group('addCollaborator', () {
      test('should add new collaborator successfully', () {
        // Arrange
        final newCollaboratorId = UserId.fromUniqueString(
          'new-collaborator-789',
        );
        final newCollaborator = ProjectCollaborator.create(
          userId: newCollaboratorId,
          role: ProjectRole.viewer,
        );

        // Act
        final updatedProject = testProject.addCollaborator(newCollaborator);

        // Assert
        expect(updatedProject.collaborators.length, 2);
        expect(
          updatedProject.collaborators.any(
            (c) => c.userId == newCollaboratorId,
          ),
          true,
        );
      });
    });

    group('updateCollaboratorRole', () {
      late UserId adminId;
      late UserId viewerId;

      setUp(() {
        adminId = UserId.fromUniqueString('admin-123');
        viewerId = UserId.fromUniqueString('viewer-456');

        testProject = Project(
          id: ProjectId.fromUniqueString('project-123'),
          name: ProjectName('Test Project'),
          description: ProjectDescription('Test Description'),
          ownerId: ownerId,
          collaborators: [
            ProjectCollaborator.create(
              userId: adminId,
              role: ProjectRole.admin,
            ),
            ProjectCollaborator.create(
              userId: viewerId,
              role: ProjectRole.viewer,
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      test('should update collaborator role when admin requests it', () {
        // Act
        final updatedProject = testProject.updateCollaboratorRole(
          adminId, // requester (admin)
          viewerId, // target user
          ProjectRole.editor, // new role
        );

        // Assert
        final updatedCollaborator = updatedProject.collaborators.firstWhere(
          (c) => c.userId == viewerId,
        );
        expect(updatedCollaborator.role, ProjectRole.editor);
      });

      test(
        'should throw ProjectPermissionException when viewer tries to update role',
        () {
          // Act & Assert
          expect(
            () => testProject.updateCollaboratorRole(
              viewerId, // requester (viewer - no permission)
              adminId, // target user
              ProjectRole.viewer, // new role
            ),
            throwsA(isA<ProjectPermissionException>()),
          );
        },
      );

      test(
        'should throw exception when user tries to change their own role',
        () {
          // Act & Assert
          expect(
            () => testProject.updateCollaboratorRole(
              adminId, // requester
              adminId, // same user (trying to change own role)
              ProjectRole.viewer, // new role
            ),
            throwsA(
              predicate(
                (e) =>
                    e is Exception &&
                    e.toString().contains('Cannot change your own role'),
              ),
            ),
          );
        },
      );

      test(
        'should throw UserNotCollaboratorException when non-collaborator requests update',
        () {
          // Arrange
          final nonCollaboratorId = UserId.fromUniqueString(
            'non-collaborator-789',
          );

          // Act & Assert
          expect(
            () => testProject.updateCollaboratorRole(
              nonCollaboratorId, // requester (not a collaborator)
              viewerId, // target user
              ProjectRole.editor, // new role
            ),
            throwsA(isA<UserNotCollaboratorException>()),
          );
        },
      );

      test(
        'should throw CollaboratorNotFoundException when target user does not exist',
        () {
          // Arrange
          final nonExistentUserId = UserId.fromUniqueString('non-existent-789');

          // Act & Assert
          expect(
            () => testProject.updateCollaboratorRole(
              adminId, // requester (admin)
              nonExistentUserId, // target user (does not exist)
              ProjectRole.editor, // new role
            ),
            throwsA(isA<CollaboratorNotFoundException>()),
          );
        },
      );
    });
  });
}
