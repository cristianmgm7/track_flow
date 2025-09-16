import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/ui/cards/base_card.dart';
import 'package:trackflow/features/ui/menus/app_popup_menu.dart';
import 'package:trackflow/core/notifications/domain/entities/notification.dart'
    as app_notification;

/// Card widget to display individual notification
class NotificationCard extends StatelessWidget {
  final app_notification.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final bool isLoading;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      onTap: onTap,
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: Dimensions.space12),
          Expanded(child: _buildContent()),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData = Icons.info; // Default value
    Color iconColor = AppColors.info; // Default value

    switch (notification.type) {
      case app_notification.NotificationType.projectInvitation:
        iconData = Icons.person_add;
        iconColor = AppColors.warning;
        break;
      case app_notification.NotificationType.projectUpdate:
        iconData = Icons.update;
        iconColor = AppColors.info;
        break;
      case app_notification.NotificationType.collaboratorJoined:
        iconData = Icons.group_add;
        iconColor = AppColors.success;
        break;
      case app_notification.NotificationType.audioCommentAdded:
        iconData = Icons.comment;
        iconColor = AppColors.primary;
        break;
      case app_notification.NotificationType.audioTrackUploaded:
        iconData = Icons.music_note;
        iconColor = AppColors.primary;
        break;
      case app_notification.NotificationType.systemMessage:
        iconData = Icons.info;
        iconColor = AppColors.info;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Icon(iconData, color: iconColor, size: Dimensions.iconMedium),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: AppTextStyle.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight:
                      notification.isUnread ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (notification.isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        SizedBox(height: Dimensions.space4),
        Text(
          notification.body,
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: Dimensions.space8),
        Text(
          _formatTimestamp(notification.timestamp),
          style: AppTextStyle.caption.copyWith(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return AppPopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: Dimensions.iconSmall,
      ),
      onSelected: (value) {
        switch (value) {
          case 'mark_read':
            onMarkAsRead?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      items: [
        AppPopupMenuItem<String>(
          value: 'mark_read',
          label: notification.isUnread ? 'Mark as read' : 'Mark as unread',
          icon:
              notification.isUnread
                  ? Icons.mark_email_read
                  : Icons.mark_email_unread,
        ),
        AppPopupMenuItem<String>(
          value: 'delete',
          label: 'Delete',
          icon: Icons.delete_outline,
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
