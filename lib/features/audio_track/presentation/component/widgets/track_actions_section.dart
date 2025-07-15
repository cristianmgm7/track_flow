import 'package:flutter/material.dart';

/// Configuration for track actions section
class TrackActionsConfig {
  final double cacheIconSize;
  final double cacheIconWidth;
  final double actionsButtonWidth;
  final Color actionsButtonColor;
  final String actionsTooltip;
  final double spacing;

  const TrackActionsConfig({
    this.cacheIconSize = 20.0,
    this.cacheIconWidth = 32.0,
    this.actionsButtonWidth = 40.0,
    this.actionsButtonColor = Colors.blueAccent,
    this.actionsTooltip = 'Actions',
    this.spacing = 4.0,
  });
}

/// Widget responsible only for track actions (cache icon and actions menu)
class TrackActionsSection extends StatelessWidget {
  final Widget cacheIcon;
  final VoidCallback? onActionsPressed;
  final Function(String)? onCacheSuccess;
  final Function(String)? onCacheError;
  final TrackActionsConfig config;

  const TrackActionsSection({
    super.key,
    required this.cacheIcon,
    this.onActionsPressed,
    this.onCacheSuccess,
    this.onCacheError,
    this.config = const TrackActionsConfig(),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cache icon
        SizedBox(
          width: config.cacheIconWidth,
          child: cacheIcon,
        ),
        SizedBox(width: config.spacing),
        // Actions button
        SizedBox(
          width: config.actionsButtonWidth,
          child: IconButton(
            icon: Icon(
              Icons.more_vert,
              color: config.actionsButtonColor,
            ),
            onPressed: onActionsPressed,
            tooltip: config.actionsTooltip,
            constraints: BoxConstraints(
              minWidth: config.actionsButtonWidth,
              minHeight: config.actionsButtonWidth,
            ),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}