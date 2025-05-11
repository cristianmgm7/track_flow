import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/features/projects/data/repositories/firestore_project_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreProjectRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = FirestoreProjectRepository(firestore: fakeFirestore);
  });

  group('FirestoreProjectRepository', () {
    final testProject = Project(
      id: 'test-id',
      userId: 'user-123',
      title: 'Test Project',
      description: 'Test Description',
      createdAt: DateTime(2024, 1, 1),
      status: Project.statusDraft,
    );

    test('creates a project successfully', () async {
      // Act
      final createdProject = await repository.createProject(testProject);

      // Assert
      expect(createdProject.id, isNotEmpty);
      expect(createdProject.title, equals(testProject.title));
      expect(createdProject.userId, equals(testProject.userId));

      // Verify in Firestore
      final doc =
          await fakeFirestore
              .collection('projects')
              .doc(createdProject.id)
              .get();
      expect(doc.exists, isTrue);
      expect(doc.data()?['title'], equals(testProject.title));
    });

    test('updates a project successfully', () async {
      // Arrange
      final createdProject = await repository.createProject(testProject);
      final updatedProject = createdProject.copyWith(
        title: 'Updated Title',
        status: Project.statusInProgress,
      );

      // Act
      await repository.updateProject(updatedProject);

      // Assert
      final doc =
          await fakeFirestore
              .collection('projects')
              .doc(createdProject.id)
              .get();
      expect(doc.data()?['title'], equals('Updated Title'));
      expect(doc.data()?['status'], equals(Project.statusInProgress));
    });

    test('deletes a project successfully', () async {
      // Arrange
      final createdProject = await repository.createProject(testProject);

      // Act
      await repository.deleteProject(createdProject.id);

      // Assert
      final doc =
          await fakeFirestore
              .collection('projects')
              .doc(createdProject.id)
              .get();
      expect(doc.exists, isFalse);
    });

    test('gets a project by id', () async {
      // Arrange
      final createdProject = await repository.createProject(testProject);

      // Act
      final retrievedProject = await repository.getProject(createdProject.id);

      // Assert
      expect(retrievedProject, isNotNull);
      expect(retrievedProject?.title, equals(testProject.title));
      expect(retrievedProject?.userId, equals(testProject.userId));
    });

    test('returns null when getting non-existent project', () async {
      // Act
      final project = await repository.getProject('non-existent-id');

      // Assert
      expect(project, isNull);
    });

    test('streams user projects', () async {
      // Arrange
      await repository.createProject(testProject);
      await repository.createProject(
        testProject.copyWith(id: 'test-id-2', title: 'Test Project 2'),
      );

      // Act
      final projectsStream = repository.getUserProjects(testProject.userId);
      final projects = await projectsStream.first;

      // Assert
      expect(projects.length, equals(2));
      expect(
        projects.map((p) => p.title).toSet(),
        containsAll({'Test Project', 'Test Project 2'}),
      );
      expect(
        projects.map((p) => p.userId).toSet(),
        everyElement(equals(testProject.userId)),
      );
    });

    test('streams user projects by status', () async {
      // Arrange
      await repository.createProject(testProject);
      await repository.createProject(
        testProject.copyWith(
          id: 'test-id-2',
          title: 'In Progress Project',
          status: Project.statusInProgress,
        ),
      );

      // Act
      final draftProjects =
          await repository
              .getUserProjectsByStatus(testProject.userId, Project.statusDraft)
              .first;
      final inProgressProjects =
          await repository
              .getUserProjectsByStatus(
                testProject.userId,
                Project.statusInProgress,
              )
              .first;

      // Assert
      expect(draftProjects.length, equals(1));
      expect(draftProjects.first.title, equals('Test Project'));
      expect(draftProjects.first.status, equals(Project.statusDraft));

      expect(inProgressProjects.length, equals(1));
      expect(inProgressProjects.first.title, equals('In Progress Project'));
      expect(inProgressProjects.first.status, equals(Project.statusInProgress));
    });
  });
}
