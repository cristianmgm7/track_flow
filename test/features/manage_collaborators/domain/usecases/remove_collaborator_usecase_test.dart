import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/manage_collaborators/domain/repositories/manage_collaborators_repository.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/remove_collaborator_usecase.dart';
import 'package:trackflow/features/manage_collaborators/domain/exceptions/manage_collaborator_exception.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:mockito/annotations.dart';

import 'remove_collaborator_usecase_test.mocks.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<ManageCollaboratorsRepository>(
      as: #CustomMockManageCollaboratorsRepository,
    ),
    MockSpec<SessionStorage>(as: #CustomMockSessionStorage),
    MockSpec<ProjectDetailRepository>(as: #CustomMockProjectDetailRepository),
  ],
)
void main() {
  late RemoveCollaboratorUseCase useCase;
  late ProjectDetailRepository mockProjectDetailRepository;
  late CustomMockManageCollaboratorsRepository mockRepository;
  late CustomMockSessionStorage mockSessionStorage;

  setUp(() {
    mockRepository = CustomMockManageCollaboratorsRepository();
    mockSessionStorage = CustomMockSessionStorage();
    mockProjectDetailRepository = CustomMockProjectDetailRepository();
    useCase = RemoveCollaboratorUseCase(
      mockProjectDetailRepository,
      mockRepository,
      mockSessionStorage,
    );
  });

  final projectId = ProjectId.fromUniqueString('project-123');
  final collaboratorId = UserId.fromUniqueString('collaborator-123');
  final params = RemoveCollaboratorParams(
    projectId: projectId,
    collaboratorId: collaboratorId,
  );

  test('should remove collaborator successfully', () async {
    final userId = 'user-123';
    final ownerId = UserId.fromUniqueString(userId);
    final project = Project(
      id: projectId,
      ownerId: ownerId,
      name: ProjectName('Test Project'),
      description: ProjectDescription('Description'),
      createdAt: DateTime.now(),
      collaborators: [
        ProjectCollaborator.create(userId: ownerId, role: ProjectRole.owner),
        ProjectCollaborator.create(
          userId: collaboratorId,
          role: ProjectRole.viewer,
        ),
      ],
    );

    when(mockSessionStorage.getUserId()).thenReturn(userId);
    when(
      mockProjectDetailRepository.getProjectById(projectId),
    ).thenAnswer((_) async => right(project));
    when(
      mockRepository.updateProject(any),
    ).thenAnswer((_) async => right(null));

    final result = await useCase(params);

    expect(result, right(null));
    verify(mockRepository.updateProject(argThat(isA<Project>()))).called(1);
  });

  test('should return ServerFailure when no user found', () async {
    when(mockSessionStorage.getUserId()).thenReturn(null);

    final result = await useCase(params);

    expect(result, left(ServerFailure('No user found')));
  });

  test(
    'should throw ManageCollaboratorException if user is not a collaborator',
    () async {
      final userId = 'user-123';
      final project = Project(
        id: projectId,
        ownerId: UserId.fromUniqueString(userId),
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        createdAt: DateTime.now(),
        collaborators: [
          ProjectCollaborator.create(
            userId: collaboratorId,
            role: ProjectRole.viewer,
          ),
        ],
      );

      when(mockSessionStorage.getUserId()).thenReturn(userId);
      when(
        mockProjectDetailRepository.getProjectById(projectId),
      ).thenAnswer((_) async => right(project));

      expect(
        () => useCase(params),
        throwsA(isA<ManageCollaboratorException>()),
      );
    },
  );

  test(
    'should return ProjectPermissionException if user lacks permission',
    () async {
      final userId = 'user-123';
      final ownerId = UserId.fromUniqueString(userId);
      final project = Project(
        id: projectId,
        ownerId: ownerId,
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        createdAt: DateTime.now(),
        collaborators: [
          ProjectCollaborator.create(
            userId: ownerId,
            role: ProjectRole.viewer, // viewer has no remove permission
          ),
          ProjectCollaborator.create(
            userId: collaboratorId,
            role: ProjectRole.viewer,
          ),
        ],
      );

      when(mockSessionStorage.getUserId()).thenReturn(userId);
      when(
        mockProjectDetailRepository.getProjectById(projectId),
      ).thenAnswer((_) async => right(project));

      final result = await useCase(params);

      expect(result, left(ProjectPermissionException()));
    },
  );

  test(
    'should return ManageCollaboratorException if collaborator to remove not found',
    () async {
      final userId = 'user-123';
      final ownerId = UserId.fromUniqueString(userId);
      final project = Project(
        id: projectId,
        ownerId: ownerId,
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        createdAt: DateTime.now(),
        collaborators: [
          ProjectCollaborator.create(userId: ownerId, role: ProjectRole.owner),
        ],
      );

      when(mockSessionStorage.getUserId()).thenReturn(userId);
      when(
        mockProjectDetailRepository.getProjectById(projectId),
      ).thenAnswer((_) async => right(project));

      final result = await useCase(params);

      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), isA<ManageCollaboratorException>());
    },
  );
}
