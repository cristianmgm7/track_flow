import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_context_cubit.dart';
import '../bloc/audio_context_state.dart';

/// Track info display with business context integration
/// Shows collaborator, project, and track metadata using AudioContextCubit
/// Separated from pure audio player to maintain SOLID principles
class TrackInfoDisplay extends StatelessWidget {
  const TrackInfoDisplay({
    super.key,
    this.padding = const EdgeInsets.all(16.0),
    this.showCollaborator = true,
    this.showProject = true,
    this.showTags = true,
    this.showUploadDate = true,
    this.backgroundColor,
    this.borderRadius = 8.0,
  });

  final EdgeInsetsGeometry padding;
  final bool showCollaborator;
  final bool showProject;
  final bool showTags;
  final bool showUploadDate;
  final Color? backgroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AudioContextCubit, AudioContextState>(
      builder: (context, state) {
        if (state is AudioContextLoading) {
          return _buildLoadingState(context, theme);
        }

        if (state is AudioContextLoaded) {
          return _buildLoadedState(context, state, theme);
        }

        if (state is AudioContextError) {
          return _buildErrorState(context, state, theme);
        }

        if (state is AudioContextNotFound) {
          return _buildNotFoundState(context, state, theme);
        }

        // Initial state - no context
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading track info...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    AudioContextLoaded state,
    ThemeData theme,
  ) {
    final context_ = state.context;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collaborator info
          if (showCollaborator && context_.collaborator != null) ...[
            _buildCollaboratorRow(context_.collaborator!, theme),
            const SizedBox(height: 8),
          ],

          // Project info
          if (showProject && context_.projectName != null) ...[
            _buildProjectRow(context_.projectName!, theme),
            const SizedBox(height: 8),
          ],

          // Upload date
          if (showUploadDate && context_.uploadedAt != null) ...[
            _buildUploadDateRow(context_.uploadedAt!, theme),
            const SizedBox(height: 8),
          ],

          // Tags
          if (showTags && context_.tags != null && context_.tags!.isNotEmpty) ...[
            _buildTagsRow(context_.tags!, theme),
            const SizedBox(height: 8),
          ],

          // Description
          if (context_.description != null && context_.description!.isNotEmpty) ...[
            _buildDescriptionRow(context_.description!, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AudioContextError state,
    ThemeData theme,
  ) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Failed to load track info',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Retry loading context
              if (state.trackId != null) {
                context.read<AudioContextCubit>().loadTrackContext(state.trackId!);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(
    BuildContext context,
    AudioContextNotFound state,
    ThemeData theme,
  ) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.primaryColor.withValues(alpha: 0.7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'No additional info available',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorRow(dynamic collaborator, ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundImage: collaborator.avatarUrl != null 
              ? NetworkImage(collaborator.avatarUrl!) 
              : null,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
          child: collaborator.avatarUrl == null 
              ? Icon(
                  Icons.person,
                  size: 14,
                  color: theme.primaryColor,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                collaborator.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (collaborator.role != null)
                Text(
                  collaborator.role!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectRow(String projectName, ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.folder,
          size: 16,
          color: theme.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            projectName,
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadDateRow(DateTime uploadedAt, ThemeData theme) {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);
    String timeAgo;

    if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}m ago';
    } else {
      timeAgo = 'Just now';
    }

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: theme.primaryColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Text(
          'Uploaded $timeAgo',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow(List<String> tags, ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags.take(3).map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tag,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.primaryColor,
            fontSize: 11,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDescriptionRow(String description, ThemeData theme) {
    return Text(
      description,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
        fontStyle: FontStyle.italic,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}