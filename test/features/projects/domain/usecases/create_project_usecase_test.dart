import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/domain/entities/project_name.dart';
import 'package:trackflow/features/projects/domain/entities/project_description.dart';
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

  test('should create project when all fields are valid', () async {
    // arrange
    final params = CreateProjectParams(
      ownerId: UserId.fromUniqueString('test-user'),
      name: ProjectName('Test Project'),
      description: ProjectDescription('Test Description'),
    );
    when(
      mockRepository.createProject(any),
    ).thenAnswer((_) async => Right(unit));

    // act
    final result = await useCase(params);

    // assert
    expect(result, Right(unit));
    verify(mockRepository.createProject(any)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    final params = CreateProjectParams(
      ownerId: UserId.fromUniqueString('test-user'),
      name: ProjectName('Test Project'),
      description: ProjectDescription('Test Description'),
    );
    when(
      mockRepository.createProject(any),
    ).thenAnswer((_) async => Left(ServerFailure('Repository error')));

    // act
    final result = await useCase(params);

    // assert
    expect(result, Left(ServerFailure('Repository error')));
    verify(mockRepository.createProject(any)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
