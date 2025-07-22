import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@injectable
class GetCurrentUserIdUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserIdUseCase(this._authRepository);

  /// Get the ID of the currently authenticated user
  Future<Either<Failure, UserId?>> call() async {
    final result = await _authRepository.getSignedInUserId();
    return result.fold(
      (failure) => Left(failure), 
      (userId) => Right(userId)
    );
  }
}