import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';

/// Use case to observe notifications for a user
/// Returns a stream of notifications
@lazySingleton
class ObserveNotificationsUseCase {
  final NotificationRepository _notificationRepository;

  ObserveNotificationsUseCase(this._notificationRepository);

  /// Observe all notifications for a user
  /// Returns a stream of notifications
  Stream<Either<Failure, List<Notification>>> call(UserId userId) {
    return _notificationRepository.watchNotifications(userId);
  }
}
