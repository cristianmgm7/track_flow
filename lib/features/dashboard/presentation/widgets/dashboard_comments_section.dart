import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_comment/presentation/models/audio_comment_ui_model.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:trackflow/features/dashboard/presentation/widgets/dashboard_comment_item.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

class DashboardCommentsSection extends StatelessWidget {
  final List<AudioCommentUiModel> comments;

  const DashboardCommentsSection({
    super.key,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DashboardSectionHeader(
          title: 'Recent Comments',
          onSeeAll: null, // No "See All" for comments
        ),
        SizedBox(height: Dimensions.space12),
        if (comments.isEmpty)
          _buildEmptyState(context)
        else
          _buildCommentsList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.space24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.comment_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: Dimensions.space12),
            Text(
              'No comments yet. Leave a comment on a track to get started!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.warning,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.space16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: comments.length,
        separatorBuilder: (context, index) => Divider(
          height: Dimensions.space16,
        ),
        itemBuilder: (context, index) {
          final comment = comments[index];
          return DashboardCommentItem(comment: comment);
        },
      ),
    );
  }
}

