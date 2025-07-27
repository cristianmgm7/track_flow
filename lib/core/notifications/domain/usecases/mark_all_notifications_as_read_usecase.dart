import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Use case to mark all notifications as read for a user
@lazySingleton
class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository _notificationRepository;

  MarkAllNotificationsAsReadUseCase(this._notificationRepository);

  /// Mark all notifications as read for a user
  /// Returns success or failure
  Future<Either<Failure, Unit>> call(UserId userId) {
    return _notificationRepository.markAllAsRead(userId);
  }
}
