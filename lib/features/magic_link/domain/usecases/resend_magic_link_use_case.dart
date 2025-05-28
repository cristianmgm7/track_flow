import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/repositories/magic_link_repository.dart';

@immutable
class ResendMagicLinkParams extends Equatable {
  final String email;

  const ResendMagicLinkParams({required this.email});

  @override
  List<Object?> get props => [email];
}

@lazySingleton
class ResendMagicLinkUseCase {
  final MagicLinkRepository _repository;

  ResendMagicLinkUseCase(this._repository);

  Future<Either<Failure, void>> call(ResendMagicLinkParams params) async {
    return (await _repository.resendMagicLink(email: params.email)).map((_) {});
  }
}
