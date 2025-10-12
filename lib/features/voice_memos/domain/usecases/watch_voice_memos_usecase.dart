import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

/// Watch all voice memos with reactive updates
@lazySingleton
class WatchVoiceMemosUseCase {
  final VoiceMemoRepository _repository;

  WatchVoiceMemosUseCase(this._repository);

  Stream<Either<Failure, List<VoiceMemo>>> call() {
    return _repository.watchAllMemos();
  }
}
