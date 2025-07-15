import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

class MockBox extends Mock implements Box<Map<String, dynamic>> {}

void main() {
  late ProjectsLocalDataSourceImpl dataSource;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    dataSource = ProjectsLocalDataSourceImpl(box: mockBox);
  });

  test('should return empty list when no projects are cached', () async {
    when(mockBox.get(any)).thenReturn(null);

    final result = await dataSource.getCachedProject(UniqueId());

    expect(result, isNull);
  });

  test('should return ProjectDTO when project is cached', () async {
    final now = DateTime.now();
    final projectId = UniqueId();
    final projectMap = {
      'id': projectId.value,
      'name': 'Test Project',
      'description': 'Test Description',
      'ownerId': 'user1',
      'createdAt': now.toIso8601String(),
      'collaborators': [],
      'collaboratorIds': [],
    };
    when(mockBox.get(projectId.value)).thenReturn(projectMap);

    final result = await dataSource.getCachedProject(projectId);

    expect(result, isA<ProjectDTO>());
    expect(result?.id, projectId.value);
    expect(result?.name, 'Test Project');
    expect(result?.description, 'Test Description');
    expect(result?.ownerId, 'user1');
  });
}
