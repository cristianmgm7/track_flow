import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

// Enum para los posibles contextos del FAB
enum FabContext {
  none,
  projects,
  projectDetailTracks,
  projectDetailComments,
  projectDetailTeam,
}

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

@injectable
class FabContextCubit extends Cubit<FabContextState> {
  FabContextCubit()
    : super(
        FabContextState(
          context: FabContext.none,
          icon: Icons.add,
          visible: false,
        ),
      );

  void setProjects(VoidCallback? onPressed) {
    emit(
      FabContextState(
        context: FabContext.projects,
        icon: Icons.add,
        onPressed: onPressed,
        visible: true,
        tooltip: 'Crear proyecto',
      ),
    );
  }

  void setProjectDetailTracks(VoidCallback? onPressed) {
    emit(
      FabContextState(
        context: FabContext.projectDetailTracks,
        icon: Icons.music_note_outlined,
        onPressed: onPressed,
        visible: true,
        tooltip: 'Agregar track',
      ),
    );
  }

  void setProjectDetailComments(VoidCallback? onPressed) {
    emit(
      FabContextState(
        context: FabContext.projectDetailComments,
        icon: Icons.comment_outlined,
        onPressed: onPressed,
        visible: true,
        tooltip: 'Agregar comentario',
      ),
    );
  }

  void setProjectDetailTeam(VoidCallback? onPressed) {
    emit(
      FabContextState(
        context: FabContext.projectDetailTeam,
        icon: Icons.person_add_outlined,
        onPressed: onPressed,
        visible: true,
        tooltip: 'Agregar colaborador',
      ),
    );
  }

  void hide() {
    emit(state.copyWith(visible: false));
  }
}
