import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';

/// Badge widget to display invitation status
class InvitationStatusBadge extends StatelessWidget {
  final InvitationStatus status;
  final double? size;

  const InvitationStatusBadge({super.key, required this.status, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.space8,
        vertical: Dimensions.space4,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: _getBorderColor(), width: 1),
      ),
      child: Text(
        _getStatusText(),
        style: AppTextStyle.caption.copyWith(
          color: _getTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case InvitationStatus.pending:
        return AppColors.warning.withOpacity(0.1);
      case InvitationStatus.accepted:
        return AppColors.success.withOpacity(0.1);
      case InvitationStatus.declined:
        return AppColors.error.withOpacity(0.1);
      case InvitationStatus.expired:
        return AppColors.disabled.withOpacity(0.1);
      case InvitationStatus.cancelled:
        return AppColors.grey700.withOpacity(0.1);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case InvitationStatus.pending:
        return AppColors.warning;
      case InvitationStatus.accepted:
        return AppColors.success;
      case InvitationStatus.declined:
        return AppColors.error;
      case InvitationStatus.expired:
        return AppColors.disabled;
      case InvitationStatus.cancelled:
        return AppColors.grey700;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case InvitationStatus.pending:
        return AppColors.warning;
      case InvitationStatus.accepted:
        return AppColors.success;
      case InvitationStatus.declined:
        return AppColors.error;
      case InvitationStatus.expired:
        return AppColors.disabled;
      case InvitationStatus.cancelled:
        return AppColors.grey700;
    }
  }

  String _getStatusText() {
    switch (status) {
      case InvitationStatus.pending:
        return 'Pending';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
      case InvitationStatus.cancelled:
        return 'Cancelled';
    }
  }
}
