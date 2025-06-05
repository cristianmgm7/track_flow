import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@immutable
class GetMagicLinkStatusParams extends Equatable {
  final String linkId;

  const GetMagicLinkStatusParams({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

@lazySingleton
class GetMagicLinkStatusUseCase {
  final MagicLinkRepository _repository;

  GetMagicLinkStatusUseCase(this._repository);

  Future<Either<Failure, MagicLinkStatus>> call(
    GetMagicLinkStatusParams params,
  ) async {
    return await _repository.getMagicLinkStatus(linkId: params.linkId);
  }
}
