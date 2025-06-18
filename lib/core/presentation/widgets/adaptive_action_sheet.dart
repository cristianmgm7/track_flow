import 'package:flutter/material.dart';

Future<void> showTrackFlowActionSheet({
  required BuildContext context,
  required List<TrackFlowActionItem> actions,
  String? title,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: true,
    builder: (context) {
      return _TrackFlowActionSheetContent(title: title, actions: actions);
    },
  );
}

class TrackFlowActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  TrackFlowActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _TrackFlowActionSheetContent extends StatelessWidget {
  final List<TrackFlowActionItem> actions;
  final String? title;

  const _TrackFlowActionSheetContent({
    super.key,
    required this.actions,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surface;

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra superior para arrastrar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[500],
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(title!, style: theme.textTheme.titleMedium),
            ),

          // Lista de acciones
          ...actions.map(
            (item) => ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              onTap: () {
                Navigator.of(context).pop();
                item.onTap();
              },
            ),
          ),
        ],
      ),
    );
  }
}
