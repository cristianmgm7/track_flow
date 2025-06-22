import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

double _initialSize(int itemCount) {
  if (itemCount <= 3) return 0.3;
  if (itemCount <= 6) return 0.5;
  return 0.65;
}

Future<void> showTrackFlowActionSheet({
  required BuildContext context,
  required List<TrackFlowActionItem> actions,
  Widget? header,
  String? title,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: _initialSize(actions.length),
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return _TrackFlowActionSheetContent(
            title: title,
            header: header,
            actions: actions,
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

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

class _TrackFlowActionSheetContent extends StatelessWidget {
  final List<TrackFlowActionItem> actions;
  final String? title;
  final Widget? header;
  final ScrollController scrollController;

  const _TrackFlowActionSheetContent({
    required this.actions,
    this.title,
    this.header,
    required this.scrollController,
  });

  void _handleTap(BuildContext context, TrackFlowActionItem item) {
    Navigator.of(context).pop();
    if (item.childSheetBuilder != null) {
      showTrackFlowActionSheet(
        context: context,
        title: item.title,
        actions: const [],
        header: item.childSheetBuilder!(context),
      );
    } else {
      item.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: Dimensions.space8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(title!, style: theme.textTheme.titleMedium),
            ),
          if (header != null)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: header),
          if (title != null || header != null) const Divider(height: 0.2),
          ...actions.map((item) {
            final isNavigable = item.childSheetBuilder != null;
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: isNavigable ? const Icon(Icons.chevron_right) : null,
              onTap: () => _handleTap(context, item),
            );
          }),
        ],
      ),
    );
  }
}
