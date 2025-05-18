import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:trackflow/features/projects/domain/usecases/project_usecases.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_bloc.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_event.dart';
import 'package:trackflow/features/projects/presentation/blocs/projects_state.dart';

import '../../domain/usecases/update_project_usecase_test.mocks.dart';
@GenerateMocks([
  CreateProjectUseCase,
  UpdateProjectUseCase,
  DeleteProjectUseCase,
])
import 'projects_bloc_test.mocks.dart';

void main() {
  late ProjectsBloc bloc;
  late MockCreateProjectUseCase mockCreateProjectUseCase;
  late MockUpdateProjectUseCase mockUpdateProjectUseCase;
  late MockDeleteProjectUseCase mockDeleteProjectUseCase;
  late MockGetProjectByIdUseCase mockGetProjectByIdUseCase;

  setUp(() {
    mockCreateProjectUseCase = MockCreateProjectUseCase();
    mockUpdateProjectUseCase = MockUpdateProjectUseCase();
    mockDeleteProjectUseCase = MockDeleteProjectUseCase();
    mockGetProjectByIdUseCase = MockGetProjectByIdUseCase();
    final useCases = ProjectUseCases(
      createProject: mockCreateProjectUseCase,
      updateProject: mockUpdateProjectUseCase,
      deleteProject: mockDeleteProjectUseCase,
      getProjectById: mockGetProjectByIdUseCase,
      repository: MockProjectRepository(),
    );
    bloc = ProjectsBloc(useCases);
  });

  final params = CreateProjectParams(
    ownerId: UserId(),
    name: ProjectName('Test Project'),
    description: ProjectDescription('Test Description'),
  );
  final project = Project(
    id: UniqueId(),
    ownerId: params.ownerId,
    name: params.name,
    description: params.description,
    createdAt: DateTime.now(),
  );
  final projectId = project.id;

  group('CreateProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when createProject succeeds',
      build: () {
        when(
          mockCreateProjectUseCase.call(any),
        ).thenAnswer((_) async => Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProjectRequested(params)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectOperationSuccess('Project created successfully'),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when createProject fails',
      build: () {
        when(
          mockCreateProjectUseCase.call(any),
        ).thenAnswer((_) async => Left(ServerFailure('error')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateProjectRequested(params)),
      expect:
          () => [
            ProjectsLoading(),
            ProjectsError('A server error occurred. Please try again later.'),
          ],
    );
  });

  group('UpdateProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when updateProject succeeds',
      build: () {
        when(
          mockUpdateProjectUseCase.call(any),
        ).thenAnswer((_) async => Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProjectRequested(project)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectOperationSuccess('Project updated successfully'),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when updateProject fails',
      build: () {
        when(
          mockUpdateProjectUseCase.call(any),
        ).thenAnswer((_) async => Left(ServerFailure('error')));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateProjectRequested(project)),
      expect:
          () => [
            ProjectsLoading(),
            ProjectsError('A server error occurred. Please try again later.'),
          ],
    );
  });

  group('DeleteProject', () {
    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectOperationSuccess] when deleteProject succeeds',
      build: () {
        when(
          mockDeleteProjectUseCase.call(any),
        ).thenAnswer((_) async => Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteProjectRequested(projectId)),
      expect:
          () => [
            ProjectsLoading(),
            const ProjectOperationSuccess('Project deleted successfully'),
          ],
    );

    blocTest<ProjectsBloc, ProjectsState>(
      'emits [ProjectsLoading, ProjectsError] when deleteProject fails',
      build: () {
        when(
          mockDeleteProjectUseCase.call(any),
        ).thenAnswer((_) async => Left(ServerFailure('error')));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteProjectRequested(projectId)),
      expect:
          () => [
            ProjectsLoading(),
            ProjectsError('A server error occurred. Please try again later.'),
          ],
    );
  });
}
