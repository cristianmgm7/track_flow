import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/user_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_id.dart';
import 'package:trackflow/features/projects/domain/entities/project_status.dart';
import 'package:trackflow/features/projects/domain/repositories/project_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/create_project_usecase.dart';

@GenerateMocks([ProjectRepository])
import 'create_project_usecase_test.mocks.dart';

void main() {
  late CreateProjectUseCase useCase;
  late MockProjectRepository mockRepository;

  setUp(() {
    mockRepository = MockProjectRepository();
    useCase = CreateProjectUseCase(mockRepository);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProject = Project(
    id: ProjectId('test-id'),
    title: 'Test Project',
    description: 'Test Description',
    userId: UserId('test-user'),
    status: ProjectStatus(Project.statusDraft),
    createdAt: testDate,
  );

  test('should create project when all fields are valid', () async {
    // arrange
    when(
      mockRepository.createProject(testProject),
    ).thenAnswer((_) async => Right(testProject));

    // act
    final result = await useCase(testProject);

    // assert
    expect(result, Right(testProject));
    verify(mockRepository.createProject(testProject));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ValidationFailure when title is empty', () async {
    // arrange
    final invalidProject = Project(
      id: ProjectId('test-id'),
      title: '',
      description: 'Test Description',
      userId: UserId('test-user'),
      status: ProjectStatus(Project.statusDraft),
      createdAt: testDate,
    );

    // act
    final result = await useCase(invalidProject);

    // assert
    expect(result, Left(ValidationFailure('Project title cannot be empty')));
    verifyNever(mockRepository.createProject(invalidProject));
  });

  test('should return ValidationFailure when userId is empty', () async {
    // arrange
    final invalidProject = Project(
      id: ProjectId('test-id'),
      title: 'Test Project',
      description: 'Test Description',
      userId: UserId(''),
      status: ProjectStatus(Project.statusDraft),
      createdAt: testDate,
    );

    // act
    final result = await useCase(invalidProject);

    // assert
    expect(result, Left(ValidationFailure('User ID cannot be empty')));
    verifyNever(mockRepository.createProject(invalidProject));
  });

  test('should return ValidationFailure when status is invalid', () async {
    // arrange
    final invalidProject = Project(
      id: ProjectId('test-id'),
      title: 'Test Project',
      description: 'Test Description',
      userId: UserId('test-user'),
      status: ProjectStatus('invalid_status'),
      createdAt: testDate,
    );

    // act
    final result = await useCase(invalidProject);

    // assert
    expect(
      result,
      Left(ValidationFailure('Invalid project status: invalid_status')),
    );
    verifyNever(mockRepository.createProject(invalidProject));
  });

  test('should return ServerFailure when repository fails', () async {
    // arrange
    when(
      mockRepository.createProject(testProject),
    ).thenAnswer((_) async => Left(ServerFailure('Repository error')));

    // act
    final result = await useCase(testProject);

    // assert
    expect(result, Left(ServerFailure('Repository error')));
    verify(mockRepository.createProject(testProject));
    verifyNoMoreInteractions(mockRepository);
  });

  test(
    'should return Right(Project) when validation passes and repository succeeds',
    () async {
      final project = Project(
        id: ProjectId(''),
        userId: UserId('user123'),
        title: 'Test Project',
        description: 'A test project',
        createdAt: DateTime.now(),
        status: ProjectStatus(Project.statusDraft),
      );

      // Arrange: repository returns Right(project)
      when(
        mockRepository.createProject(any),
      ).thenAnswer((_) async => Right(project));

      // Act
      final result = await useCase(project);

      // Assert
      expect(result, Right(project));
      verify(mockRepository.createProject(any)).called(1);
    },
  );

  test('should return Left(ValidationFailure) when validation fails', () async {
    final invalidProject = Project(
      id: ProjectId(''),
      userId: UserId(''),
      title: '',
      description: '',
      createdAt: DateTime.now(),
      status: ProjectStatus(Project.statusDraft),
    );

    // Act
    final result = await useCase(invalidProject);

    // Assert
    expect(result.isLeft(), true);
    expect(result.fold((l) => l, (r) => null), isA<ValidationFailure>());
    verifyNever(mockRepository.createProject(any));
  });
}
