import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';

@injectable
class MarkAsUnreadUseCase {
  final NotificationRepository _notificationRepository;

  MarkAsUnreadUseCase(this._notificationRepository);

  Future<Either<Failure, Notification>> call(
    NotificationId notificationId,
  ) async {
    return await _notificationRepository.markAsUnread(notificationId);
  }
}
