import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/domain/entities/notification_entity.dart';
import 'package:trackflow/features/invitations/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// Use case to observe notifications for a user
/// Returns a stream of notifications
@lazySingleton
class ObserveNotificationsUseCase {
  final NotificationRepository _notificationRepository;

  ObserveNotificationsUseCase(this._notificationRepository);

  /// Observe all notifications for a user
  /// Returns a stream of notifications
  Stream<Either<Failure, List<NotificationEntity>>> call(UserId userId) {
    return _notificationRepository.watchNotifications(userId);
  }
}
