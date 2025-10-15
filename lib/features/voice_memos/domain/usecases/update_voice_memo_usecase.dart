import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

/// Update voice memo (for rename)
@lazySingleton
class UpdateVoiceMemoUseCase {
  final VoiceMemoRepository _repository;

  UpdateVoiceMemoUseCase(this._repository);

  Future<Either<Failure, Unit>> call(VoiceMemo memo) async {
    return await _repository.updateMemo(memo);
  }
}
