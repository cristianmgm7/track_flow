import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';

abstract class MagicLinkRepository {
  Future<Either<Failure, MagicLink>> generateMagicLink({
    required ProjectId projectId,
    required UserId userId,
  });
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required MagicLinkId linkId,
  });
  Future<Either<Failure, Unit>> consumeMagicLink({required MagicLinkId linkId});
  Future<Either<Failure, Unit>> resendMagicLink({required MagicLinkId linkId});
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required MagicLinkId linkId,
  });
}
