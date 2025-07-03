import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@Injectable(as: MagicLinkRepository)
class MagicLinkRepositoryImp extends MagicLinkRepository {
  final MagicLinkRemoteDataSource _magicLinkRemoteDataSource;

  MagicLinkRepositoryImp(this._magicLinkRemoteDataSource);

  @override
  Future<Either<Failure, MagicLink>> generateMagicLink({
    required ProjectId projectId,
    required UserId userId,
  }) async {
    return await _magicLinkRemoteDataSource.generateMagicLink(
      projectId: projectId.value,
      userId: userId.value,
    );
  }

  @override
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required MagicLinkId linkId,
  }) async {
    return await _magicLinkRemoteDataSource.validateMagicLink(linkId: linkId.value);
  }

  @override
  Future<Either<Failure, Unit>> consumeMagicLink({
    required MagicLinkId linkId,
  }) async {
    return await _magicLinkRemoteDataSource.consumeMagicLink(linkId: linkId.value);
  }

  @override
  Future<Either<Failure, Unit>> resendMagicLink({
    required MagicLinkId linkId,
  }) async {
    return await _magicLinkRemoteDataSource.resendMagicLink(linkId: linkId.value);
  }

  @override
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required MagicLinkId linkId,
  }) async {
    return await _magicLinkRemoteDataSource.getMagicLinkStatus(linkId: linkId.value);
  }
}
