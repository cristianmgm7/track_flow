import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@Injectable(as: MagicLinkRepository)
class MagicLinkImpl extends MagicLinkRepository {
  final MagicLinkRemoteDataSource _magicLinkRemoteDataSource;
  final MagicLinkLocalDataSource _magicLinkLocalDataSource;

  MagicLinkImpl(
    this._magicLinkRemoteDataSource,
    this._magicLinkLocalDataSource,
  );

  @override
  Future<Either<Failure, MagicLink>> generateMagicLink({
    required UserId userId,
  }) async {
    return await _magicLinkRemoteDataSource.generateMagicLink(email);
  }

  @override
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required String linkId,
  }) async {
    return await _magicLinkRemoteDataSource.validateMagicLink(linkId);
  }

  @override
  Future<Either<Failure, Unit>> consumeMagicLink({
    required String linkId,
  }) async {
    return await _magicLinkRemoteDataSource.consumeMagicLink(linkId);
  }

  @override
  Future<Either<Failure, Unit>> resendMagicLink({required String email}) async {
    return await _magicLinkRemoteDataSource.resendMagicLink(email);
  }

  @override
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required String linkId,
  }) async {
    return await _magicLinkRemoteDataSource.getMagicLinkStatus(linkId);
  }
}
