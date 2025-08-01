import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/notifications/domain/entities/notification_id.dart';

enum NotificationType {
  projectInvitation,
  projectUpdate,
  collaboratorJoined,
  audioCommentAdded,
  audioTrackUploaded,
  systemMessage,
  // ... other notification types
}

class Notification extends Entity<NotificationId> {
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic> payload; // Contains feature-specific data
  final bool isRead;
  final UserId recipientUserId;

  const Notification({
    required NotificationId id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.payload,
    required this.isRead,
    required this.recipientUserId,
  }) : super(id);

  // Domain methods
  bool get isUnread => !isRead;
  bool get isProjectInvitation => type == NotificationType.projectInvitation;

  Notification markAsRead() {
    return copyWith(isRead: true);
  }

  Notification markAsUnread() {
    return copyWith(isRead: false);
  }

  // Helper getters for common payload data
  String? get invitationId {
    if (isProjectInvitation) {
      return payload['invitationId'] as String?;
    }
    return null;
  }

  String? get projectId {
    if (type == NotificationType.projectInvitation ||
        type == NotificationType.projectUpdate ||
        type == NotificationType.collaboratorJoined) {
      return payload['projectId'] as String?;
    }
    return null;
  }

  String? get inviterName {
    if (isProjectInvitation) {
      return payload['inviterName'] as String?;
    }
    return null;
  }

  Notification copyWith({
    NotificationId? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    Map<String, dynamic>? payload,
    bool? isRead,
    UserId? recipientUserId,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      recipientUserId: recipientUserId ?? this.recipientUserId,
    );
  }

  List<Object?> get props => [
    id,
    type,
    title,
    body,
    timestamp,
    payload,
    isRead,
    recipientUserId,
  ];
}
