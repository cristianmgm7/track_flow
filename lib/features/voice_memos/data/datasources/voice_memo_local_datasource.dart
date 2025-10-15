import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/file_system_utils.dart';
import '../models/voice_memo_document.dart';

/// Abstract contract for local data source
abstract class VoiceMemoLocalDataSource {
  Stream<List<VoiceMemoDocument>> watchAllMemos();
  Future<Either<Failure, VoiceMemoDocument?>> getMemoById(String id);
  Future<Either<Failure, Unit>> saveMemo(VoiceMemoDocument memo);
  Future<Either<Failure, Unit>> updateMemo(VoiceMemoDocument memo);
  Future<Either<Failure, Unit>> deleteMemo(String id);
  Future<Either<Failure, Unit>> deleteAllMemos();
}

/// Isar implementation of local data source
@LazySingleton(as: VoiceMemoLocalDataSource)
class IsarVoiceMemoLocalDataSource implements VoiceMemoLocalDataSource {
  final Isar _isar;

  IsarVoiceMemoLocalDataSource(this._isar);

  @override
  Stream<List<VoiceMemoDocument>> watchAllMemos() {
    return _isar.voiceMemoDocuments
        .where()
        .sortByRecordedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<Either<Failure, VoiceMemoDocument?>> getMemoById(String id) async {
    try {
      final memo = await _isar.voiceMemoDocuments
          .filter()
          .idEqualTo(id)
          .findFirst();
      return Right(memo);
    } catch (e) {
      return Left(CacheFailure('Failed to get memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMemo(VoiceMemoDocument memo) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.put(memo);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to save memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateMemo(VoiceMemoDocument memo) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.put(memo);
      });
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMemo(String id) async {
    try {
      // Get memo to find file path
      final memo = await _isar.voiceMemoDocuments
          .filter()
          .idEqualTo(id)
          .findFirst();

      if (memo == null) {
        return Left(CacheFailure('Memo not found'));
      }

      // Delete database entry
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.delete(fastHash(id));
      });

      // Delete audio file (path may be absolute or relative; failure is ignored)
      await FileSystemUtils.deleteFileIfExists(memo.fileLocalPath);

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete memo: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllMemos() async {
    try {
      // Get all memos to delete their files
      final memos = await _isar.voiceMemoDocuments.where().findAll();

      // Delete all database entries
      await _isar.writeTxn(() async {
        await _isar.voiceMemoDocuments.clear();
      });

      // Delete all audio files (paths may be absolute or relative)
      for (final memo in memos) {
        await FileSystemUtils.deleteFileIfExists(memo.fileLocalPath);
      }

      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to delete all memos: $e'));
    }
  }
}
