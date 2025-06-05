import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/project_detail/domain/usecases/load_user_profile_collaborators_usecase.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/project_detail/domain/usecases/leave_project_usecase.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailsEvent, ProjectDetailsState> {
  final LoadUserProfileCollaboratorsUseCase loadProjectDetails;
  final LeaveProjectUseCase leaveProjectUseCase;

  ProjectDetailBloc({
    required this.loadProjectDetails,
    required this.leaveProjectUseCase,
  }) : super(ProjectDetailsInitial()) {
    on<LoadProjectDetails>(_onLoadProjectDetails);
    on<LeaveProject>(_onLeaveProject);
  }

  Future<void> _onLoadProjectDetails(
    LoadProjectDetails event,
    Emitter<ProjectDetailsState> emit,
  ) async {
    emit(ProjectDetailsLoading());
    final Either<Failure, List<UserProfile>> failureOrProject =
        await loadProjectDetails.call(
          ProjectWithCollaborators(project: event.project),
        );

    failureOrProject.fold(
      (failure) => emit(ProjectDetailsError(_mapFailureToMessage(failure))),
      (project) => emit(
        ProjectDetailsLoaded(
          collaborators: project,
          roles: event.project.roles,
          members: event.project.members,
        ),
      ),
    );
  }

  Future<void> _onLeaveProject(
    LeaveProject event,
    Emitter<ProjectDetailsState> emit,
  ) async {
    emit(ProjectDetailsLoading());
    final Either<Failure, void> failureOrSuccess = await leaveProjectUseCase
        .call(
          LeaveProjectParams(
            projectId: event.projectId,
            userId: UserId.fromUniqueString('currentUserId'),
          ),
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
