import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Value object that encapsulates all information needed to render a cache icon
class CacheIconData extends Equatable {
  const CacheIconData({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.showBadge = false,
    this.badgeText,
    this.badgeColor,
    this.isLoading = false,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final bool showBadge;
  final String? badgeText;
  final Color? badgeColor;
  final bool isLoading;

  /// Factory for not cached state
  factory CacheIconData.notCached() {
    return const CacheIconData(
      icon: Icons.cloud_off,
      color: Colors.grey,
      tooltip: 'Not cached',
    );
  }

  /// Factory for fully cached state
  factory CacheIconData.fullyCached({required String tooltip}) {
    return CacheIconData(
      icon: Icons.cloud_done,
      color: Colors.green,
      tooltip: tooltip,
    );
  }

  /// Factory for partially cached state with badge
  factory CacheIconData.partiallyCached({
    required String tooltip,
    required String badgeText,
  }) {
    return CacheIconData(
      icon: Icons.cloud_sync,
      color: Colors.orange,
      tooltip: tooltip,
      showBadge: true,
      badgeText: badgeText,
      badgeColor: Colors.orange,
    );
  }

  /// Factory for downloading state
  factory CacheIconData.downloading({required String tooltip}) {
    return CacheIconData(
      icon: Icons.cloud_download,
      color: Colors.blue,
      tooltip: tooltip,
      isLoading: true,
    );
  }

  /// Factory for failed state
  factory CacheIconData.failed({required String tooltip}) {
    return CacheIconData(
      icon: Icons.error,
      color: Colors.red,
      tooltip: tooltip,
    );
  }

  /// Factory for loading state
  factory CacheIconData.loading() {
    return const CacheIconData(
      icon: Icons.cloud_off,
      color: Colors.grey,
      tooltip: 'Loading...',
      isLoading: true,
    );
  }

  @override
  List<Object?> get props => [
        icon,
        color,
        tooltip,
        showBadge,
        badgeText,
        badgeColor,
        isLoading,
      ];
}