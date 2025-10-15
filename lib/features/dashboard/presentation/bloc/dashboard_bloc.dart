import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/dashboard/domain/usecases/watch_dashboard_bundle_usecase.dart';
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:trackflow/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:trackflow/features/dashboard/domain/entities/dashboard_bundle.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final WatchDashboardBundleUseCase _watchDashboardBundleUseCase;

  DashboardBloc({
    required WatchDashboardBundleUseCase watchDashboardBundleUseCase,
  })  : _watchDashboardBundleUseCase = watchDashboardBundleUseCase,
        super(const DashboardInitial()) {
    on<WatchDashboard>(_onWatchDashboard);
    on<StopWatchingDashboard>(_onStopWatchingDashboard);
  }

  Future<void> _onWatchDashboard(
    WatchDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final stream = _watchDashboardBundleUseCase.call();

    await emit.onEach<Either<Failure, DashboardBundle>>(
      stream,
      onData: (either) {
        either.fold(
          (failure) => emit(DashboardError(_mapFailureToMessage(failure))),
          (bundle) {
            emit(
              DashboardLoaded(
                projectPreview: bundle.projectPreview,
                trackPreview: bundle.trackPreview,
                recentComments: bundle.recentComments,
                isLoading: false,
                failureOption: none(), // No failure
              ),
            );
          },
        );
      },
      onError: (error, stackTrace) {
        emit(DashboardError('An unexpected error occurred: $error'));
      },
    );
  }

  Future<void> _onStopWatchingDashboard(
    StopWatchingDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    // emit.onEach handles cleanup automatically, but we emit initial state
    emit(const DashboardInitial());
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is PermissionFailure) {
      return "You don't have permission to view the dashboard.";
    } else if (failure is DatabaseFailure) {
      return "A database error occurred. Please try again.";
    } else if (failure is AuthenticationFailure) {
      return "Authentication error. Please log in again.";
    } else if (failure is ServerFailure) {
      return "A server error occurred. Please try again later.";
    } else if (failure is UnexpectedFailure) {
      return "An unexpected error occurred. Please try again later.";
    }
    return "An unknown error occurred.";
  }
}


