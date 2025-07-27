import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/invitations/domain/entities/notification_id.dart';

enum NotificationType {
  projectInvitation,
  projectUpdate,
  collaboratorJoined,
  audioCommentAdded,
  audioTrackUploaded,
  // ... other notification types
}

class NotificationEntity extends Entity<NotificationId> {
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final Map<String, dynamic> payload; // Contains invitation data
  final bool isRead;
  final UserId recipientUserId;

  const NotificationEntity({
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

  NotificationEntity markAsRead() {
    return copyWith(isRead: true);
  }

  NotificationEntity markAsUnread() {
    return copyWith(isRead: false);
  }

  String? get invitationId {
    if (isProjectInvitation) {
      return payload['invitationId'] as String?;
    }
    return null;
  }

  String? get projectId {
    if (isProjectInvitation) {
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

  NotificationEntity copyWith({
    NotificationId? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? timestamp,
    Map<String, dynamic>? payload,
    bool? isRead,
    UserId? recipientUserId,
  }) {
    return NotificationEntity(
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

  @override
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

// Factory methods for common notification types
extension NotificationEntityFactory on NotificationEntity {
  static NotificationEntity createProjectInvitation({
    required NotificationId id,
    required UserId recipientUserId,
    required String invitationId,
    required String projectId,
    required String projectName,
    required String inviterName,
    required String inviterEmail,
  }) {
    return NotificationEntity(
      id: id,
      type: NotificationType.projectInvitation,
      title: 'You have been invited!',
      body: '$inviterName invited you to collaborate on "$projectName"',
      timestamp: DateTime.now(),
      payload: {
        'invitationId': invitationId,
        'projectId': projectId,
        'projectName': projectName,
        'inviterName': inviterName,
        'inviterEmail': inviterEmail,
      },
      isRead: false,
      recipientUserId: recipientUserId,
    );
  }

  static NotificationEntity createProjectUpdate({
    required NotificationId id,
    required UserId recipientUserId,
    required String projectId,
    required String projectName,
    required String updateMessage,
  }) {
    return NotificationEntity(
      id: id,
      type: NotificationType.projectUpdate,
      title: 'Project Updated',
      body: updateMessage,
      timestamp: DateTime.now(),
      payload: {'projectId': projectId, 'projectName': projectName},
      isRead: false,
      recipientUserId: recipientUserId,
    );
  }

  static NotificationEntity createCollaboratorJoined({
    required NotificationId id,
    required UserId recipientUserId,
    required String projectId,
    required String projectName,
    required String collaboratorName,
  }) {
    return NotificationEntity(
      id: id,
      type: NotificationType.collaboratorJoined,
      title: 'New Collaborator',
      body: '$collaboratorName joined "$projectName"',
      timestamp: DateTime.now(),
      payload: {
        'projectId': projectId,
        'projectName': projectName,
        'collaboratorName': collaboratorName,
      },
      isRead: false,
      recipientUserId: recipientUserId,
    );
  }
}
