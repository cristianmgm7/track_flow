import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/domain/services/session_service.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Use case to get current user data (ID and email)
/// This follows Clean Architecture by encapsulating the logic to get user data
/// without exposing domain services to the presentation layer
@injectable
class GetCurrentUserDataUseCase {
  final SessionService _sessionService;

  GetCurrentUserDataUseCase(this._sessionService);

  /// Returns the current user's ID and email
  /// Returns null for both if user is not authenticated
  Future<Either<Failure, ({UserId? userId, String? email})>> call() async {
    try {
      AppLogger.info(
        'Getting current user data from session service',
        tag: 'GET_CURRENT_USER_DATA',
      );

      final sessionResult = await _sessionService.getCurrentSession();

      return sessionResult.fold(
        (failure) {
          AppLogger.error(
            'Failed to get current user data: ${failure.message}',
            tag: 'GET_CURRENT_USER_DATA',
          );
          return Left(failure);
        },
        (session) {
          if (session.currentUser != null) {
            final userId = session.currentUser!.id;
            final email = session.currentUser!.email;

            AppLogger.info(
              'Successfully retrieved user data - userId: $userId, email: $email',
              tag: 'GET_CURRENT_USER_DATA',
            );

            return Right((userId: userId, email: email));
          } else {
            AppLogger.warning(
              'Session exists but no user data available',
              tag: 'GET_CURRENT_USER_DATA',
            );
            return Right((userId: null, email: null));
          }
        },
      );
    } catch (e) {
      AppLogger.error(
        'Exception getting current user data: $e',
        tag: 'GET_CURRENT_USER_DATA',
      );
      return Left(DatabaseFailure('Failed to get current user data: $e'));
    }
  }
}
