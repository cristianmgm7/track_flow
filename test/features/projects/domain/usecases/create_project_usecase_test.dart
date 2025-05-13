import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
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
    id: 'test-id',
    title: 'Test Project',
    description: 'Test Description',
    userId: 'test-user',
    status: Project.statusDraft,
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
      id: 'test-id',
      title: '',
      description: 'Test Description',
      userId: 'test-user',
      status: Project.statusDraft,
      createdAt: testDate,
    );

    // act
    final result = await useCase(invalidProject);

    // assert
    expect(
      result,
      Left(ValidationFailure(message: 'Project title cannot be empty')),
    );
    verifyNever(mockRepository.createProject(invalidProject));
  });

  test('should return ValidationFailure when userId is empty', () async {
    // arrange
    final invalidProject = Project(
      id: 'test-id',
      title: 'Test Project',
      description: 'Test Description',
      userId: '',
      status: Project.statusDraft,
      createdAt: testDate,
    );

    // act
    final result = await useCase(invalidProject);

    // assert
    expect(result, Left(ValidationFailure(message: 'User ID cannot be empty')));
    verifyNever(mockRepository.createProject(invalidProject));
  });

  test('should return ValidationFailure when status is invalid', () async {
    // arrange
    final invalidProject = Project(
      id: 'test-id',
      title: 'Test Project',
      description: 'Test Description',
      userId: 'test-user',
      status: 'invalid_status',
      createdAt: testDate,
    );

    // act
    final result = await useCase(invalidProject);

    // assert
    expect(result, Left(ValidationFailure(message: 'Invalid project status')));
    verifyNever(mockRepository.createProject(invalidProject));
  });

  test('should return ServerFailure when repository fails', () async {
    // arrange
    when(
      mockRepository.createProject(testProject),
    ).thenAnswer((_) async => Left(ServerFailure()));

    // act
    final result = await useCase(testProject);

    // assert
    expect(result, Left(ServerFailure()));
    verify(mockRepository.createProject(testProject));
    verifyNoMoreInteractions(mockRepository);
  });
}
