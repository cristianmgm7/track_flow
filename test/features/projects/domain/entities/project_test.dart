import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/core/entities/user_id.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';

void main() {
  final DateTime testDate = DateTime(2024, 1, 1);
  final Project testProject = Project(
    id: ProjectId('test-id'),
    title: 'Test Project',
    description: 'Test Description',
    userId: UserId('test-user'),
    status: ProjectStatus(Project.statusDraft),
    createdAt: testDate,
  );

  group('Project Entity', () {
    test('should create a valid Project instance', () {
      expect(testProject.id.value, equals('test-id'));
      expect(testProject.title, equals('Test Project'));
      expect(testProject.description, equals('Test Description'));
      expect(testProject.userId.value.getOrElse(() => ''), equals('test-user'));
      expect(
        testProject.status.value.getOrElse(() => ''),
        equals(Project.statusDraft),
      );
      expect(testProject.createdAt, equals(testDate));
      expect(testProject.updatedAt, isNull);
    });

    test('should have valid status constants', () {
      expect(Project.statusDraft, equals('draft'));
      expect(Project.statusInProgress, equals('in_progress'));
      expect(Project.statusFinished, equals('finished'));
    });

    test('should have correct list of valid statuses', () {
      expect(Project.validStatuses, contains(Project.statusDraft));
      expect(Project.validStatuses, contains(Project.statusInProgress));
      expect(Project.validStatuses, contains(Project.statusFinished));
      expect(Project.validStatuses.length, equals(3));
    });

    test('copyWith should create a new instance with updated values', () {
      final updatedDate = DateTime(2024, 1, 2);
      final updatedProject = testProject.copyWith(
        title: 'Updated Title',
        status: ProjectStatus(Project.statusInProgress),
        updatedAt: updatedDate,
      );

      expect(updatedProject.id.value, equals(testProject.id.value));
      expect(updatedProject.title, equals('Updated Title'));
      expect(updatedProject.description, equals(testProject.description));
      expect(
        updatedProject.userId.value.getOrElse(() => ''),
        equals(testProject.userId.value.getOrElse(() => '')),
      );
      expect(
        updatedProject.status.value.getOrElse(() => ''),
        equals(Project.statusInProgress),
      );
      expect(updatedProject.createdAt, equals(testProject.createdAt));
      expect(updatedProject.updatedAt, equals(updatedDate));
    });

    test('copyWith should not modify original instance', () {
      testProject.copyWith(title: 'New Title');
      expect(testProject.title, equals('Test Project'));
    });

    test('toMap should return correct map representation', () {
      final map = ProjectDTO.fromEntity(testProject).toMap();

      expect(map['id'], equals('test-id'));
      expect(map['title'], equals('Test Project'));
      expect(map['description'], equals('Test Description'));
      expect(map['userId'], equals('test-user'));
      expect(map['status'], equals(Project.statusDraft));
      expect(map['createdAt'], equals(testDate.toIso8601String()));
      expect(map['updatedAt'], isNull);
    });

    test('fromMap should create correct Project instance', () {
      final map = {
        'id': 'test-id',
        'title': 'Test Project',
        'description': 'Test Description',
        'userId': 'test-user',
        'status': Project.statusDraft,
        'createdAt': testDate.toIso8601String(),
      };

      final project = ProjectDTO.fromMap(map).toEntity();

      expect(project.id.value, equals('test-id'));
      expect(project.title, equals('Test Project'));
      expect(project.description, equals('Test Description'));
      expect(project.userId.value.getOrElse(() => ''), equals('test-user'));
      expect(
        project.status.value.getOrElse(() => ''),
        equals(Project.statusDraft),
      );
      expect(project.createdAt, equals(testDate));
      expect(project.updatedAt, isNull);
    });

    test('equals should work correctly', () {
      final project1 = Project(
        id: ProjectId('id'),
        title: 'title',
        description: 'description',
        userId: UserId('userId'),
        status: ProjectStatus(Project.statusDraft),
        createdAt: testDate,
      );

      final project2 = Project(
        id: ProjectId('id'),
        title: 'title',
        description: 'description',
        userId: UserId('userId'),
        status: ProjectStatus(Project.statusDraft),
        createdAt: testDate,
      );

      final project3 = Project(
        id: ProjectId('different-id'),
        title: 'title',
        description: 'description',
        userId: UserId('userId'),
        status: ProjectStatus(Project.statusDraft),
        createdAt: testDate,
      );

      expect(project1, equals(project2));
      expect(project1, isNot(equals(project3)));
    });

    test('hashCode should be consistent', () {
      final project1 = Project(
        id: ProjectId('id'),
        title: 'title',
        description: 'description',
        userId: UserId('userId'),
        status: ProjectStatus(Project.statusDraft),
        createdAt: testDate,
      );

      final project2 = Project(
        id: ProjectId('id'),
        title: 'title',
        description: 'description',
        userId: UserId('userId'),
        status: ProjectStatus(Project.statusDraft),
        createdAt: testDate,
      );

      expect(project1.hashCode, equals(project2.hashCode));
    });
  });
}
