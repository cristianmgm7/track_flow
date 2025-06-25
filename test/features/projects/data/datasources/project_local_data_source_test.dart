import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

void main() {
  late ProjectsLocalDataSourceImpl dataSource;
  late Isar isar;

  setUp(() async {
    await Directory('test/db').create(recursive: true);
    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [ProjectDocumentSchema],
      directory: 'test/db',
      name: 'test_db',
    );
    dataSource = ProjectsLocalDataSourceImpl(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
  });

  final tProjectDto = ProjectDTO(
    id: '1',
    ownerId: 'owner1',
    name: 'Test Project',
    description: 'Test Description',
    createdAt: DateTime.now(),
  );

  test('should cache a project document', () async {
    // act
    await dataSource.cacheProject(tProjectDto);
    // assert
    final projects = await isar.projectDocuments.where().findAll();
    expect(projects.length, 1);
    expect(projects.first.id, tProjectDto.id);
  });
}
