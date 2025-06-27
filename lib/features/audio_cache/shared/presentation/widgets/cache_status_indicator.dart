import 'package:flutter/material.dart';

import '../../domain/entities/cached_audio.dart';

class CacheStatusIndicator extends StatelessWidget {
  final CacheStatus status;
  final double size;
  final Color? color;
  final bool showLabel;
  final bool showBackground;

  const CacheStatusIndicator({
    super.key,
    required this.status,
    this.size = 16.0,
    this.color,
    this.showLabel = false,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.primaryColor;

    Widget indicator = _buildStatusIcon(effectiveColor);

    if (showBackground) {
      indicator = Container(
        padding: EdgeInsets.all(size * 0.2),
        decoration: BoxDecoration(
          color: _getBackgroundColor(effectiveColor),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: indicator,
      );
    }

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(width: size * 0.3),
          Text(
            _getStatusLabel(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getStatusColor(effectiveColor),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return indicator;
  }

  Widget _buildStatusIcon(Color effectiveColor) {
    switch (status) {
      case CacheStatus.cached:
        return Icon(
          Icons.download_done,
          color: Colors.green,
          size: size,
        );
      
      case CacheStatus.downloading:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: size * 0.15,
            color: effectiveColor,
          ),
        );
      
      case CacheStatus.failed:
        return Icon(
          Icons.error_outline,
          color: Colors.red,
          size: size,
        );
      
      case CacheStatus.notCached:
      default:
        return Icon(
          Icons.download_outlined,
          color: effectiveColor.withValues(alpha: 0.6),
          size: size,
        );
    }
  }

  Color _getStatusColor(Color effectiveColor) {
    switch (status) {
      case CacheStatus.cached:
        return Colors.green;
      case CacheStatus.downloading:
        return effectiveColor;
      case CacheStatus.failed:
        return Colors.red;
      case CacheStatus.notCached:
      default:
        return effectiveColor.withValues(alpha: 0.6);
    }
  }

  Color _getBackgroundColor(Color effectiveColor) {
    switch (status) {
      case CacheStatus.cached:
        return Colors.green.withValues(alpha: 0.1);
      case CacheStatus.downloading:
        return effectiveColor.withValues(alpha: 0.1);
      case CacheStatus.failed:
        return Colors.red.withValues(alpha: 0.1);
      case CacheStatus.notCached:
      default:
        return effectiveColor.withValues(alpha: 0.05);
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case CacheStatus.cached:
        return 'Cached';
      case CacheStatus.downloading:
        return 'Downloading';
      case CacheStatus.failed:
        return 'Failed';
      case CacheStatus.notCached:
      default:
        return 'Not cached';
    }
  }
}