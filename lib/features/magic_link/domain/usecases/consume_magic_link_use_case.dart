import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@immutable
class ConsumeMagicLinkParams extends Equatable {
  final String token;

  const ConsumeMagicLinkParams({required this.token});

  @override
  List<Object?> get props => [token];
}

@lazySingleton
class ConsumeMagicLinkUseCase {
  final MagicLinkRepository _repository;

  ConsumeMagicLinkUseCase(this._repository);

  Future<Either<Failure, void>> call(ConsumeMagicLinkParams params) async {
    return await _repository.consumeMagicLink(linkId: params.token);
  }
}
