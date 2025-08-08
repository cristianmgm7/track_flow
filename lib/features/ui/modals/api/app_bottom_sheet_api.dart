import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  bool useRootNavigator = true,
  List<BlocBase>? reprovideBlocs,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      if (isScrollControlled) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            final Widget effectiveChild =
                scrollableChildBuilder != null
                    ? scrollableChildBuilder(scrollController)
                    : SingleChildScrollView(
                      controller: scrollController,
                      child: child,
                    );
            Widget sheet = AppBottomSheet(
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
            if (reprovideBlocs != null && reprovideBlocs.isNotEmpty) {
              sheet = MultiBlocProvider(
                providers:
                    reprovideBlocs
                        .map((b) => BlocProvider.value(value: b))
                        .toList(),
                child: sheet,
              );
            }
            return sheet;
          },
        );
      }

      Widget sheet = AppBottomSheet(
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
      if (reprovideBlocs != null && reprovideBlocs.isNotEmpty) {
        sheet = MultiBlocProvider(
          providers:
              reprovideBlocs.map((b) => BlocProvider.value(value: b)).toList(),
          child: sheet,
        );
      }
      return sheet;
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
  bool useRootNavigator = true,
  List<BlocBase>? reprovideBlocs,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    builder: (context) {
      Widget sheet = Padding(
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
      if (reprovideBlocs != null && reprovideBlocs.isNotEmpty) {
        sheet = MultiBlocProvider(
          providers:
              reprovideBlocs.map((b) => BlocProvider.value(value: b)).toList(),
          child: sheet,
        );
      }
      return sheet;
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
  bool useRootNavigator = true,
  List<BlocBase>? reprovideBlocs,
}) {
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
      useRootNavigator: useRootNavigator,
      reprovideBlocs: reprovideBlocs,
      child: body,
    );
  }

  // Default: use draggable sheet with computed initial size (stable for lists)
  final itemCount = actions.length;
  final calculatedInitialSize =
      initialChildSize ??
      (itemCount <= 3
          ? 0.3
          : itemCount <= 6
          ? 0.5
          : 0.65);

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
    useRootNavigator: useRootNavigator,
    reprovideBlocs: reprovideBlocs,
    scrollableChildBuilder:
        (scrollController) => AppBottomSheetList(
          actions: actions,
          scrollController: scrollController,
        ),
    child: const SizedBox.shrink(),
  );
}
