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
      // ✅ ENHANCED: Use comprehensive session cleanup before auth logout
      final cleanupResult = await _sessionCleanupService.clearAllUserData();
      
      // Log cleanup result but don't fail logout if cleanup has issues
      cleanupResult.fold(
        (failure) {
          // Log warning but continue with logout
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

      // Perform authentication logout
      return await _authRepository.signOut();
    } catch (e) {
      return Left(AuthenticationFailure('Failed to sign out: $e'));
    }
  }
}