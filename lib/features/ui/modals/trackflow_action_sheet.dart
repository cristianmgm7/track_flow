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
  final convertedActions =
      actions
          .map(
            (item) => AppBottomSheetAction(
              icon: item.icon,
              title: item.title,
              subtitle: item.subtitle,
              onTap: item.onTap,
              childSheetBuilder: item.childSheetBuilder,
            ),
          )
          .toList();

  // Usar el componente base del sistema de diseño
  return showAppActionSheet(
    context: context,
    actions: convertedActions,
    title: title,
    header: header,
    body: body,
  );
}

/// TrackFlow Content Modal - para modales con contenido personalizado que se ajustan al tamaño
///
/// Uso recomendado:
/// ```dart
/// showTrackFlowContentModal(
///   context: context,
///   title: 'Editar Rol',
///   child: RadioToUpdateCollaboratorRole(...),
/// );
/// ```
Future<T?> showTrackFlowContentModal<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  Widget? header,
  List<Widget>? actions,
  bool showHandle = true,
  bool showCloseButton = false,
  bool isDismissible = true,
  bool enableDrag = true,
  VoidCallback? onClose,
  EdgeInsetsGeometry? padding,
  Color? backgroundColor,
  BorderRadius? borderRadius,
  double? maxHeight,
}) {
  return showAppContentModal<T>(
    context: context,
    child: child,
    title: title,
    header: header,
    actions: actions,
    showHandle: showHandle,
    showCloseButton: showCloseButton,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    onClose: onClose,
    padding: padding,
    backgroundColor: backgroundColor,
    borderRadius: borderRadius,
    maxHeight: maxHeight,
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
