import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/navegation/fab_cubit.dart/fab_cubit_state.dart';

// Enum para los posibles contextos del FAB
enum FabContext {
  none,
  projects,
  projectDetailTracks,
  projectDetailComments,
  projectDetailTeam,
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
