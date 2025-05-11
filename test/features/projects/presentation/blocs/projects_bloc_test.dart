import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';

@GenerateMocks([ProjectRepository])
import 'projects_bloc_test.mocks.dart';

void main() {
  late MockProjectRepository mockRepository;
  late ProjectsBloc bloc;

  setUp(() {
    mockRepository = MockProjectRepository();
    bloc = ProjectsBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ProjectsBloc', () {
    final testProject = Project(
      id: 'test-id',
      userId: 'user-123',
      title: 'Test Project',
      description: 'Test Description',
      createdAt: DateTime(2024, 1, 1),
      status: Project.statusDraft,
    );

    test('initial state is ProjectsInitial', () {
      expect(bloc.state, isA<ProjectsInitial>());
    });

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsLoaded] when LoadProjects succeeds',
      build: () {
        when(
          mockRepository.getUserProjects('user-123'),
        ).thenAnswer((_) => Stream.value([testProject]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProjects('user-123')),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsLoaded>().having(
              (state) => state.projects,
              'projects',
              [testProject],
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when LoadProjects fails',
      build: () {
        when(
          mockRepository.getUserProjects('user-123'),
        ).thenAnswer((_) => Stream.error('Failed to load projects'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProjects('user-123')),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (state) => state.message,
              'error message',
              'Failed to load projects',
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when CreateProject succeeds',
      build: () {
        when(
          mockRepository.createProject(testProject),
        ).thenAnswer((_) async => testProject);
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProject(testProject)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectOperationSuccess>().having(
              (state) => state.message,
              'success message',
              'Project created successfully',
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when CreateProject fails',
      build: () {
        when(
          mockRepository.createProject(testProject),
        ).thenThrow(Exception('Failed to create project'));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProject(testProject)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (state) => state.message,
              'error message',
              'Exception: Failed to create project',
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when UpdateProject succeeds',
      build: () {
        when(
          mockRepository.updateProject(testProject),
        ).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProject(testProject)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectOperationSuccess>().having(
              (state) => state.message,
              'success message',
              'Project updated successfully',
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when DeleteProject succeeds',
      build: () {
        when(mockRepository.deleteProject('test-id')).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteProject('test-id')),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectOperationSuccess>().having(
              (state) => state.message,
              'success message',
              'Project deleted successfully',
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectDetailsLoaded] when LoadProjectDetails succeeds',
      build: () {
        when(
          mockRepository.getProject('test-id'),
        ).thenAnswer((_) async => testProject);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProjectDetails('test-id')),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectDetailsLoaded>().having(
              (state) => state.project,
              'project',
              testProject,
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when LoadProjectDetails fails',
      build: () {
        when(
          mockRepository.getProject('test-id'),
        ).thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadProjectDetails('test-id')),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (state) => state.message,
              'error message',
              'Project not found',
            ),
          ],
    );
  });
}
