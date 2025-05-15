import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_user_projects_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/get_project_by_id_usecase.dart';

@GenerateMocks([
  CreateProjectUseCase,
  UpdateProjectUseCase,
  DeleteProjectUseCase,
  GetUserProjectsUseCase,
  GetProjectByIdUseCase,
])
import 'projects_bloc_test.mocks.dart';

void main() {
  late ProjectsBloc bloc;
  late MockCreateProjectUseCase mockCreateProjectUseCase;
  late MockUpdateProjectUseCase mockUpdateProjectUseCase;
  late MockDeleteProjectUseCase mockDeleteProjectUseCase;
  late MockGetUserProjectsUseCase mockGetUserProjectsUseCase;
  late MockGetProjectByIdUseCase mockGetProjectByIdUseCase;

  setUp(() {
    mockCreateProjectUseCase = MockCreateProjectUseCase();
    mockUpdateProjectUseCase = MockUpdateProjectUseCase();
    mockDeleteProjectUseCase = MockDeleteProjectUseCase();
    mockGetUserProjectsUseCase = MockGetUserProjectsUseCase();
    mockGetProjectByIdUseCase = MockGetProjectByIdUseCase();
    final useCases = ProjectUseCases(
      createProject: mockCreateProjectUseCase,
      updateProject: mockUpdateProjectUseCase,
      deleteProject: mockDeleteProjectUseCase,
      getUserProjects: mockGetUserProjectsUseCase,
      getProjectById: mockGetProjectByIdUseCase,
    );
    bloc = ProjectsBloc(useCases);
  });

  tearDown(() {
    bloc.close();
  });

  final testProject = Project(
    id: 'test-id',
    title: 'Test Project',
    description: 'Test Description',
    userId: 'test-user',
    status: ProjectStatus('draft'),
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
          mockGetUserProjectsUseCase(userId),
        ).thenReturn(Right(projectsStream));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjects(userId)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsLoaded>().having(
              (s) => s.projects,
              'projects',
              testProjects,
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when loading fails',
      build: () {
        when(
          mockGetUserProjectsUseCase(any),
        ).thenReturn(Left(ServerFailure('')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjects(userId)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (e) => e.message,
              'message',
              'A server error occurred. Please try again later.',
            ),
          ],
    );
  });

  group('CreateProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when project is created successfully',
      build: () {
        when(
          mockCreateProjectUseCase(any),
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
          mockCreateProjectUseCase(any),
        ).thenAnswer((_) async => Left(ServerFailure('Repository error')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProject(testProject)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (e) => e.message,
              'message',
              'A server error occurred. Please try again later.',
            ),
          ],
    );
  });

  group('UpdateProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when project is updated successfully',
      build: () {
        when(
          mockUpdateProjectUseCase(any),
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
          mockUpdateProjectUseCase(any),
        ).thenAnswer((_) async => Left(ServerFailure('Repository error')));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProject(testProject)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (e) => e.message,
              'message',
              'A server error occurred. Please try again later.',
            ),
          ],
    );
  });

  group('DeleteProject', () {
    final projectId = 'test-id';
    final userId = 'test-user';

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when project is deleted successfully',
      build: () {
        when(
          mockDeleteProjectUseCase(projectId: projectId, userId: userId),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) {
        bloc.currentUserId = userId;
        bloc.add(DeleteProject(projectId));
      },
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectOperationSuccess>().having(
              (s) => s.message,
              'message',
              'Project deleted successfully',
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when deletion fails',
      build: () {
        when(
          mockDeleteProjectUseCase(projectId: projectId, userId: userId),
        ).thenAnswer((_) async => Left(ServerFailure('Repository error')));
        return bloc;
      },
      act: (bloc) {
        bloc.currentUserId = userId;
        bloc.add(DeleteProject(projectId));
      },
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (e) => e.message,
              'message',
              'A server error occurred. Please try again later.',
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
          mockGetProjectByIdUseCase(projectId),
        ).thenAnswer((_) async => Right(testProject));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjectDetails(projectId)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectDetailsLoaded>().having(
              (s) => s.project,
              'project',
              testProject,
            ),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when loading details fails',
      build: () {
        when(
          mockGetProjectByIdUseCase(projectId),
        ).thenAnswer((_) async => Left(ServerFailure('Repository error')));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadProjectDetails(projectId)),
      expect:
          () => [
            isA<ProjectsLoading>(),
            isA<ProjectsError>().having(
              (e) => e.message,
              'message',
              'A server error occurred. Please try again later.',
            ),
          ],
    );
  });
}
