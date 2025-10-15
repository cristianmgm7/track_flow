import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_cache/domain/repositories/audio_storage_repository.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_track/domain/usecases/download_track_usecase.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/projects/domain/entities/project_collaborator.dart';
import 'package:trackflow/features/projects/domain/exceptions/project_exceptions.dart';
import 'package:trackflow/features/projects/domain/repositories/projects_repository.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_role.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_name.dart';
import 'package:trackflow/features/projects/domain/value_objects/project_description.dart';
import 'package:trackflow/features/track_version/domain/entities/track_version.dart';
import 'package:trackflow/features/track_version/domain/repositories/track_version_repository.dart';
import 'package:trackflow/core/app_flow/domain/services/session_service.dart';

@GenerateMocks([
  AudioStorageRepository,
  AudioTrackRepository,
  TrackVersionRepository,
  ProjectsRepository,
  SessionService,
])
import 'download_track_usecase_test.mocks.dart';

void main() {
  late DownloadTrackUseCase useCase;
  late MockAudioStorageRepository mockAudioStorageRepository;
  late MockAudioTrackRepository mockAudioTrackRepository;
  late MockTrackVersionRepository mockTrackVersionRepository;
  late MockProjectsRepository mockProjectsRepository;
  late MockSessionService mockSessionService;

  late AudioTrackId trackId;
  late TrackVersionId versionId;
  late UserId userId;
  late ProjectId projectId;

  setUp(() {
    mockAudioStorageRepository = MockAudioStorageRepository();
    mockAudioTrackRepository = MockAudioTrackRepository();
    mockTrackVersionRepository = MockTrackVersionRepository();
    mockProjectsRepository = MockProjectsRepository();
    mockSessionService = MockSessionService();

    useCase = DownloadTrackUseCase(
      audioStorageRepository: mockAudioStorageRepository,
      audioTrackRepository: mockAudioTrackRepository,
      trackVersionRepository: mockTrackVersionRepository,
      projectsRepository: mockProjectsRepository,
      sessionService: mockSessionService,
    );

    trackId = AudioTrackId();
    versionId = TrackVersionId();
    userId = UserId();
    projectId = ProjectId();
  });

  group('DownloadTrackUseCase', () {
    test('should return file path when user has download permission', () async {
      // Arrange
      final track = AudioTrack(
        id: trackId,
        name: 'My Test Track',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final version = TrackVersion(
        id: versionId,
        trackId: trackId,
        versionNumber: 2,
        label: null,
        fileLocalPath: null,
        fileRemoteUrl: 'https://example.com/audio.mp3',
        durationMs: 180000,
        status: TrackVersionStatus.ready,
        createdAt: DateTime.now(),
        createdBy: userId,
      );

      final collaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.editor,
      );

      final project = Project(
        id: projectId,
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: userId,
        createdAt: DateTime.now(),
        collaborators: [collaborator],
      );

      when(mockSessionService.getCurrentUserId()).thenAnswer((_) async => Right(userId.value));
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(mockAudioStorageRepository.getCachedAudioPath(
        trackId,
        versionId: versionId,
      )).thenAnswer((_) async => const Right('/cache/path/version123.mp3'));
      when(mockTrackVersionRepository.getById(versionId))
          .thenAnswer((_) async => Right(version));

      // Act
      final result = await useCase(trackId: trackId.value, versionId: versionId.value);

      // Assert
      expect(result.isRight(), true);
      final filePath = result.getOrElse(() => '');
      expect(filePath, contains('My_Test_Track_v2.mp3'));
    });

    test('should return ProjectPermissionException when user is viewer', () async {
      // Arrange
      final track = AudioTrack(
        id: trackId,
        name: 'Test Track',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final viewerCollaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.viewer, // ← Viewer role
      );

      final project = Project(
        id: projectId,
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: UserId(),
        createdAt: DateTime.now(),
        collaborators: [viewerCollaborator],
      );

      when(mockSessionService.getCurrentUserId()).thenAnswer((_) async => Right(userId.value));
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));

      // Act
      final result = await useCase(trackId: trackId.value);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ProjectPermissionException>()),
        (_) => fail('Should have returned failure'),
      );
    });

    test('should sanitize filenames correctly', () async {
      // Arrange - Track name with special characters
      final track = AudioTrack(
        id: trackId,
        name: 'Track: Name/With\\Special*Chars',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final version = TrackVersion(
        id: versionId,
        trackId: trackId,
        versionNumber: 1,
        label: null,
        fileLocalPath: null,
        fileRemoteUrl: 'https://example.com/audio.mp3',
        durationMs: 180000,
        status: TrackVersionStatus.ready,
        createdAt: DateTime.now(),
        createdBy: userId,
      );

      final collaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.editor,
      );

      final project = Project(
        id: projectId,
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: userId,
        createdAt: DateTime.now(),
        collaborators: [collaborator],
      );

      when(mockSessionService.getCurrentUserId()).thenAnswer((_) async => Right(userId.value));
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(mockAudioStorageRepository.getCachedAudioPath(
        trackId,
        versionId: versionId,
      )).thenAnswer((_) async => const Right('/cache/path/version123.mp3'));
      when(mockTrackVersionRepository.getById(versionId))
          .thenAnswer((_) async => Right(version));

      // Act
      final result = await useCase(trackId: trackId.value, versionId: versionId.value);

      // Assert
      expect(result.isRight(), true);
      final filePath = result.getOrElse(() => '');
      // Should remove special chars and replace spaces
      expect(filePath, contains('Track_NameWithSpecialChars_v1.mp3'));
    });

    test('should return error when track not cached', () async {
      // Arrange
      final track = AudioTrack(
        id: trackId,
        name: 'Test Track',
        url: 'https://example.com/track.mp3',
        duration: const Duration(minutes: 3),
        projectId: projectId,
        uploadedBy: userId,
        createdAt: DateTime.now(),
        activeVersionId: versionId,
      );

      final collaborator = ProjectCollaborator.create(
        userId: userId,
        role: ProjectRole.editor,
      );

      final project = Project(
        id: projectId,
        name: ProjectName('Test Project'),
        description: ProjectDescription('Description'),
        ownerId: userId,
        createdAt: DateTime.now(),
        collaborators: [collaborator],
      );

      when(mockSessionService.getCurrentUserId()).thenAnswer((_) async => Right(userId.value));
      when(mockAudioTrackRepository.getTrackById(trackId))
          .thenAnswer((_) async => Right(track));
      when(mockProjectsRepository.getProjectById(projectId))
          .thenAnswer((_) async => Right(project));
      when(mockAudioStorageRepository.getCachedAudioPath(
        trackId,
        versionId: versionId,
      )).thenAnswer((_) async => const Left(
        CacheFailure('File not cached'),
      ));

      // Act
      final result = await useCase(trackId: trackId.value);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('not cached')),
        (_) => fail('Should have returned failure'),
      );
    });
  });
}

