import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_dto.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_cache_dto.dart';

abstract class MagicLinkLocalDataSource {
  Future<Either<Failure, MagicLinkDto>> cacheMagicLink(
    MagicLinkCacheRequestDto request,
  );
  Future<Either<Failure, MagicLinkDto>> getCachedMagicLink(
    MagicLinkCacheQueryDto query,
  );
  Future<Either<Failure, Unit>> clearCachedMagicLink(
    MagicLinkCacheQueryDto query,
  );
}

@LazySingleton(as: MagicLinkLocalDataSource)
class MagicLinkLocalDataSourceImpl extends MagicLinkLocalDataSource {
  MagicLinkLocalDataSourceImpl();

  @override
  Future<Either<Failure, MagicLinkDto>> cacheMagicLink(
    MagicLinkCacheRequestDto request,
  ) {
    // TODO: implement cacheMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MagicLinkDto>> getCachedMagicLink(
    MagicLinkCacheQueryDto query,
  ) {
    // TODO: implement getCachedMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> clearCachedMagicLink(
    MagicLinkCacheQueryDto query,
  ) {
    // TODO: implement clearCachedMagicLink
    throw UnimplementedError();
  }
}
