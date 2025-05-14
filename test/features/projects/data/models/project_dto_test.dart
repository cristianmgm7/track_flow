import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:mockito/mockito.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

void main() {
  group('ProjectDTO', () {
    final testProject = Project(
      id: '1',
      userId: 'user1',
      title: 'Test Project',
      description: 'A test project',
      createdAt: DateTime(2023, 1, 1),
      status: 'draft',
    );

    final testDTO = ProjectDTO(
      id: '1',
      userId: 'user1',
      title: 'Test Project',
      description: 'A test project',
      createdAt: DateTime(2023, 1, 1),
      status: 'draft',
    );

    test('fromFirestore creates DTO from Firestore document', () {
      final doc = MockDocumentSnapshot();
      when(doc.data()).thenReturn({
        ProjectDTO.fieldId: '1',
        ProjectDTO.fieldUserId: 'user1',
        ProjectDTO.fieldTitle: 'Test Project',
        ProjectDTO.fieldDescription: 'A test project',
        ProjectDTO.fieldCreatedAt: Timestamp.fromDate(DateTime(2023, 1, 1)),
        ProjectDTO.fieldStatus: 'draft',
      });

      final dto = ProjectDTO.fromFirestore(doc);
      expect(dto, testDTO);
    });

    test('toFirestore converts DTO to Firestore document map', () {
      final map = testDTO.toFirestore();
      expect(map, {
        ProjectDTO.fieldUserId: 'user1',
        ProjectDTO.fieldTitle: 'Test Project',
        ProjectDTO.fieldDescription: 'A test project',
        ProjectDTO.fieldCreatedAt: Timestamp.fromDate(DateTime(2023, 1, 1)),
        ProjectDTO.fieldStatus: 'draft',
      });
    });

    test('toEntity converts DTO to domain entity', () {
      final entity = testDTO.toEntity();
      expect(entity, testProject);
    });

    test('fromEntity creates DTO from domain entity', () {
      final dto = ProjectDTO.fromEntity(testProject);
      expect(dto, testDTO);
    });

    test('copyWith creates a copy with modified fields', () {
      final modifiedDTO = testDTO.copyWith(title: 'Modified Title');
      expect(modifiedDTO.title, 'Modified Title');
      expect(modifiedDTO.id, testDTO.id);
    });

    test('fromMap creates DTO from map', () {
      final map = {
        ProjectDTO.fieldId: '1',
        ProjectDTO.fieldUserId: 'user1',
        ProjectDTO.fieldTitle: 'Test Project',
        ProjectDTO.fieldDescription: 'A test project',
        ProjectDTO.fieldCreatedAt: Timestamp.fromDate(DateTime(2023, 1, 1)),
        ProjectDTO.fieldStatus: 'draft',
      };

      final dto = ProjectDTO.fromMap(map);
      expect(dto, testDTO);
    });

    test('toMap converts DTO to map for local storage', () {
      final map = testDTO.toMap();
      expect(map, {
        ProjectDTO.fieldId: '1',
        ProjectDTO.fieldUserId: 'user1',
        ProjectDTO.fieldTitle: 'Test Project',
        ProjectDTO.fieldDescription: 'A test project',
        ProjectDTO.fieldCreatedAt: DateTime(2023, 1, 1),
        ProjectDTO.fieldStatus: 'draft',
      });
    });
  });
}
