import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'app_bar.dart';
import 'bottom_nav.dart';
import 'package:trackflow/core/sync/presentation/widgets/global_sync_indicator.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppAppBar? appBar;
  final AppBottomNavigation? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final Widget? persistentFooterWidget;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.persistentFooterWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          _buildBody(),
          // App-wide minimal sync indicator pinned at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 0,
            right: 0,
            child: const GlobalSyncIndicator(),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor ?? AppColors.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildBody() {
    if (persistentFooterWidget != null) {
      return Column(children: [Expanded(child: body), persistentFooterWidget!]);
    }
    return body;
  }
}

class AppScaffoldMessenger extends StatelessWidget {
  final Widget child;

  const AppScaffoldMessenger({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(child: child);
  }
}

class AppSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimum;

  const AppSafeArea({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum ?? EdgeInsets.all(Dimensions.space0),
      child: child,
    );
  }
}

class AppPadding extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const AppPadding({
    super.key,
    required this.child,
    this.padding,
    this.all,
    this.horizontal,
    this.vertical,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry finalPadding;

    if (padding != null) {
      finalPadding = padding!;
    } else if (all != null) {
      finalPadding = EdgeInsets.all(all!);
    } else {
      finalPadding = EdgeInsets.only(
        top: top ?? vertical ?? 0,
        bottom: bottom ?? vertical ?? 0,
        left: left ?? horizontal ?? 0,
        right: right ?? horizontal ?? 0,
      );
    }

    return Padding(padding: finalPadding, child: child);
  }
}

class AppContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;

  const AppContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}
