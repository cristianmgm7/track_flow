import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:trackflow/core/app_flow/domain/services/session_cleanup_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@lazySingleton
class SignOutUseCase {
  final AuthRepository _authRepository;
  final SessionCleanupService _sessionCleanupService;

  SignOutUseCase(this._authRepository, this._sessionCleanupService);

  Future<Either<Failure, Unit>> call() async {
    try {
      AppLogger.info(
        'Starting sign out process',
        tag: 'SIGN_OUT_USE_CASE',
      );

      // Step 1: Comprehensive session cleanup FIRST
      // This clears SessionStorage immediately preventing race conditions
      AppLogger.info(
        'Starting comprehensive session cleanup (including SessionStorage)',
        tag: 'SIGN_OUT_USE_CASE',
      );
      
      final cleanupResult = await _sessionCleanupService.clearAllUserData();
      
      // Log cleanup result but don't fail logout if cleanup has issues
      cleanupResult.fold(
        (failure) {
          AppLogger.warning(
            'Session cleanup partially failed during manual logout: ${failure.message}',
            tag: 'SIGN_OUT_USE_CASE',
          );
        },
        (_) {
          AppLogger.info(
            'Session cleanup completed successfully during manual logout',
            tag: 'SIGN_OUT_USE_CASE',
          );
        },
      );

      // Step 2: Perform authentication logout (Firebase only, SessionStorage already cleared)
      AppLogger.info(
        'Performing Firebase authentication logout',
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