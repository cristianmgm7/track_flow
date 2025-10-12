import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/file_system_utils.dart';
import '../../domain/entities/voice_memo.dart';
import '../../domain/repositories/voice_memo_repository.dart';
import '../../../../core/entities/unique_id.dart';
import '../datasources/voice_memo_local_datasource.dart';
import '../models/voice_memo_document.dart';

@LazySingleton(as: VoiceMemoRepository)
class VoiceMemoRepositoryImpl implements VoiceMemoRepository {
  final VoiceMemoLocalDataSource _localDataSource;

  VoiceMemoRepositoryImpl(this._localDataSource);

  @override
  Stream<Either<Failure, List<VoiceMemo>>> watchAllMemos() {
    try {
      return _localDataSource.watchAllMemos().map(
        (docs) => Right(docs.map((doc) => doc.toDomain()).toList()),
      );
    } catch (e) {
      return Stream.value(
        Left(CacheFailure('Failed to watch memos: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, VoiceMemo?>> getMemoById(VoiceMemoId memoId) async {
    final result = await _localDataSource.getMemoById(memoId.value);
    return result.fold(
      (failure) => Left(failure),
      (doc) => Right(doc?.toDomain()),
    );
  }

  @override
  Future<Either<Failure, Unit>> saveMemo(VoiceMemo memo) async {
    try {
      // Move file from temp to permanent storage
      final permanentPath = await _moveToPermStorage(memo.fileLocalPath);

      // Create updated memo with permanent path
      final updatedMemo = memo.copyWith(fileLocalPath: permanentPath);

      // Save to database
      final doc = VoiceMemoDocument.fromDomain(updatedMemo);
      return await _localDataSource.saveMemo(doc);
    } catch (e) {
      return Left(StorageFailure('Failed to save memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMemo(VoiceMemo memo) async {
    final doc = VoiceMemoDocument.fromDomain(memo);
    return await _localDataSource.updateMemo(doc);
  }

  @override
  Future<Either<Failure, Unit>> deleteMemo(VoiceMemoId memoId) async {
    return await _localDataSource.deleteMemo(memoId.value);
  }

  @override
  Future<Either<Failure, Unit>> deleteAllMemos() async {
    return await _localDataSource.deleteAllMemos();
  }

  /// Move file from temp to permanent voice memos directory
  Future<String> _moveToPermStorage(String tempPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final voiceMemosDir = Directory('${appDir.path}/trackflow/audio/voice_memos');

    // Ensure directory exists
    await FileSystemUtils.ensureDirectoryExists(voiceMemosDir.path);

    // Generate filename from original temp path
    final filename = tempPath.split('/').last;
    final permanentPath = '${voiceMemosDir.path}/$filename';

    // Move file
    final tempFile = File(tempPath);
    await tempFile.copy(permanentPath);
    await tempFile.delete();

    return permanentPath;
  }
}
