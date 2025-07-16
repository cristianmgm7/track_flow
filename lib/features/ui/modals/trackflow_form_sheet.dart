import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

/// TrackFlow Form Sheet - parte del sistema de diseño
///
/// Uso recomendado:
/// ```dart
/// showTrackFlowFormSheet(
///   context: context,
///   title: 'Crear Proyecto',
///   child: MyFormWidget(),
/// );
/// ```
Future<T?> showTrackFlowFormSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  double initialChildSize = 0.9,
  double minChildSize = 0.5,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool useRootNavigator = false,
}) {
  return showAppFormSheet<T>(
    context: context,
    child: child,
    title: title,
    initialChildSize: initialChildSize,
    minChildSize: minChildSize,
    maxChildSize: maxChildSize,
    isDismissible: isDismissible,
    useRootNavigator: useRootNavigator,
  );
}

/// Función base del sistema de diseño (para uso interno)
Future<T?> showAppFormSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  double initialChildSize = 0.9,
  double minChildSize = 0.5,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return _AppFormSheetContent(
            title: title,
            scrollController: scrollController,
            child: child,
          );
        },
      );
    },
  );
}

class _AppFormSheetContent extends StatelessWidget {
  final Widget child;
  final String? title;
  final ScrollController scrollController;

  const _AppFormSheetContent({
    required this.child,
    this.title,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: Dimensions.space12),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              if (title != null)
                Text(title!, style: theme.textTheme.titleLarge),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.space24),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: child,
            ),
          ),
          const SizedBox(height: Dimensions.space32),
        ],
      ),
    );
  }
}
