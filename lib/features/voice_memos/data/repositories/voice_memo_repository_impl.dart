import 'dart:io';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/infrastructure/domain/directory_service.dart';
import '../../domain/entities/voice_memo.dart';
import '../../domain/repositories/voice_memo_repository.dart';
import '../../../../core/entities/unique_id.dart';
import '../datasources/voice_memo_local_datasource.dart';
import '../models/voice_memo_document.dart';

@LazySingleton(as: VoiceMemoRepository)
class VoiceMemoRepositoryImpl implements VoiceMemoRepository {
  final VoiceMemoLocalDataSource _localDataSource;
  final DirectoryService _directoryService;

  VoiceMemoRepositoryImpl(
    this._localDataSource,
    this._directoryService,
  );

  @override
  Stream<Either<Failure, List<VoiceMemo>>> watchAllMemos() {
    try {
      // Resolve stored relative paths to absolute before exposing domain entities
      return _localDataSource.watchAllMemos().asyncMap((docs) async {
        final memos = await Future.wait(
          docs.map((doc) async {
            final resolvedPath = await _resolveAbsolutePath(doc.fileLocalPath);
            final domain = doc.toDomain().copyWith(
              fileLocalPath: resolvedPath,
            );
            return domain;
          }),
        );
        return Right(memos);
      });
    } catch (e) {
      return Stream.value(
        Left(CacheFailure('Failed to watch memos: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, VoiceMemo?>> getMemoById(VoiceMemoId memoId) async {
    final result = await _localDataSource.getMemoById(memoId.value);
    return await result.fold(
      (failure) async => Left(failure),
      (doc) async {
        if (doc == null) return const Right(null);
        final resolvedPath = await _resolveAbsolutePath(doc.fileLocalPath);
        return Right(doc.toDomain().copyWith(fileLocalPath: resolvedPath));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> saveMemo(VoiceMemo memo) async {
    try {
      // Move file from temp to permanent storage
      final permanentPath = await _moveToPermStorage(memo.fileLocalPath);

      // Convert to relative path for storage
      final relativePath = _directoryService.getRelativePath(
        permanentPath,
        DirectoryType.voiceMemos,
      );

      // Build document explicitly to ensure relative path is stored
      final doc = VoiceMemoDocument()
        ..id = memo.id.value
        ..title = memo.title
        ..fileLocalPath = relativePath
        ..fileRemoteUrl = memo.fileRemoteUrl
        ..durationMs = memo.duration.inMilliseconds
        ..recordedAt = memo.recordedAt
        ..convertedToTrackId = memo.convertedToTrackId
        ..createdBy = memo.createdBy?.value
        ..waveformAmplitudesJson = memo.waveformData != null
            ? jsonEncode(memo.waveformData!.amplitudes)
            : null
        ..waveformSampleRate = memo.waveformData?.sampleRate
        ..waveformTargetSampleCount = memo.waveformData?.targetSampleCount;

      return await _localDataSource.saveMemo(doc);
    } catch (e) {
      return Left(StorageFailure('Failed to save memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMemo(VoiceMemo memo) async {
    // Ensure we persist relative path, even if caller passed absolute
    final relativePath = memo.fileLocalPath.startsWith('/')
        ? _directoryService.getRelativePath(
            memo.fileLocalPath,
            DirectoryType.voiceMemos,
          )
        : memo.fileLocalPath;

    final doc = VoiceMemoDocument()
      ..id = memo.id.value
      ..title = memo.title
      ..fileLocalPath = relativePath
      ..fileRemoteUrl = memo.fileRemoteUrl
      ..durationMs = memo.duration.inMilliseconds
      ..recordedAt = memo.recordedAt
      ..convertedToTrackId = memo.convertedToTrackId
      ..createdBy = memo.createdBy?.value
      ..waveformAmplitudesJson = memo.waveformData != null
          ? jsonEncode(memo.waveformData!.amplitudes)
          : null
      ..waveformSampleRate = memo.waveformData?.sampleRate
      ..waveformTargetSampleCount = memo.waveformData?.targetSampleCount;

    return await _localDataSource.updateMemo(doc);
  }

  @override
  Future<Either<Failure, Unit>> deleteMemo(VoiceMemoId memoId) async {
    try {
      // Fetch memo to resolve the absolute path for deletion
      final memoEither = await _localDataSource.getMemoById(memoId.value);
      final deletion = await memoEither.fold<Future<Either<Failure, Unit>>>(
        (failure) async => Left(failure),
        (doc) async {
          if (doc == null) return Left(CacheFailure('Memo not found'));

          // Resolve absolute path if relative
          final storedPath = doc.fileLocalPath;
          final absEither = await _directoryService.getAbsolutePath(
            storedPath,
            DirectoryType.voiceMemos,
          );
          final absolutePath = absEither.getOrElse(() => storedPath);

          // Delete the file if it exists
          try {
            final file = File(absolutePath);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (_) {
            // ignore file deletion errors
          }

          // Delete DB entry
          return await _localDataSource.deleteMemo(memoId.value);
        },
      );
      return deletion;
    } catch (e) {
      return Left(StorageFailure('Failed to delete memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllMemos() async {
    return await _localDataSource.deleteAllMemos();
  }

  /// Move file from temp to permanent voice memos directory
  Future<String> _moveToPermStorage(String tempPath) async {
    // Get voice memos directory using DirectoryService
    final dirResult = await _directoryService.getDirectory(DirectoryType.voiceMemos);

    return dirResult.fold(
      (failure) => throw Exception('Failed to get voice memos directory: ${failure.message}'),
      (voiceMemosDir) async {
        // Generate filename from original temp path
        final filename = tempPath.split('/').last;
        final permanentPath = '${voiceMemosDir.path}/$filename';

        // Move file
        final tempFile = File(tempPath);
        await tempFile.copy(permanentPath);
        await tempFile.delete();

        return permanentPath;
      },
    );
  }

  /// Resolve stored (possibly relative) path to absolute path under voice memos directory
  Future<String> _resolveAbsolutePath(String storedPath) async {
    if (storedPath.startsWith('/')) return storedPath;
    final absEither = await _directoryService.getAbsolutePath(
      storedPath,
      DirectoryType.voiceMemos,
    );
    return absEither.fold((_) => storedPath, (p) => p);
  }
}
