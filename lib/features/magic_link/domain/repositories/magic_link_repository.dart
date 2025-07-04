import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';

abstract class MagicLinkRepository {
  Future<Either<Failure, MagicLink>> generateMagicLink({
    required String projectId,
    required String userId,
  });
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required String linkId,
  });
  Future<Either<Failure, Unit>> consumeMagicLink({required String linkId});
  Future<Either<Failure, Unit>> resendMagicLink({required String linkId});
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required String linkId,
  });
}
