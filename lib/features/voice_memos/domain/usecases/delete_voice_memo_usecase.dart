import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/entities/unique_id.dart';
import '../repositories/voice_memo_repository.dart';

/// Delete a voice memo and its audio file
@lazySingleton
class DeleteVoiceMemoUseCase {
  final VoiceMemoRepository _repository;

  DeleteVoiceMemoUseCase(this._repository);

  Future<Either<Failure, Unit>> call(VoiceMemoId memoId) async {
    return await _repository.deleteMemo(memoId);
  }
}
