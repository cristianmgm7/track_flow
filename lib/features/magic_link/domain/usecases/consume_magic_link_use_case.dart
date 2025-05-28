import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@immutable
class ConsumeMagicLinkParams extends Equatable {
  final String linkId;

  const ConsumeMagicLinkParams({required this.linkId});

  @override
  List<Object?> get props => [linkId];
}

@lazySingleton
class ConsumeMagicLinkUseCase {
  final MagicLinkRepository _repository;

  ConsumeMagicLinkUseCase(this._repository);

  Future<Either<Failure, void>> call(ConsumeMagicLinkParams params) async {
    return await _repository.consumeMagicLink(params.linkId);
  }
}
