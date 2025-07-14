import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/components/modals/app_form_sheet.dart';

// Compatibility wrapper - delegates to the design system component
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
