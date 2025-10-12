import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_memo.dart';
import '../../../../core/entities/unique_id.dart';

/// Repository contract for voice memo operations
abstract class VoiceMemoRepository {
  /// Watch all voice memos (sorted by recordedAt desc)
  Stream<Either<Failure, List<VoiceMemo>>> watchAllMemos();

  /// Get single memo by ID
  Future<Either<Failure, VoiceMemo?>> getMemoById(VoiceMemoId memoId);

  /// Save a new voice memo
  Future<Either<Failure, Unit>> saveMemo(VoiceMemo memo);

  /// Update existing memo (for rename)
  Future<Either<Failure, Unit>> updateMemo(VoiceMemo memo);

  /// Delete memo and its audio file
  Future<Either<Failure, Unit>> deleteMemo(VoiceMemoId memoId);

  /// Delete all memos (cleanup)
  Future<Either<Failure, Unit>> deleteAllMemos();
}
