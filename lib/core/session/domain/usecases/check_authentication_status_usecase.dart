import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';

@injectable
class CheckAuthenticationStatusUseCase {
  final AuthRepository _authRepository;

  CheckAuthenticationStatusUseCase(this._authRepository);

  /// Check if user is currently authenticated
  Future<Either<Failure, bool>> call() async {
    return await _authRepository.isLoggedIn();
  }
}