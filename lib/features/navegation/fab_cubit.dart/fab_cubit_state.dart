import 'package:flutter/material.dart';
import 'package:trackflow/features/navegation/fab_cubit.dart/fab_cubit.dart';

class FabContextState {
  final FabContext context;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool visible;
  final String? tooltip;

  FabContextState({
    required this.context,
    required this.icon,
    this.onPressed,
    this.visible = true,
    this.tooltip,
  });

  FabContextState copyWith({
    FabContext? context,
    IconData? icon,
    VoidCallback? onPressed,
    bool? visible,
    String? tooltip,
  }) {
    return FabContextState(
      context: context ?? this.context,
      icon: icon ?? this.icon,
      onPressed: onPressed ?? this.onPressed,
      visible: visible ?? this.visible,
      tooltip: tooltip ?? this.tooltip,
    );
  }
}
