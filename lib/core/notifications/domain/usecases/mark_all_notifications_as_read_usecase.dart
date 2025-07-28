import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/session/current_user_service.dart';

/// Use case to mark all notifications as read for a user
@injectable
class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository _notificationRepository;
  final CurrentUserService _currentUserService;

  MarkAllNotificationsAsReadUseCase({
    required NotificationRepository notificationRepository,
    required CurrentUserService currentUserService,
  }) : _notificationRepository = notificationRepository,
       _currentUserService = currentUserService;

  /// Mark all notifications as read for current user
  /// Returns success or failure
  Future<Either<Failure, Unit>> call() async {
    try {
      final currentUserId = await _currentUserService.getCurrentUserIdOrThrow();
      return await _notificationRepository.markAllAsRead(currentUserId);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
