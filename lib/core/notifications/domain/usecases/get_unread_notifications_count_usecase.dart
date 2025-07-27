import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Use case to get unread notifications count for a user
@lazySingleton
class GetUnreadNotificationsCountUseCase {
  final NotificationRepository _notificationRepository;

  GetUnreadNotificationsCountUseCase(this._notificationRepository);

  /// Get unread notifications count for a user
  /// Returns the count of unread notifications
  Future<Either<Failure, int>> call(UserId userId) {
    return _notificationRepository.getUnreadNotificationsCount(userId);
  }
}
