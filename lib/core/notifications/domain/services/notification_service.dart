import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';
import 'package:trackflow/core/notifications/domain/repositories/notification_repository.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Core notification service that other features can inject and use
/// Provides high-level methods for creating common notification types
@lazySingleton
class NotificationService {
  final NotificationRepository _repository;

  NotificationService(this._repository);

  /// Create a project invitation notification
  Future<void> createProjectInvitationNotification({
    required UserId recipientId,
    required String invitationId,
    required String projectId,
    required String projectName,
    required String inviterName,
    String? inviterEmail,
  }) async {
    await createNotification(
      type: NotificationType.projectInvitation,
      title: 'You have been invited!',
      body: '$inviterName invited you to collaborate on "$projectName"',
      recipientId: recipientId,
      payload: {
        'invitationId': invitationId,
        'projectId': projectId,
        'projectName': projectName,
        'inviterName': inviterName,
        'inviterEmail': inviterEmail,
      },
    );
  }

  /// Create a collaborator joined notification
  Future<void> createCollaboratorJoinedNotification({
    required UserId recipientId,
    required String projectId,
    required String projectName,
    required String collaboratorName,
  }) async {
    await createNotification(
      type: NotificationType.collaboratorJoined,
      title: 'New Collaborator',
      body: '$collaboratorName joined "$projectName"',
      recipientId: recipientId,
      payload: {
        'projectId': projectId,
        'projectName': projectName,
        'collaboratorName': collaboratorName,
      },
    );
  }

  /// Create a project update notification
  Future<void> createProjectUpdateNotification({
    required UserId recipientId,
    required String projectId,
    required String projectName,
    required String updateMessage,
  }) async {
    await createNotification(
      type: NotificationType.projectUpdate,
      title: 'Project Updated',
      body: updateMessage,
      recipientId: recipientId,
      payload: {
        'projectId': projectId,
        'projectName': projectName,
        'updateMessage': updateMessage,
      },
    );
  }

  /// Create an audio comment notification
  Future<void> createAudioCommentNotification({
    required UserId recipientId,
    required String trackId,
    required String trackName,
    required String commenterName,
    String? commentText,
  }) async {
    await createNotification(
      type: NotificationType.audioCommentAdded,
      title: 'New Comment',
      body:
          commentText != null
              ? '$commenterName commented: "$commentText"'
              : '$commenterName commented on "$trackName"',
      recipientId: recipientId,
      payload: {
        'trackId': trackId,
        'trackName': trackName,
        'commenterName': commenterName,
        'commentText': commentText,
      },
    );
  }

  /// Create an audio track upload notification
  Future<void> createAudioTrackUploadNotification({
    required UserId recipientId,
    required String projectId,
    required String projectName,
    required String uploaderName,
    required String trackName,
  }) async {
    await createNotification(
      type: NotificationType.audioTrackUploaded,
      title: 'New Track Uploaded',
      body: '$uploaderName uploaded "$trackName" to "$projectName"',
      recipientId: recipientId,
      payload: {
        'projectId': projectId,
        'projectName': projectName,
        'uploaderName': uploaderName,
        'trackName': trackName,
      },
    );
  }

  /// Create a system message notification
  Future<void> createSystemMessageNotification({
    required UserId recipientId,
    required String title,
    required String message,
    Map<String, dynamic>? additionalPayload,
  }) async {
    await createNotification(
      type: NotificationType.systemMessage,
      title: title,
      body: message,
      recipientId: recipientId,
      payload: additionalPayload ?? {},
    );
  }

  /// Generic method for creating any notification
  /// Used by features that need custom notification types
  Future<void> createNotification({
    required NotificationType type,
    required String title,
    required String body,
    required UserId recipientId,
    required Map<String, dynamic> payload,
  }) async {
    final notification = Notification(
      id: NotificationId(),
      type: type,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      payload: payload,
      isRead: false,
      recipientUserId: recipientId,
    );

    final result = await _repository.createNotification(notification);

    result.fold((failure) {
      // Log the error for debugging
      AppLogger.error('Failed to create notification', error: failure);

      // Throw a more user-friendly exception
      throw Exception('Unable to create notification. Please try again later.');
    }, (notification) => AppLogger.info('Notification created: ${notification.id}'));
  }

  /// Mark a notification as read
  Future<void> markAsRead(NotificationId notificationId) async {
    final result = await _repository.markAsRead(notificationId);

    result.fold(
      (failure) =>
          throw Exception('Failed to mark notification as read: $failure'),
      (notification) =>
          AppLogger.info('Notification marked as read: ${notification.id}'),
    );
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(UserId userId) async {
    final result = await _repository.markAllAsRead(userId);

    result.fold(
      (failure) =>
          throw Exception('Failed to mark all notifications as read: $failure'),
      (_) => AppLogger.info('All notifications marked as read for user: $userId'),
    );
  }

  /// Get unread notifications count for a user
  Future<int> getUnreadCount(UserId userId) async {
    final result = await _repository.getUnreadNotificationsCount(userId);

    return result.fold(
      (failure) => throw Exception('Failed to get unread count: $failure'),
      (count) => count,
    );
  }
}
