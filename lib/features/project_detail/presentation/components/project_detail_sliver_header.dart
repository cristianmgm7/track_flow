import 'package:flutter/material.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';
import 'package:trackflow/features/ui/project/project_cover_art.dart';
import 'package:trackflow/core/theme/app_text_style.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/ui/modals/app_bottom_sheet.dart';
import 'package:trackflow/features/project_detail/presentation/widgets/project_detail_actions_sheet.dart';

/// A sliver header for the project detail screen, showing the cover art as background
class ProjectDetailSliverHeader extends StatelessWidget {
  final Project project;
  final double expandedHeight;

  const ProjectDetailSliverHeader({
    super.key,
    required this.project,
    this.expandedHeight = 280,
  });

  void _openProjectDetailActionsSheet(BuildContext context) {
    showAppActionSheet(
      title: 'Project Actions',
      context: context,
      actions: ProjectDetailActions.forProject(context, project),
      sizeToContent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectName = project.name.value.fold((l) => '', (r) => r);
    final projectDescription = project.description.value.fold(
      (l) => '',
      (r) => r,
    );

    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: expandedHeight,
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final percent = ((constraints.maxHeight - kToolbarHeight) /
                  (expandedHeight - kToolbarHeight))
              .clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            children: [
              // Cover art as background
              ProjectCoverArt(
                projectName: projectName,
                projectDescription: projectDescription,
                imageUrl: null, // Replace with project.coverArtUrl if available
                size: expandedHeight,
                showShadow: false,
                borderRadius: BorderRadius.zero,
              ),
              // Gradient overlay for readability
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.black87,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              // Project info overlay
              Positioned(
                left: 24,
                right: 24,
                bottom: 32 + 16 * percent, // Animate up as it collapses
                child: Opacity(
                  opacity: percent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projectName,
                        style: AppTextStyle.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (projectDescription.isNotEmpty)
                        Text(
                          projectDescription,
                          style: AppTextStyle.bodyLarge.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ${project.createdAt.toString().split(' ')[0]}',
                            style: AppTextStyle.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => _openProjectDetailActionsSheet(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
