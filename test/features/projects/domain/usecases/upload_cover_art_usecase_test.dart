import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/storage/domain/image_storage_repository.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/usecases/upload_cover_art_usecase.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';

import 'upload_cover_art_usecase_test.mocks.dart';

@GenerateMocks([ProjectsRepository, ImageStorageRepository, DirectoryService])
void main() {
  late UploadCoverArtUseCase useCase;
  late MockProjectsRepository mockProjectsRepository;
  late MockImageStorageRepository mockImageStorageRepository;
  late MockDirectoryService mockDirectoryService;

  setUp(() {
    mockProjectsRepository = MockProjectsRepository();
    mockImageStorageRepository = MockImageStorageRepository();
    mockDirectoryService = MockDirectoryService();
    useCase = UploadCoverArtUseCase(
      mockProjectsRepository,
      mockImageStorageRepository,
      mockDirectoryService,
    );
  });

  final projectId = ProjectId.fromUniqueString('test-project-id');
  final imageFile = File('/path/to/test.jpg');
  const downloadUrl = 'https://storage.googleapis.com/cover.webp';
  const localPath = '/local/path/cover.webp';

  final mockProject = Project(
    id: projectId,
    ownerId: UserId.fromUniqueString('owner-id'),
    name: ProjectName('Test Project'),
    description: ProjectDescription('Test Description'),
    createdAt: DateTime.now(),
  );

  test('should upload cover art and return download URL', () async {
    // Arrange
    when(mockProjectsRepository.getProjectById(projectId))
        .thenAnswer((_) async => Right(mockProject));
    when(mockDirectoryService.getFilePath(
      DirectoryType.projectCovers,
      any,
    )).thenAnswer((_) async => const Right(localPath));
    when(mockProjectsRepository.updateProject(any))
        .thenAnswer((_) async => const Right(unit));
    when(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    )).thenAnswer((_) async => const Right(downloadUrl));

    // Act
    final result = await useCase(UploadCoverArtParams(
      projectId: projectId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, const Right(downloadUrl));
    verify(mockProjectsRepository.getProjectById(projectId));
    verify(mockDirectoryService.getFilePath(DirectoryType.projectCovers, any));
    verify(mockProjectsRepository.updateProject(any)).called(2); // Local and remote updates
    verify(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    ));
  });

  test('should return failure when project not found', () async {
    // Arrange
    when(mockProjectsRepository.getProjectById(projectId))
        .thenAnswer((_) async => Left(DatabaseFailure('Project not found')));

    // Act
    final result = await useCase(UploadCoverArtParams(
      projectId: projectId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, Left(DatabaseFailure('Project not found')));
    verify(mockProjectsRepository.getProjectById(projectId));
    verifyNever(mockDirectoryService.getFilePath(any, any));
    verifyNever(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
    ));
  });

  test('should return failure when upload fails', () async {
    // Arrange
    when(mockProjectsRepository.getProjectById(projectId))
        .thenAnswer((_) async => Right(mockProject));
    when(mockDirectoryService.getFilePath(
      DirectoryType.projectCovers,
      any,
    )).thenAnswer((_) async => const Right(localPath));
    when(mockProjectsRepository.updateProject(any))
        .thenAnswer((_) async => const Right(unit));
    when(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    )).thenAnswer((_) async => Left(ServerFailure('Upload failed')));

    // Act
    final result = await useCase(UploadCoverArtParams(
      projectId: projectId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, Left(ServerFailure('Upload failed')));
    verify(mockProjectsRepository.getProjectById(projectId));
    verify(mockDirectoryService.getFilePath(DirectoryType.projectCovers, any));
    verify(mockProjectsRepository.updateProject(any)); // Local update succeeded
    verify(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    ));
  });
}
