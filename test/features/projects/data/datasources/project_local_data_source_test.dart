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
    dataSource = ProjectsLocalDataSourceImpl(mockBox);
  });

  test('should return empty list when no projects are cached', () async {
    when(mockBox.get(any)).thenReturn(null);

    final result = await dataSource.getCachedProject(UniqueId());

    expect(result, isNull);
  });

  test('should return ProjectDTO list when projects are cached', () async {
    final now = DateTime.now();
    final projectMap = {
      'id1': {
        'title': 'Test',
        'description': 'Desc',
        'userId': 'user1',
        'status': 'draft',
        'createdAt': now,
      },
    };
    when(mockBox.get(any)).thenReturn(projectMap);

    final result = await dataSource.getCachedProject(UniqueId());

    expect(result, isA<ProjectDTO?>());
    expect(result?.id, UniqueId());
  });
}
