import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/infrastructure/domain/directory_service.dart';
import 'package:trackflow/core/storage/domain/image_storage_repository.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/audio_track/domain/repositories/audio_track_repository.dart';
import 'package:trackflow/features/audio_track/domain/usecases/upload_track_cover_art_usecase.dart';

import 'upload_track_cover_art_usecase_test.mocks.dart';

@GenerateMocks([AudioTrackRepository, ImageStorageRepository, DirectoryService])
void main() {
  late UploadTrackCoverArtUseCase useCase;
  late MockAudioTrackRepository mockAudioTrackRepository;
  late MockImageStorageRepository mockImageStorageRepository;
  late MockDirectoryService mockDirectoryService;

  setUp(() {
    mockAudioTrackRepository = MockAudioTrackRepository();
    mockImageStorageRepository = MockImageStorageRepository();
    mockDirectoryService = MockDirectoryService();
    useCase = UploadTrackCoverArtUseCase(
      mockAudioTrackRepository,
      mockImageStorageRepository,
      mockDirectoryService,
    );
  });

  final trackId = AudioTrackId.fromUniqueString('test-track-id');
  final imageFile = File('/path/to/test.jpg');
  const downloadUrl = 'https://storage.googleapis.com/track_cover.webp';
  const localPath = '/local/path/track_cover.webp';

  final mockTrack = AudioTrack(
    id: trackId,
    name: 'Test Track',
    coverUrl: '',
    duration: const Duration(minutes: 3),
    projectId: ProjectId.fromUniqueString('test-project'),
    uploadedBy: UserId.fromUniqueString('test-user'),
    createdAt: DateTime.now(),
  );

  test('should upload track cover art and return download URL', () async {
    // Arrange
    when(mockDirectoryService.getFilePath(
      DirectoryType.trackCovers,
      any,
    )).thenAnswer((_) async => const Right(localPath));
    when(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    )).thenAnswer((_) async => const Right(downloadUrl));
    when(mockAudioTrackRepository.getTrackById(trackId))
        .thenAnswer((_) async => Right(mockTrack));
    when(mockAudioTrackRepository.updateTrack(any))
        .thenAnswer((_) async => const Right(unit));

    // Act
    final result = await useCase(UploadTrackCoverArtParams(
      trackId: trackId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, const Right(downloadUrl));
    verify(mockDirectoryService.getFilePath(DirectoryType.trackCovers, any));
    verify(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    ));
    verify(mockAudioTrackRepository.getTrackById(trackId));
    verify(mockAudioTrackRepository.updateTrack(any));
  });

  test('should return failure when track not found', () async {
    // Arrange
    when(mockDirectoryService.getFilePath(
      DirectoryType.trackCovers,
      any,
    )).thenAnswer((_) async => const Right(localPath));
    when(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    )).thenAnswer((_) async => const Right(downloadUrl));
    when(mockAudioTrackRepository.getTrackById(trackId))
        .thenAnswer((_) async => Left(DatabaseFailure('Track not found')));

    // Act
    final result = await useCase(UploadTrackCoverArtParams(
      trackId: trackId,
      imageFile: imageFile,
    ));

    // Assert
    result.fold(
      (failure) => expect(failure, isA<DatabaseFailure>()),
      (_) => fail('Should return failure'),
    );
    verify(mockDirectoryService.getFilePath(DirectoryType.trackCovers, any));
    verify(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    ));
    verify(mockAudioTrackRepository.getTrackById(trackId));
    verifyNever(mockAudioTrackRepository.updateTrack(any));
  });

  test('should return failure when upload fails', () async {
    // Arrange
    when(mockDirectoryService.getFilePath(
      DirectoryType.trackCovers,
      any,
    )).thenAnswer((_) async => const Right(localPath));
    when(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    )).thenAnswer((_) async => Left(ServerFailure('Upload failed')));

    // Act
    final result = await useCase(UploadTrackCoverArtParams(
      trackId: trackId,
      imageFile: imageFile,
    ));

    // Assert
    expect(result, Left(ServerFailure('Upload failed')));
    verify(mockDirectoryService.getFilePath(DirectoryType.trackCovers, any));
    verify(mockImageStorageRepository.uploadImage(
      imageFile: anyNamed('imageFile'),
      storagePath: anyNamed('storagePath'),
      metadata: anyNamed('metadata'),
      quality: anyNamed('quality'),
    ));
    verifyNever(mockAudioTrackRepository.getTrackById(any));
    verifyNever(mockAudioTrackRepository.updateTrack(any));
  });
}
