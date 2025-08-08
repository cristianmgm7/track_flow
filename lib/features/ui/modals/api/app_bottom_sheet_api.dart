import 'package:flutter/material.dart';
import 'package:trackflow/features/ui/modals/base/app_bottom_sheet_base.dart';
import 'package:trackflow/features/ui/modals/actions/app_bottom_sheet_actions.dart';

// Convenience function to show bottom sheet
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  Widget Function(ScrollController scrollController)? scrollableChildBuilder,
  String? title,
  Widget? header,
  List<Widget>? actions,
  bool showHandle = true,
  bool showCloseButton = false,
  bool isScrollControlled = true,
  double initialChildSize = 0.6,
  double minChildSize = 0.3,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
  VoidCallback? onClose,
  EdgeInsetsGeometry? padding,
  Color? backgroundColor,
  BorderRadius? borderRadius,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: false,
    builder: (context) {
      if (isScrollControlled) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            final Widget effectiveChild = scrollableChildBuilder != null
                ? scrollableChildBuilder(scrollController)
                : SingleChildScrollView(
                    controller: scrollController,
                    child: child,
                  );
            return AppBottomSheet(
              title: title,
              header: header,
              actions: actions,
              showHandle: showHandle,
              showCloseButton: showCloseButton,
              onClose: onClose,
              padding: padding,
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
              child: effectiveChild,
            );
          },
        );
      }

      return AppBottomSheet(
        title: title,
        header: header,
        actions: actions,
        showHandle: showHandle,
        showCloseButton: showCloseButton,
        onClose: onClose,
        padding: padding,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        child: child,
      );
    },
  );
}

// Convenience function to show content-based modal that sizes to content
Future<T?> showAppContentModal<T>({
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
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: false,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
          ),
          child: IntrinsicHeight(
            child: AppBottomSheet(
              title: title,
              header: header,
              actions: actions,
              showHandle: showHandle,
              showCloseButton: showCloseButton,
              onClose: onClose,
              padding: padding,
              backgroundColor: backgroundColor,
              borderRadius: borderRadius,
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

// Convenience function to show action sheet
Future<T?> showAppActionSheet<T>({
  required BuildContext context,
  required List<AppBottomSheetAction> actions,
  String? title,
  Widget? header,
  Widget? body,
  bool showHandle = true,
  bool showCloseButton = false,
  bool isScrollControlled = true,
  double? initialChildSize,
  double minChildSize = 0.3,
  double maxChildSize = 0.9,
  bool isDismissible = true,
  bool enableDrag = true,
  VoidCallback? onClose,
}) {
  final itemCount = actions.length;
  final calculatedInitialSize = initialChildSize ??
      (itemCount <= 3 ? 0.3 : itemCount <= 6 ? 0.5 : 0.65);

  if (body != null) {
    return showAppContentModal<T>(
      context: context,
      title: title,
      header: header,
      showHandle: showHandle,
      showCloseButton: showCloseButton,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      onClose: onClose,
      child: body,
    );
  }

  return showAppBottomSheet<T>(
    context: context,
    title: title,
    header: header,
    showHandle: showHandle,
    showCloseButton: showCloseButton,
    isScrollControlled: isScrollControlled,
    initialChildSize: calculatedInitialSize,
    minChildSize: minChildSize,
    maxChildSize: maxChildSize,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    onClose: onClose,
    scrollableChildBuilder: (scrollController) => AppBottomSheetList(
      actions: actions,
      scrollController: scrollController,
    ),
    child: const SizedBox.shrink(),
  );
}


