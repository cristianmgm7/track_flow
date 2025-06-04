import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/entities/user_role.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/usecases/load_project_details_usecase.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:trackflow/features/manage_collaborators/domain/usecases/update_colaborator_role_usecase.dart';
import 'package:trackflow/features/project_detail/domain/repositories/project_detail_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/projects/domain/entities/project.dart';

class ProjectDetailBloc extends Bloc<ProjectDetailsEvent, ProjectDetailsState> {
  final LoadProjectDetail loadProjectDetails;

  ProjectDetailBloc({
    required this.updateCollaboratorRoleUseCase,
    required this.loadProjectDetails,
  }) : super(ProjectDetailsInitial()) {
    on<LoadProjectDetails>(_onLoadProjectDetails);
    on<LeaveProject>(_onLeaveProject);
  }

  Future<void> _onLoadProjectDetails(
    LoadProjectDetails event,
    Emitter<ProjectDetailsState> emit,
  ) async {
    emit(ProjectDetailsLoading());
    final Either<Failure, Project> failureOrProject = await loadProjectDetails
        .call(event.projectId);

    failureOrProject.fold(
      (failure) => emit(ProjectDetailsError(_mapFailureToMessage(failure))),
      (project) => emit(
        ProjectDetailsLoaded(
          project: project,
          currentUserRole: UserRole.member, // Example role, adjust as needed
          participants: [], // Example participants, adjust as needed
        ),
      ),
    );
  }

  Future<void> _onLeaveProject(
    LeaveProject event,
    Emitter<ProjectDetailsState> emit,
  ) async {
    emit(ProjectDetailsLoading());
    final Either<Failure, void> failureOrSuccess = await projectRepository
        .removeParticipant(
          event.projectId,
          UserId.fromUniqueString('currentUserId'),
        );

    failureOrSuccess.fold(
      (failure) => emit(ProjectDetailsError(_mapFailureToMessage(failure))),
      (_) => emit(ProjectLeaveSuccess()),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    // Map different types of failures to user-friendly messages
    return failure.toString();
  }
}
