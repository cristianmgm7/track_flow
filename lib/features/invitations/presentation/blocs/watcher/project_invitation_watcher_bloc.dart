import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/session/current_user_service.dart';
import 'package:trackflow/features/invitations/domain/entities/project_invitation.dart';
import 'package:trackflow/features/invitations/domain/repositories/invitation_repository.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';

@injectable
class ProjectInvitationWatcherBloc
    extends Bloc<InvitationWatcherEvent, InvitationWatcherState> {
  final InvitationRepository _invitationRepository;
  final CurrentUserService _currentUserService;

  ProjectInvitationWatcherBloc({
    required InvitationRepository invitationRepository,
    required CurrentUserService currentUserService,
  }) : _invitationRepository = invitationRepository,
       _currentUserService = currentUserService,
       super(InvitationWatcherInitial()) {
    on<WatchPendingInvitations>(_onWatchPendingInvitations);
    on<WatchSentInvitations>(_onWatchSentInvitations);
    on<WatchInvitationCount>(_onWatchInvitationCount);
    on<StopWatchingInvitations>(_onStopWatchingInvitations);
  }

  /// Watch pending invitations for a user
  Future<void> _onWatchPendingInvitations(
    WatchPendingInvitations event,
    Emitter<InvitationWatcherState> emit,
  ) async {
    emit(InvitationWatcherLoading());

    try {
      final currentUserId = await _currentUserService.getCurrentUserIdOrThrow();

      await emit.onEach<Either<Failure, List<ProjectInvitation>>>(
        _invitationRepository.watchPendingInvitations(currentUserId),
        onData: (result) {
          result.fold(
            (failure) => emit(InvitationWatcherError(failure.message)),
            (invitations) => emit(PendingInvitationsWatcherState(invitations)),
          );
        },
        onError: (error, stackTrace) {
          emit(InvitationWatcherError(error.toString()));
        },
      );
    } catch (e) {
      emit(InvitationWatcherError(e.toString()));
    }
  }

  /// Watch sent invitations by a user
  Future<void> _onWatchSentInvitations(
    WatchSentInvitations event,
    Emitter<InvitationWatcherState> emit,
  ) async {
    emit(InvitationWatcherLoading());

    try {
      final currentUserId = await _currentUserService.getCurrentUserIdOrThrow();

      await emit.onEach<Either<Failure, List<ProjectInvitation>>>(
        _invitationRepository.watchSentInvitations(currentUserId),
        onData: (result) {
          result.fold(
            (failure) => emit(InvitationWatcherError(failure.message)),
            (invitations) => emit(SentInvitationsWatcherState(invitations)),
          );
        },
        onError: (error, stackTrace) {
          emit(InvitationWatcherError(error.toString()));
        },
      );
    } catch (e) {
      emit(InvitationWatcherError(e.toString()));
    }
  }

  /// Watch invitation count for a user
  Future<void> _onWatchInvitationCount(
    WatchInvitationCount event,
    Emitter<InvitationWatcherState> emit,
  ) async {
    emit(InvitationWatcherLoading());

    try {
      final currentUserId = await _currentUserService.getCurrentUserIdOrThrow();

      await emit.onEach<Either<Failure, List<ProjectInvitation>>>(
        _invitationRepository.watchPendingInvitations(currentUserId),
        onData: (result) {
          result.fold(
            (failure) => emit(InvitationWatcherError(failure.message)),
            (invitations) =>
                emit(InvitationCountWatcherState(invitations.length)),
          );
        },
        onError: (error, stackTrace) {
          emit(InvitationWatcherError(error.toString()));
        },
      );
    } catch (e) {
      emit(InvitationWatcherError(e.toString()));
    }
  }

  /// Stop watching invitations
  Future<void> _onStopWatchingInvitations(
    StopWatchingInvitations event,
    Emitter<InvitationWatcherState> emit,
  ) async {
    emit(InvitationWatcherInitial());
  }

  @override
  Future<void> close() {
    // Clean up any subscriptions if needed
    return super.close();
  }
}
