import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/core/entities/user_id.dart';
import 'package:trackflow/features/projects/data/repositories/sync_project_repository.dart';
import 'package:trackflow/features/projects/data/datasources/project_local_data_source.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mockito/annotations.dart';
import 'package:trackflow/features/projects/domain/entities/project_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';
import 'sync_project_repository_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ProjectLocalDataSource>(),
  MockSpec<ProjectRemoteDataSource>(),
  MockSpec<Connectivity>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SyncProjectRepository repository;
  late MockProjectLocalDataSource mockLocal;
  late MockProjectRemoteDataSource mockRemote;
  late MockConnectivity mockConnectivity;

  final testProject = Project(
    id: ProjectId('1'),
    title: 'Test Project',
    description: 'A test project',
    userId: UserId('user1'),
    status: ProjectStatus(Project.statusDraft),
    createdAt: DateTime.now(),
    updatedAt: null,
  );
  final testDTO = ProjectDTO.fromEntity(testProject);

  setUp(() {
    mockLocal = MockProjectLocalDataSource();
    mockRemote = MockProjectRemoteDataSource();
    mockConnectivity = MockConnectivity();
    repository = SyncProjectRepository(
      localDataSource: mockLocal,
      remoteDataSource: mockRemote,
      connectivity: mockConnectivity,
    );
    when(
      mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());
  });

  test('createProject stores locally and queues sync', () async {
    when(mockLocal.cacheProject(any)).thenAnswer((_) async => Future.value());
    when(
      mockRemote.createProject(any),
    ).thenAnswer((_) async => Right(testProject));
    when(
      mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());

    final result = await repository.createProject(testProject);
    expect(result.isRight(), true);
    verify(mockLocal.cacheProject(any)).called(1);
  });

  test('updateProject updates locally and queues sync', () async {
    when(mockLocal.cacheProject(any)).thenAnswer((_) async => Future.value());
    when(
      mockRemote.updateProject(any),
    ).thenAnswer((_) async => Right(testProject));
    when(
      mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());

    final result = await repository.updateProject(testProject);
    expect(result.isRight(), true);
    verify(mockLocal.cacheProject(any)).called(1);
  });

  test('deleteProject removes locally and queues sync', () async {
    when(
      mockLocal.removeCachedProject(any),
    ).thenAnswer((_) async => Future.value());
    when(
      mockRemote.deleteProject(any),
    ).thenAnswer((_) async => const Right(null));
    when(
      mockConnectivity.onConnectivityChanged,
    ).thenAnswer((_) => const Stream.empty());

    final result = await repository.deleteProject(testProject.id.value);
    expect(result.isRight(), true);
    verify(mockLocal.removeCachedProject(any)).called(1);
  });

  test('getProjectById returns project from local if present', () async {
    when(mockLocal.getCachedProject(any)).thenAnswer((_) async => testDTO);
    final result = await repository.getProjectById(testProject.id.value);
    expect(result.isRight(), true);
    expect(result.getOrElse(() => throw ''), isA<Project>());
    verify(mockLocal.getCachedProject(any)).called(1);
  });

  test('getProjectById returns failure if not found', () async {
    when(mockLocal.getCachedProject(any)).thenAnswer((_) async => null);
    when(
      mockConnectivity.checkConnectivity(),
    ).thenAnswer((_) async => ConnectivityResult.none);
    final result = await repository.getProjectById(testProject.id.value);
    expect(result.isLeft(), true);
  });
}
