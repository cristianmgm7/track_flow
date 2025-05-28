import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';

abstract class MagicLinkLocalDataSource {
  Future<Either<Failure, MagicLink>> cacheMagicLink({required UserId userId});
  Future<Either<Failure, MagicLink>> getCachedMagicLink({
    required UserId userId,
  });
  Future<Either<Failure, Unit>> clearCachedMagicLink({required UserId userId});
}
