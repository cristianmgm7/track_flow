import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/components/modals/app_bottom_sheet.dart';

// Convenience function that maintains backward compatibility
Future<void> showTrackFlowActionSheet({
  required BuildContext context,
  required List<TrackFlowActionItem> actions,
  Widget? header,
  String? title,
  Widget? body,
}) {
  // Convert TrackFlowActionItem to AppBottomSheetAction
  final convertedActions = actions.map((item) => AppBottomSheetAction(
    icon: item.icon,
    title: item.title,
    subtitle: item.subtitle,
    onTap: item.onTap,
    childSheetBuilder: item.childSheetBuilder,
  )).toList();

  return showAppActionSheet(
    context: context,
    actions: convertedActions,
    title: title,
    header: header,
    body: body,
  );
}

// Keep backward compatibility with existing TrackFlowActionItem
class TrackFlowActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget Function(BuildContext)? childSheetBuilder;

  TrackFlowActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.childSheetBuilder,
  });
}
