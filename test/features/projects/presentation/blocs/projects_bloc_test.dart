import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';

@GenerateMocks([ProjectRepository])
import 'projects_bloc_test.mocks.dart';

void main() {
  late ProjectsBloc bloc;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    bloc = ProjectsBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final testProject = Project(
    id: 'test-id',
    title: 'Test Project',
    description: 'Test Description',
    userId: 'test-user',
    status: Project.statusDraft,
    createdAt: DateTime.now(),
  );

  final testProjects = [testProject];

  group('LoadProjects', () {
    final userId = 'test-user';
    final projectsStream = Stream.value(testProjects);

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsLoaded] when projects are loaded successfully',
      build: () {
        when(
          mockRepository.getUserProjects(userId),
        ).thenReturn(Right(projectsStream));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjects(userId)),
      expect: () => [ProjectsLoading(), ProjectsLoaded(testProjects)],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when loading fails',
      build: () {
        when(
          mockRepository.getUserProjects(userId),
        ).thenReturn(Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjects(userId)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectsError(
              'Server error occurred. Please try again later.',
            ),
          ],
    );
  });

  group('CreateProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when project is created successfully',
      build: () {
        when(
          mockRepository.createProject(testProject),
        ).thenAnswer((_) async => Right(testProject));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProject(testProject)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectOperationSuccess('Project created successfully'),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when creation fails',
      build: () {
        when(
          mockRepository.createProject(testProject),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProject(testProject)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectsError(
              'Server error occurred. Please try again later.',
            ),
          ],
    );
  });

  group('UpdateProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when project is updated successfully',
      build: () {
        when(
          mockRepository.updateProject(testProject),
        ).thenAnswer((_) async => Right(testProject));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProject(testProject)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectOperationSuccess('Project updated successfully'),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when update fails',
      build: () {
        when(
          mockRepository.updateProject(testProject),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProject(testProject)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectsError(
              'Server error occurred. Please try again later.',
            ),
          ],
    );
  });

  group('DeleteProject', () {
    final projectId = 'test-id';

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when project is deleted successfully',
      build: () {
        when(
          mockRepository.deleteProject(projectId),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteProject(projectId)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectOperationSuccess('Project deleted successfully'),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when deletion fails',
      build: () {
        when(
          mockRepository.deleteProject(projectId),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteProject(projectId)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectsError(
              'Server error occurred. Please try again later.',
            ),
          ],
    );
  });

  group('LoadProjectDetails', () {
    final projectId = 'test-id';

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectDetailsLoaded] when project details are loaded successfully',
      build: () {
        when(
          mockRepository.getProjectById(projectId),
        ).thenAnswer((_) async => Right(testProject));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjectDetails(projectId)),
      expect: () => [ProjectsLoading(), ProjectDetailsLoaded(testProject)],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when loading details fails',
      build: () {
        when(
          mockRepository.getProjectById(projectId),
        ).thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjectDetails(projectId)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectsError(
              'Server error occurred. Please try again later.',
            ),
          ],
    );
  });
}
