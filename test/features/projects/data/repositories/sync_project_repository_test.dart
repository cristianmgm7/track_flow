import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/data/repositories/sync_project_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';

import '../sync_project_repository_test.mocks.dart';

@GenerateMocks([ProjectLocalDataSource, ProjectRemoteDataSource])
void main() {
  late SyncProjectRepository repository;
  late MockProjectLocalDataSource mockLocalDataSource;
  late MockProjectRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockProjectLocalDataSource();
    mockRemoteDataSource = MockProjectRemoteDataSource();
    repository = SyncProjectRepository(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final dummyProject = Project(
    id: UniqueId(),
    ownerId: UserId(),
    name: ProjectName('Test Project'),
    description: ProjectDescription('Test Description'),
    createdAt: DateTime.now(),
  );
  final dummyId = dummyProject.id;
  final dummyDto = ProjectDTO.fromDomain(dummyProject);

  group('createProject', () {
    test(
      'should return Right(unit) when both local and remote succeed',
      () async {
        when(
          mockLocalDataSource.cacheProject(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockRemoteDataSource.createProject(any),
        ).thenAnswer((_) async => Right(unit));
        final result = await repository.createProject(dummyProject);
        expect(result, Right(unit));
        verify(mockLocalDataSource.cacheProject(any)).called(1);
        verify(mockRemoteDataSource.createProject(any)).called(1);
      },
    );
    test('should return Left(ServerFailure) when remote fails', () async {
      when(
        mockLocalDataSource.cacheProject(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockRemoteDataSource.createProject(any),
      ).thenAnswer((_) async => Left(ServerFailure('Remote error')));
      final result = await repository.createProject(dummyProject);
      expect(result, Left(ServerFailure('Remote error')));
      verify(mockLocalDataSource.cacheProject(any)).called(1);
      verify(mockRemoteDataSource.createProject(any)).called(1);
    });
  });

  group('updateProject', () {
    test(
      'should return Right(unit) when both local and remote succeed',
      () async {
        when(
          mockLocalDataSource.cacheProject(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockRemoteDataSource.updateProject(any),
        ).thenAnswer((_) async => Right(unit));
        final result = await repository.updateProject(dummyProject);
        expect(result, Right(unit));
        verify(mockLocalDataSource.cacheProject(any)).called(1);
        verify(mockRemoteDataSource.updateProject(any)).called(1);
      },
    );
    test('should return Left(ServerFailure) when remote fails', () async {
      when(
        mockLocalDataSource.cacheProject(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockRemoteDataSource.updateProject(any),
      ).thenAnswer((_) async => Left(ServerFailure('Remote error')));
      final result = await repository.updateProject(dummyProject);
      expect(result, Left(ServerFailure('Remote error')));
      verify(mockLocalDataSource.cacheProject(any)).called(1);
      verify(mockRemoteDataSource.updateProject(any)).called(1);
    });
  });

  group('deleteProject', () {
    test(
      'should return Right(unit) when both local and remote succeed',
      () async {
        when(
          mockLocalDataSource.removeCachedProject(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockRemoteDataSource.deleteProject(any),
        ).thenAnswer((_) async => Right(unit));
        final result = await repository.deleteProject(dummyId);
        expect(result, Right(unit));
        verify(mockLocalDataSource.removeCachedProject(any)).called(1);
        verify(mockRemoteDataSource.deleteProject(any)).called(1);
      },
    );
    test('should return Left(ServerFailure) when remote fails', () async {
      when(
        mockLocalDataSource.removeCachedProject(any),
      ).thenAnswer((_) async => Future.value());
      when(
        mockRemoteDataSource.deleteProject(any),
      ).thenAnswer((_) async => Left(ServerFailure('Remote error')));
      final result = await repository.deleteProject(dummyId);
      expect(result, Left(ServerFailure('Remote error')));
      verify(mockLocalDataSource.removeCachedProject(any)).called(1);
      verify(mockRemoteDataSource.deleteProject(any)).called(1);
    });
  });
}
