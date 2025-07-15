import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/data/datasources/magic_link_remote_data_source.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_request_dto.dart';
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
    final request = MagicLinkRequestDto(
      projectId: projectId.value,
      userId: userId.value,
    );
    
    final result = await _magicLinkRemoteDataSource.generateMagicLink(request);
    
    return result.fold(
      (failure) => Left(failure),
      (dto) => Right(dto.toDomain()),
    );
  }

  @override
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required MagicLinkId linkId,
  }) async {
    final validation = MagicLinkValidationDto(linkId: linkId.value);
    final result = await _magicLinkRemoteDataSource.validateMagicLink(validation);
    
    return result.fold(
      (failure) => Left(failure),
      (dto) => Right(dto.toDomain()),
    );
  }

  @override
  Future<Either<Failure, Unit>> consumeMagicLink({
    required MagicLinkId linkId,
  }) async {
    final validation = MagicLinkValidationDto(linkId: linkId.value);
    return await _magicLinkRemoteDataSource.consumeMagicLink(validation);
  }

  @override
  Future<Either<Failure, Unit>> resendMagicLink({
    required MagicLinkId linkId,
  }) async {
    final validation = MagicLinkValidationDto(linkId: linkId.value);
    return await _magicLinkRemoteDataSource.resendMagicLink(validation);
  }

  @override
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required MagicLinkId linkId,
  }) async {
    final status = MagicLinkStatusDto(linkId: linkId.value);
    final result = await _magicLinkRemoteDataSource.getMagicLinkStatus(status);
    
    return result.fold(
      (failure) => Left(failure),
      (statusString) => Right(MagicLinkStatus.values.firstWhere(
        (status) => status.toString().split('.').last == statusString,
        orElse: () => MagicLinkStatus.valid,
      )),
    );
  }
}
