import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/invitations/domain/usecases/accept_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/cancel_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/decline_invitation_usecase.dart';
import 'package:trackflow/features/invitations/domain/usecases/send_invitation_usecase.dart';
import 'package:trackflow/features/invitations/presentation/blocs/events/invitation_events.dart';
import 'package:trackflow/features/invitations/presentation/blocs/states/invitation_states.dart';

@injectable
class ProjectInvitationActorBloc
    extends Bloc<InvitationActorEvent, InvitationActorState> {
  final SendInvitationUseCase _sendInvitationUseCase;
  final AcceptInvitationUseCase _acceptInvitationUseCase;
  final DeclineInvitationUseCase _declineInvitationUseCase;
  final CancelInvitationUseCase _cancelInvitationUseCase;

  ProjectInvitationActorBloc({
    required SendInvitationUseCase sendInvitationUseCase,
    required AcceptInvitationUseCase acceptInvitationUseCase,
    required DeclineInvitationUseCase declineInvitationUseCase,
    required CancelInvitationUseCase cancelInvitationUseCase,
  }) : _sendInvitationUseCase = sendInvitationUseCase,
       _acceptInvitationUseCase = acceptInvitationUseCase,
       _declineInvitationUseCase = declineInvitationUseCase,
       _cancelInvitationUseCase = cancelInvitationUseCase,
       super(const InvitationActorInitial()) {
    on<SendInvitation>(_onSendInvitation);
    on<AcceptInvitation>(_onAcceptInvitation);
    on<DeclineInvitation>(_onDeclineInvitation);
    on<CancelInvitation>(_onCancelInvitation);
    on<ResetInvitationActorState>(_onResetInvitationActorState);
  }

  /// Send an invitation
  Future<void> _onSendInvitation(
    SendInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(const InvitationActorLoading());

    final result = await _sendInvitationUseCase(event.params);

    result.fold(
      (failure) => emit(InvitationActorError(failure.message)),
      (invitation) => emit(
        SendInvitationSuccess(
          message: 'Invitation sent successfully',
          invitation: invitation,
        ),
      ),
    );
  }

  /// Accept an invitation
  Future<void> _onAcceptInvitation(
    AcceptInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(const InvitationActorLoading());

    final result = await _acceptInvitationUseCase(event.invitationId);

    result.fold(
      (failure) => emit(InvitationActorError(failure.message)),
      (invitation) => emit(
        AcceptInvitationSuccess(
          message: 'Invitation accepted successfully',
          invitation: invitation,
        ),
      ),
    );
  }

  /// Decline an invitation
  Future<void> _onDeclineInvitation(
    DeclineInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(const InvitationActorLoading());

    final result = await _declineInvitationUseCase(event.invitationId);

    result.fold(
      (failure) => emit(InvitationActorError(failure.message)),
      (invitation) => emit(
        DeclineInvitationSuccess(
          message: 'Invitation declined successfully',
          invitation: invitation,
        ),
      ),
    );
  }

  /// Cancel an invitation
  Future<void> _onCancelInvitation(
    CancelInvitation event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(const InvitationActorLoading());

    final result = await _cancelInvitationUseCase(event.invitationId);

    result.fold(
      (failure) => emit(InvitationActorError(failure.message)),
      (_) => emit(
        const CancelInvitationSuccess(
          message: 'Invitation cancelled successfully',
        ),
      ),
    );
  }

  /// Reset actor state
  Future<void> _onResetInvitationActorState(
    ResetInvitationActorState event,
    Emitter<InvitationActorState> emit,
  ) async {
    emit(const InvitationActorInitial());
  }
}
