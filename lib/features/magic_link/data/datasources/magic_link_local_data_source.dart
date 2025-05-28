import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';

@lazySingleton
abstract class MagicLinkLocalDataSource {
  Future<Either<Failure, MagicLink>> cacheMagicLink({required UserId userId});
  Future<Either<Failure, MagicLink>> getCachedMagicLink({
    required UserId userId,
  });
  Future<Either<Failure, Unit>> clearCachedMagicLink({required UserId userId});
}

@Injectable(as: MagicLinkLocalDataSource)
class MagicLinkLocalDataSourceImpl extends MagicLinkLocalDataSource {
  MagicLinkLocalDataSourceImpl();

  @override
  Future<Either<Failure, MagicLink>> cacheMagicLink({required UserId userId}) {
    // TODO: implement cacheMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MagicLink>> getCachedMagicLink({
    required UserId userId,
  }) {
    // TODO: implement getCachedMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> clearCachedMagicLink({required UserId userId}) {
    // TODO: implement clearCachedMagicLink
    throw UnimplementedError();
  }
}
