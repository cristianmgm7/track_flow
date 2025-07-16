import 'package:flutter/material.dart';
import 'app_bottom_sheet.dart';

/// TrackFlow Action Sheet - parte del sistema de diseño
/// 
/// Uso recomendado:
/// ```dart
/// showTrackFlowActionSheet(
///   context: context,
///   title: 'Opciones',
///   actions: [
///     TrackFlowActionItem(
///       icon: Icons.add,
///       title: 'Crear',
///       subtitle: 'Crear algo nuevo',
///       onTap: () => // acción
///     ),
///   ],
/// );
/// ```
Future<void> showTrackFlowActionSheet({
  required BuildContext context,
  required List<TrackFlowActionItem> actions,
  Widget? header,
  String? title,
  Widget? body,
}) {
  // Convertir TrackFlowActionItem a AppBottomSheetAction del sistema de diseño
  final convertedActions = actions.map((item) => AppBottomSheetAction(
    icon: item.icon,
    title: item.title,
    subtitle: item.subtitle,
    onTap: item.onTap,
    childSheetBuilder: item.childSheetBuilder,
  )).toList();

  // Usar el componente base del sistema de diseño
  return showAppActionSheet(
    context: context,
    actions: convertedActions,
    title: title,
    header: header,
    body: body,
  );
}

/// TrackFlow Action Item - compatible con el sistema de diseño
class TrackFlowActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget Function(BuildContext)? childSheetBuilder;

  const TrackFlowActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.childSheetBuilder,
  });
}