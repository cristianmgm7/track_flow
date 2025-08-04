import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@lazySingleton
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<Either<Failure, Unit>> call() async {
    try {
      AppLogger.info('Starting sign out process', tag: 'SIGN_OUT_USE_CASE');

      // ✅ FIXED: Only perform Firebase logout, let AppFlowBloc handle cleanup
      // This prevents duplicate cleanup calls (manual + auth stream reaction)
      AppLogger.info(
        'Performing Firebase authentication logout (cleanup handled by AppFlowBloc)',
        tag: 'SIGN_OUT_USE_CASE',
      );

      final authResult = await _authRepository.signOut();

      AppLogger.info(
        'Sign out process completed successfully',
        tag: 'SIGN_OUT_USE_CASE',
      );

      return authResult;
    } catch (e) {
      AppLogger.error(
        'Sign out process failed: $e',
        tag: 'SIGN_OUT_USE_CASE',
        error: e,
      );
      return Left(AuthenticationFailure('Failed to sign out: $e'));
    }
  }
}
