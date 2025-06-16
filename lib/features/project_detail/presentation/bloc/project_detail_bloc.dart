import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/manage_collaborators/presentation/models/manage_colaborators_params.dart';
import 'package:trackflow/features/project_detail/domain/usecases/load_user_profile_collaborators_usecase.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_event.dart';
import 'package:trackflow/features/project_detail/presentation/bloc/project_detail_state.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/features/project_detail/domain/usecases/leave_project_usecase.dart';

@injectable
class ProjectDetailBloc extends Bloc<ProjectDetailsEvent, ProjectDetailsState> {
  final LoadUserProfileCollaboratorsUseCase getProjectWithUserProfilesUseCase;
  final LeaveProjectUseCase leaveProjectUseCase;

  ProjectDetailBloc({
    required this.getProjectWithUserProfilesUseCase,
    required this.leaveProjectUseCase,
  }) : super(ProjectDetailsInitial()) {
    on<LoadUserProfiles>(_onGetProjectWithUserProfiles);
    on<LeaveProject>(_onLeaveProject);
  }

  Future<void> _onGetProjectWithUserProfiles(
    LoadUserProfiles event,
    Emitter<ProjectDetailsState> emit,
  ) async {
    final result = await getProjectWithUserProfilesUseCase.call(
      ProjectWithCollaborators(project: event.project),
    );
    await result.fold(
      (failure) async =>
          emit(ProjectDetailsError(_mapFailureToMessage(failure))),
      (projectWithUserProfiles) async => emit(
        ProjectDetailsLoaded(
          params: ManageCollaboratorsParams(
            projectId: event.project.id,
            collaborators: projectWithUserProfiles,
          ),
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
