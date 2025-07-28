import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';

@injectable
class DeleteNotificationUseCase {
  final NotificationRepository _notificationRepository;

  DeleteNotificationUseCase(this._notificationRepository);

  Future<Either<Failure, Unit>> call(NotificationId notificationId) async {
    return await _notificationRepository.deleteNotification(notificationId);
  }
}
