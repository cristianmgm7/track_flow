import 'package:flutter/material.dart';
import 'package:trackflow/core/theme/app_dimensions.dart';
import 'package:trackflow/core/theme/app_gradients.dart';
import 'app_bar.dart';
import 'bottom_nav.dart';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.glassmorphismBackground,
      ),
      child: Stack(
        children: [
          // Subtle texture overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.bottomLeft,
                  radius: 1.2,
                  colors: [
                    Colors.blue.withValues(alpha: 0.01),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main scaffold
          Scaffold(
            appBar: appBar,
            body: _buildBody(),
            bottomNavigationBar: bottomNavigationBar,
            drawer: drawer,
            endDrawer: endDrawer,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            extendBody: extendBody,
            extendBodyBehindAppBar: extendBodyBehindAppBar,
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          ),
        ],
      ),
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
