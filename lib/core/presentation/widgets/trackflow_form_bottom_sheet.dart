import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';

Future<T?> showTrackFlowFormSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  double initialChildSize = 0.9,
  double minChildSize = 0.5,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool useRootNavigator = true,
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
          return _TrackFlowFormSheetContent(
            title: title,
            scrollController: scrollController,
            child: child,
          );
        },
      );
    },
  );
}

class _TrackFlowFormSheetContent extends StatelessWidget {
  final Widget child;
  final String? title;
  final ScrollController scrollController;

  const _TrackFlowFormSheetContent({
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
        gradient: LinearGradient(
          colors: [AppColors.grey800, AppColors.grey900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
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
